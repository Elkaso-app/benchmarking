"""FastAPI REST API for invoice processing."""
from fastapi import FastAPI, File, UploadFile, HTTPException, BackgroundTasks
from fastapi.responses import FileResponse, JSONResponse
from fastapi.middleware.cors import CORSMiddleware
from pathlib import Path
from typing import List, Optional
import tempfile
import shutil
import uuid
from datetime import datetime

from invoice_processor import InvoiceProcessor
from benchmark import InvoiceBenchmark
from csv_exporter import CSVExporter
from models import ProcessingResult, BenchmarkResult
from config import settings

app = FastAPI(
    title="Invoice Processing Benchmarking API",
    description="API for processing invoices and extracting structured data",
    version="1.0.0"
)

# CORS middleware for Flutter web frontend
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:3000",
        "http://localhost:8080", 
        "http://127.0.0.1:3000",
        "http://127.0.0.1:8080",
        "*"  # Allow all for development
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
    expose_headers=["*"],
)

# Global processor instance
processor = InvoiceProcessor()


@app.get("/")
async def root():
    """Root endpoint."""
    return {
        "message": "Invoice Processing Benchmarking API",
        "version": "1.0.0",
        "model": processor.model,
        "endpoints": {
            "process_single": "/api/process",
            "process_batch": "/api/process/batch",
            "run_benchmark": "/api/benchmark",
            "download_csv": "/api/download/{file_type}/{filename}",
            "health": "/health"
        }
    }


@app.get("/health")
async def health_check():
    """Health check endpoint."""
    return {
        "status": "healthy",
        "model": processor.model,
        "timestamp": datetime.now().isoformat()
    }


@app.post("/api/process", response_model=ProcessingResult)
async def process_single_invoice(file: UploadFile = File(...)):
    """Process a single invoice file.
    
    Args:
        file: Invoice PDF file to process
        
    Returns:
        Processing result with extracted data
    """
    # Validate file type
    if not file.filename.lower().endswith('.pdf'):
        raise HTTPException(status_code=400, detail="Only PDF files are supported")
    
    # Create temporary file
    with tempfile.NamedTemporaryFile(delete=False, suffix='.pdf') as tmp_file:
        tmp_path = Path(tmp_file.name)
        
        # Save uploaded file
        content = await file.read()
        tmp_file.write(content)
    
    try:
        # Process invoice
        result = processor.process_invoice(tmp_path)
        return result
    
    finally:
        # Clean up temporary file
        tmp_path.unlink(missing_ok=True)


@app.post("/api/process/batch")
async def process_batch_invoices(files: List[UploadFile] = File(...)):
    """Process multiple invoice files.
    
    Args:
        files: List of invoice PDF files to process
        
    Returns:
        List of processing results and CSV download links
    """
    if len(files) == 0:
        raise HTTPException(status_code=400, detail="No files provided")
    
    results: List[ProcessingResult] = []
    temp_files: List[Path] = []
    
    try:
        # Process each file
        for file in files:
            if not file.filename.lower().endswith('.pdf'):
                continue
            
            # Create temporary file
            with tempfile.NamedTemporaryFile(delete=False, suffix='.pdf') as tmp_file:
                tmp_path = Path(tmp_file.name)
                temp_files.append(tmp_path)
                
                # Save uploaded file
                content = await file.read()
                tmp_file.write(content)
            
            # Process invoice
            result = processor.process_invoice(tmp_path)
            results.append(result)
        
        # Export to CSV
        output_path = Path(settings.output_dir)
        csv_files = CSVExporter.export_all(results, output_path)
        
        # Calculate statistics
        successful = sum(1 for r in results if r.success)
        total_time = sum(r.processing_time for r in results)
        
        return {
            "total_files": len(results),
            "successful": successful,
            "failed": len(results) - successful,
            "total_time": total_time,
            "results": [r.model_dump() for r in results],
            "downloads": {
                "items_csv": f"/api/download/items/{Path(csv_files['items_csv']).name}",
                "summary_csv": f"/api/download/summary/{Path(csv_files['summary_csv']).name}"
            }
        }
    
    finally:
        # Clean up temporary files
        for tmp_path in temp_files:
            tmp_path.unlink(missing_ok=True)


@app.post("/api/benchmark")
async def run_benchmark(limit: Optional[int] = None):
    """Run benchmark on all invoices in the invoices directory.
    
    Args:
        limit: Optional limit on number of files to process
        
    Returns:
        Benchmark results with download links
    """
    benchmark = InvoiceBenchmark()
    
    try:
        results = benchmark.run_and_export(limit=limit)
        
        # Add download links
        files = results['files']
        results['downloads'] = {
            "items_csv": f"/api/download/items/{Path(files['items_csv']).name}",
            "summary_csv": f"/api/download/summary/{Path(files['summary_csv']).name}",
            "json": f"/api/download/json/{Path(files['json_results']).name}"
        }
        
        return results
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/api/download/{file_type}/{filename}")
async def download_file(file_type: str, filename: str):
    """Download generated CSV or JSON files.
    
    Args:
        file_type: Type of file (items, summary, json)
        filename: Name of the file to download
        
    Returns:
        File download response
    """
    output_path = Path(settings.output_dir)
    file_path = output_path / filename
    
    if not file_path.exists():
        raise HTTPException(status_code=404, detail="File not found")
    
    # Determine media type
    if filename.endswith('.csv'):
        media_type = "text/csv"
    elif filename.endswith('.json'):
        media_type = "application/json"
    else:
        media_type = "application/octet-stream"
    
    return FileResponse(
        path=file_path,
        filename=filename,
        media_type=media_type
    )


@app.get("/api/invoices/list")
async def list_invoices():
    """List all invoice files in the invoices directory.
    
    Returns:
        List of invoice filenames
    """
    invoices_path = Path(settings.invoices_dir)
    
    if not invoices_path.exists():
        return {"files": [], "count": 0}
    
    pdf_files = sorted([f.name for f in invoices_path.glob("*.pdf")])
    
    return {
        "files": pdf_files,
        "count": len(pdf_files),
        "directory": str(invoices_path)
    }


@app.get("/api/outputs/list")
async def list_outputs():
    """List all generated output files.
    
    Returns:
        List of output files grouped by type
    """
    output_path = Path(settings.output_dir)
    
    if not output_path.exists():
        return {"csv_files": [], "json_files": []}
    
    csv_files = sorted([f.name for f in output_path.glob("*.csv")], reverse=True)
    json_files = sorted([f.name for f in output_path.glob("*.json")], reverse=True)
    
    return {
        "csv_files": csv_files,
        "json_files": json_files,
        "directory": str(output_path)
    }


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "api:app",
        host=settings.api_host,
        port=settings.api_port,
        reload=True
    )

