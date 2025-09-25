import 'package:flutter/material.dart';
import '../core/services/app_state.dart';
import '../core/services/app_state_scope.dart';
import '../features/assignments/presentation/assignment_dashboard.dart';
import '../features/communications/presentation/communications_center.dart';
import '../features/profile/presentation/profile_screen.dart';
import 'theme.dart';

class WeekendChefDispatchApp extends StatelessWidget {
  const WeekendChefDispatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Weekend Chef Dispatch',
      theme: buildTheme(),
      home: const _RootShell(),
    );
  }
}

class _RootShell extends StatefulWidget {
  const _RootShell();

  @override
  State<_RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<_RootShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final destinations = [
      const AssignmentDashboard(),
      CommunicationsCenter(threads: appState.chatThreads),
      ProfileScreen(dispatcher: appState.dispatcherProfile),
    ];

    return Scaffold(
      body: SafeArea(child: destinations[_currentIndex]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.assignment_turned_in_outlined),
            selectedIcon: Icon(Icons.assignment_turned_in),
            label: 'Assignments',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_outlined),
            selectedIcon: Icon(Icons.chat_bubble),
            label: 'Comms',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
      ),
    );
  }
}
