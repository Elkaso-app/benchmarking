"""Data models for invoice processing."""
from pydantic import BaseModel, Field
from typing import List, Optional
from datetime import datetime


class InvoiceItem(BaseModel):
    """Represents a single item in an invoice."""
    item_number: Optional[int] = Field(None, description="Item sequence number")
    description: str = Field(..., description="Item description")
    quantity: Optional[float] = Field(None, description="Quantity")
    unit_price: Optional[float] = Field(None, description="Unit price")
    total: Optional[float] = Field(None, description="Total price for this item")
    unit: Optional[str] = Field(None, description="Unit of measurement")


class InvoiceData(BaseModel):
    """Represents extracted invoice data."""
    invoice_number: Optional[str] = Field(None, description="Invoice number")
    invoice_date: Optional[str] = Field(None, description="Invoice date")
    vendor_name: Optional[str] = Field(None, description="Vendor/seller name")
    customer_name: Optional[str] = Field(None, description="Customer/buyer name")
    items: List[InvoiceItem] = Field(default_factory=list, description="List of items")
    subtotal: Optional[float] = Field(None, description="Subtotal amount")
    tax: Optional[float] = Field(None, description="Tax amount")
    total_amount: Optional[float] = Field(None, description="Total amount")
    currency: Optional[str] = Field(None, description="Currency")


class ProcessingResult(BaseModel):
    """Result of processing an invoice."""
    filename: str
    success: bool
    invoice_data: Optional[InvoiceData] = None
    error: Optional[str] = None
    processing_time: float = 0.0
    model_used: str = ""


class BenchmarkResult(BaseModel):
    """Benchmarking results for multiple invoices."""
    total_files: int
    successful: int
    failed: int
    total_time: float
    average_time: float
    results: List[ProcessingResult]
    timestamp: str = Field(default_factory=lambda: datetime.now().isoformat())





