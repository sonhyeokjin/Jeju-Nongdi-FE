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
