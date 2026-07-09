class UserModel {
  final int id;
  final String username;
  final String name;
  final String email;

  UserModel({
    required this.id,
    required this.username,
    required this.name,
    required this.email,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
    );
  }
}

class LoginResponse {
  final String result;
  final int code;
  final String message;
  final UserModel? user;
  final String? token;

  LoginResponse({
    required this.result,
    required this.code,
    required this.message,
    this.user,
    this.token,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      result: json['result'] ?? '',
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      token: json['token'],
    );
  }
}
