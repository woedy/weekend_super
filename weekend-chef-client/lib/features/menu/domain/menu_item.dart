class MenuPortionOption {
  const MenuPortionOption({
    required this.id,
    required this.label,
    required this.price,
  });

  final String id;
  final String label;
  final double price;

  factory MenuPortionOption.fromJson(Map<String, dynamic> json) {
    return MenuPortionOption(
      id: json['id']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
    );
  }
}

class MenuAddonOption {
  const MenuAddonOption({
    required this.id,
    required this.label,
    required this.price,
  });

  final String id;
  final String label;
  final double price;

  factory MenuAddonOption.fromJson(Map<String, dynamic> json) {
    return MenuAddonOption(
      id: json['id']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
    );
  }
}

class MenuItem {
  MenuItem({
    required this.id,
    required this.chefId,
    required this.name,
    required this.description,
    required this.photo,
    required this.portions,
    required this.addons,
    required this.groceryAdvance,
    required this.platformFee,
    required this.dietary,
  });

  final String id;
  final String chefId;
  final String name;
  final String description;
  final String photo;
  final List<MenuPortionOption> portions;
  final List<MenuAddonOption> addons;
  final double groceryAdvance;
  final double platformFee;
  final List<String> dietary;

  double get minimumPrice => portions.isEmpty ? 0 : portions.map((portion) => portion.price).reduce((a, b) => a < b ? a : b);

  factory MenuItem.fromJson(Map<String, dynamic> json, {required String chefId}) {
    final List<dynamic> portionsJson = json['basePortions'] as List<dynamic>? ?? const [];
    final List<dynamic> addonsJson = json['addons'] as List<dynamic>? ?? const [];
    return MenuItem(
      id: json['id']?.toString() ?? '',
      chefId: chefId,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      photo: json['photo']?.toString() ?? '',
      portions: portionsJson.map((e) => MenuPortionOption.fromJson(e as Map<String, dynamic>)).toList(),
      addons: addonsJson.map((e) => MenuAddonOption.fromJson(e as Map<String, dynamic>)).toList(),
      groceryAdvance: (json['groceryAdvance'] as num?)?.toDouble() ?? 0,
      platformFee: (json['platformFee'] as num?)?.toDouble() ?? 0,
      dietary: (json['dietary'] as List<dynamic>? ?? const []).map((e) => e.toString()).toList(),
    );
  }
}
