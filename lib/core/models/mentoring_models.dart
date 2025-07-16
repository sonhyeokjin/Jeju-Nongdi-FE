import 'package:json_annotation/json_annotation.dart';

part 'mentoring_models.g.dart';

@JsonSerializable()
class UserResponse {
  final int id;
  final String name;
  final String? email;
  final String? profileImageUrl;

  UserResponse({
    required this.id,
    required this.name,
    this.email,
    this.profileImageUrl,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) => 
      _$UserResponseFromJson(json);
  
  Map<String, dynamic> toJson() => _$UserResponseToJson(this);
}

@JsonSerializable()
class MentoringResponse {
  final int id;
  final String title;
  final String description;
  final String mentoringType;
  final String mentoringTypeName;
  final String category;
  final String categoryName;
  final String experienceLevel;
  final String experienceLevelName;
  final String? preferredLocation;
  final String? preferredSchedule;
  final String? contactPhone;
  final String? contactEmail;
  final String status;
  final String statusName;
  final UserResponse author;
  final DateTime createdAt;
  final DateTime updatedAt;

  MentoringResponse({
    required this.id,
    required this.title,
    required this.description,
    required this.mentoringType,
    required this.mentoringTypeName,
    required this.category,
    required this.categoryName,
    required this.experienceLevel,
    required this.experienceLevelName,
    this.preferredLocation,
    this.preferredSchedule,
    this.contactPhone,
    this.contactEmail,
    required this.status,
    required this.statusName,
    required this.author,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MentoringResponse.fromJson(Map<String, dynamic> json) => 
      _$MentoringResponseFromJson(json);
  
  Map<String, dynamic> toJson() => _$MentoringResponseToJson(this);

  // 편의 메서드들
  String get content => description;
  String get location => preferredLocation ?? '';
  String get authorName => author.name;
}

@JsonSerializable()
class MentoringRequest {
  final String title;
  final String description;
  final String mentoringType;
  final String category;
  final String experienceLevel;
  final String? preferredLocation;
  final String? preferredSchedule;
  final String? contactPhone;
  final String? contactEmail;

  MentoringRequest({
    required this.title,
    required this.description,
    required this.mentoringType,
    required this.category,
    required this.experienceLevel,
    this.preferredLocation,
    this.preferredSchedule,
    this.contactPhone,
    this.contactEmail,
  });

  factory MentoringRequest.fromJson(Map<String, dynamic> json) => 
      _$MentoringRequestFromJson(json);
  
  Map<String, dynamic> toJson() => _$MentoringRequestToJson(this);

  // 연락처 정보 유효성 검증
  bool get isContactInfoValid {
    return (contactPhone != null && contactPhone!.trim().isNotEmpty) ||
           (contactEmail != null && contactEmail!.trim().isNotEmpty);
  }
}

// Enum classes for type safety
enum MentoringType {
  mentorWanted('MENTOR_WANTED', '멘토 구함'),
  menteeWanted('MENTEE_WANTED', '멘티 구함'),
  mentor('MENTOR', '멘토'),
  mentee('MENTEE', '멘티');

  const MentoringType(this.value, this.koreanName);
  
  final String value;
  final String koreanName;
}

enum Category {
  cropCultivation('CROP_CULTIVATION', '작물재배'),
  livestock('LIVESTOCK', '축산'),
  greenhouse('GREENHOUSE', '온실관리'),
  organicFarming('ORGANIC_FARMING', '유기농업'),
  farmManagement('FARM_MANAGEMENT', '농장경영'),
  marketing('MARKETING', '판매/마케팅'),
  technology('TECHNOLOGY', '농업기술'),
  certification('CERTIFICATION', '인증'),
  agriculturalTechnology('AGRICULTURAL_TECHNOLOGY', '농업 기술'),
  funding('FUNDING', '자금 조달'),
  other('OTHER', '기타');

  const Category(this.value, this.koreanName);
  
  final String value;
  final String koreanName;
}

enum ExperienceLevel {
  beginner('BEGINNER', '초급 (1년 미만)'),
  intermediate('INTERMEDIATE', '중급 (1-5년)'),
  advanced('ADVANCED', '고급 (5-10년)'),
  expert('EXPERT', '전문가 (10년 이상)');

  const ExperienceLevel(this.value, this.koreanName);
  
  final String value;
  final String koreanName;
}

@JsonSerializable(genericArgumentFactories: true)
class PageResponse<T> {
  final List<T> content;
  final bool last;
  final int totalPages;
  final int totalElements;
  final int size;
  final int number;
  final bool first;
  final int numberOfElements;

  PageResponse({
    required this.content,
    required this.last,
    required this.totalPages,
    required this.totalElements,
    required this.size,
    required this.number,
    required this.first,
    required this.numberOfElements,
  });

  factory PageResponse.fromJson(
      Map<String, dynamic> json,
      T Function(Object? json) fromJsonT,
      ) {
    // 서버에서 온 content 리스트가 null일 경우를 대비해 빈 리스트로 초기화합니다.
    final contentList = json['content'] as List<dynamic>? ?? [];

    // 리스트 내부의 항목 중 null이 아닌 것만 필터링하여 안전하게 변환합니다.
    final validContent = contentList
        .where((item) => item != null)
        .map(fromJsonT)
        .toList();

    return PageResponse<T>(
      content: validContent,
      last: json['last'] as bool? ?? true,
      totalPages: json['totalPages'] as int? ?? 0,
      totalElements: json['totalElements'] as int? ?? 0,
      size: json['size'] as int? ?? 0,
      number: json['number'] as int? ?? 0,
      first: json['first'] as bool? ?? true,
      numberOfElements: json['numberOfElements'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson(Object Function(T value) toJsonT) =>
      _$PageResponseToJson(this, toJsonT);
}
