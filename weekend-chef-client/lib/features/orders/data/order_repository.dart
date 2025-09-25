import '../../../core/network/api_client.dart';
import '../../../core/network/network_exceptions.dart';
import '../../../core/sample_data/sample_data_loader.dart';
import '../domain/order_models.dart';

class OrderRepository {
  OrderRepository(this._apiClient, {SampleDataLoader? sampleDataLoader})
      : _sampleDataLoader = sampleDataLoader ?? const SampleDataLoader();

  final ApiClient _apiClient;
  final SampleDataLoader _sampleDataLoader;

  Future<List<OrderSummary>> fetchOrders(String token) async {
    try {
      final response = await _apiClient.get('orders/api/v2/orders/', token: token);
      final List<dynamic> results;
      if (response is List) {
        results = response;
      } else if (response is Map<String, dynamic>) {
        results = response['results'] as List<dynamic>? ?? const [];
      } else {
        results = const [];
      }
      if (results.isNotEmpty) {
        return results.map((e) => OrderSummary.fromJson(e as Map<String, dynamic>)).toList();
      }
    } on ApiException {
      // fall back to sample data
    }
    final local = await _sampleDataLoader.loadJson('order_timeline.json');
    final List<dynamic> orders = local['orders'] as List<dynamic>? ?? const [];
    return orders.map((e) => OrderSummary.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> confirmDelivery(String orderId, {required String token}) async {
    try {
      await _apiClient.post('orders/api/v2/orders/$orderId/status/', token: token, body: {'status': 'completed'});
    } on ApiException {
      rethrow;
    }
  }

  Future<void> reportIssue({
    required String orderId,
    required String description,
    required String token,
  }) async {
    try {
      await _apiClient.post('complaints/api/v2/disputes/', token: token, body: {'order': orderId, 'description': description});
    } on ApiException {
      rethrow;
    }
  }

  Future<void> submitRating({
    required String orderId,
    required int rating,
    required String? report,
    required String token,
  }) async {
    try {
      await _apiClient.post('orders/api/v2/orders/$orderId/rating/', token: token, body: {
        'rating': rating,
        if (report != null && report.isNotEmpty) 'report': report,
      });
    } on ApiException {
      rethrow;
    }
  }
}
