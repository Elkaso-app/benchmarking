import 'package:flutter/material.dart';

class KpiCards extends StatelessWidget {
  final Map<String, dynamic> costAnalysis;

  const KpiCards({super.key, required this.costAnalysis});

  @override
  Widget build(BuildContext context) {
    final totalSavings = costAnalysis['total_savings'] ?? 0;
    final numItemsWithReduction = costAnalysis['num_items_with_cost_reduction'] ?? 0;
    final percentCostReduction = costAnalysis['cost_reduction_percent'] ?? 0;
    final percentOverpaid = costAnalysis['percent_overpaid'] ?? 0;
    final currency = costAnalysis['currency'] ?? 'AED';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF059669), // Emerald green
            Color(0xFF10B981), // Green
            Color(0xFF34D399), // Light green
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text(
            'Overview',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          
          // KPI Cards Row - 4 cards to match design
          Row(
            children: [
              Expanded(
                child: _buildKpiCard(
                  label: '# of Items with % Cost reduction',
                  value: '$numItemsWithReduction',
                  unit: '',
                  subtext: 'items identified',
                  icon: Icons.inventory_2,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildKpiCard(
                  label: 'Potential Monthly Savings',
                  value: '${_formatNumber(totalSavings)}',
                  unit: currency,
                  subtext: 'total savings opportunity',
                  icon: Icons.savings,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildKpiCard(
                  label: 'x % of overpaid items',
                  value: '${percentOverpaid.toStringAsFixed(1)}%',
                  unit: '',
                  subtext: 'of items analyzed',
                  icon: Icons.trending_down,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildKpiCard(
                  label: '% Cost Reduction',
                  value: '${percentCostReduction.toStringAsFixed(1)}%',
                  unit: '',
                  subtext: 'potential savings',
                  icon: Icons.percent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKpiCard({
    required String label,
    required String value,
    required String unit,
    required String subtext,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label and Icon
          Row(
            children: [
              Icon(icon, color: const Color(0xFF059669), size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Big Number in Green
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFD1FAE5), // Light green/mint background
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF047857), // Dark green for better contrast
                  ),
                ),
                if (unit.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 4),
                    child: Text(
                      unit,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF059669), // Emerald green
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          
          // Subtext
          Text(
            subtext,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(double number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toStringAsFixed(0);
  }
}

