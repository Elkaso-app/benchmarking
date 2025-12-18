import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

/// ============================================================================
/// CENTRALIZED DASHBOARD DATA SOURCE
/// ============================================================================
///
/// This file contains a single source of truth for all dashboard data.
/// All charts, tables, and metrics use the same underlying data model.
///
/// HOW TO MAP TO API:
/// -----------------
/// 1. Create API endpoint: GET /api/dashboard/summary
/// 2. Response format should match DashboardData structure:
///    {
///      "items": [
///        {
///          "name": "Chicken Breast (kg)",
///          "displayName": "Chicken Breast",
///          "supplier": "Al Rawdah Foods",
///          "yourPrice": 18.0,
///          "benchmarkPrice": 15.0,
///          "monthlyQuantity": 150
///        },
///        ...
///      ],
///      "generatedDate": "2024-12-09T00:00:00Z"
///    }
///
/// 3. Replace _initializeDemoData() with API call:
///    ```dart
///    Future<void> _loadDashboardData() async {
///      final response = await apiService.getDashboardSummary();
///      setState(() {
///        _dashboardData = DashboardData(
///          items: response['items'].map((json) =>
///            DashboardItemData(
///              name: json['name'],
///              supplier: json['supplier'],
///              yourPrice: json['yourPrice'],
///              benchmarkPrice: json['benchmarkPrice'],
///              monthlyQuantity: json['monthlyQuantity'],
///              displayName: json['displayName'],
///            )
///          ).toList(),
///          generatedDate: DateTime.parse(response['generatedDate']),
///        );
///      });
///    }
///    ```
///
/// BENEFITS:
/// --------
/// - Single source of truth for all dashboard data
/// - Consistent values across all visualizations
/// - Easy to update demo data in one place
/// - Automatic calculation of aggregate metrics
/// - Type-safe data access
///
/// ============================================================================

// Data model for individual items
class DashboardItemData {
  final String name;
  final String supplier;
  final double yourPrice;
  final double benchmarkPrice;
  final int monthlyQuantity;
  final String displayName; // For chart labels (shorter/multi-line)

  DashboardItemData({
    required this.name,
    required this.supplier,
    required this.yourPrice,
    required this.benchmarkPrice,
    required this.monthlyQuantity,
    String? displayName,
  }) : displayName = displayName ?? name;

  // Calculated properties
  double get savingPercent =>
      ((yourPrice - benchmarkPrice) / yourPrice * 100).clamp(0, 100);
  double get monthlySavings => (yourPrice - benchmarkPrice) * monthlyQuantity;
  double get priceDifference => yourPrice - benchmarkPrice;
}

// Centralized data source for the entire dashboard
class DashboardData {
  final List<DashboardItemData> items;
  final DateTime generatedDate;

  DashboardData({required this.items, DateTime? generatedDate})
    : generatedDate = generatedDate ?? DateTime.now();

  // Calculated aggregate metrics
  double get totalMonthlySavings =>
      items.fold(0, (sum, item) => sum + item.monthlySavings);

  double get averageSavingPercent => items.isEmpty
      ? 0
      : items.fold(0.0, (sum, item) => sum + item.savingPercent) / items.length;

  int get itemsOverpriced =>
      items.where((item) => item.savingPercent > 10).length;

  int get totalItems => items.length;

  // Get top N items by monthly savings
  List<DashboardItemData> getTopSavingsItems(int n) {
    final sorted = List<DashboardItemData>.from(items)
      ..sort((a, b) => b.monthlySavings.compareTo(a.monthlySavings));
    return sorted.take(n).toList();
  }
}

class DashboardPage extends StatefulWidget {
  final VoidCallback onNavigateToUpload;

  const DashboardPage({super.key, required this.onNavigateToUpload});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // SINGLE SOURCE OF TRUTH for all dashboard data
  // In production, this would be loaded from API: GET /api/dashboard/summary
  late final DashboardData _dashboardData;

  @override
  void initState() {
    super.initState();
    _initializeDemoData();
  }

  void _initializeDemoData() {
    _dashboardData = DashboardData(
      generatedDate: DateTime(2024, 12, 9),
      items: [
        // HIGH SAVINGS ITEMS (>20%)
        DashboardItemData(
          name: 'Premium Salmon Fillet (kg)',
          displayName: 'Salmon Fillet',
          supplier: 'Ocean Fresh Trading',
          yourPrice: 85.0,
          benchmarkPrice: 65.0,
          monthlyQuantity: 120,
        ),
        DashboardItemData(
          name: 'Italian Extra Virgin Olive Oil (5L)',
          displayName: 'Olive Oil (5L)',
          supplier: 'Mediterranean Foods',
          yourPrice: 195.0,
          benchmarkPrice: 155.0,
          monthlyQuantity: 15,
        ),
        DashboardItemData(
          name: 'Wagyu Beef Striploin (kg)',
          displayName: 'Wagyu Beef',
          supplier: 'Prime Cuts International',
          yourPrice: 420.0,
          benchmarkPrice: 340.0,
          monthlyQuantity: 25,
        ),

        // MODERATE SAVINGS (10-20%)
        DashboardItemData(
          name: 'Chicken Breast Boneless (kg)',
          displayName: 'Chicken Breast',
          supplier: 'Al Rawdah Foods',
          yourPrice: 22.0,
          benchmarkPrice: 18.5,
          monthlyQuantity: 200,
        ),
        DashboardItemData(
          name: 'King Prawns Raw (kg)',
          displayName: 'King Prawns',
          supplier: 'Seafood Specialists',
          yourPrice: 95.0,
          benchmarkPrice: 82.0,
          monthlyQuantity: 75,
        ),
        DashboardItemData(
          name: 'Premium Basmati Rice (20kg)',
          displayName: 'Basmati Rice',
          supplier: 'Global Grains LLC',
          yourPrice: 48.0,
          benchmarkPrice: 42.0,
          monthlyQuantity: 30,
        ),

        // LOW SAVINGS (<10%)
        DashboardItemData(
          name: 'Organic Roma Tomatoes (kg)',
          displayName: 'Tomatoes (kg)',
          supplier: 'Fresh Harvest Co',
          yourPrice: 6.2,
          benchmarkPrice: 5.8,
          monthlyQuantity: 250,
        ),
        DashboardItemData(
          name: 'Aged Cheddar Cheese Block (kg)',
          displayName: 'Cheddar Cheese',
          supplier: 'Dairy Best Trading',
          yourPrice: 45.0,
          benchmarkPrice: 42.5,
          monthlyQuantity: 60,
        ),

        // GOOD DEAL (already below market)
        DashboardItemData(
          name: 'Black Angus Ribeye (kg)',
          displayName: 'Black Angus',
          supplier: 'Premium Meats Hub',
          yourPrice: 115.0,
          benchmarkPrice: 125.0,
          monthlyQuantity: 50,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 32),
            _buildTopStatsCards(),
            const SizedBox(height: 32),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 900) {
                  // Stack vertically on smaller screens
                  return Column(
                    children: [
                      _buildPriceComparisonChart(),
                      const SizedBox(height: 24),
                      _buildAutoNegotiateCard(),
                    ],
                  );
                }
                // Side by side on larger screens
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(flex: 2, child: _buildPriceComparisonChart()),
                    const SizedBox(width: 24),
                    Flexible(flex: 1, child: _buildAutoNegotiateCard()),
                  ],
                );
              },
            ),
            const SizedBox(height: 32),
            _buildMonthlySavingsChart(),
            const SizedBox(height: 32),
            _buildItemizedSavingsTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title and subtitle
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Text(
                    'Marketprice Radar',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF08012D),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFF08012D)),
                    ),
                    child: const Text(
                      'Beta',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF08012D),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Based on your latest supplier invoices  •  Generated on ${_formatDate(_dashboardData.generatedDate)}',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ],
          ),
        ),
        const SizedBox(width: 24),
        // Buttons aligned to the right
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              onPressed: widget.onNavigateToUpload,
              icon: const Icon(Icons.upload_file, size: 22),
              label: const Text(
                'Upload Invoices',
                style: TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF08012D),
                side: const BorderSide(color: Color(0xFF08012D)),
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.search, size: 22),
              label: const Text(
                'Find better prices',
                style: TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF08012D),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTopStatsCards() {
    final totalSavings = _dashboardData.totalMonthlySavings;
    final avgSavingPercent = _dashboardData.averageSavingPercent;
    final overpriced = _dashboardData.itemsOverpriced;
    final totalItems = _dashboardData.totalItems;

    return LayoutBuilder(
      builder: (context, constraints) {
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Flexible(
                flex: 1,
                child: _buildStatCard(
                  title: 'Total Monthly Savings Potential',
                  value: 'AED ${totalSavings.toStringAsFixed(0)}',
                  subtitle: '',
                  icon: Icons.trending_up,
                  iconColor: const Color(0xFF10B981),
                  hasProgressBar: false,
                ),
              ),
              const SizedBox(width: 24),
              Flexible(
                flex: 1,
                child: _buildStatCard(
                  title: 'Average Cost Reduction per Item',
                  value: '${avgSavingPercent.toStringAsFixed(0)}%',
                  subtitle: 'Across $totalItems benchmarked items',
                  icon: Icons.help_outline,
                  iconColor: Colors.grey[400]!,
                  hasProgressBar: true,
                  progressValue: avgSavingPercent / 100,
                ),
              ),
              const SizedBox(width: 24),
              Flexible(
                flex: 1,
                child: _buildStatCard(
                  title: 'Items Overpriced',
                  value: '$overpriced /$totalItems',
                  subtitle: 'paying >10% above market average',
                  icon: Icons.error_outline,
                  iconColor: const Color(0xFFEF4444),
                  hasProgressBar: false,
                  showDots: true,
                  totalDots: totalItems,
                  filledDots: overpriced,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    bool hasProgressBar = false,
    double progressValue = 0.0,
    bool showDots = false,
    int totalDots = 0,
    int filledDots = 0,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top section: Title with icon
          Row(
            children: [
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Icon(icon, size: 20, color: iconColor),
            ],
          ),
          const SizedBox(height: 12),
          // Middle section: Value
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.bold,
                color: Color(0xFF08012D),
              ),
            ),
          ),
          // Spacer to push bottom content down
          const Spacer(),
          // Bottom section: Subtitle, progress bar, or dots
          if (subtitle.isNotEmpty)
            Text(
              subtitle,
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          if (hasProgressBar) ...[
            if (subtitle.isNotEmpty) const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progressValue,
              backgroundColor: const Color(0xFFE5E7EB),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF08012D)),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
          if (showDots)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(totalDots, (index) {
                  return Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.only(right: 5),
                    decoration: BoxDecoration(
                      color: index < filledDots
                          ? const Color(0xFFEF4444)
                          : const Color(0xFFE5E7EB),
                      shape: BoxShape.circle,
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPriceComparisonChart() {
    // Use centralized data
    final items = _dashboardData.items
        .map(
          (item) => {
            'name': item.displayName,
            'yourPrice': item.yourPrice,
            'benchmark': item.benchmarkPrice,
          },
        )
        .toList();

    // Calculate totals for the "Total" bar
    double totalYourPrice = _dashboardData.items.fold(
      0.0,
      (sum, item) => sum + item.yourPrice,
    );
    double totalBenchmark = _dashboardData.items.fold(
      0.0,
      (sum, item) => sum + item.benchmarkPrice,
    );

    // Add total as the first item
    final itemsWithTotal = [
      {
        'name': 'Total',
        'yourPrice': totalYourPrice,
        'benchmark': totalBenchmark,
      },
      ...items,
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Price Comparison',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF08012D),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Your current unit prices vs. Kaso market benchmark',
            style: TextStyle(fontSize: 15, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Your Price', const Color(0xFFE53E51)),
              const SizedBox(width: 24),
              _buildLegendItem('Kaso Benchmark Price', const Color(0xFF08012D)),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 400,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (totalYourPrice * 1.1).ceilToDouble(),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) => Colors.white,
                    tooltipPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    tooltipMargin: 16,
                    tooltipRoundedRadius: 12,
                    maxContentWidth: 280,
                    fitInsideHorizontally: true,
                    fitInsideVertically: true,
                    tooltipBorder: BorderSide(
                      color: Colors.grey.shade300,
                      width: 1,
                    ),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final item = itemsWithTotal[group.x.toInt()];
                      final yourPrice = item['yourPrice'] as double;
                      final benchmark = item['benchmark'] as double;
                      final potentialSaving =
                          ((yourPrice - benchmark) / yourPrice * 100);
                      final itemName = item['name'] as String;

                      // Only show tooltip on first rod (yourPrice) to avoid duplicates
                      if (rodIndex != 0) return null;

                      return BarTooltipItem(
                        '$itemName\n\n',
                        const TextStyle(
                          color: Color(0xFF1F2937),
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                        textAlign: TextAlign.left,
                        children: [
                          // Red dot for Your Price (matches bar color)
                          const TextSpan(
                            text: '● ',
                            style: TextStyle(
                              color: Color(0xFFE53E51),
                              fontSize: 14,
                            ),
                          ),
                          TextSpan(
                            text: 'Your Price:  ',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.normal,
                              fontSize: 14,
                            ),
                          ),
                          TextSpan(
                            text: 'AED ${yourPrice.toStringAsFixed(0)}\n',
                            style: const TextStyle(
                              color: Color(0xFF1F2937),
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          // Dark blue dot for Market Benchmark (matches bar color)
                          const TextSpan(
                            text: '● ',
                            style: TextStyle(
                              color: Color(0xFF08012D),
                              fontSize: 14,
                            ),
                          ),
                          TextSpan(
                            text: 'Market Benchmark:  ',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.normal,
                              fontSize: 14,
                            ),
                          ),
                          TextSpan(
                            text: 'AED ${benchmark.toStringAsFixed(0)}\n\n',
                            style: const TextStyle(
                              color: Color(0xFF1F2937),
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          // Divider line using dashes
                          TextSpan(
                            text: '───────────────\n',
                            style: TextStyle(
                              color: Colors.grey[300],
                              fontSize: 10,
                              letterSpacing: -2,
                            ),
                          ),
                          // Potential Saving in green
                          TextSpan(
                            text:
                                'Potential Saving: ${potentialSaving > 0 ? potentialSaving.toStringAsFixed(0) : 0}%',
                            style: TextStyle(
                              color: potentialSaving > 0
                                  ? const Color(0xFF10B981)
                                  : Colors.grey[500],
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 &&
                            value.toInt() < itemsWithTotal.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              itemsWithTotal[value.toInt()]['name'] as String,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontWeight: value.toInt() == 0
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          'AED ${value.toInt()}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        );
                      },
                      reservedSize: 55,
                      interval: (totalYourPrice / 4).ceilToDouble(),
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: (totalYourPrice / 4).ceilToDouble(),
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: const Color(0xFFF3F4F6),
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    left: BorderSide(color: Colors.grey[300]!),
                    bottom: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                barGroups: itemsWithTotal.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final yourPrice = item['yourPrice'] as double;
                  final benchmark = item['benchmark'] as double;

                  return BarChartGroupData(
                    x: index,
                    barsSpace: 4,
                    barRods: [
                      BarChartRodData(
                        toY: yourPrice,
                        color: const Color(0xFFE53E51),
                        width: 32,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                      BarChartRodData(
                        toY: benchmark,
                        color: const Color(0xFF08012D),
                        width: 32,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildAutoNegotiateCard() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF08012D), Color(0xFF08012D)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Automate your savings',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
                child: const Text(
                  'Coming Soon',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'We can negotiate better prices with your suppliers automatically using our AI-driven RFQ engine.',
            style: TextStyle(fontSize: 15, color: Colors.white70, height: 1.5),
          ),
          const SizedBox(height: 28),
          _buildStep('1', 'Select items to renegotiate'),
          const SizedBox(height: 14),
          _buildStep('2', 'AI contacts suppliers'),
          const SizedBox(height: 14),
          _buildStep('3', 'You approve the best offer'),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF08012D),
                padding: const EdgeInsets.symmetric(vertical: 18),
              ),
              child: const Text(
                'Find Better Prices',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(String number, String text) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Text(text, style: const TextStyle(fontSize: 16, color: Colors.white)),
      ],
    );
  }

  Widget _buildMonthlySavingsChart() {
    // Get top 5 items by monthly savings from centralized data
    final topItems = _dashboardData.getTopSavingsItems(5);
    final savingsData = topItems
        .map((item) => {'name': item.displayName, 'price': item.monthlySavings})
        .toList();

    // Calculate max Y for chart scaling
    final maxSavings = topItems.isEmpty
        ? 900.0
        : topItems.first.monthlySavings * 1.2;

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Monthly saving potential',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF08012D),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  color: Color(0xFF08012D),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Monthly Savings',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Monthly Savings (AED)',
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
          const SizedBox(height: 40),
          SizedBox(
            height: 500,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceEvenly,
                maxY: maxSavings,
                minY: 0,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) => Colors.transparent,
                    tooltipPadding: EdgeInsets.zero,
                    tooltipMargin: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final item = savingsData[groupIndex];
                      return BarTooltipItem(
                        '${(item['price'] as double).toStringAsFixed(0)} AED',
                        const TextStyle(
                          color: Color(0xFF08012D),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 100,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 &&
                            value.toInt() < savingsData.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text(
                              savingsData[value.toInt()]['name'] as String,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF6B7280),
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 4,
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      interval: (maxSavings / 4).ceilToDouble(),
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: (maxSavings / 4).ceilToDouble(),
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: const Color(0xFFF3F4F6),
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    left: BorderSide(color: Colors.grey[300]!, width: 1),
                    bottom: BorderSide(color: Colors.grey[300]!, width: 1),
                  ),
                ),
                barGroups: savingsData.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final price = item['price'] as double;
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: price,
                        color: const Color(0xFF08012D),
                        width: 50,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(6),
                        ),
                      ),
                    ],
                    // Always show the price label on top of the bar
                    showingTooltipIndicators: [0],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemizedSavingsTable() {
    // Use centralized data - filter items with savings > 10%
    // In production, this would come from backend API: GET /api/savings/itemized
    final savingsItems =
        _dashboardData.items.where((item) => item.savingPercent > 10).toList()
          ..sort((a, b) => b.monthlySavings.compareTo(a.monthlySavings));

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Itemized Savings Potential',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF08012D),
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Items where you are paying significantly more than market average.',
                      style: TextStyle(fontSize: 15, color: Color(0xFF6B7280)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Table
          LayoutBuilder(
            builder: (context, constraints) {
              return SizedBox(
                width: constraints.maxWidth,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(
                        const Color(0xFFF9FAFB),
                      ),
                      columnSpacing: 60,
                      horizontalMargin: 0,
                      dataRowMinHeight: 60,
                      dataRowMaxHeight: 80,
                      columns: const [
                        DataColumn(
                          label: Expanded(
                            child: Text(
                              'Item Name',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF08012D),
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Supplier',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF08012D),
                              fontSize: 15,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Your Price',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF08012D),
                              fontSize: 15,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Kaso Benchmark Price',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF08012D),
                              fontSize: 15,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Saving %',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF08012D),
                              fontSize: 15,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Monthly Savings',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF08012D),
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                      rows: savingsItems.map((item) {
                        return DataRow(
                          cells: [
                            DataCell(
                              Text(
                                item.name,
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Color(0xFF1F2937),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                item.supplier,
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                'AED ${item.yourPrice.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                'AED ${item.benchmarkPrice.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 7,
                                ),
                                decoration: BoxDecoration(
                                  color: item.savingPercent > 20
                                      ? const Color(
                                          0xFF10B981,
                                        ).withValues(alpha: 0.1)
                                      : const Color(
                                          0xFF08012D,
                                        ).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${item.savingPercent.toStringAsFixed(0)}%',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: item.savingPercent > 20
                                            ? const Color(0xFF10B981)
                                            : const Color(0xFF08012D),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Icon(
                                      Icons.south_rounded,
                                      size: 16,
                                      color: item.savingPercent > 20
                                          ? const Color(0xFF10B981)
                                          : const Color(0xFF08012D),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                'AED ${item.monthlySavings.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Color(0xFF10B981),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Helper method to format date
  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
