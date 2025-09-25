import 'package:flutter/material.dart';

import 'user_profile.dart';

enum AuthStatus { unknown, unauthenticated, authenticated, needsVerification }

enum VerificationPurpose { email, phone }

class AuthState {
  const AuthState({
    required this.status,
    this.user,
    this.token,
    this.error,
    this.locale,
    this.isLoading = false,
  });

  final AuthStatus status;
  final UserProfile? user;
  final String? token;
  final String? error;
  final Locale? locale;
  final bool isLoading;

  AuthState copyWith({
    AuthStatus? status,
    UserProfile? user,
    String? token,
    String? error,
    bool? isLoading,
    Locale? locale,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      token: token ?? this.token,
      error: clearError ? null : error ?? this.error,
      isLoading: isLoading ?? this.isLoading,
      locale: locale ?? this.locale,
    );
  }

  factory AuthState.initial() => const AuthState(status: AuthStatus.unknown);
}
