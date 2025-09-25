import 'package:flutter/material.dart';

import 'app/app.dart';
import 'core/services/app_state.dart';
import 'core/services/app_state_scope.dart';
import 'core/sample_data/sample_data.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final seedState = buildSampleAppState();
  runApp(
    AppStateScope(
      notifier: seedState,
      child: const WeekendChefDispatchApp(),
    ),
  );
}
