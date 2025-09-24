class SignInModel {
  String? message;
  SignInData? data;
  Map<String, List<String>>? errors;

  SignInModel({this.message, this.data, this.errors});

  factory SignInModel.fromJson(Map<String, dynamic> json) {
    return SignInModel(
      message: json['message'],
      data: json['data'] != null ? SignInData.fromJson(json['data']) : null,
      errors: json['errors'] != null ? _parseErrors(json['errors']) : null,
    );
  }

  static Map<String, List<String>> _parseErrors(Map<String, dynamic> errorData) {
    Map<String, List<String>> errors = {};
    errorData.forEach((key, value) {
      if (value is List) {
        errors[key] = List<String>.from(value);
      } else if (value is String) {
        errors[key] = [value];
      }
    });
    return errors;
  }
}

class SignInData {
  String? token;
  String? firstName;
  String? lastName;
  String? email;
  String? emailVerifiedAt;

  SignInData({this.token, this.firstName, this.lastName, this.email, this.emailVerifiedAt});

  factory SignInData.fromJson(Map<String, dynamic> json) {
    return SignInData(
      token: json['token'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      emailVerifiedAt: json['email_verified_at'],
    );
  }
}