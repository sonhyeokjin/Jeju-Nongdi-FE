import 'package:json_annotation/json_annotation.dart';
import 'package:jejunongdi/core/models/mentoring_models.dart'; // UserResponse 재사용

part 'idle_farmland_models.g.dart';

/// 유휴 농지 상태 열거형
enum IdleFarmlandStatus {
  @JsonValue('AVAILABLE')
  available,
  @JsonValue('RENTED')
  rented,
  @JsonValue('MAINTENANCE')
  maintenance,
  @JsonValue('SUSPENDED')
  suspended,
  @JsonValue('UNAVAILABLE')
  unavailable,
}

/// 토양 타입 열거형
enum SoilType {
  @JsonValue('SANDY')
  sandy,
  @JsonValue('CLAY')
  clay,
  @JsonValue('LOAM')
  loam,
  @JsonValue('SILT')
  silt,
  @JsonValue('VOLCANIC')
  volcanic,
}

/// 농지 사용 타입 열거형
enum UsageType {
  @JsonValue('VEGETABLE')
  vegetable,
  @JsonValue('FRUIT')
  fruit,
  @JsonValue('GRAIN')
  grain,
  @JsonValue('FLOWER')
  flower,
  @JsonValue('HERB')
  herb,
  @JsonValue('MIXED')
  mixed,
}

/// 유휴 농지 정보 응답 모델
@JsonSerializable(explicitToJson: true)
class IdleFarmlandResponse {
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
  final bool waterSupply;
  final bool electricitySupply;
  final bool farmingToolsIncluded;
  final String? contactPhone;
  final String? contactEmail;
  final String status;
  final List<String> imageUrls;
  final UserResponse? author;
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
    this.waterSupply = false,
    this.electricitySupply = false,
    this.farmingToolsIncluded = false,
    this.contactPhone,
    this.contactEmail,
    required this.status,
    List<String>? imageUrls,
    this.author,
    required this.createdAt,
    required this.updatedAt,
  }) : imageUrls = imageUrls ?? [];

  /// JSON에서 안전하게 DateTime 파싱
  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return DateTime.now();
      }
    }
    if (value is DateTime) return value;
    return DateTime.now();
  }

  /// JSON에서 안전하게 UserResponse 파싱
  static UserResponse? _parseUser(dynamic value) {
    if (value == null) return null;
    if (value is Map<String, dynamic>) {
      try {
        return UserResponse.fromJson(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  factory IdleFarmlandResponse.fromJson(Map<String, dynamic> json) {
    try {
      return IdleFarmlandResponse(
        id: json['id'] as int? ?? 0,
        title: json['title'] as String? ?? '',
        description: json['description'] as String? ?? '',
        farmlandName: json['farmlandName'] as String? ?? '',
        address: json['address'] as String? ?? '',
        latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
        longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
        areaSize: (json['areaSize'] as num?)?.toDouble() ?? 0.0,
        soilType: json['soilType'] as String?,
        usageType: json['usageType'] as String?,
        monthlyRent: json['monthlyRent'] as int?,
        availableStartDate: json['availableStartDate'] as String? ?? '',
        availableEndDate: json['availableEndDate'] as String? ?? '',
        waterSupply: json['waterSupply'] as bool? ?? false,
        electricitySupply: json['electricitySupply'] as bool? ?? false,
        farmingToolsIncluded: json['farmingToolsIncluded'] as bool? ?? false,
        contactPhone: json['contactPhone'] as String?,
        contactEmail: json['contactEmail'] as String?,
        status: json['status'] as String? ?? 'AVAILABLE',
        imageUrls: (json['imageUrls'] as List<dynamic>?)?.cast<String>() ?? [],
        author: _parseUser(json['author']),
        createdAt: _parseDateTime(json['createdAt']),
        updatedAt: _parseDateTime(json['updatedAt']),
      );
    } catch (e) {
      throw FormatException('IdleFarmlandResponse.fromJson 파싱 오류: $e');
    }
  }
  Map<String, dynamic> toJson() => _$IdleFarmlandResponseToJson(this);
}

/// 유휴 농지 생성/수정 요청 모델
@JsonSerializable(explicitToJson: true)
class IdleFarmlandRequest {
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
  final String soilType;
  final String usageType;
  final bool waterSupply;
  final bool electricitySupply;
  final bool farmingToolsIncluded;
  final String? contactEmail;

  const IdleFarmlandRequest({
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
    required this.soilType,
    required this.usageType,
    this.waterSupply = false,
    this.electricitySupply = false,
    this.farmingToolsIncluded = false,
    this.contactEmail,
  });

  /// 유효성 검증
  bool isValid() {
    return title.isNotEmpty &&
        description.isNotEmpty &&
        farmlandName.isNotEmpty &&
        address.isNotEmpty &&
        latitude >= -90 && latitude <= 90 &&
        longitude >= -180 && longitude <= 180 &&
        areaSize > 0 &&
        monthlyRent >= 0 &&
        availableStartDate.isNotEmpty &&
        availableEndDate.isNotEmpty &&
        soilType.isNotEmpty &&
        usageType.isNotEmpty;
  }

  factory IdleFarmlandRequest.fromJson(Map<String, dynamic> json) =>
      _$IdleFarmlandRequestFromJson(json);
  Map<String, dynamic> toJson() => _$IdleFarmlandRequestToJson(this);
}