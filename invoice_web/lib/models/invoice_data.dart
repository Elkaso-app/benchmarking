/// Data models for invoice processing

class InvoiceItem {
  final int? itemNumber;
  final String description;
  final double? quantity;
  final double? unitPrice;
  final double? total;
  final String? unit;

  InvoiceItem({
    this.itemNumber,
    required this.description,
    this.quantity,
    this.unitPrice,
    this.total,
    this.unit,
  });

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      itemNumber: json['item_number'],
      description: json['description'] ?? '',
      quantity: json['quantity']?.toDouble(),
      unitPrice: json['unit_price']?.toDouble(),
      total: json['total']?.toDouble(),
      unit: json['unit'],
    );
  }
}

class InvoiceData {
  final String? invoiceNumber;
  final String? invoiceDate;
  final String? vendorName;
  final String? customerName;
  final String? currency;
  final List<InvoiceItem> items;
  final double? subtotal;
  final double? tax;
  final double? totalAmount;

  InvoiceData({
    this.invoiceNumber,
    this.invoiceDate,
    this.vendorName,
    this.customerName,
    this.currency,
    required this.items,
    this.subtotal,
    this.tax,
    this.totalAmount,
  });

  factory InvoiceData.fromJson(Map<String, dynamic> json) {
    return InvoiceData(
      invoiceNumber: json['invoice_number'],
      invoiceDate: json['invoice_date'],
      vendorName: json['vendor_name'],
      customerName: json['customer_name'],
      currency: json['currency'],
      items: (json['items'] as List?)
              ?.map((item) => InvoiceItem.fromJson(item))
              .toList() ??
          [],
      subtotal: json['subtotal']?.toDouble(),
      tax: json['tax']?.toDouble(),
      totalAmount: json['total_amount']?.toDouble(),
    );
  }
}

class ProcessingResult {
  final String filename;
  final bool success;
  final InvoiceData? invoiceData;
  final String? error;
  final double processingTime;
  final String modelUsed;

  ProcessingResult({
    required this.filename,
    required this.success,
    this.invoiceData,
    this.error,
    required this.processingTime,
    required this.modelUsed,
  });

  factory ProcessingResult.fromJson(Map<String, dynamic> json) {
    return ProcessingResult(
      filename: json['filename'] ?? '',
      success: json['success'] ?? false,
      invoiceData: json['invoice_data'] != null
          ? InvoiceData.fromJson(json['invoice_data'])
          : null,
      error: json['error'],
      processingTime: (json['processing_time'] ?? 0).toDouble(),
      modelUsed: json['model_used'] ?? '',
    );
  }
}

class BenchmarkResult {
  final int totalFiles;
  final int successful;
  final int failed;
  final double totalTime;
  final double averageTime;
  final List<ProcessingResult> results;
  final Map<String, String>? downloads;

  BenchmarkResult({
    required this.totalFiles,
    required this.successful,
    required this.failed,
    required this.totalTime,
    required this.averageTime,
    required this.results,
    this.downloads,
  });

  factory BenchmarkResult.fromJson(Map<String, dynamic> json) {
    return BenchmarkResult(
      totalFiles: json['total_files'] ?? 0,
      successful: json['successful'] ?? 0,
      failed: json['failed'] ?? 0,
      totalTime: (json['total_time'] ?? 0).toDouble(),
      averageTime: (json['average_time'] ?? 0).toDouble(),
      results: (json['results'] as List?)
              ?.map((r) => ProcessingResult.fromJson(r))
              .toList() ??
          [],
      downloads: json['downloads'] != null
          ? Map<String, String>.from(json['downloads'])
          : null,
    );
  }
}



