/// Summary model for aggregated items
class ItemSummary {
  final String description;
  final double totalQuantity;
  final String? unit;
  final double minPrice;
  final double maxPrice;
  final int occurrences;

  ItemSummary({
    required this.description,
    required this.totalQuantity,
    this.unit,
    required this.minPrice,
    required this.maxPrice,
    required this.occurrences,
  });

  String get priceRange {
    if (minPrice == maxPrice) {
      return minPrice.toStringAsFixed(2);
    }
    return '[${minPrice.toStringAsFixed(2)}, ${maxPrice.toStringAsFixed(2)}]';
  }
}


