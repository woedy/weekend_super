import 'package:shared_preferences/shared_preferences.dart';

import '../../constants.dart';

class TokenStorage {
  Future<String?> readToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(PreferenceKeys.authToken);
  }

  Future<void> writeToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(PreferenceKeys.authToken, token);
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(PreferenceKeys.authToken);
  }

  Future<void> saveLocale(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(PreferenceKeys.locale, languageCode);
  }

  Future<String?> readLocale() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(PreferenceKeys.locale);
  }
}
