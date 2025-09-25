import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFFF94638);
  static const primaryDark = Color(0xFF800A00);
  static const onPrimary = Colors.white;
  static const scaffold = Color(0xFFF8F7FC);
  static const surface = Colors.white;
  static const mutedText = Color(0xFF6B6B6B);
  static const success = Color(0xFF1B998B);
  static const warning = Color(0xFFEEA243);
  static const error = Color(0xFFD64550);
  static const border = Color(0xFFE6E3F3);
}

class Spacing {
  static const nano = 4.0;
  static const micro = 8.0;
  static const small = 12.0;
  static const medium = 16.0;
  static const large = 24.0;
  static const xLarge = 32.0;
  static const xxLarge = 48.0;
}

class Corners {
  static const small = Radius.circular(8);
  static const medium = Radius.circular(16);
  static const large = Radius.circular(24);
}

class Shadows {
  static const soft = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 12,
      offset: Offset(0, 6),
    ),
  ];
}

class EnvironmentConfig {
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000/',
  );

  static const mediaBaseUrl = String.fromEnvironment(
    'API_MEDIA_BASE_URL',
    defaultValue: 'http://localhost:8000',
  );

  static const pusherKey = String.fromEnvironment('PUSHER_KEY');
  static const pusherCluster = String.fromEnvironment(
    'PUSHER_CLUSTER',
    defaultValue: 'mt1',
  );

  static const paystackPublicKey = String.fromEnvironment('PAYSTACK_PUBLIC_KEY', defaultValue: '');
}

class PreferenceKeys {
  static const authToken = 'auth_token';
  static const locale = 'preferred_locale';
}

class AnimationDurations {
  static const short = Duration(milliseconds: 200);
  static const medium = Duration(milliseconds: 350);
  static const long = Duration(milliseconds: 600);
}
