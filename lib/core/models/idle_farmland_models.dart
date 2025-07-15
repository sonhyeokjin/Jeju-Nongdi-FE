import 'package:json_annotation/json_annotation.dart';
import 'package:jejunongdi/core/models/mentoring_models.dart'; // UserResponse 재사용

part 'idle_farmland_models.g.dart';

/// 유휴 농지 정보 응답 모델
@JsonSerializable()
class IdleFarmlandResponse {
  final int id;
  final String address;
  final double area; // 면적 (평)
  final String description;
  final List<String>? imageUrls;
  final UserResponse author;
  final DateTime createdAt;
  final DateTime updatedAt;

  IdleFarmlandResponse({
    required this.id,
    required this.address,
    required this.area,
    required this.description,
    this.imageUrls,
    required this.author,
    required this.createdAt,
    required this.updatedAt,
  });

  factory IdleFarmlandResponse.fromJson(Map<String, dynamic> json) =>
      _$IdleFarmlandResponseFromJson(json);
  Map<String, dynamic> toJson() => _$IdleFarmlandResponseToJson(this);
}

/// 유휴 농지 생성/수정 요청 모델
@JsonSerializable()
class IdleFarmlandRequest {
  final String address;
  final double area;
  final String description;
  // 이미지 URL은 별도의 업로드 API를 통해 처리 후, URL 목록을 전달하는 방식으로 가정
  final List<String>? imageUrls;

  IdleFarmlandRequest({
    required this.address,
    required this.area,
    required this.description,
    this.imageUrls,
  });

  factory IdleFarmlandRequest.fromJson(Map<String, dynamic> json) =>
      _$IdleFarmlandRequestFromJson(json);
  Map<String, dynamic> toJson() => _$IdleFarmlandRequestToJson(this);
}