import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../config.dart';

class LinePriceChart extends StatelessWidget {
  final Map<String, dynamic> costAnalysis;

  const LinePriceChart({
    super.key,
    required this.costAnalysis,
  });

  @override
  Widget build(BuildContext context) {
    final topItems = costAnalysis['top_items'] as List? ?? [];
    final currency = costAnalysis['currency'] ?? 'AED';

    if (topItems.isEmpty) {
      return const SizedBox.shrink();
    }

    // Extract data for chart
    final itemNames = topItems.map((item) => item['name'] as String).toList();
    final currentPrices = topItems.map((item) => (item['current_price'] ?? 0.0).toDouble()).toList();
    final marketPrices = topItems.map((item) => (item['market_price'] ?? 0.0).toDouble()).toList();
    
    // Find max price for Y-axis
    final allPrices = [...currentPrices, ...marketPrices];
    final maxPrice = allPrices.reduce((a, b) => a > b ? a : b);
    final minPrice = allPrices.reduce((a, b) => a < b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          'Current Price v Market Price per Unit ($currency)',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        
        // Chart
        SizedBox(
          height: 500,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxPrice * 1.15,
              minY: minPrice * 0.85,
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final item = topItems[groupIndex];
                    final price = rodIndex == 0 ? item['current_price'] : item['market_price'];
                    final label = rodIndex == 0 ? 'Your Price' : 'Kaso Price';
                    
                    return BarTooltipItem(
                      '$label\n${price.toStringAsFixed(2)} $currency',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
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
                      if (index < 0 || index >= itemNames.length) {
                        return const Text('');
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: SizedBox(
                          width: 100,
                          child: AppConfig.demoMode
                              ? ImageFiltered(
                                  imageFilter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                                  child: Transform.rotate(
                                    angle: -0.3,
                                    child: Text(
                                      itemNames[index],
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                )
                              : Transform.rotate(
                                  angle: -0.3,
                                  child: Text(
                                    itemNames[index],
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  axisNameWidget: Text(
                    'Price ($currency)',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  axisNameSize: 24,
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: (maxPrice - minPrice) / 5,
                    reservedSize: 50,
                    getTitlesWidget: (value, meta) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Text(
                          value.toStringAsFixed(0),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade400, width: 1),
                  left: BorderSide(color: Colors.grey.shade400, width: 1),
                ),
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
                final currentPrice = (item['current_price'] ?? 0.0).toDouble();
                final marketPrice = (item['market_price'] ?? 0.0).toDouble();
                
                return BarChartGroupData(
                  x: index,
                  barsSpace: 8,
                  barRods: [
                    // Your current price (red/coral bar)
                    BarChartRodData(
                      toY: currentPrice,
                      color: const Color(0xFFE57373), // Coral/light red to match design
                      width: 35,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(6),
                        topRight: Radius.circular(6),
                      ),
                      rodStackItems: [],
                      backDrawRodData: BackgroundBarChartRodData(
                        show: false,
                      ),
                    ),
                    // Kaso market price (navy blue bar)
                    BarChartRodData(
                      toY: marketPrice,
                      color: const Color(0xFF1A237E), // Navy blue to match design
                      width: 35,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(6),
                        topRight: Radius.circular(6),
                      ),
                    ),
                  ],
                  showingTooltipIndicators: [0, 1],
                );
              }).toList(),
            ),
          ),
        ),
        
        // Show values on bars as a legend below chart
        const SizedBox(height: 24),
        Wrap(
          spacing: 20,
          runSpacing: 12,
          children: topItems.asMap().entries.map((entry) {
            final item = entry.value;
            final name = item['name'] ?? '';
            final currentPrice = (item['current_price'] ?? 0.0).toDouble();
            final marketPrice = (item['market_price'] ?? 0.0).toDouble();
            
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 120,
                    child: AppConfig.demoMode
                        ? ImageFiltered(
                            imageFilter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                            child: Text(
                              name,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
                        : Text(
                            name,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE57373).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _formatNumber(currentPrice),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE57373),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A237E).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _formatNumber(marketPrice),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A237E),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
  
  String _formatNumber(double number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toStringAsFixed(0);
  }
}
