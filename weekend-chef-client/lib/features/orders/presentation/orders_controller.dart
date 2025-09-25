import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/network/network_exceptions.dart';
import '../../authentication/presentation/controllers/auth_controller.dart';
import '../data/order_realtime_service.dart';
import '../data/order_repository.dart';
import '../domain/order_models.dart';

class OrdersController extends ChangeNotifier {
  OrdersController(this._repository, this._realtimeService, this._authController);

  final OrderRepository _repository;
  final OrderRealtimeService _realtimeService;
  final AuthController _authController;

  List<OrderSummary> _orders = const [];
  OrderSummary? _selected;
  bool _loading = false;
  String? _error;
  StreamSubscription<OrderStatusUpdate>? _subscription;
  String? _activeOrderId;

  List<OrderSummary> get orders => _orders;
  OrderSummary? get selected => _selected;
  bool get isLoading => _loading;
  String? get error => _error;

  Future<void> load() async {
    final token = _authController.state.token;
    if (token == null) return;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _orders = await _repository.fetchOrders(token);
    } on ApiException catch (error) {
      _error = error.message;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void selectOrder(OrderSummary order) {
    _selected = order;
    _subscription?.cancel();
    if (_activeOrderId != null && _activeOrderId != order.orderId) {
      _realtimeService.disconnect(_activeOrderId!);
    }
    _subscription = _realtimeService.stream.listen((update) {
      _applyUpdate(order.orderId, update);
    });
    _realtimeService.connect(order.orderId);
    _activeOrderId = order.orderId;
    notifyListeners();
  }

  void _applyUpdate(String orderId, OrderStatusUpdate update) {
    final index = _orders.indexWhere((element) => element.orderId == orderId);
    if (index == -1) return;
    final order = _orders[index];
    final timeline = List<OrderStatusUpdate>.from(order.timeline)..insert(0, update);
    final updated = OrderSummary(
      orderId: order.orderId,
      chefId: order.chefId,
      menuItemId: order.menuItemId,
      status: update.status,
      total: order.total,
      groceryAdvance: order.groceryAdvance,
      remainingBalance: order.remainingBalance,
      timeline: timeline,
    );
    _orders = List<OrderSummary>.from(_orders)..[index] = updated;
    if (_selected?.orderId == orderId) {
      _selected = updated;
    }
    notifyListeners();
  }

  Future<void> confirmDelivery(String orderId) async {
    final token = _authController.state.token;
    if (token == null) return;
    try {
      await _repository.confirmDelivery(orderId, token: token);
    } on ApiException catch (error) {
      _error = error.message;
      notifyListeners();
    }
  }

  Future<void> reportIssue(String orderId, String description) async {
    final token = _authController.state.token;
    if (token == null) return;
    try {
      await _repository.reportIssue(orderId: orderId, description: description, token: token);
    } on ApiException catch (error) {
      _error = error.message;
      notifyListeners();
    }
  }

  Future<void> submitRating(String orderId, int rating, {String? report}) async {
    final token = _authController.state.token;
    if (token == null) return;
    try {
      await _repository.submitRating(orderId: orderId, rating: rating, report: report, token: token);
    } on ApiException catch (error) {
      _error = error.message;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    if (_activeOrderId != null) {
      _realtimeService.disconnect(_activeOrderId!);
    }
    super.dispose();
  }
}
