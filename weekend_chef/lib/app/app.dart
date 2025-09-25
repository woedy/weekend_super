import 'package:flutter/material.dart';

import '../core/app_state.dart';
import '../features/earnings/earnings_screen.dart';
import '../features/menu/menu_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/orders/order_detail_screen.dart';
import '../features/orders/orders_screen.dart';
import '../features/profile/profile_screen.dart';
import 'theme.dart';

class WeekendChefCookApp extends StatefulWidget {
  const WeekendChefCookApp({super.key});

  @override
  State<WeekendChefCookApp> createState() => _WeekendChefCookAppState();
}

class _WeekendChefCookAppState extends State<WeekendChefCookApp> {
  late final AppState _state;

  @override
  void initState() {
    super.initState();
    _state = AppState();
  }

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CookAppScope(
      notifier: _state,
      child: MaterialApp(
        title: 'Weekend Chef — Cook',
        debugShowCheckedModeBanner: false,
        theme: buildCookTheme(),
        home: const CookHomeRouter(),
      ),
    );
  }
}

class CookHomeRouter extends StatefulWidget {
  const CookHomeRouter({super.key});

  @override
  State<CookHomeRouter> createState() => _CookHomeRouterState();
}

class _CookHomeRouterState extends State<CookHomeRouter> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final state = CookAppScope.of(context);
    if (!state.onboardingComplete) {
      return const OnboardingScreen();
    }

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          OrdersScreen(
            onViewOrder: (order) {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => OrderDetailScreen(orderId: order.id),
                ),
              );
            },
          ),
          MenuScreen(
            onCreateDish: (dish) => state.addDish(dish),
            onUpdateDish: state.updateDish,
            onDeleteDish: state.deleteDish,
          ),
          const EarningsScreen(),
          ProfileScreen(
            onEditVerification: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const OnboardingScreen(isEditing: true),
                ),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.event_available_outlined),
            selectedIcon: Icon(Icons.event_available),
            label: 'Orders',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Menu',
          ),
          NavigationDestination(
            icon: Icon(Icons.payments_outlined),
            selectedIcon: Icon(Icons.payments),
            label: 'Earnings',
          ),
          NavigationDestination(
            icon: Icon(Icons.verified_user_outlined),
            selectedIcon: Icon(Icons.verified_user),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
