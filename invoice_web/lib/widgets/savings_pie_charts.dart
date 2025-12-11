import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../config.dart';

class SavingsPieCharts extends StatelessWidget {
  final Map<String, dynamic> costAnalysis;

  const SavingsPieCharts({super.key, required this.costAnalysis});

  @override
  Widget build(BuildContext context) {
    final topItems = costAnalysis['top_items'] as List<dynamic>? ?? [];
    final totalSavings = costAnalysis['total_savings'] ?? 0.0;
    final totalSpending = costAnalysis['total_current_spending'] ?? 0.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Pie Chart - Savings Breakdown
        Expanded(
          child: Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Potential Savings per Item v Total Savings',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    height: 300,
                    child: _buildSavingsPieChart(topItems, totalSavings),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        
        // Right Pie Chart - Spending Breakdown
        Expanded(
          child: Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Current Spending per Item v Total Spending',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    height: 300,
                    child: _buildSpendingPieChart(topItems, totalSpending),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSavingsPieChart(List<dynamic> topItems, double totalSavings) {
    // Blue shades for savings - navy blue gradient to match design
    final colors = [
      const Color(0xFF1A237E), // Navy blue (darkest)
      const Color(0xFF283593), // Dark blue
      const Color(0xFF3949AB), // Medium blue
      const Color(0xFF5C6BC0), // Light blue
      const Color(0xFF9FA8DA), // Lightest blue
    ];

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: PieChart(
            PieChartData(
              sections: _createSavingsSections(topItems, totalSavings, colors),
              sectionsSpace: 2,
              centerSpaceRadius: 50,
              borderData: FlBorderData(show: false),
            ),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 2,
          child: _buildLegend(topItems, colors, showSavings: true),
        ),
      ],
    );
  }

  Widget _buildSpendingPieChart(List<dynamic> topItems, double totalSpending) {
    // Red/coral shades for spending to match design
    final colors = [
      const Color(0xFFE57373), // Coral/light red (matches bar chart)
      const Color(0xFFEF9A9A), // Light coral
      const Color(0xFFFFCDD2), // Very light coral
      const Color(0xFFF8BBD0), // Pink
      const Color(0xFFFCE4EC), // Very light pink
    ];

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: PieChart(
            PieChartData(
              sections: _createSpendingSections(topItems, totalSpending, colors),
              sectionsSpace: 2,
              centerSpaceRadius: 50,
              borderData: FlBorderData(show: false),
            ),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 2,
          child: _buildLegend(topItems, colors, showSavings: false),
        ),
      ],
    );
  }

  List<PieChartSectionData> _createSavingsSections(
    List<dynamic> topItems,
    double totalSavings,
    List<Color> colors,
  ) {
    return topItems.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final savingAmount = (item['saving_amount'] ?? 0.0).toDouble();
      final percentage = totalSavings > 0 ? (savingAmount / totalSavings * 100) : 0.0;
      
      return PieChartSectionData(
        value: savingAmount,
        title: '${percentage.toStringAsFixed(1)}%',
        color: colors[index % colors.length],
        radius: 100,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  List<PieChartSectionData> _createSpendingSections(
    List<dynamic> topItems,
    double totalSpending,
    List<Color> colors,
  ) {
    return topItems.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final currentPrice = (item['current_price'] ?? 0.0).toDouble();
      final percentage = totalSpending > 0 ? (currentPrice / totalSpending * 100) : 0.0;
      
      return PieChartSectionData(
        value: currentPrice,
        title: '${percentage.toStringAsFixed(1)}%',
        color: colors[index % colors.length],
        radius: 100,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildLegend(List<dynamic> topItems, List<Color> colors, {required bool showSavings}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: topItems.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        final name = item['name'] ?? '';
        
        // Blur the item name
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: colors[index % colors.length],
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppConfig.demoMode
                    ? ImageFiltered(
                        imageFilter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                        child: Text(
                          name,
                          style: const TextStyle(fontSize: 12),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                    : Text(
                        name,
                        style: const TextStyle(fontSize: 12),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

