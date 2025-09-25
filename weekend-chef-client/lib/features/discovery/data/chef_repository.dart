import '../../../core/network/api_client.dart';
import '../../../core/network/network_exceptions.dart';
import '../../../core/sample_data/sample_data_loader.dart';
import '../../menu/domain/menu_item.dart';
import '../domain/chef_summary.dart';

class ChefRepository {
  ChefRepository(this._apiClient, {SampleDataLoader? sampleDataLoader})
      : _sampleDataLoader = sampleDataLoader ?? const SampleDataLoader();

  final ApiClient _apiClient;
  final SampleDataLoader _sampleDataLoader;

  Future<List<ChefSummary>> fetchFeaturedChefs({String? token}) async {
    try {
      final response = await _apiClient.get('client/discovery/recommendations/', token: token);
      final data = _normalizeResponse(response);
      if (data.isNotEmpty) {
        return data;
      }
    } on ApiException {
      // fall back to local data
    }
    final local = await _sampleDataLoader.loadJson('recommended_cooks.json');
    final List<dynamic> chefs = local['chefs'] as List<dynamic>? ?? const [];
    return chefs
        .map((e) => ChefSummary.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<MenuItem?> fetchMenuItem(String chefId, String menuItemId, {String? token}) async {
    try {
      final response = await _apiClient.get(
        'chef/api/v2/menu-items/',
        queryParameters: {'chef': chefId},
        token: token,
      );
      final List<dynamic> results = response is List ? response : (response['results'] as List<dynamic>? ?? const []);
      for (final item in results) {
        final Map<String, dynamic> map = item as Map<String, dynamic>;
        if (map['id'].toString() == menuItemId) {
          return MenuItem.fromJson(map, chefId: chefId);
        }
      }
    } on ApiException {
      // ignore and fall back
    }
    final local = await _sampleDataLoader.loadJson('recommended_cooks.json');
    final List<dynamic> chefs = local['chefs'] as List<dynamic>? ?? const [];
    for (final entry in chefs) {
      final chef = ChefSummary.fromJson(entry as Map<String, dynamic>);
      final menuItem = chef.findMenuItem(menuItemId);
      if (menuItem != null) {
        return menuItem;
      }
    }
    return null;
  }

  List<ChefSummary> _normalizeResponse(dynamic response) {
    if (response == null) {
      return const [];
    }
    if (response is List) {
      return response
          .map((e) => ChefSummary.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    if (response is Map<String, dynamic>) {
      final List<dynamic> results = response['results'] as List<dynamic>? ?? response['chefs'] as List<dynamic>? ?? const [];
      return results
          .map((e) => ChefSummary.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return const [];
  }
}
