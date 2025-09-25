import 'package:flutter/material.dart';

import '../domain/menu_item.dart';
import '../domain/menu_order_draft.dart';

class MenuBuilderController extends ChangeNotifier {
  MenuBuilderController(MenuItem item) : draft = MenuOrderDraft(item: item);

  MenuOrderDraft draft;

  void selectPortion(MenuPortionOption option) {
    draft.selectedPortion = option;
    notifyListeners();
  }

  void toggleAddon(MenuAddonOption addon) {
    if (draft.selectedAddons.contains(addon)) {
      draft.selectedAddons.remove(addon);
    } else {
      draft.selectedAddons.add(addon);
    }
    notifyListeners();
  }

  void setQuantity(int quantity) {
    draft.quantity = quantity.clamp(1, 20);
    notifyListeners();
  }

  void incrementQuantity() {
    setQuantity(draft.quantity + 1);
  }

  void decrementQuantity() {
    setQuantity(draft.quantity - 1);
  }

  void schedule(DateTime date, TimeOfDay time) {
    draft.deliveryDate = date;
    draft.deliveryTime = time;
    notifyListeners();
  }

  void clearSchedule() {
    draft.deliveryDate = null;
    draft.deliveryTime = null;
    notifyListeners();
  }
}
