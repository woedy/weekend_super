import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _bootstrapWithSentry(const WeekendChefCookApp());
}

Future<void> _bootstrapWithSentry(Widget app) async {
  const dsn = String.fromEnvironment('SENTRY_DSN', defaultValue: '');
  if (dsn.isEmpty) {
    runApp(app);
    return;
  }

  final environment = const String.fromEnvironment('SENTRY_ENVIRONMENT', defaultValue: 'development');
  final tracesSampleRate = double.tryParse(
        const String.fromEnvironment('SENTRY_TRACES_SAMPLE_RATE', defaultValue: '0.1'),
      ) ??
      0.1;

  await SentryFlutter.init(
    (options) {
      options.dsn = dsn;
      options.environment = environment;
      options.tracesSampleRate = tracesSampleRate;
    },
    appRunner: () => runApp(app),
  );
}
