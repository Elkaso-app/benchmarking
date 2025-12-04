import 'package:flutter/material.dart';
import 'dart:math';
import '../models/invoice_data.dart';
import '../models/item_summary.dart';

class TopOverpayChart extends StatelessWidget {
  final List<ProcessingResult> results;

  const TopOverpayChart({
    super.key,
    required this.results,
  });

  List<ItemSavingPotential> _calculateTopOverpayItems() {
    final Map<String, List<InvoiceItem>> groupedItems = {};

    // Group items by description
    for (var result in results) {
      if (result.success && result.invoiceData != null) {
        for (var item in result.invoiceData!.items) {
          final key = item.description.trim().toLowerCase();
          groupedItems.putIfAbsent(key, () => []);
          groupedItems[key]!.add(item);
        }
      }
    }

    // Calculate total cost and potential savings
    final List<ItemSavingPotential> items = [];
    final random = Random();

    groupedItems.forEach((key, itemList) {
      double totalCost = 0;
      String originalDescription = itemList.first.description;
      String? unit;

      for (var item in itemList) {
        if (item.total != null) {
          totalCost += item.total!;
        }
        if (unit == null && item.unit != null) {
          unit = item.unit;
        }
      }

      if (totalCost > 0) {
        // Random saving between 3% and 9%
        final savingPercentage = 3.0 + random.nextDouble() * 6.0; // 3.0 to 9.0
        final savingAmount = totalCost * (savingPercentage / 100);

        items.add(ItemSavingPotential(
          description: originalDescription,
          totalCost: totalCost,
          savingPercentage: savingPercentage,
          savingAmount: savingAmount,
          unit: unit,
          occurrences: itemList.length,
        ));
      }
    });

    // Sort by total cost descending and take top 3
    items.sort((a, b) => b.totalCost.compareTo(a.totalCost));
    return items.take(3).toList();
  }

  @override
  Widget build(BuildContext context) {
    final topItems = _calculateTopOverpayItems();

    if (topItems.isEmpty) {
      return const SizedBox.shrink();
    }

    final totalSavings = topItems.fold<double>(
      0,
      (sum, item) => sum + item.savingAmount,
    );

    return Card(
      elevation: 4,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.orange.shade50,
              Colors.white,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with total savings
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade300, width: 2),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.savings,
                      size: 48,
                      color: Colors.orange.shade700,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Potential Savings',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${totalSavings.toStringAsFixed(2)} AED',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'From top 3 high-cost items',
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
                  Icon(
                    Icons.trending_down,
                    color: Colors.orange.shade700,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Top 3 Cost Optimization Opportunities',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Items with highest spending and saving potential',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),

              // Top 3 items
              ...topItems.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return _buildItemCard(context, item, index + 1);
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemCard(BuildContext context, ItemSavingPotential item, int rank) {
    final maxBarWidth = 400.0;
    final barWidth = maxBarWidth * (item.savingAmount / results.length);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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
          Row(
            children: [
              // Rank badge
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _getRankColor(rank),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '#$rank',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // Item name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.description,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${item.occurrences} occurrence(s)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Saving percentage badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green.shade300),
                ),
                child: Text(
                  '${item.savingPercentage.toStringAsFixed(1)}% off',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Cost info
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Spending',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      '${item.totalCost.toStringAsFixed(2)} AED',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward, color: Colors.grey[400]),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Potential Saving',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      '${item.savingAmount.toStringAsFixed(2)} AED',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Visual bar
          Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Container(
                height: 8,
                width: barWidth.clamp(0, maxBarWidth),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange.shade400, Colors.green.shade400],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber.shade600;
      case 2:
        return Colors.grey.shade400;
      case 3:
        return Colors.brown.shade400;
      default:
        return Colors.grey.shade600;
    }
  }
}

class ItemSavingPotential {
  final String description;
  final double totalCost;
  final double savingPercentage;
  final double savingAmount;
  final String? unit;
  final int occurrences;

  ItemSavingPotential({
    required this.description,
    required this.totalCost,
    required this.savingPercentage,
    required this.savingAmount,
    this.unit,
    required this.occurrences,
  });
}

