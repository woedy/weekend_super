import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:weekend_chef_dispatch/app/app.dart';
import 'package:weekend_chef_dispatch/core/sample_data/sample_data.dart';
import 'package:weekend_chef_dispatch/core/services/app_state_scope.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Dispatch dashboard shows delivery queue and navigation targets', (tester) async {
    final state = buildSampleAppState();

    await tester.pumpWidget(
      AppStateScope(
        notifier: state,
        child: const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: WeekendChefDispatchApp(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Delivery queue'), findsOneWidget);
    expect(find.textContaining('Ready'), findsWidgets);

    await tester.tap(find.text('Comms'));
    await tester.pumpAndSettle();
    expect(find.text('Messages & incidents'), findsOneWidget);

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('My profile'), findsOneWidget);
  });
}
