import 'package:flutter/material.dart';

class PriceComparisonChart extends StatelessWidget {
  final Map<String, dynamic> costAnalysis;

  const PriceComparisonChart({
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
                          'Group Buying Savings',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${totalSavings.toStringAsFixed(2)} $currency',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Total saving from top 3 items',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
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
                  'Top 3 Overpaying Items',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Current Price vs Market Price Comparison',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Chart items
            ...topItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return _buildChartItem(context, item, index + 1, currency);
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildChartItem(
    BuildContext context, 
    Map<String, dynamic> item, 
    int rank,
    String currency,
  ) {
    final name = item['name'] ?? '';
    final currentPrice = (item['current_price'] ?? 0).toDouble();
    final marketPrice = (item['market_price'] ?? 0).toDouble();
    final savingAmount = (item['saving_amount'] ?? 0).toDouble();
    final discountPercent = (item['discount_percent'] ?? 0).toDouble();
    final occurrences = item['occurrences'] ?? 0;

    // Calculate bar widths (relative to current price)
    final maxWidth = 400.0;
    final currentBarWidth = maxWidth;
    final marketBarWidth = maxWidth * (marketPrice / currentPrice);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              // Rank badge
              Container(
                width: 40,
                height: 40,
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
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Item name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '$occurrences occurrence(s)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Discount badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${discountPercent.toStringAsFixed(1)}% off',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Price comparison chart
          Column(
            children: [
              // Current Price Bar
              _buildPriceBar(
                label: 'Current Price',
                price: currentPrice,
                barWidth: currentBarWidth,
                color: Colors.red.shade400,
                currency: currency,
              ),
              
              const SizedBox(height: 12),
              
              // Market Price Bar
              _buildPriceBar(
                label: 'Market Price',
                price: marketPrice,
                barWidth: marketBarWidth,
                color: Colors.green.shade400,
                currency: currency,
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Savings info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.trending_down, color: Colors.green.shade700),
                const SizedBox(width: 8),
                Text(
                  'Potential Saving: ${savingAmount.toStringAsFixed(2)} $currency',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceBar({
    required String label,
    required double price,
    required double barWidth,
    required Color color,
    required String currency,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Row(
            children: [
              Container(
                height: 32,
                width: barWidth.clamp(0, 400),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 8),
                child: Text(
                  '${price.toStringAsFixed(2)} $currency',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
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

