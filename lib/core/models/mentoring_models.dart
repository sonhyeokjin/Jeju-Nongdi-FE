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
  ) =>
      _$PageResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object Function(T value) toJsonT) =>
      _$PageResponseToJson(this, toJsonT);
}
