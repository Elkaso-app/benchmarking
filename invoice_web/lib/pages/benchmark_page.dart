import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';
import '../models/invoice_data.dart';
import '../widgets/invoice_result_card.dart';

class BenchmarkPage extends StatefulWidget {
  const BenchmarkPage({super.key});

  @override
  State<BenchmarkPage> createState() => _BenchmarkPageState();
}

class _BenchmarkPageState extends State<BenchmarkPage> {
  bool _isLoading = false;
  BenchmarkResult? _result;
  String? _error;
  List<String>? _availableInvoices;
  int? _selectedLimit;

  @override
  void initState() {
    super.initState();
    _loadAvailableInvoices();
  }

  Future<void> _loadAvailableInvoices() async {
    try {
      final apiService = context.read<ApiService>();
      final invoices = await apiService.listInvoices();
      setState(() {
        _availableInvoices = invoices;
      });
    } catch (e) {
      // Ignore errors, just won't show the count
    }
  }

  Future<void> _runBenchmark() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final apiService = context.read<ApiService>();
      final result = await apiService.runBenchmark(limit: _selectedLimit);

      setState(() {
        _result = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
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
            'Run Benchmark',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Process all invoices in the server directory',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),

          // Configuration card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.assessment,
                        size: 48,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Benchmark Configuration',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (_availableInvoices != null)
                              Text(
                                '${_availableInvoices!.length} invoices available on server',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Processing Limit (optional)',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<int?>(
                          value: _selectedLimit,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Process all invoices',
                          ),
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text('All invoices'),
                            ),
                            const DropdownMenuItem(
                              value: 5,
                              child: Text('First 5 invoices (test)'),
                            ),
                            const DropdownMenuItem(
                              value: 10,
                              child: Text('First 10 invoices'),
                            ),
                            const DropdownMenuItem(
                              value: 20,
                              child: Text('First 20 invoices'),
                            ),
                          ],
                          onChanged: _isLoading
                              ? null
                              : (value) {
                                  setState(() => _selectedLimit = value);
                                },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: FilledButton.icon(
                      onPressed: _isLoading ? null : _runBenchmark,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.play_arrow),
                      label: Text(_isLoading ? 'Running...' : 'Run Benchmark'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 48,
                          vertical: 20,
                        ),
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  if (_isLoading) ...[
                    const SizedBox(height: 24),
                    const LinearProgressIndicator(),
                    const SizedBox(height: 8),
                    const Center(
                      child: Text(
                        'Processing invoices... This may take a few minutes.',
                        style: TextStyle(fontStyle: FontStyle.italic),
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
            const SizedBox(height: 24),
            _buildResultsList(),
          ],
        ],
      ),
    );
  }

  Widget _buildResultsSummary() {
    final result = _result!;
    final successRate = result.totalFiles > 0
        ? (result.successful / result.totalFiles * 100)
        : 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Benchmark Results',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Icon(
                  successRate >= 90
                      ? Icons.celebration
                      : successRate >= 70
                          ? Icons.thumb_up
                          : Icons.warning,
                  color: successRate >= 90
                      ? Colors.green
                      : successRate >= 70
                          ? Colors.orange
                          : Colors.red,
                  size: 32,
                ),
              ],
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
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Successful',
                    result.successful.toString(),
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Failed',
                    result.failed.toString(),
                    Icons.error,
                    Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Success Rate',
                    '${successRate.toStringAsFixed(1)}%',
                    Icons.percent,
                    Colors.purple,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Total Time',
                    '${result.totalTime.toStringAsFixed(1)}s',
                    Icons.schedule,
                    Colors.indigo,
                  ),
                ),
                const SizedBox(width: 12),
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
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
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
                if (downloads.containsKey('json'))
                  _buildDownloadButton(
                    'JSON Results',
                    downloads['json']!,
                    Icons.data_object,
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



