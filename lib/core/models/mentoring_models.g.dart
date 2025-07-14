// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mentoring_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserResponse _$UserResponseFromJson(Map<String, dynamic> json) => UserResponse(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  email: json['email'] as String?,
  profileImageUrl: json['profileImageUrl'] as String?,
);

Map<String, dynamic> _$UserResponseToJson(UserResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'profileImageUrl': instance.profileImageUrl,
    };

MentoringResponse _$MentoringResponseFromJson(Map<String, dynamic> json) =>
    MentoringResponse(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      description: json['description'] as String,
      mentoringType: json['mentoringType'] as String,
      mentoringTypeName: json['mentoringTypeName'] as String,
      category: json['category'] as String,
      categoryName: json['categoryName'] as String,
      experienceLevel: json['experienceLevel'] as String,
      experienceLevelName: json['experienceLevelName'] as String,
      preferredLocation: json['preferredLocation'] as String?,
      preferredSchedule: json['preferredSchedule'] as String?,
      contactPhone: json['contactPhone'] as String?,
      contactEmail: json['contactEmail'] as String?,
      status: json['status'] as String,
      statusName: json['statusName'] as String,
      author: UserResponse.fromJson(json['author'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$MentoringResponseToJson(MentoringResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'mentoringType': instance.mentoringType,
      'mentoringTypeName': instance.mentoringTypeName,
      'category': instance.category,
      'categoryName': instance.categoryName,
      'experienceLevel': instance.experienceLevel,
      'experienceLevelName': instance.experienceLevelName,
      'preferredLocation': instance.preferredLocation,
      'preferredSchedule': instance.preferredSchedule,
      'contactPhone': instance.contactPhone,
      'contactEmail': instance.contactEmail,
      'status': instance.status,
      'statusName': instance.statusName,
      'author': instance.author,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

MentoringRequest _$MentoringRequestFromJson(Map<String, dynamic> json) =>
    MentoringRequest(
      title: json['title'] as String,
      description: json['description'] as String,
      mentoringType: json['mentoringType'] as String,
      category: json['category'] as String,
      experienceLevel: json['experienceLevel'] as String,
      preferredLocation: json['preferredLocation'] as String?,
      preferredSchedule: json['preferredSchedule'] as String?,
      contactPhone: json['contactPhone'] as String?,
      contactEmail: json['contactEmail'] as String?,
    );

Map<String, dynamic> _$MentoringRequestToJson(MentoringRequest instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'mentoringType': instance.mentoringType,
      'category': instance.category,
      'experienceLevel': instance.experienceLevel,
      'preferredLocation': instance.preferredLocation,
      'preferredSchedule': instance.preferredSchedule,
      'contactPhone': instance.contactPhone,
      'contactEmail': instance.contactEmail,
    };

PageResponse<T> _$PageResponseFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) => PageResponse<T>(
  content: (json['content'] as List<dynamic>).map(fromJsonT).toList(),
  last: json['last'] as bool,
  totalPages: (json['totalPages'] as num).toInt(),
  totalElements: (json['totalElements'] as num).toInt(),
  size: (json['size'] as num).toInt(),
  number: (json['number'] as num).toInt(),
  first: json['first'] as bool,
  numberOfElements: (json['numberOfElements'] as num).toInt(),
);

Map<String, dynamic> _$PageResponseToJson<T>(
  PageResponse<T> instance,
  Object? Function(T value) toJsonT,
) => <String, dynamic>{
  'content': instance.content.map(toJsonT).toList(),
  'last': instance.last,
  'totalPages': instance.totalPages,
  'totalElements': instance.totalElements,
  'size': instance.size,
  'number': instance.number,
  'first': instance.first,
  'numberOfElements': instance.numberOfElements,
};
