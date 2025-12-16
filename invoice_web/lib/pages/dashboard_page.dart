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
                'Based on your latest supplier invoices  •  Generated on Dec 9, 2024',
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
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
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
            color: Colors.white.withOpacity(0.2),
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

  Widget _buildItemizedSavingsTable() {
    // Demo data - In production, this would come from backend API
    // API endpoint: GET /api/savings/itemized
    // Response structure: { items: [...], totalMonthlySavings: number }
    final savingsItems = [
      {
        'name': 'Chicken Breast (kg)',
        'supplier': 'Al Rawdah Foods',
        'yourPrice': 24.0,
        'benchmarkPrice': 19.0,
        'monthlyQuantity': 150, // kg per month
      },
      {
        'name': 'Italian Tomatoes (kg)',
        'supplier': 'Fresh Fruits Co',
        'yourPrice': 6.5,
        'benchmarkPrice': 4.2,
        'monthlyQuantity': 200, // kg per month
      },
      {
        'name': 'Olive Oil Extra Virgin (5L)',
        'supplier': 'Global Foods LLC',
        'yourPrice': 180.0,
        'benchmarkPrice': 155.0,
        'monthlyQuantity': 12, // bottles per month
      },
      {
        'name': 'Basmati Rice (20kg)',
        'supplier': 'Global Foods LLC',
        'yourPrice': 45.0,
        'benchmarkPrice': 38.0,
        'monthlyQuantity': 25, // bags per month
      },
      {
        'name': 'Cheddar Cheese Block (kg)',
        'supplier': 'Dairy Best Trading',
        'yourPrice': 32.0,
        'benchmarkPrice': 28.0,
        'monthlyQuantity': 80, // kg per month
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
                        final yourPrice = item['yourPrice'] as double;
                        final benchmarkPrice = item['benchmarkPrice'] as double;
                        final monthlyQuantity = item['monthlyQuantity'] as int;
                        final savingPercent =
                            ((yourPrice - benchmarkPrice) / yourPrice * 100);
                        // Monthly savings = (price difference) * monthly quantity
                        final monthlySavings =
                            (yourPrice - benchmarkPrice) * monthlyQuantity;

                        return DataRow(
                          cells: [
                            DataCell(
                              Text(
                                item['name'] as String,
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Color(0xFF1F2937),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                item['supplier'] as String,
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                'AED ${yourPrice.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                'AED ${benchmarkPrice.toStringAsFixed(2)}',
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
                                  color: savingPercent > 20
                                      ? const Color(0xFF10B981).withOpacity(0.1)
                                      : const Color(
                                          0xFF08012D,
                                        ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${savingPercent.toStringAsFixed(0)}%',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: savingPercent > 20
                                            ? const Color(0xFF10B981)
                                            : const Color(0xFF08012D),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Icon(
                                      Icons.arrow_downward,
                                      size: 16,
                                      color: savingPercent > 20
                                          ? const Color(0xFF10B981)
                                          : const Color(0xFF08012D),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                'AED ${monthlySavings.toStringAsFixed(0)}',
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
}
