class SignUpModel {
  String? message;
  SignUpData? data;
  Map<String, List<String>>? errors;

  SignUpModel({this.message, this.data, this.errors});

  factory SignUpModel.fromJson(Map<String, dynamic> json) {
    return SignUpModel(
      message: json['message'],
      data: json['data'] != null ? SignUpData.fromJson(json['data']) : null,
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

class SignUpData {
  String? token;
  String? firstName;
  String? lastName;
  String? email;
 

  SignUpData({this.token, this.firstName, this.lastName, this.email});

  factory SignUpData.fromJson(Map<String, dynamic> json) {
    return SignUpData(
      token: json['token'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
    );
  }
}