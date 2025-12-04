"""Benchmarking utilities for invoice processing."""
import time
from pathlib import Path
from typing import List, Optional
import json

from invoice_processor import InvoiceProcessor
from csv_exporter import CSVExporter
from models import BenchmarkResult, ProcessingResult
from config import settings


class InvoiceBenchmark:
    """Benchmarking tool for invoice processing."""
    
    def __init__(self):
        """Initialize the benchmark."""
        self.processor = InvoiceProcessor()
        self.output_path = Path(settings.output_dir)
        self.output_path.mkdir(exist_ok=True)
    
    def run_benchmark(
        self, 
        invoices_dir: Optional[Path] = None,
        limit: Optional[int] = None
    ) -> BenchmarkResult:
        """Run benchmark on all invoices in directory.
        
        Args:
            invoices_dir: Directory containing invoice PDFs
            limit: Optional limit on number of files to process
            
        Returns:
            Benchmark results
        """
        if invoices_dir is None:
            invoices_dir = Path(settings.invoices_dir)
        
        # Get all PDF files
        pdf_files = sorted(list(invoices_dir.glob("*.pdf")))
        
        if limit:
            pdf_files = pdf_files[:limit]
        
        print(f"Found {len(pdf_files)} PDF files to process")
        print(f"Using OpenAI model: {self.processor.model}")
        print("-" * 80)
        
        results: List[ProcessingResult] = []
        start_time = time.time()
        
        for i, pdf_file in enumerate(pdf_files, 1):
            print(f"Processing {i}/{len(pdf_files)}: {pdf_file.name}...", end=" ")
            
            result = self.processor.process_invoice(pdf_file)
            results.append(result)
            
            if result.success:
                items_count = len(result.invoice_data.items) if result.invoice_data else 0
                print(f"✓ Success - {items_count} items - {result.processing_time:.2f}s")
            else:
                print(f"✗ Failed - {result.error} - {result.processing_time:.2f}s")
        
        total_time = time.time() - start_time
        
        # Calculate statistics
        successful = sum(1 for r in results if r.success)
        failed = len(results) - successful
        avg_time = total_time / len(results) if results else 0
        
        print("-" * 80)
        print(f"Benchmark Complete!")
        print(f"Total: {len(results)} | Success: {successful} | Failed: {failed}")
        print(f"Total Time: {total_time:.2f}s | Average: {avg_time:.2f}s per file")
        
        # Create benchmark result
        benchmark_result = BenchmarkResult(
            total_files=len(results),
            successful=successful,
            failed=failed,
            total_time=total_time,
            average_time=avg_time,
            results=results
        )
        
        return benchmark_result
    
    def export_results(self, benchmark_result: BenchmarkResult) -> dict:
        """Export benchmark results to CSV and JSON.
        
        Args:
            benchmark_result: Benchmark results to export
            
        Returns:
            Dictionary with paths to exported files
        """
        print("\nExporting results...")
        
        # Export CSVs
        csv_files = CSVExporter.export_all(
            benchmark_result.results,
            self.output_path
        )
        
        # Export JSON with full results
        from datetime import datetime
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        json_file = self.output_path / f"benchmark_results_{timestamp}.json"
        
        with open(json_file, 'w', encoding='utf-8') as f:
            json.dump(benchmark_result.model_dump(), f, indent=2, ensure_ascii=False)
        
        output_files = {
            **csv_files,
            'json_results': str(json_file)
        }
        
        print(f"✓ Items CSV: {csv_files['items_csv']}")
        print(f"✓ Summary CSV: {csv_files['summary_csv']}")
        print(f"✓ JSON Results: {json_file}")
        
        return output_files
    
    def run_and_export(
        self,
        invoices_dir: Optional[Path] = None,
        limit: Optional[int] = None
    ) -> dict:
        """Run benchmark and export results.
        
        Args:
            invoices_dir: Directory containing invoice PDFs
            limit: Optional limit on number of files to process
            
        Returns:
            Dictionary with benchmark results and export file paths
        """
        # Run benchmark
        benchmark_result = self.run_benchmark(invoices_dir, limit)
        
        # Export results
        output_files = self.export_results(benchmark_result)
        
        return {
            'benchmark': benchmark_result.model_dump(),
            'files': output_files
        }


def main():
    """Main entry point for CLI usage."""
    import argparse
    
    parser = argparse.ArgumentParser(description="Invoice Processing Benchmarking Tool")
    parser.add_argument(
        "--invoices-dir",
        type=str,
        default=settings.invoices_dir,
        help="Directory containing invoice PDFs"
    )
    parser.add_argument(
        "--limit",
        type=int,
        default=None,
        help="Limit number of files to process"
    )
    args = parser.parse_args()
    
    # Run benchmark
    benchmark = InvoiceBenchmark()
    results = benchmark.run_and_export(
        invoices_dir=Path(args.invoices_dir),
        limit=args.limit
    )
    
    print("\n" + "=" * 80)
    print("Benchmark completed successfully!")
    print("=" * 80)


if __name__ == "__main__":
    main()

