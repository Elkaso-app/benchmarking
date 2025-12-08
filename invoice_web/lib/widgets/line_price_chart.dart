import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class LinePriceChart extends StatelessWidget {
  final Map<String, dynamic> costAnalysis;

  const LinePriceChart({
    super.key,
    required this.costAnalysis,
  });

  @override
  Widget build(BuildContext context) {
    final topItems = costAnalysis['top_3_items'] as List? ?? [];
    final totalSavings = costAnalysis['total_savings'] ?? 0;
    final currency = costAnalysis['currency'] ?? 'AED';

    if (topItems.isEmpty) {
      return const SizedBox.shrink();
    }

    // Find min and max for Y-axis
    double minPrice = topItems.map((item) => (item['market_price'] ?? 0).toDouble()).reduce((a, b) => a < b ? a : b);
    double maxPrice = topItems.map((item) => (item['current_price'] ?? 0).toDouble()).reduce((a, b) => a > b ? a : b);
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with total savings
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange.shade100, Colors.orange.shade50],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade300, width: 2),
              ),
              child: Row(
                children: [
                  Icon(Icons.savings, size: 48, color: Colors.orange.shade700),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kaso Saving Potential',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              '${totalSavings.toStringAsFixed(2)} $currency',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade700,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                'Total saving from top 3 items',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Title
            Row(
              children: [
                Icon(Icons.show_chart, color: Colors.blue.shade700, size: 28),
                const SizedBox(width: 12),
                const Text(
                  'Price Comparison - Your Price vs Kaso Price',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Legend
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.arrow_upward, color: Colors.red.shade600, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Your Price (Top)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade700,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.trending_down, color: Colors.orange.shade600, size: 24),
                  const SizedBox(width: 16),
                  Icon(Icons.arrow_downward, color: Colors.orange.shade600, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Kaso Price (Bottom)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '= Savings',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Candlestick Chart
            SizedBox(
              height: 500,  // Taller for better visibility
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceEvenly,  // Better spacing
                  maxY: maxPrice * 1.15,  // More top padding
                  minY: minPrice * 0.85,  // More bottom padding
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final item = topItems[groupIndex];
                        final currentPrice = (item['current_price'] ?? 0).toDouble();
                        final marketPrice = (item['market_price'] ?? 0).toDouble();
                        final savings = (item['saving_amount'] ?? 0).toDouble();
                        
                        return BarTooltipItem(
                          'Your Price: ${currentPrice.toStringAsFixed(2)} $currency\n'
                          'Kaso Price: ${marketPrice.toStringAsFixed(2)} $currency\n'
                          'Save: ${savings.toStringAsFixed(2)} $currency',
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
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 80,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          int index = value.toInt();
                          if (index < 0 || index >= topItems.length) {
                            return const Text('');
                          }
                          
                          final item = topItems[index];
                          final name = item['name'] ?? 'Item ${index + 1}';
                          
                          // Blur the item name
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: SizedBox(
                              width: 100,
                              child: ImageFiltered(
                                imageFilter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                                child: Transform.rotate(
                                  angle: -0.3,
                                  child: Text(
                                    name,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[800],
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: (maxPrice - minPrice) / 5,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          return Text(
                            value.toStringAsFixed(0),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                        reservedSize: 42,
                      ),
                      axisNameWidget: Text(
                        'Price ($currency)',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      axisNameSize: 20,
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey.shade400, width: 1),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: (maxPrice - minPrice) / 5,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.shade300,
                        strokeWidth: 1,
                      );
                    },
                  ),
                  barGroups: topItems.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    final currentPrice = (item['current_price'] ?? 0).toDouble();
                    final marketPrice = (item['market_price'] ?? 0).toDouble();
                    final savingAmount = currentPrice - marketPrice;
                    
                    // Create candlestick: bottom (Kaso price) to top (Your price)
                    return BarChartGroupData(
                      x: index,
                      barsSpace: 20,
                      barRods: [
                        BarChartRodData(
                          fromY: marketPrice, // Kaso price (bottom)
                          toY: currentPrice,   // Your price (top)
                          // Gradient from red (top) to orange (bottom) to show the savings
                          gradient: LinearGradient(
                            colors: [
                              Colors.red.shade600,      // Top - Your Price (bad)
                              Colors.red.shade400,
                              Colors.orange.shade400,   // Bottom - Kaso Price (good)
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          width: 60,  // Wider bars
                          borderRadius: BorderRadius.circular(4),
                          borderSide: BorderSide(
                            color: Colors.red.shade800,
                            width: 2,
                          ),
                          // Add tooltip-like stack items to show the difference
                          rodStackItems: [
                            BarChartRodStackItem(
                              marketPrice,
                              marketPrice + (savingAmount * 0.5),
                              Colors.red.shade300.withOpacity(0.5),
                            ),
                          ],
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Items details
            ...topItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return _buildItemDetail(item, index + 1, currency);
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildItemDetail(Map<String, dynamic> item, int rank, String currency) {
    final name = item['name'] ?? '';
    final currentPrice = (item['current_price'] ?? 0).toDouble();
    final marketPrice = (item['market_price'] ?? 0).toDouble();
    final savingAmount = (item['saving_amount'] ?? 0).toDouble();
    final occurrences = item['occurrences'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          // Rank
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _getRankColor(rank),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$rank',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // Item info (BLURRED)
          Expanded(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '$occurrences occurrence(s)',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Prices (NOT BLURRED)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Your: ${currentPrice.toStringAsFixed(2)} $currency',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade600,
                ),
              ),
              Text(
                'Kaso: ${marketPrice.toStringAsFixed(2)} $currency',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade600,
                ),
              ),
            ],
          ),
          
          const SizedBox(width: 16),
          
          // Savings (replace % with -)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '- ${savingAmount.toStringAsFixed(2)} $currency',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber.shade600; // Gold
      case 2:
        return Colors.grey.shade400; // Silver
      case 3:
        return Colors.brown.shade400; // Bronze
      default:
        return Colors.grey.shade600;
    }
  }
}
