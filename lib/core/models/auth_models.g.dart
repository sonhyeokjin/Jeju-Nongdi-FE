// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SignupRequest _$SignupRequestFromJson(Map<String, dynamic> json) =>
    SignupRequest(
      email: json['email'] as String,
      password: json['password'] as String,
      name: json['name'] as String,
      nickname: json['nickname'] as String,
      phone: json['phone'] as String,
    );

Map<String, dynamic> _$SignupRequestToJson(SignupRequest instance) =>
    <String, dynamic>{
      'email': instance.email,
      'password': instance.password,
      'name': instance.name,
      'nickname': instance.nickname,
      'phone': instance.phone,
    };

LoginRequest _$LoginRequestFromJson(Map<String, dynamic> json) => LoginRequest(
  email: json['email'] as String,
  password: json['password'] as String,
);

Map<String, dynamic> _$LoginRequestToJson(LoginRequest instance) =>
    <String, dynamic>{'email': instance.email, 'password': instance.password};

ServerAuthResponse _$ServerAuthResponseFromJson(Map<String, dynamic> json) =>
    ServerAuthResponse(
      token: json['token'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      nickname: json['nickname'] as String,
      role: json['role'] as String,
    );

Map<String, dynamic> _$ServerAuthResponseToJson(ServerAuthResponse instance) =>
    <String, dynamic>{
      'token': instance.token,
      'email': instance.email,
      'name': instance.name,
      'nickname': instance.nickname,
      'role': instance.role,
    };

AuthResponse _$AuthResponseFromJson(Map<String, dynamic> json) => AuthResponse(
  accessToken: json['accessToken'] as String,
  refreshToken: json['refreshToken'] as String,
);

Map<String, dynamic> _$AuthResponseToJson(AuthResponse instance) =>
    <String, dynamic>{
      'accessToken': instance.accessToken,
      'refreshToken': instance.refreshToken,
    };

User _$UserFromJson(Map<String, dynamic> json) => User(
  email: json['email'] as String,
  name: json['name'] as String,
  nickname: json['nickname'] as String,
  phone: json['phone'] as String,
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'email': instance.email,
  'name': instance.name,
  'nickname': instance.nickname,
  'phone': instance.phone,
};
