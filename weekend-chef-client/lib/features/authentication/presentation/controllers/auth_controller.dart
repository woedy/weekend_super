import 'package:flutter/material.dart';

import '../../../../core/network/network_exceptions.dart';
import '../../../../core/storage/token_storage.dart';
import '../../data/auth_repository.dart';
import '../../domain/auth_state.dart';
import '../../domain/user_profile.dart';

class AuthController extends ChangeNotifier {
  AuthController(this._repository, this._tokenStorage);

  final AuthRepository _repository;
  final TokenStorage _tokenStorage;

  AuthState _state = AuthState.initial();
  AuthState get state => _state;

  void _updateState(AuthState state) {
    _state = state;
    notifyListeners();
  }

  Future<void> bootstrap() async {
    final storedLocale = await _tokenStorage.readLocale();
    Locale? locale;
    if (storedLocale != null && storedLocale.isNotEmpty) {
      locale = Locale(storedLocale);
    }
    final storedToken = await _tokenStorage.readToken();
    if (storedToken == null) {
      _updateState(AuthState.initial().copyWith(
        status: AuthStatus.unauthenticated,
        locale: locale,
      ));
      return;
    }
    _updateState(state.copyWith(isLoading: true, locale: locale, clearError: true));
    try {
      final profile = await _repository.fetchProfile(storedToken);
      final status = profile.isFullyVerified ? AuthStatus.authenticated : AuthStatus.needsVerification;
      _updateState(AuthState(
        status: status,
        user: profile,
        token: storedToken,
        locale: locale,
      ));
    } catch (error) {
      await _tokenStorage.clearToken();
      _updateState(AuthState.initial().copyWith(
        status: AuthStatus.unauthenticated,
        locale: locale,
      ));
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    _updateState(state.copyWith(isLoading: true, clearError: true));
    try {
      final (user, token) = await _repository.login(email: email, password: password);
      await _tokenStorage.writeToken(token);
      final status = user.isFullyVerified ? AuthStatus.authenticated : AuthStatus.needsVerification;
      _updateState(state.copyWith(
        status: status,
        user: user,
        token: token,
        isLoading: false,
      ));
    } on ApiException catch (error) {
      _updateState(state.copyWith(
        isLoading: false,
        error: error.message,
      ));
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
    required String role,
  }) async {
    _updateState(state.copyWith(isLoading: true, clearError: true));
    try {
      final (user, token) = await _repository.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        role: role,
      );
      await _tokenStorage.writeToken(token);
      _updateState(state.copyWith(
        status: user.isFullyVerified ? AuthStatus.authenticated : AuthStatus.needsVerification,
        user: user,
        token: token,
        isLoading: false,
      ));
    } on ApiException catch (error) {
      _updateState(state.copyWith(isLoading: false, error: error.message));
    }
  }

  Future<void> requestVerification(VerificationPurpose purpose) async {
    final token = state.token;
    if (token == null) return;
    try {
      await _repository.requestVerification(token: token, purpose: purpose);
    } on ApiException catch (error) {
      _updateState(state.copyWith(error: error.message));
    }
  }

  Future<void> resendPhoneVerification() async {
    final token = state.token;
    if (token == null) return;
    try {
      await _repository.resendPhoneCode(token);
    } on ApiException catch (error) {
      _updateState(state.copyWith(error: error.message));
    }
  }

  Future<void> verifyCode({
    required VerificationPurpose purpose,
    required String code,
  }) async {
    final token = state.token;
    if (token == null) return;
    _updateState(state.copyWith(isLoading: true, clearError: true));
    try {
      final UserProfile updated = await _repository.verifyCode(
        token: token,
        purpose: purpose,
        code: code,
      );
      final status = updated.isFullyVerified ? AuthStatus.authenticated : AuthStatus.needsVerification;
      _updateState(state.copyWith(status: status, user: updated, isLoading: false));
    } on ApiException catch (error) {
      _updateState(state.copyWith(isLoading: false, error: error.message));
    }
  }

  Future<void> signOut() async {
    await _tokenStorage.clearToken();
    _updateState(AuthState.initial().copyWith(status: AuthStatus.unauthenticated, locale: state.locale));
  }

  Future<void> updateLocale(Locale locale) async {
    await _tokenStorage.saveLocale(locale.languageCode);
    _updateState(state.copyWith(locale: locale));
  }
}
