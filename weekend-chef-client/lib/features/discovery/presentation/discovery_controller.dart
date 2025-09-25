import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

import '../../../authentication/presentation/controllers/auth_controller.dart';
import '../../menu/domain/menu_item.dart';
import '../data/chef_repository.dart';
import '../domain/chef_summary.dart';

class DiscoveryController extends ChangeNotifier {
  DiscoveryController(this._repository, this._authController);

  final ChefRepository _repository;
  final AuthController _authController;

  List<ChefSummary> _chefs = const [];
  List<ChefSummary> _filtered = const [];
  bool _isLoading = false;
  bool _offlineFallback = false;
  String? _selectedCuisine;
  String? _selectedDiet;
  String? _selectedLocation;

  List<ChefSummary> get chefs => _filtered;
  bool get isLoading => _isLoading;
  bool get offlineFallback => _offlineFallback;
  String? get selectedCuisine => _selectedCuisine;
  String? get selectedDiet => _selectedDiet;
  String? get selectedLocation => _selectedLocation;

  Iterable<String> get cuisines => _chefs.expand((chef) => chef.cuisines).toSet()..removeWhere((element) => element.isEmpty);
  Iterable<String> get diets => _chefs.expand((chef) => chef.dietaryTags).toSet()..removeWhere((element) => element.isEmpty);
  Iterable<String> get locations => _chefs.map((chef) => chef.locationName).where((name) => name.isNotEmpty).toSet();

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();
    try {
      final token = _authController.state.token;
      final chefs = await _repository.fetchFeaturedChefs(token: token);
      _chefs = chefs;
      _offlineFallback = chefs.isEmpty;
      _applyFilters();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectCuisine(String? cuisine) {
    _selectedCuisine = cuisine == _selectedCuisine ? null : cuisine;
    _applyFilters();
  }

  void selectDiet(String? diet) {
    _selectedDiet = diet == _selectedDiet ? null : diet;
    _applyFilters();
  }

  void selectLocation(String? location) {
    _selectedLocation = location == _selectedLocation ? null : location;
    _applyFilters();
  }

  void clearFilters() {
    _selectedCuisine = null;
    _selectedDiet = null;
    _selectedLocation = null;
    _applyFilters();
  }

  MenuItem? findMenuItem(String chefId, String menuItemId) {
    final chef = _chefs.firstWhereOrNull((element) => element.id == chefId);
    return chef?.findMenuItem(menuItemId);
  }

  Future<MenuItem?> fetchMenuItem(String chefId, String menuItemId) {
    final token = _authController.state.token;
    return _repository.fetchMenuItem(chefId, menuItemId, token: token);
  }

  void _applyFilters() {
    _filtered = _chefs.where((chef) {
      final matchesCuisine = _selectedCuisine == null || chef.cuisines.contains(_selectedCuisine);
      final matchesDiet = _selectedDiet == null || chef.dietaryTags.contains(_selectedDiet);
      final matchesLocation = _selectedLocation == null || chef.locationName == _selectedLocation;
      return matchesCuisine && matchesDiet && matchesLocation;
    }).toList();
    notifyListeners();
  }
}
