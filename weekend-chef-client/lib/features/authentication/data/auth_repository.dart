import '../../../core/network/api_client.dart';
import '../../../core/network/network_exceptions.dart';
import '../domain/auth_state.dart';
import '../domain/user_profile.dart';

class AuthRepository {
  AuthRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<(UserProfile user, String token)> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      'accounts/v2/login/',
      body: {
        'email': email.trim(),
        'password': password,
      },
    );
    final token = response['token']?.toString() ?? '';
    final profile = UserProfile.fromJson(response['user'] as Map<String, dynamic>);
    return (profile, token);
  }

  Future<(UserProfile user, String token)> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
    required String role,
  }) async {
    await _apiClient.post(
      'accounts/v2/register/',
      body: {
        'email': email.trim(),
        'password': password,
        'first_name': firstName.trim(),
        'last_name': lastName.trim(),
        'phone': phone.trim(),
        'role': role,
      },
    );
    return login(email: email, password: password);
  }

  Future<UserProfile> fetchProfile(String token) async {
    final response = await _apiClient.get('accounts/v2/profile/', token: token);
    return UserProfile.fromJson(response as Map<String, dynamic>);
  }

  Future<void> requestVerification({
    required String token,
    required VerificationPurpose purpose,
  }) async {
    final body = {'purpose': purpose == VerificationPurpose.email ? 'email' : 'phone'};
    await _apiClient.post('accounts/v2/request-verification/', body: body, token: token);
  }

  Future<UserProfile> verifyCode({
    required String token,
    required VerificationPurpose purpose,
    required String code,
  }) async {
    final response = await _apiClient.post(
      'accounts/v2/verify/',
      body: {
        'purpose': purpose == VerificationPurpose.email ? 'email' : 'phone',
        'code': code,
      },
      token: token,
    );
    return UserProfile.fromJson(response as Map<String, dynamic>);
  }

  Future<void> resendPhoneCode(String token) async {
    await _apiClient.post('accounts/v2/resend-phone/', token: token);
  }

  Future<void> changePassword({
    required String token,
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _apiClient.post(
        'accounts/change-password/',
        body: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
        token: token,
      );
    } on ApiException {
      rethrow;
    }
  }
}
