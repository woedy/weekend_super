import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:weekend_chef_client/core/network/api_client.dart';
import 'package:weekend_chef_client/core/storage/token_storage.dart';
import 'package:weekend_chef_client/features/authentication/data/auth_repository.dart';
import 'package:weekend_chef_client/features/authentication/domain/auth_state.dart';
import 'package:weekend_chef_client/features/authentication/domain/user_profile.dart';
import 'package:weekend_chef_client/features/authentication/presentation/controllers/auth_controller.dart';
import 'package:weekend_chef_client/features/discovery/data/chef_repository.dart';
import 'package:weekend_chef_client/features/discovery/domain/chef_summary.dart';
import 'package:weekend_chef_client/features/discovery/presentation/discovery_controller.dart';
import 'package:weekend_chef_client/features/discovery/presentation/discovery_screen.dart';
import 'package:weekend_chef_client/features/menu/domain/menu_item.dart';
import 'package:weekend_chef_client/features/orders/data/order_repository.dart';
import 'package:weekend_chef_client/features/orders/data/order_realtime_service.dart';
import 'package:weekend_chef_client/features/orders/domain/order_models.dart';
import 'package:weekend_chef_client/features/orders/presentation/orders_controller.dart';
import 'package:weekend_chef_client/features/orders/presentation/screens/orders_screen.dart';
import 'package:weekend_chef_client/features/profile/presentation/profile_screen.dart';
import 'package:weekend_chef_client/localization/app_localizations.dart';

class _StubAuthRepository extends AuthRepository {
  _StubAuthRepository(this._profile) : super(ApiClient());

  final UserProfile _profile;

  @override
  Future<(UserProfile user, String token)> login({
    required String email,
    required String password,
  }) async => (_profile, 'token-123');

  @override
  Future<(UserProfile user, String token)> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
    required String role,
  }) async => (_profile, 'token-123');

  @override
  Future<UserProfile> fetchProfile(String token) async => _profile;

  @override
  Future<void> requestVerification({required String token, required VerificationPurpose purpose}) async {}

  @override
  Future<UserProfile> verifyCode({
    required String token,
    required VerificationPurpose purpose,
    required String code,
  }) async => _profile;

  @override
  Future<void> resendPhoneCode(String token) async {}
}

class _InMemoryTokenStorage extends TokenStorage {
  _InMemoryTokenStorage({String? token, String? locale})
      : _token = token,
        _locale = locale;

  String? _token;
  String? _locale;

  @override
  Future<String?> readToken() async => _token;

  @override
  Future<void> writeToken(String token) async => _token = token;

  @override
  Future<void> clearToken() async => _token = null;

  @override
  Future<void> saveLocale(String languageCode) async => _locale = languageCode;

  @override
  Future<String?> readLocale() async => _locale;
}

class _StubChefRepository extends ChefRepository {
  _StubChefRepository(this._chefs) : super(ApiClient());

  final List<ChefSummary> _chefs;

  @override
  Future<List<ChefSummary>> fetchFeaturedChefs({String? token}) async => _chefs;

  @override
  Future<MenuItem?> fetchMenuItem(String chefId, String menuItemId, {String? token}) async {
    return _chefs
        .firstWhere((chef) => chef.id == chefId)
        .menuItems
        .firstWhere((item) => item.id == menuItemId, orElse: () => _chefs.first.menuItems.first);
  }
}

class _StubOrderRepository extends OrderRepository {
  _StubOrderRepository(this._orders) : super(ApiClient());

  final List<OrderSummary> _orders;

  @override
  Future<List<OrderSummary>> fetchOrders(String token) async => _orders;

  @override
  Future<void> confirmDelivery(String orderId, {required String token}) async {}

  @override
  Future<void> reportIssue({required String orderId, required String description, required String token}) async {}

  @override
  Future<void> submitRating({
    required String orderId,
    required int rating,
    required String? report,
    required String token,
  }) async {}
}

class _SilentRealtimeService extends OrderRealtimeService {
  _SilentRealtimeService() : super();

  final StreamController<OrderStatusUpdate> _controller = StreamController.broadcast();

  @override
  Stream<OrderStatusUpdate> get stream => _controller.stream;

  @override
  Future<void> connect(String orderRoom) async {}

  @override
  Future<void> disconnect(String orderRoom) async {}

  void shutdown() {
    _controller.close();
  }
}

Future<_TestHarness> _buildHarness() async {
  final user = UserProfile(
    id: 'user-1',
    firstName: 'Ada',
    lastName: 'Lovelace',
    email: 'ada@example.com',
    phone: '+15551234567',
    role: 'Client',
    emailVerified: true,
    phoneVerified: true,
  );

  final authRepository = _StubAuthRepository(user);
  final tokenStorage = _InMemoryTokenStorage(token: 'token-123', locale: 'en');
  final authController = AuthController(authRepository, tokenStorage);
  await authController.bootstrap();

  final menuItem = MenuItem(
    id: 'menu-1',
    chefId: 'chef-1',
    name: 'Signature Pasta',
    description: 'House made pasta with roasted tomatoes.',
    photo: '',
    portions: const [
      MenuPortionOption(id: 'portion-regular', label: 'Regular', price: 24),
    ],
    addons: const [],
    groceryAdvance: 10,
    platformFee: 3,
    dietary: const ['Vegetarian'],
  );

  final chef = ChefSummary(
    id: 'chef-1',
    displayName: 'Chef Ada',
    tagline: 'Elegant computing cuisine',
    cuisines: ['Fusion'],
    dietaryTags: ['Vegetarian'],
    locationName: 'Downtown',
    averageRating: 4.9,
    heroImage: '',
    nextAvailable: DateTime.now().add(const Duration(days: 1)),
    startingFrom: 24,
    groceryAdvanceEstimate: 12,
    menuItems: [menuItem],
  );

  final discoveryController = DiscoveryController(_StubChefRepository([chef]), authController);

  final orders = [
    OrderSummary(
      orderId: 'ORDER-1',
      chefId: chef.id,
      menuItemId: menuItem.id,
      status: 'pending',
      total: 120,
      groceryAdvance: 40,
      remainingBalance: 80,
      timeline: [OrderStatusUpdate(status: 'pending', changedAt: DateTime.now())],
    ),
  ];
  final realtimeService = _SilentRealtimeService();
  final ordersController = OrdersController(
    _StubOrderRepository(orders),
    realtimeService,
    authController,
  );

  return _TestHarness(
    authController: authController,
    discoveryController: discoveryController,
    ordersController: ordersController,
    chef: chef,
    menuItem: menuItem,
    realtimeService: realtimeService,
  );
}

class _TestHarness {
  _TestHarness({
    required this.authController,
    required this.discoveryController,
    required this.ordersController,
    required this.chef,
    required this.menuItem,
    required this.realtimeService,
  });

  final AuthController authController;
  final DiscoveryController discoveryController;
  final OrdersController ordersController;
  final ChefSummary chef;
  final MenuItem menuItem;
  final _SilentRealtimeService realtimeService;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _TestHarness harness;

  setUpAll(() async {
    harness = await _buildHarness();
  });

  tearDownAll(() {
    harness.authController.dispose();
    harness.discoveryController.dispose();
    harness.ordersController.dispose();
    harness.realtimeService.shutdown();
  });

  Widget _buildApp(Widget home) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.localizationsDelegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
    );
  }

  testWidgets('Discovery screen renders chefs and recommended menu items', (tester) async {
    await tester.pumpWidget(
      _buildApp(
        DiscoveryScreen(
          controller: harness.discoveryController,
          onMenuSelected: (_, __) {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Chef Ada'), findsOneWidget);
    expect(find.textContaining('Elegant computing cuisine'), findsOneWidget);
    expect(find.text('Signature Pasta'), findsOneWidget);
    expect(find.text('Fusion'), findsWidgets);
  });

  testWidgets('Orders screen lists status timeline with translations', (tester) async {
    await tester.pumpWidget(
      _buildApp(
        OrdersScreen(
          controller: harness.ordersController,
          discoveryController: harness.discoveryController,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Signature Pasta'), findsOneWidget);
    expect(find.textContaining('Status timeline: Pending'), findsOneWidget);
  });

  testWidgets('Profile screen shows verification and localization controls', (tester) async {
    await tester.pumpWidget(
      _buildApp(
        ProfileScreen(authController: harness.authController),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Hi Ada'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('Sign out'), findsOneWidget);
  });
}
