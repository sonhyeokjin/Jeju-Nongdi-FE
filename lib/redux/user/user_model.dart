// 사용자 모델 - JWT 기반 회원정보
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class User {
  final String id;
  final String email;
  final String name;
  final String nickname;
  final String? profileImageUrl;
  final String? phoneNumber;
  final DateTime? birthDate;
  final UserRole role;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.id,
    required this.email,
    required this.name,
    required this.nickname,
    this.profileImageUrl,
    this.phoneNumber,
    this.birthDate,
    required this.role,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  // JSON 직렬화
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  // copyWith 메서드
  User copyWith({
    String? id,
    String? email,
    String? name,
    String? nickname,
    String? profileImageUrl,
    String? phoneNumber,
    DateTime? birthDate,
    UserRole? role,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      nickname: nickname ?? this.nickname,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      birthDate: birthDate ?? this.birthDate,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'User{'
        'id: $id, '
        'email: $email, '
        'name: $name, '
        'nickname: $nickname, '
        'role: $role'
        '}';
  }
}

// 사용자 역할 열거형
@JsonEnum()
enum UserRole {
  //구직자
  @JsonValue('worker')
  worker,
  //농지주
  @JsonValue('master')
  master,
}

// JWT 응답 모델
@JsonSerializable()
class AuthResponse {
  final User user;
  final String accessToken;
  final String? refreshToken;
  final int expiresIn; // 토큰 만료 시간 (초)

  const AuthResponse({
    required this.user,
    required this.accessToken,
    this.refreshToken,
    required this.expiresIn,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => _$AuthResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);

  @override
  String toString() {
    return 'AuthResponse{'
        'user: $user, '
        'hasAccessToken: ${accessToken.isNotEmpty}, '
        'hasRefreshToken: ${refreshToken != null}, '
        'expiresIn: $expiresIn'
        '}';
  }
}