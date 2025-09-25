class UserProfile {
  const UserProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.role,
    required this.emailVerified,
    required this.phoneVerified,
    this.language,
    this.about,
    this.locationName,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String role;
  final bool emailVerified;
  final bool phoneVerified;
  final String? language;
  final String? about;
  final String? locationName;

  String get displayName => '$firstName $lastName'.trim();

  bool get isFullyVerified => emailVerified && phoneVerified;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['user_id']?.toString() ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: json['user_type'] ?? 'Client',
      emailVerified: json['email_verified'] ?? false,
      phoneVerified: json['phone_verified'] ?? false,
      language: json['language'] as String?,
      about: json['about_me'] as String?,
      locationName: json['location_name'] as String?,
    );
  }
}
