"""CSV export functionality for invoice data."""
import pandas as pd
from pathlib import Path
from typing import List
from datetime import datetime

from models import ProcessingResult, InvoiceItem


class CSVExporter:
    """Exports invoice processing results to CSV format."""
    
    @staticmethod
    def export_items(results: List[ProcessingResult], output_path: Path) -> str:
        """Export all invoice items to a CSV file.
        
        Args:
            results: List of processing results
            output_path: Base path for output files
            
        Returns:
            Path to the generated CSV file
        """
        rows = []
        
        for result in results:
            if result.success and result.invoice_data:
                invoice = result.invoice_data
                
                # If there are items, export them
                if invoice.items:
                    for item in invoice.items:
                        rows.append({
                            'filename': result.filename,
                            'invoice_number': invoice.invoice_number,
                            'invoice_date': invoice.invoice_date,
                            'vendor_name': invoice.vendor_name,
                            'customer_name': invoice.customer_name,
                            'currency': invoice.currency,
                            'item_number': item.item_number,
                            'description': item.description,
                            'quantity': item.quantity,
                            'unit': item.unit,
                            'unit_price': item.unit_price,
                            'item_total': item.total,
                            'invoice_subtotal': invoice.subtotal,
                            'invoice_tax': invoice.tax,
                            'invoice_total': invoice.total_amount,
                            'processing_time': result.processing_time,
                            'model_used': result.model_used
                        })
                else:
                    # No items found, still export invoice metadata
                    rows.append({
                        'filename': result.filename,
                        'invoice_number': invoice.invoice_number,
                        'invoice_date': invoice.invoice_date,
                        'vendor_name': invoice.vendor_name,
                        'customer_name': invoice.customer_name,
                        'currency': invoice.currency,
                        'item_number': None,
                        'description': None,
                        'quantity': None,
                        'unit': None,
                        'unit_price': None,
                        'item_total': None,
                        'invoice_subtotal': invoice.subtotal,
                        'invoice_tax': invoice.tax,
                        'invoice_total': invoice.total_amount,
                        'processing_time': result.processing_time,
                        'model_used': result.model_used
                    })
        
        # Create DataFrame
        df = pd.DataFrame(rows)
        
        # Generate filename with timestamp
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        csv_filename = output_path / f"invoice_items_{timestamp}.csv"
        
        # Export to CSV
        df.to_csv(csv_filename, index=False, encoding='utf-8-sig')
        
        return str(csv_filename)
    
    @staticmethod
    def export_summary(results: List[ProcessingResult], output_path: Path) -> str:
        """Export processing summary to CSV.
        
        Args:
            results: List of processing results
            output_path: Base path for output files
            
        Returns:
            Path to the generated summary CSV file
        """
        rows = []
        
        for result in results:
            row = {
                'filename': result.filename,
                'success': result.success,
                'processing_time': result.processing_time,
                'model_used': result.model_used,
                'error': result.error if result.error else ''
            }
            
            if result.success and result.invoice_data:
                invoice = result.invoice_data
                row.update({
                    'invoice_number': invoice.invoice_number,
                    'invoice_date': invoice.invoice_date,
                    'vendor_name': invoice.vendor_name,
                    'customer_name': invoice.customer_name,
                    'total_items': len(invoice.items),
                    'total_amount': invoice.total_amount,
                    'currency': invoice.currency
                })
            
            rows.append(row)
        
        df = pd.DataFrame(rows)
        
        # Generate filename with timestamp
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        csv_filename = output_path / f"processing_summary_{timestamp}.csv"
        
        # Export to CSV
        df.to_csv(csv_filename, index=False, encoding='utf-8-sig')
        
        return str(csv_filename)
    
    @staticmethod
    def export_all(results: List[ProcessingResult], output_path: Path) -> dict:
        """Export both items and summary.
        
        Args:
            results: List of processing results
            output_path: Base path for output files
            
        Returns:
            Dictionary with paths to generated files
        """
        items_file = CSVExporter.export_items(results, output_path)
        summary_file = CSVExporter.export_summary(results, output_path)
        
        return {
            'items_csv': items_file,
            'summary_csv': summary_file
        }



