import 'package:json_annotation/json_annotation.dart';

part 'job_posting_model.g.dart';

// Enum 정의
enum CropType {
  @JsonValue('CITRUS')
  citrus,
  @JsonValue('VEGETABLE') 
  vegetable,
  @JsonValue('GRAIN')
  grain,
  @JsonValue('FRUIT')
  fruit,
  @JsonValue('FLOWER')
  flower,
  @JsonValue('OTHER')
  other,
}

enum WorkType {
  @JsonValue('PLANTING')
  planting,
  @JsonValue('HARVESTING')
  harvesting,
  @JsonValue('WEEDING')
  weeding,
  @JsonValue('PRUNING')
  pruning,
  @JsonValue('PACKAGING')
  packaging,
  @JsonValue('OTHER')
  other,
}

enum WageType {
  @JsonValue('HOURLY')
  hourly,
  @JsonValue('DAILY')
  daily,
  @JsonValue('MONTHLY')
  monthly,
  @JsonValue('PIECE_RATE')
  pieceRate,
}

// Enum 확장 메소드
extension CropTypeExtension on CropType {
  String get displayName {
    switch (this) {
      case CropType.citrus:
        return '감귤';
      case CropType.vegetable:
        return '채소';
      case CropType.grain:
        return '곡물';
      case CropType.fruit:
        return '과일';
      case CropType.flower:
        return '화훼';
      case CropType.other:
        return '기타';
    }
  }
}

extension WorkTypeExtension on WorkType {
  String get displayName {
    switch (this) {
      case WorkType.planting:
        return '파종/정식';
      case WorkType.harvesting:
        return '수확';
      case WorkType.weeding:
        return '제초/풀뽑기';
      case WorkType.pruning:
        return '전정/가지치기';
      case WorkType.packaging:
        return '포장/선별';
      case WorkType.other:
        return '기타';
    }
  }
}

extension WageTypeExtension on WageType {
  String get displayName {
    switch (this) {
      case WageType.hourly:
        return '시급';
      case WageType.daily:
        return '일급';
      case WageType.monthly:
        return '월급';
      case WageType.pieceRate:
        return '성과급';
    }
  }
}

// API 응답에서 작성자 정보를 담는 모델
@JsonSerializable()
class AuthorInfo {
  final int id;
  final String name;
  final String nickname;
  final String? phone;
  final String? email;

  AuthorInfo({
    required this.id,
    required this.name,
    required this.nickname,
    this.phone,
    this.email,
  });

  factory AuthorInfo.fromJson(Map<String, dynamic> json) =>
      _$AuthorInfoFromJson(json);
  Map<String, dynamic> toJson() => _$AuthorInfoToJson(this);
}

// 일손 모집 공고 목록 또는 상세 정보 응답을 위한 모델
@JsonSerializable()
class JobPostingResponse {
  final int id;
  final String title;
  final String? description;
  final String farmName;
  final String address;
  final double latitude;
  final double longitude;
  final String cropType;
  final String cropTypeName;
  final String workType;
  final String workTypeName;
  final int wages;
  final String wageType;
  final String wageTypeName;
  final String workStartDate;
  final String workEndDate;
  final int recruitmentCount;
  final String? contactPhone;
  final String? contactEmail;
  final String status;
  final String statusName;
  final AuthorInfo author;
  final DateTime createdAt;
  final DateTime updatedAt;

  JobPostingResponse({
    required this.id,
    required this.title,
    this.description,
    required this.farmName,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.cropType,
    required this.cropTypeName,
    required this.workType,
    required this.workTypeName,
    required this.wages,
    required this.wageType,
    required this.wageTypeName,
    required this.workStartDate,
    required this.workEndDate,
    required this.recruitmentCount,
    this.contactPhone,
    this.contactEmail,
    required this.status,
    required this.statusName,
    required this.author,
    required this.createdAt,
    required this.updatedAt,
  });

  factory JobPostingResponse.fromJson(Map<String, dynamic> json) =>
      _$JobPostingResponseFromJson(json);
  Map<String, dynamic> toJson() => _$JobPostingResponseToJson(this);
}

// 페이징된 일손 모집 공고 응답을 위한 모델
@JsonSerializable()
class JobPostingPageResponse {
  final List<JobPostingResponse> content;
  final int totalElements;
  final int totalPages;
  final int size;
  final int number;
  final bool first;
  final bool last;
  final bool empty;

  JobPostingPageResponse({
    required this.content,
    required this.totalElements,
    required this.totalPages,
    required this.size,
    required this.number,
    required this.first,
    required this.last,
    required this.empty,
  });

  factory JobPostingPageResponse.fromJson(Map<String, dynamic> json) =>
      _$JobPostingPageResponseFromJson(json);
  Map<String, dynamic> toJson() => _$JobPostingPageResponseToJson(this);
}

// 일손 모집 공고 등록 요청을 위한 모델
@JsonSerializable()
class JobPostingRequest {
  final String title;
  final String? description;
  final String farmName;
  final String address;
  final double latitude;
  final double longitude;
  final CropType cropType;
  final WorkType workType;
  final int wages;
  final WageType wageType;
  final String workStartDate; // ISO 8601 형식으로 전송
  final String workEndDate;   // ISO 8601 형식으로 전송
  final int recruitmentCount;
  final String? contactPhone;
  final String? contactEmail;

  JobPostingRequest({
    required this.title,
    this.description,
    required this.farmName,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.cropType,
    required this.workType,
    required this.wages,
    this.wageType = WageType.daily,
    required this.workStartDate,
    required this.workEndDate,
    required this.recruitmentCount,
    this.contactPhone,
    this.contactEmail,
  });

  factory JobPostingRequest.fromJson(Map<String, dynamic> json) =>
      _$JobPostingRequestFromJson(json);
  Map<String, dynamic> toJson() => _$JobPostingRequestToJson(this);
}
