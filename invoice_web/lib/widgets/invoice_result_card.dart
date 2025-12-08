import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/invoice_data.dart';

class InvoiceResultCard extends StatelessWidget {
  final ProcessingResult result;

  const InvoiceResultCard({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: Icon(
          result.success ? Icons.check_circle : Icons.error,
          color: result.success ? Colors.green : Colors.red,
          size: 32,
        ),
        title: Text(
          result.filename,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          result.success
              ? 'Processed in ${result.processingTime.toStringAsFixed(2)}s'
              : 'Failed: ${result.error}',
          style: TextStyle(
            color: result.success ? Colors.green : Colors.red,
          ),
        ),
        children: [
          if (result.success && result.invoiceData != null)
            _buildInvoiceDetails(result.invoiceData!),
        ],
      ),
    );
  }

  Widget _buildInvoiceDetails(InvoiceData invoice) {
    final currencyFormat = NumberFormat.currency(
      symbol: invoice.currency ?? '\$',
      decimalDigits: 2,
    );

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Metadata
          _buildInfoSection('Invoice Information', [
            if (invoice.invoiceNumber != null)
              _buildInfoRow('Number', invoice.invoiceNumber!),
            if (invoice.invoiceDate != null)
              _buildInfoRow('Date', invoice.invoiceDate!),
            if (invoice.vendorName != null)
              _buildInfoRow('Vendor', invoice.vendorName!),
            if (invoice.customerName != null)
              _buildInfoRow('Customer', invoice.customerName!),
          ]),

          // Items
          if (invoice.items.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              'Items (${invoice.items.length})',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildItemsTable(invoice.items, currencyFormat),
          ],

          // Totals
          if (invoice.subtotal != null ||
              invoice.tax != null ||
              invoice.totalAmount != null) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            _buildTotalsSection(invoice, currencyFormat),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    if (children.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildItemsTable(List<InvoiceItem> items, NumberFormat formatter) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 24,
        headingRowHeight: 40,
        dataRowMinHeight: 36,
        dataRowMaxHeight: 56,
        columns: const [
          DataColumn(label: Text('#')),
          DataColumn(label: Text('Description')),
          DataColumn(label: Text('Qty')),
          DataColumn(label: Text('Unit')),
          DataColumn(label: Text('Price')),
          DataColumn(label: Text('Total')),
        ],
        rows: items.map((item) {
          return DataRow(
            cells: [
              DataCell(Text(item.itemNumber?.toString() ?? '-')),
              DataCell(
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 300),
                  child: Text(
                    item.description,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ),
              DataCell(Text(item.quantity?.toString() ?? '-')),
              DataCell(Text(item.unit ?? '-')),
              DataCell(Text(
                item.unitPrice != null
                    ? formatter.format(item.unitPrice)
                    : '-',
              )),
              DataCell(Text(
                item.total != null ? formatter.format(item.total) : '-',
              )),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTotalsSection(InvoiceData invoice, NumberFormat formatter) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          if (invoice.subtotal != null)
            _buildTotalRow('Subtotal', formatter.format(invoice.subtotal)),
          if (invoice.tax != null)
            _buildTotalRow('Tax', formatter.format(invoice.tax)),
          if (invoice.totalAmount != null) ...[
            const Divider(),
            _buildTotalRow(
              'Total Amount',
              formatter.format(invoice.totalAmount),
              isBold: true,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 16 : 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 18 : 14,
            ),
          ),
        ],
      ),
    );
  }
}







