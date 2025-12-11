import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';
import '../models/invoice_data.dart';
import '../widgets/invoice_result_card.dart';
import '../widgets/kpi_cards.dart';
import '../widgets/line_price_chart.dart';
import '../widgets/savings_pie_charts.dart';
import '../widgets/monthly_savings_chart.dart';
import '../widgets/blurred_suppliers_list.dart';
import '../widgets/magic_wand_loader.dart';
import '../widgets/simple_upload_zone.dart';
import '../config.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> with SingleTickerProviderStateMixin {
  List<PlatformFile>? _selectedFiles;
  bool _isProcessing = false;
  BenchmarkResult? _result;
  Map<String, dynamic>? _costAnalysis;
  List<dynamic>? _masterList;
  String? _error;
  int _processingStage = 0;
  late AnimationController _successController;

  @override
  void initState() {
    super.initState();
    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _successController.dispose();
    super.dispose();
  }

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
          _successController.reset();
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
      _processingStage = 0;
    });

    try {
      // Simulate processing stages for better UX
      _updateStage(1); // Uploading
      await Future.delayed(const Duration(milliseconds: 500));
      
      _updateStage(2); // AI scanning
      await Future.delayed(const Duration(milliseconds: 500));
      
      _updateStage(3); // Extracting data
      final apiService = context.read<ApiService>();
      final response = await apiService.processBatchInvoices(_selectedFiles!);
      
      _updateStage(4); // Analyzing costs
      await Future.delayed(const Duration(milliseconds: 500));
      
      _updateStage(5); // Complete
      await Future.delayed(const Duration(milliseconds: 300));

      setState(() {
        _result = response;
        _costAnalysis = response.costAnalysis;
        _masterList = response.masterList;
        _isProcessing = false;
      });
      
      // Trigger success animation
      _successController.forward();
      
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isProcessing = false;
        _processingStage = 0;
      });
    }
  }

  void _updateStage(int stage) {
    if (mounted) {
      setState(() => _processingStage = stage);
    }
  }

  String _getProcessingMessage(int stage) {
    switch (stage) {
      case 1:
        return 'Uploading files...';
      case 2:
        return 'AI scanning documents...';
      case 3:
        return 'Extracting data from invoices...';
      case 4:
        return 'Analyzing costs and calculating savings...';
      case 5:
        return 'Finalizing results...';
      default:
        return 'Preparing...';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Simple Upload Zone
          SimpleUploadZone(
            selectedFiles: _selectedFiles,
            onSelectFiles: _pickFiles,
            onProcess: _processFiles,
            isProcessing: _isProcessing,
          ),

          // Processing indicator
          if (_isProcessing) ...[
            const SizedBox(height: 60),
            const Center(
              child: MagicWandLoader(
                message: 'AI is processing your invoices...',
                size: 100,
              ),
            ),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                children: [
                  Text(
                    'Processing ${_selectedFiles?.length ?? 0} invoice(s)',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: _processingStage > 0 ? _processingStage / 5 : null,
                    backgroundColor: const Color(0xFFE5E7EB),
                    valueColor: const AlwaysStoppedAnimation(Color(0xFF6366F1)),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _getProcessingMessage(_processingStage),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Error message
          if (_error != null) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red.shade700, size: 28),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Processing Error',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade700,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _error!,
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Success Animation and Results
          if (_result != null && !_isProcessing) ...[
            const SizedBox(height: 40),
            // Success indicator with animation
            AnimatedBuilder(
              animation: _successController,
              builder: (context, child) {
                return Transform.scale(
                  scale: 0.8 + (_successController.value * 0.2),
                  child: Opacity(
                    opacity: _successController.value,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4CAF50).withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.white, size: 32),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Processing Complete!',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'AI has successfully analyzed your invoices',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.auto_awesome, color: Colors.white, size: 28),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            _buildResultsSummary(),
            
            // Only show analysis if we have data from server
            if (_costAnalysis != null) ...[
              const SizedBox(height: 40),
              const Divider(thickness: 2),
              const SizedBox(height: 32),
              
              // 1. KPI Cards with big green numbers (Overview section)
              KpiCards(costAnalysis: _costAnalysis!),
              
              const SizedBox(height: 32),
              
              // 2. Bar Chart - Current Price vs Market Price per Unit
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 40,
                              height: 20,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE57373),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Your current price (SAR)',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(width: 24),
                            Container(
                              width: 40,
                              height: 20,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A237E),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Kaso market price (est) (SAR)',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      LinePriceChart(costAnalysis: _costAnalysis!),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // 3. Two Pie Charts Side by Side
              SavingsPieCharts(costAnalysis: _costAnalysis!),
              
              const SizedBox(height: 32),
              
              // 4. Bottom Bar Chart - Monthly Savings per Item
              MonthlySavingsChart(costAnalysis: _costAnalysis!),
              
              const SizedBox(height: 32),
              
              // 5. Blurred Suppliers List (only in demo mode)
              if (AppConfig.demoMode) ...[
                BlurredSuppliersList(itemsList: _masterList),
                const SizedBox(height: 32),
              ],
              
              // 6. Master List of Items
              if (_masterList != null)
                _buildMasterList(),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildResultsSummary() {
    final result = _result!;
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.blue.shade50.withOpacity(0.3),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A237E).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.analytics,
                    color: Color(0xFF1A237E),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Processing Summary',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
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
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMasterList() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A237E).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.list,
                    color: Color(0xFF1A237E),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Master List - All Items',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A237E).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_masterList!.length} unique items',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF1A237E),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 32,
                headingRowColor: MaterialStateProperty.all(const Color(0xFF1A237E).withOpacity(0.05)),
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
                        child: AppConfig.demoMode
                            ? ImageFiltered(
                                imageFilter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                child: Text(item['description'] ?? ''),
                              )
                            : Text(item['description'] ?? ''),
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
}
