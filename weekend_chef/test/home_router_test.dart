import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:weekend_chef/app/app.dart';
import 'package:weekend_chef/app/theme.dart';
import 'package:weekend_chef/core/app_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Cook home router gates onboarding until completed', (tester) async {
    final state = AppState();

    await tester.pumpWidget(
      CookAppScope(
        notifier: state,
        child: const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: CookHomeRouter(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Get verified to cook'), findsOneWidget);
  });

  testWidgets('Cook app navigation switches between primary destinations', (tester) async {
    final state = AppState()..onboardingComplete = true;

    await tester.pumpWidget(
      CookAppScope(
        notifier: state,
        child: MaterialApp(
          theme: buildCookTheme(),
          home: const CookHomeRouter(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Menu & inventory'), findsNothing);

    await tester.tap(find.text('Menu'));
    await tester.pumpAndSettle();
    expect(find.text('Menu & inventory'), findsOneWidget);

    await tester.tap(find.text('Earnings'));
    await tester.pumpAndSettle();
    expect(find.text('Earnings dashboard'), findsOneWidget);

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('Cook profile'), findsOneWidget);
  });
}
