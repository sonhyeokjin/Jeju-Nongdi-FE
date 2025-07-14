import 'package:json_annotation/json_annotation.dart';

part 'job_posting_model.g.dart';

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

/// 새로운 일손 모집 공고를 등록할 때 서버로 보내는 데이터 모델
@JsonSerializable(includeIfNull: false)
class JobPostingRequest {
  final String title;
  final String? description;
  final String farmName;
  final String address;
  final double latitude;
  final double longitude;
  final String cropType;
  final String workType;
  final int wages;
  final String wageType;
  final String workStartDate; // "YYYY-MM-DD" 형식
  final String workEndDate;   // "YYYY-MM-DD" 형식
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
    required this.wageType,
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

