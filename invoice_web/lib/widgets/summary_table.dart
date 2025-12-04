import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/invoice_data.dart';
import '../models/item_summary.dart';

class SummaryTable extends StatelessWidget {
  final List<ProcessingResult> results;

  const SummaryTable({
    super.key,
    required this.results,
  });

  List<ItemSummary> _aggregateItems() {
    final Map<String, List<InvoiceItem>> groupedItems = {};

    // Group items by description (case-insensitive)
    for (var result in results) {
      if (result.success && result.invoiceData != null) {
        for (var item in result.invoiceData!.items) {
          final key = item.description.trim().toLowerCase();
          groupedItems.putIfAbsent(key, () => []);
          groupedItems[key]!.add(item);
        }
      }
    }

    // Aggregate data for each item
    final List<ItemSummary> summaries = [];
    groupedItems.forEach((key, items) {
      double totalQty = 0;
      double minPrice = double.infinity;
      double maxPrice = double.negativeInfinity;
      String? unit;
      
      for (var item in items) {
        if (item.quantity != null) {
          totalQty += item.quantity!;
        }
        if (item.unitPrice != null) {
          if (item.unitPrice! < minPrice) minPrice = item.unitPrice!;
          if (item.unitPrice! > maxPrice) maxPrice = item.unitPrice!;
        }
        if (unit == null && item.unit != null) {
          unit = item.unit;
        }
      }

      // Use original description (with proper casing) from first item
      final originalDescription = items.first.description;

      summaries.add(ItemSummary(
        description: originalDescription,
        totalQuantity: totalQty,
        unit: unit,
        minPrice: minPrice == double.infinity ? 0 : minPrice,
        maxPrice: maxPrice == double.negativeInfinity ? 0 : maxPrice,
        occurrences: items.length,
      ));
    });

    // Sort by description
    summaries.sort((a, b) => a.description.compareTo(b.description));
    return summaries;
  }

  @override
  Widget build(BuildContext context) {
    final summaries = _aggregateItems();

    if (summaries.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('No items to display'),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.summarize, size: 28),
                const SizedBox(width: 12),
                const Text(
                  'Items Summary',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${summaries.length} unique items',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Grouped by item name with total quantities and price ranges',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 32,
                headingRowColor: MaterialStateProperty.all(
                  Colors.blue.shade50,
                ),
                headingRowHeight: 56,
                dataRowMinHeight: 48,
                columns: const [
                  DataColumn(
                    label: Text(
                      'Item Description',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Total Quantity',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    numeric: true,
                  ),
                  DataColumn(
                    label: Text(
                      'Unit',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Price Range',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    numeric: true,
                  ),
                  DataColumn(
                    label: Text(
                      'Occurrences',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    numeric: true,
                  ),
                ],
                rows: summaries.map((summary) {
                  return DataRow(
                    cells: [
                      DataCell(
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 300),
                          child: Text(
                            summary.description,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          summary.totalQuantity.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          summary.unit ?? '-',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      DataCell(
                        Text(
                          summary.priceRange,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: summary.minPrice == summary.maxPrice
                                ? Colors.black
                                : Colors.blue.shade700,
                          ),
                        ),
                      ),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${summary.occurrences}×',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


