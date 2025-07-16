import 'package:json_annotation/json_annotation.dart';
import 'package:jejunongdi/core/models/mentoring_models.dart'; // UserResponse 재사용

part 'idle_farmland_models.g.dart';

/// 유휴 농지 정보 응답 모델
@JsonSerializable()
class IdleFarmlandResponse {
  // [수정] 서버 응답에 맞게 모든 필드 추가
  final int id;
  final String title;
  final String description;
  final String farmlandName;
  final String address;
  final double latitude;
  final double longitude;
  final double areaSize;
  final String? soilType;
  final String? usageType;
  final int? monthlyRent;
  final String availableStartDate;
  final String availableEndDate;
  final bool? waterSupply;
  final bool? electricitySupply;
  final bool? farmingToolsIncluded;
  final String? contactPhone;
  final String? contactEmail;
  final String status;
  final List<String>? imageUrls;
  final UserResponse author;
  final DateTime createdAt;
  final DateTime updatedAt;

  IdleFarmlandResponse({
    required this.id,
    required this.title,
    required this.description,
    required this.farmlandName,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.areaSize,
    this.soilType,
    this.usageType,
    this.monthlyRent,
    required this.availableStartDate,
    required this.availableEndDate,
    this.waterSupply,
    this.electricitySupply,
    this.farmingToolsIncluded,
    this.contactPhone,
    this.contactEmail,
    required this.status,
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
  // [수정] 서버 요구사항에 맞게 필드 대거 추가
  final String title;
  final String description;
  final String farmlandName;
  final String address;
  final double latitude;
  final double longitude;
  final double areaSize;
  final int monthlyRent;
  final String availableStartDate;
  final String availableEndDate;
  final String? contactPhone;

  // [추가된 필드]
  final String soilType;
  final String usageType;
  final bool waterSupply;
  final bool electricitySupply;
  final bool farmingToolsIncluded;
  final String? contactEmail;


  IdleFarmlandRequest({
    required this.title,
    required this.description,
    required this.farmlandName,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.areaSize,
    required this.monthlyRent,
    required this.availableStartDate,
    required this.availableEndDate,
    this.contactPhone,
    // [추가]
    required this.soilType,
    required this.usageType,
    required this.waterSupply,
    required this.electricitySupply,
    required this.farmingToolsIncluded,
    this.contactEmail,
  });

  factory IdleFarmlandRequest.fromJson(Map<String, dynamic> json) =>
      _$IdleFarmlandRequestFromJson(json);
  Map<String, dynamic> toJson() => _$IdleFarmlandRequestToJson(this);
}