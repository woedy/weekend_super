import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;
  Map<String, dynamic> _localizedValues = <String, dynamic>{};

  static const supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  static const localizationsDelegate = _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    final AppLocalizations? result = Localizations.of<AppLocalizations>(context, AppLocalizations);
    assert(result != null, 'No AppLocalizations found in context');
    return result!;
  }

  Future<void> load() async {
    final String languageCode = locale.languageCode.toLowerCase();
    final List<String> candidates = <String>{languageCode, 'en'}.toList();
    for (final candidate in candidates) {
      final String path = 'assets/l10n/$candidate.json';
      try {
        final String jsonString = await rootBundle.loadString(path);
        _localizedValues = json.decode(jsonString) as Map<String, dynamic>;
        return;
      } on FlutterError {
        if (candidate == candidates.last) rethrow;
      }
    }
  }

  String translate(String key, {Map<String, String>? params}) {
    final dynamic value = _localizedValues[key];
    if (value is! String) {
      return key;
    }
    if (params == null || params.isEmpty) {
      return value;
    }
    return params.entries.fold<String>(
      value,
      (previousValue, entry) => previousValue.replaceAll('{${entry.key}}', entry.value),
    );
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => AppLocalizations.supportedLocales.any(
        (supported) => supported.languageCode.toLowerCase() == locale.languageCode.toLowerCase(),
      );

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
