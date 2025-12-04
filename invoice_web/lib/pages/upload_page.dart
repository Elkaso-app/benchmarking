import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';
import '../models/invoice_data.dart';
import '../widgets/invoice_result_card.dart';
import '../widgets/price_comparison_chart.dart';
import '../widgets/contact_supplier_cta.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  List<PlatformFile>? _selectedFiles;
  bool _isProcessing = false;
  BenchmarkResult? _result;
  Map<String, dynamic>? _costAnalysis;
  List<dynamic>? _masterList;
  String? _error;

  Future<void> _pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: true,
      );

      if (result != null) {
        setState(() {
          _selectedFiles = result.files;
          _result = null;
          _error = null;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error picking files: $e';
      });
    }
  }

  Future<void> _processFiles() async {
    if (_selectedFiles == null || _selectedFiles!.isEmpty) {
      setState(() => _error = 'Please select files first');
      return;
    }

    setState(() {
      _isProcessing = true;
      _error = null;
    });

    try {
      final apiService = context.read<ApiService>();
      final response = await apiService.processBatchInvoices(_selectedFiles!);

      setState(() {
        _result = response;
        // Extract server-side calculated data
        _costAnalysis = response.costAnalysis;
        _masterList = response.masterList;
        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isProcessing = false;
      });
    }
  }

  Future<void> _downloadFile(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          const Text(
            'Upload & Process Invoices',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select PDF invoices to extract structured data',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),

          // File picker card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    Icons.cloud_upload,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Select Invoice Files',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('Supported format: PDF'),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _isProcessing ? null : _pickFiles,
                    icon: const Icon(Icons.file_open),
                    label: const Text('Choose Files'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                  ),
                  if (_selectedFiles != null && _selectedFiles!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),
                    Text(
                      '${_selectedFiles!.length} file(s) selected',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 150,
                      child: ListView.builder(
                        itemCount: _selectedFiles!.length,
                        itemBuilder: (context, index) {
                          final file = _selectedFiles![index];
                          return ListTile(
                            dense: true,
                            leading: const Icon(Icons.picture_as_pdf),
                            title: Text(file.name),
                            subtitle: Text(
                              '${(file.size / 1024).toStringAsFixed(1)} KB',
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: _isProcessing ? null : _processFiles,
                      icon: _isProcessing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.play_arrow),
                      label: Text(
                        _isProcessing ? 'Processing...' : 'Process Invoices',
                      ),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Error message
          if (_error != null) ...[
            const SizedBox(height: 24),
            Card(
              color: Colors.red[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.red),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Results
          if (_result != null) ...[
            const SizedBox(height: 32),
            _buildResultsSummary(),
            const SizedBox(height: 24),
            _buildDownloadButtons(),
            
            // Only show analysis if we have data from server
            if (_costAnalysis != null) ...[
              const SizedBox(height: 40),
              const Divider(thickness: 2),
              const SizedBox(height: 24),
              
              // Header for analysis section
              Row(
                children: [
                  Icon(Icons.analytics, size: 32, color: Colors.blue.shade700),
                  const SizedBox(width: 12),
                  const Text(
                    'Cost Savings Analysis',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Group buying opportunity - Save money on your purchases',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 32),
              
              // 1. Price Comparison Chart (Current vs Market Price)
              PriceComparisonChart(costAnalysis: _costAnalysis!),
              
              const SizedBox(height: 32),
              
              // 2. Contact Supplier CTA (Blurred)
              ContactSupplierCTA(
                potentialSavings: (_costAnalysis!['total_savings'] ?? 0).toDouble(),
              ),
              
              const SizedBox(height: 32),
              
              // 3. Master List of Items
              if (_masterList != null)
                _buildMasterList(),
            ],
            
            const SizedBox(height: 32),
            
            // Optional: Individual results in expandable section
            ExpansionTile(
              title: const Text(
                'View Individual Invoice Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              children: [
                _buildResultsList(),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResultsSummary() {
    final result = _result!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Processing Summary',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Files',
                    result.totalFiles.toString(),
                    Icons.description,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Successful',
                    result.successful.toString(),
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Failed',
                    result.failed.toString(),
                    Icons.error,
                    Colors.red,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Avg Time',
                    '${result.averageTime.toStringAsFixed(2)}s',
                    Icons.timer,
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadButtons() {
    final downloads = _result!.downloads;
    if (downloads == null) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Download Results',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                if (downloads.containsKey('items_csv'))
                  _buildDownloadButton(
                    'Items CSV',
                    downloads['items_csv']!,
                    Icons.table_chart,
                  ),
                if (downloads.containsKey('summary_csv'))
                  _buildDownloadButton(
                    'Summary CSV',
                    downloads['summary_csv']!,
                    Icons.summarize,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDownloadButton(String label, String path, IconData icon) {
    final apiService = context.read<ApiService>();
    final url = '${apiService.baseUrl}$path';

    return ElevatedButton.icon(
      onPressed: () => _downloadFile(url),
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),
    );
  }

  Widget _buildMasterList() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.list, size: 28),
                const SizedBox(width: 12),
                const Text(
                  'Master List - All Items',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_masterList!.length} unique items',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 32,
                headingRowColor: MaterialStateProperty.all(Colors.blue.shade50),
                columns: const [
                  DataColumn(label: Text('Item', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Quantity', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                  DataColumn(label: Text('Unit', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Price Range', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Count', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                ],
                rows: _masterList!.map((item) {
                  final priceMin = item['price_min'];
                  final priceMax = item['price_max'];
                  String priceRange = '-';
                  if (priceMin != null && priceMax != null) {
                    if (priceMin == priceMax) {
                      priceRange = priceMin.toStringAsFixed(2);
                    } else {
                      priceRange = '[${priceMin.toStringAsFixed(2)}, ${priceMax.toStringAsFixed(2)}]';
                    }
                  }
                  
                  return DataRow(cells: [
                    DataCell(
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 300),
                        child: Text(item['description'] ?? ''),
                      ),
                    ),
                    DataCell(Text((item['total_quantity'] ?? 0).toStringAsFixed(1))),
                    DataCell(Text(item['unit'] ?? '-')),
                    DataCell(Text(priceRange)),
                    DataCell(Text('${item['occurrences']}')),
                  ]);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Processing Details',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _result!.results.length,
          itemBuilder: (context, index) {
            return InvoiceResultCard(
              result: _result!.results[index],
            );
          },
        ),
      ],
    );
  }
}


