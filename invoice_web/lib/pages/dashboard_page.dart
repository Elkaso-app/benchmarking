import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardPage extends StatefulWidget {
  final VoidCallback onNavigateToUpload;
  final VoidCallback onNavigateToReports;

  const DashboardPage({
    super.key,
    required this.onNavigateToUpload,
    required this.onNavigateToReports,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
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
            _buildItemizedSavingsTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Text(
              'Price Benchmark Report',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFEBF5FF),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFF3B82F6)),
              ),
              child: const Text(
                'Beta',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3B82F6),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Based on your latest supplier invoices  •  Generated on Dec 9, 2024',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.end,
          children: [
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
              label: const Text('Export PDF'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF1F2937),
                side: BorderSide(color: Colors.grey[300]!),
                elevation: 0,
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.auto_awesome, size: 18),
              label: const Text('Auto-Negotiate'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                elevation: 0,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTopStatsCards() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          children: [
            Flexible(
              flex: 1,
              child: _buildStatCard(
                title: 'Total Monthly Savings Potential',
                value: 'AED 3,420',
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
                value: '12%',
                subtitle: 'Across 25 benchmarked items',
                icon: Icons.help_outline,
                iconColor: Colors.grey[400]!,
                hasProgressBar: true,
                progressValue: 0.12,
              ),
            ),
            const SizedBox(width: 24),
            Flexible(
              flex: 1,
              child: _buildStatCard(
                title: 'Items Overpriced',
                value: '8 /25',
                subtitle: 'paying >10% above market average',
                icon: Icons.error_outline,
                iconColor: const Color(0xFFEF4444),
                hasProgressBar: false,
                showDots: true,
                totalDots: 25,
                filledDots: 8,
              ),
            ),
          ],
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Icon(icon, size: 18, color: iconColor),
            ],
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (hasProgressBar) ...[
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progressValue,
              backgroundColor: const Color(0xFFE5E7EB),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF10B981)),
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
            ),
          ],
          if (showDots) ...[
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(totalDots, (index) {
                  return Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(right: 4),
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
        ],
      ),
    );
  }

  Widget _buildPriceComparisonChart() {
    final items = [
      {'name': 'Chicken Breast', 'yourPrice': 18.0, 'benchmark': 15.0},
      {'name': 'Olive Oil (5L)', 'yourPrice': 180.0, 'benchmark': 155.0},
      {'name': 'Basmati Rice', 'yourPrice': 42.0, 'benchmark': 38.0},
      {'name': 'Tomatoes (kg)', 'yourPrice': 5.5, 'benchmark': 5.2},
      {'name': 'Cheddar Cheese', 'yourPrice': 32.0, 'benchmark': 30.0},
      {'name': 'Black Angus', 'yourPrice': 115.0, 'benchmark': 125.0},
    ];

    // Calculate totals for the "Total" bar
    double totalYourPrice = items.fold(
      0,
      (sum, item) => sum + (item['yourPrice'] as double),
    );
    double totalBenchmark = items.fold(
      0,
      (sum, item) => sum + (item['benchmark'] as double),
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
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Your current unit prices vs. Kaso market benchmark',
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Your Price', const Color(0xFFE53E51)),
              const SizedBox(width: 24),
              _buildLegendItem('Kaso Benchmark Price', const Color(0xFF1E3A8A)),
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
                    getTooltipColor: (group) => const Color(0xFF1F2937),
                    tooltipPadding: const EdgeInsets.all(8),
                    tooltipMargin: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final item = itemsWithTotal[group.x.toInt()];
                      final yourPrice = item['yourPrice'] as double;
                      final benchmark = item['benchmark'] as double;
                      final percentDiff =
                          ((yourPrice - benchmark) / benchmark * 100);
                      final isYourPrice = rodIndex == 0;
                      final value = isYourPrice ? yourPrice : benchmark;
                      final label = isYourPrice
                          ? 'Your Price'
                          : 'Kaso Benchmark';

                      return BarTooltipItem(
                        '$label\nAED ${value.toStringAsFixed(1)}\n${percentDiff >= 0 ? '+' : ''}${percentDiff.toStringAsFixed(1)}%',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
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
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 &&
                            value.toInt() < itemsWithTotal.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              itemsWithTotal[value.toInt()]['name'] as String,
                              style: TextStyle(
                                fontSize: 11,
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
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        );
                      },
                      reservedSize: 50,
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
                        color: const Color(0xFF1E3A8A),
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
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildAutoNegotiateCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E3A8A), Color(0xFF1E40AF)],
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
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: const Text(
                  'Coming Soon',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'We can negotiate better prices with your suppliers automatically using our AI-driven RFQ engine.',
            style: TextStyle(fontSize: 13, color: Colors.white70, height: 1.5),
          ),
          const SizedBox(height: 24),
          _buildStep('1', 'Select items to renegotiate'),
          const SizedBox(height: 12),
          _buildStep('2', 'AI contacts suppliers'),
          const SizedBox(height: 12),
          _buildStep('3', 'You approve the best offer'),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF1E3A8A),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Find Better Prices',
                style: TextStyle(fontWeight: FontWeight.w600),
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
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(text, style: const TextStyle(fontSize: 14, color: Colors.white)),
      ],
    );
  }

  Widget _buildItemizedSavingsTable() {
    final savingsItems = [
      {
        'name': 'Chicken Breast',
        'supplier': 'Al Rawdah',
        'yourPrice': 24.0,
        'benchmarkPrice': 19.0,
        'monthlyCost': 1200.0,
      },
      {
        'name': 'Italian Tomatoes (kg)',
        'supplier': 'Fresh Fruits Co',
        'yourPrice': 6.5,
        'benchmarkPrice': 4.2,
        'monthlyCost': 325.0,
      },
      {
        'name': 'Olive Oil Extra Virgin (5L)',
        'supplier': 'Global Foods',
        'yourPrice': 180.0,
        'benchmarkPrice': 155.0,
        'monthlyCost': 900.0,
      },
      {
        'name': 'Basmati Rice (20kg)',
        'supplier': 'Global Foods',
        'yourPrice': 45.0,
        'benchmarkPrice': 38.0,
        'monthlyCost': 675.0,
      },
      {
        'name': 'Cheddar Cheese (Block)',
        'supplier': 'Dairy Best',
        'yourPrice': 32.0,
        'benchmarkPrice': 28.0,
        'monthlyCost': 480.0,
      },
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
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Itemized Savings Potential',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Items where you are paying significantly more than market average.',
                      style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
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
                                color: Color(0xFF1F2937),
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Supplier',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1F2937),
                              fontSize: 13,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Your Price',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1F2937),
                              fontSize: 13,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Kaso Benchmark Price',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1F2937),
                              fontSize: 13,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Saving %',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1F2937),
                              fontSize: 13,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Monthly Savings',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1F2937),
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                      rows: savingsItems.map((item) {
                        final yourPrice = item['yourPrice'] as double;
                        final benchmarkPrice = item['benchmarkPrice'] as double;
                        final monthlyCost = item['monthlyCost'] as double;
                        final savingPercent =
                            ((yourPrice - benchmarkPrice) / yourPrice * 100);
                        final monthlySavings =
                            monthlyCost * (savingPercent / 100);

                        return DataRow(
                          cells: [
                            DataCell(
                              Text(
                                item['name'] as String,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF1F2937),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                item['supplier'] as String,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                'AED ${yourPrice.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                'AED ${benchmarkPrice.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: savingPercent > 20
                                      ? const Color(0xFF10B981).withOpacity(0.1)
                                      : const Color(
                                          0xFF3B82F6,
                                        ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${savingPercent.toStringAsFixed(0)}%',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: savingPercent > 20
                                            ? const Color(0xFF10B981)
                                            : const Color(0xFF3B82F6),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.arrow_downward,
                                      size: 14,
                                      color: savingPercent > 20
                                          ? const Color(0xFF10B981)
                                          : const Color(0xFF3B82F6),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                'Provide data',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[500],
                                  fontStyle: FontStyle.italic,
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
}
