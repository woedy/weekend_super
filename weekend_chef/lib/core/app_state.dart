import 'package:flutter/material.dart';

import 'models/cook_profile.dart';
import 'models/dish.dart';
import 'models/order.dart';
import 'models/payout.dart';
import 'sample_data/sample_data.dart';

class AppState extends ChangeNotifier {
  AppState()
      : profile = SampleData.profile(),
        dishes = SampleData.dishes(),
        orders = SampleData.orders(),
        payouts = SampleData.payouts(),
        onboardingComplete = false,
        allServiceAreas = SampleData.serviceAreas(),
        allSpecialties = SampleData.specialties();

  CookProfile profile;
  List<Dish> dishes;
  List<CookOrder> orders;
  List<Payout> payouts;
  bool onboardingComplete;
  final List<String> allServiceAreas;
  final List<String> allSpecialties;

  void submitProfile(CookProfile updated) {
    profile = updated.copyWith(
      approvalStatus: ApprovalStatus.pending,
      approvalMessage: 'Documents sent. We will respond within 24 hours.',
      submittedAt: DateTime.now(),
    );
    onboardingComplete = true;
    notifyListeners();
  }

  void saveProfileDraft(CookProfile updated) {
    profile = updated;
    notifyListeners();
  }

  void setApprovalStatus(ApprovalStatus status, {String? message}) {
    profile = profile.copyWith(approvalStatus: status, approvalMessage: message);
    notifyListeners();
  }

  void updateServiceAreas(List<String> areas) {
    profile = profile.copyWith(serviceAreas: List<String>.from(areas));
    notifyListeners();
  }

  void updateSpecialties(List<String> specialties) {
    profile = profile.copyWith(specialties: List<String>.from(specialties));
    notifyListeners();
  }

  void addAvailabilityWindow(AvailabilityWindow window) {
    final availability = List<AvailabilityWindow>.from(profile.availability);
    if (!availability.contains(window)) {
      availability.add(window);
      availability.sort((a, b) => a.day.compareTo(b.day));
      profile = profile.copyWith(availability: availability);
      notifyListeners();
    }
  }

  void removeAvailabilityWindow(AvailabilityWindow window) {
    final availability = List<AvailabilityWindow>.from(profile.availability)
      ..removeWhere((entry) => entry == window);
    profile = profile.copyWith(availability: availability);
    notifyListeners();
  }

  void addDish(Dish dish) {
    dishes = <Dish>[...dishes, dish];
    dishes.sort((a, b) => a.name.compareTo(b.name));
    notifyListeners();
  }

  void updateDish(Dish dish) {
    dishes = dishes
        .map((existing) => existing.id == dish.id ? dish : existing)
        .toList(growable: false);
    notifyListeners();
  }

  void deleteDish(String id) {
    dishes = dishes.where((dish) => dish.id != id).toList(growable: false);
    notifyListeners();
  }

  void updateOrderStage(String orderId, OrderStage stage) {
    orders = orders
        .map((order) => order.id == orderId ? order.copyWith(stage: stage) : order)
        .toList(growable: false);
    notifyListeners();
  }

  void toggleReceipt(String orderId, bool value) {
    orders = orders
        .map((order) => order.id == orderId ? order.copyWith(receiptUploaded: value) : order)
        .toList(growable: false);
    notifyListeners();
  }

  void addOrderMessage(String orderId, OrderMessage message) {
    orders = orders.map((order) {
      if (order.id != orderId) return order;
      final updatedConversation = List<OrderMessage>.from(order.conversation)..add(message);
      return order.copyWith(conversation: updatedConversation);
    }).toList(growable: false);
    notifyListeners();
  }

  CookOrder findOrder(String id) {
    return orders.firstWhere(
      (order) => order.id == id,
      orElse: () => throw ArgumentError('Order with id $id not found'),
    );
  }

  EarningsBreakdown get earningsBreakdown {
    final pendingAdvances = orders
        .where((order) => order.stage == OrderStage.accepted || order.stage == OrderStage.cooking)
        .fold<double>(0, (sum, order) => sum + order.groceryAdvance);

    final pendingFinals = payouts
        .where((payout) => payout.status == PayoutStatus.pending)
        .fold<double>(0, (sum, payout) => sum + payout.amount);

    final released = payouts
        .where((payout) => payout.status == PayoutStatus.released)
        .fold<double>(0, (sum, payout) => sum + payout.amount);

    final platformFees = payouts.fold<double>(0, (sum, payout) => sum + payout.platformFee);

    return EarningsBreakdown(
      pendingAdvances: pendingAdvances,
      pendingFinals: pendingFinals,
      released: released,
      platformFees: platformFees,
    );
  }
}

class CookAppScope extends InheritedNotifier<AppState> {
  const CookAppScope({
    super.key,
    required AppState notifier,
    required Widget child,
  }) : super(notifier: notifier, child: child);

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<CookAppScope>();
    assert(scope != null, 'CookAppScope not found in context');
    return scope!.notifier!;
  }
}
