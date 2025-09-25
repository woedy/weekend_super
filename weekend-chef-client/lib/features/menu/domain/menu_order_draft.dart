import 'package:flutter/material.dart';

import 'menu_item.dart';

class MenuOrderDraft {
  MenuOrderDraft({required this.item})
      : selectedPortion = item.portions.isNotEmpty ? item.portions.first : null,
        selectedAddons = <MenuAddonOption>{},
        quantity = 1;

  final MenuItem item;
  MenuPortionOption? selectedPortion;
  final Set<MenuAddonOption> selectedAddons;
  int quantity;
  DateTime? deliveryDate;
  TimeOfDay? deliveryTime;

  double get portionPrice => (selectedPortion?.price ?? 0) * quantity;

  double get addonsPrice =>
      selectedAddons.fold<double>(0, (previousValue, addon) => previousValue + (addon.price * quantity));

  double get subtotal => portionPrice + addonsPrice;

  double get groceryAdvance => item.groceryAdvance * quantity;

  double get platformFee => item.platformFee;

  double get totalDueToday => groceryAdvance + platformFee;

  double get remainingBalance => (subtotal - groceryAdvance).clamp(0, double.infinity);

  bool get isScheduled => deliveryDate != null && deliveryTime != null;

  MenuOrderDraft copyWith({
    MenuPortionOption? portion,
    Set<MenuAddonOption>? addons,
    int? quantity,
    DateTime? deliveryDate,
    TimeOfDay? deliveryTime,
  }) {
    final draft = MenuOrderDraft(item: item);
    draft.selectedPortion = portion ?? selectedPortion;
    draft.selectedAddons
      ..clear()
      ..addAll(addons ?? selectedAddons);
    draft.quantity = quantity ?? this.quantity;
    draft.deliveryDate = deliveryDate ?? this.deliveryDate;
    draft.deliveryTime = deliveryTime ?? this.deliveryTime;
    return draft;
  }
}
