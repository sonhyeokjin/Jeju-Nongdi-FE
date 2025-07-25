import 'package:json_annotation/json_annotation.dart';

part 'auth_models.g.dart';

@JsonSerializable()
class SignupRequest {
  final String email;
  final String password;
  final String name;
  final String nickname;
  final String phone;

  SignupRequest({
    required this.email,
    required this.password,
    required this.name,
    required this.nickname,
    required this.phone,
  });

  factory SignupRequest.fromJson(Map<String, dynamic> json) =>
      _$SignupRequestFromJson(json);
  Map<String, dynamic> toJson() => _$SignupRequestToJson(this);
}

@JsonSerializable()
class LoginRequest {
  final String email;
  final String password;

  LoginRequest({
    required this.email,
    required this.password,
  });

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);
  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}

// 서버 응답에 맞는 로그인 응답 모델
@JsonSerializable()
class ServerAuthResponse {
  final String token;
  final String email;
  final String name;
  final String nickname;
  final String role; // "USER" or "ADMIN" 등의 문자열

  ServerAuthResponse({
    required this.token,
    required this.email,
    required this.name,
    required this.nickname,
    required this.role,
  });

  factory ServerAuthResponse.fromJson(Map<String, dynamic> json) =>
      _$ServerAuthResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ServerAuthResponseToJson(this);
}

@JsonSerializable()
class AuthResponse {
  final String accessToken;
  final String refreshToken;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);
}

@JsonSerializable()
class User {
  final String email;
  final String name;
  final String nickname;
  final String phone;

  User({
    required this.email,
    required this.name,
    required this.nickname,
    required this.phone,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
