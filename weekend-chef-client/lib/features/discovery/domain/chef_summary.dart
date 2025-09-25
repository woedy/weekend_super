import 'package:collection/collection.dart';

import '../../menu/domain/menu_item.dart';

class ChefSummary {
  ChefSummary({
    required this.id,
    required this.displayName,
    required this.tagline,
    required this.cuisines,
    required this.dietaryTags,
    required this.locationName,
    required this.averageRating,
    required this.heroImage,
    required this.nextAvailable,
    required this.startingFrom,
    required this.groceryAdvanceEstimate,
    required this.menuItems,
  });

  final String id;
  final String displayName;
  final String tagline;
  final List<String> cuisines;
  final List<String> dietaryTags;
  final String locationName;
  final double averageRating;
  final String heroImage;
  final DateTime nextAvailable;
  final double startingFrom;
  final double groceryAdvanceEstimate;
  final List<MenuItem> menuItems;

  String get primaryCuisine => cuisines.isEmpty ? 'General' : cuisines.first;
  String get primaryDiet => dietaryTags.isEmpty ? 'all' : dietaryTags.first;

  MenuItem? findMenuItem(String id) => menuItems.firstWhereOrNull((item) => item.id == id);

  factory ChefSummary.fromJson(Map<String, dynamic> json) {
    final List<dynamic> cuisinesJson = json['cuisines'] as List<dynamic>? ?? const [];
    final List<dynamic> dietaryJson = json['dietaryTags'] as List<dynamic>? ?? const [];
    final List<dynamic> menuJson = json['menuItems'] as List<dynamic>? ?? const [];
    return ChefSummary(
      id: json['id']?.toString() ?? '',
      displayName: json['displayName']?.toString() ?? '',
      tagline: json['tagline']?.toString() ?? '',
      cuisines: cuisinesJson.map((e) => e.toString()).toList(),
      dietaryTags: dietaryJson.map((e) => e.toString()).toList(),
      locationName: json['locationName']?.toString() ?? '',
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0,
      heroImage: json['heroImage']?.toString() ?? '',
      nextAvailable: DateTime.tryParse(json['nextAvailable']?.toString() ?? '') ?? DateTime.now(),
      startingFrom: (json['startingFrom'] as num?)?.toDouble() ?? 0,
      groceryAdvanceEstimate: (json['groceryAdvanceEstimate'] as num?)?.toDouble() ?? 0,
      menuItems: menuJson
          .map((item) => MenuItem.fromJson(item as Map<String, dynamic>, chefId: json['id']?.toString() ?? ''))
          .toList(),
    );
  }
}
