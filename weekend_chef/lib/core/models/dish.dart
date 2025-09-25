class Dish {
  const Dish({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.suggestedPrice,
    required this.leadTimeMinutes,
    required this.ingredients,
    required this.inventory,
    required this.lowStockThreshold,
    required this.reorderRate,
    this.isPublished = true,
  });

  final String id;
  final String name;
  final String description;
  final double price;
  final double suggestedPrice;
  final int leadTimeMinutes;
  final List<String> ingredients;
  final int inventory;
  final int lowStockThreshold;
  final double reorderRate;
  final bool isPublished;

  bool get isLowStock => inventory <= lowStockThreshold;

  Dish copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    double? suggestedPrice,
    int? leadTimeMinutes,
    List<String>? ingredients,
    int? inventory,
    int? lowStockThreshold,
    double? reorderRate,
    bool? isPublished,
  }) {
    return Dish(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      suggestedPrice: suggestedPrice ?? this.suggestedPrice,
      leadTimeMinutes: leadTimeMinutes ?? this.leadTimeMinutes,
      ingredients: ingredients ?? List<String>.from(this.ingredients),
      inventory: inventory ?? this.inventory,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      reorderRate: reorderRate ?? this.reorderRate,
      isPublished: isPublished ?? this.isPublished,
    );
  }
}
