import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../core/network/api_client.dart';
import '../core/payment/payment_service.dart';
import '../core/storage/token_storage.dart';
import '../features/authentication/data/auth_repository.dart';
import '../features/authentication/domain/auth_state.dart';
import '../features/authentication/presentation/controllers/auth_controller.dart';
import '../features/authentication/presentation/screens/onboarding_screen.dart';
import '../features/authentication/presentation/screens/registration_screen.dart';
import '../features/authentication/presentation/screens/sign_in_screen.dart';
import '../features/authentication/presentation/screens/verification_screen.dart';
import '../features/discovery/data/chef_repository.dart';
import '../features/discovery/domain/chef_summary.dart';
import '../features/discovery/presentation/discovery_controller.dart';
import '../features/discovery/presentation/discovery_screen.dart';
import '../features/menu/domain/menu_item.dart';
import '../features/menu/presentation/checkout_screen.dart';
import '../features/menu/presentation/menu_builder_controller.dart';
import '../features/menu/presentation/menu_builder_screen.dart';
import '../features/menu/presentation/schedule_picker_screen.dart';
import '../features/orders/data/order_realtime_service.dart';
import '../features/orders/data/order_repository.dart';
import '../features/orders/presentation/orders_controller.dart';
import '../features/orders/presentation/screens/orders_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../localization/app_localizations.dart';
import '../localization/localization_extension.dart';
import 'theme.dart';

class WeekendChefClientApp extends StatefulWidget {
  const WeekendChefClientApp({super.key});

  @override
  State<WeekendChefClientApp> createState() => _WeekendChefClientAppState();
}

class _WeekendChefClientAppState extends State<WeekendChefClientApp> {
  late final ApiClient _apiClient;
  late final TokenStorage _tokenStorage;
  late final AuthRepository _authRepository;
  late final AuthController _authController;
  late final ChefRepository _chefRepository;
  late final DiscoveryController _discoveryController;
  late final OrderRepository _orderRepository;
  late final OrderRealtimeService _realtimeService;
  late final OrdersController _ordersController;
  late final PaymentService _paymentService;

  @override
  void initState() {
    super.initState();
    _apiClient = ApiClient();
    _tokenStorage = TokenStorage();
    _authRepository = AuthRepository(_apiClient);
    _authController = AuthController(_authRepository, _tokenStorage);
    _chefRepository = ChefRepository(_apiClient);
    _discoveryController = DiscoveryController(_chefRepository, _authController);
    _orderRepository = OrderRepository(_apiClient);
    _realtimeService = OrderRealtimeService();
    _ordersController = OrdersController(_orderRepository, _realtimeService, _authController);
    _paymentService = PaymentService();
    _authController.bootstrap();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _authController,
      builder: (context, _) {
        final locale = _authController.state.locale;
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: buildAppTheme(),
          locale: locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.localizationsDelegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: RootShell(
            authController: _authController,
            discoveryController: _discoveryController,
            ordersController: _ordersController,
            paymentService: _paymentService,
          ),
        );
      },
    );
  }
}

class RootShell extends StatelessWidget {
  const RootShell({
    super.key,
    required this.authController,
    required this.discoveryController,
    required this.ordersController,
    required this.paymentService,
  });

  final AuthController authController;
  final DiscoveryController discoveryController;
  final OrdersController ordersController;
  final PaymentService paymentService;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: authController,
      builder: (context, _) {
        final state = authController.state;
        switch (state.status) {
          case AuthStatus.unknown:
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          case AuthStatus.unauthenticated:
            return AuthFlow(authController: authController);
          case AuthStatus.needsVerification:
            return VerificationScreen(
              controller: authController,
              initialPurpose: VerificationPurpose.email,
            );
          case AuthStatus.authenticated:
            return MainShell(
              authController: authController,
              discoveryController: discoveryController,
              ordersController: ordersController,
              paymentService: paymentService,
            );
        }
      },
    );
  }
}

class AuthFlow extends StatefulWidget {
  const AuthFlow({super.key, required this.authController});

  final AuthController authController;

  @override
  State<AuthFlow> createState() => _AuthFlowState();
}

enum _AuthPage { onboarding, signIn, register, verify }

class _AuthFlowState extends State<AuthFlow> {
  _AuthPage _page = _AuthPage.onboarding;

  @override
  Widget build(BuildContext context) {
    switch (_page) {
      case _AuthPage.onboarding:
        return OnboardingScreen(
          onCreateAccount: () => setState(() => _page = _AuthPage.register),
          onSignIn: () => setState(() => _page = _AuthPage.signIn),
        );
      case _AuthPage.signIn:
        return SignInScreen(
          controller: widget.authController,
          onBack: () => setState(() => _page = _AuthPage.onboarding),
        );
      case _AuthPage.register:
        return RegistrationScreen(
          controller: widget.authController,
          onBack: () => setState(() => _page = _AuthPage.onboarding),
        );
      case _AuthPage.verify:
        return VerificationScreen(controller: widget.authController, initialPurpose: VerificationPurpose.email);
    }
  }
}

class MainShell extends StatefulWidget {
  const MainShell({
    super.key,
    required this.authController,
    required this.discoveryController,
    required this.ordersController,
    required this.paymentService,
  });

  final AuthController authController;
  final DiscoveryController discoveryController;
  final OrdersController ordersController;
  final PaymentService paymentService;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final pages = [
      DiscoveryScreen(
        controller: widget.discoveryController,
        onMenuSelected: _onMenuSelected,
      ),
      OrdersScreen(controller: widget.ordersController, discoveryController: widget.discoveryController),
      ProfileScreen(authController: widget.authController),
    ];
    final titles = [
      l10n.translate('homeTab'),
      l10n.translate('ordersTab'),
      l10n.translate('profileTab'),
    ];
    return Scaffold(
      appBar: AppBar(title: Text(titles[_index])),
      body: pages[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (value) => setState(() => _index = value),
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.explore), label: l10n.translate('homeTab')),
          BottomNavigationBarItem(icon: const Icon(Icons.receipt_long), label: l10n.translate('ordersTab')),
          BottomNavigationBarItem(icon: const Icon(Icons.person), label: l10n.translate('profileTab')),
        ],
      ),
    );
  }

  void _onMenuSelected(ChefSummary chef, MenuItem item) {
    final controller = MenuBuilderController(item);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MenuBuilderScreen(
          controller: controller,
          onSchedule: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => SchedulePickerScreen(
                  controller: controller,
                  earliest: chef.nextAvailable,
                  onContinue: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CheckoutScreen(
                          controller: controller,
                          paymentService: widget.paymentService,
                          user: widget.authController.state.user!,
                          onComplete: () {
                            final messenger = ScaffoldMessenger.of(context);
                            Navigator.of(context)
                              ..pop()
                              ..pop()
                              ..pop();
                            messenger.showSnackBar(
                              SnackBar(content: Text(context.l10n.translate('orderConfirmed'))),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
