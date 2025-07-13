// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_posting_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthorInfo _$AuthorInfoFromJson(Map<String, dynamic> json) => AuthorInfo(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  nickname: json['nickname'] as String,
  phone: json['phone'] as String?,
  email: json['email'] as String?,
);

Map<String, dynamic> _$AuthorInfoToJson(AuthorInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'nickname': instance.nickname,
      'phone': instance.phone,
      'email': instance.email,
    };

JobPostingResponse _$JobPostingResponseFromJson(Map<String, dynamic> json) =>
    JobPostingResponse(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      description: json['description'] as String?,
      farmName: json['farmName'] as String,
      address: json['address'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      cropType: json['cropType'] as String,
      cropTypeName: json['cropTypeName'] as String,
      workType: json['workType'] as String,
      workTypeName: json['workTypeName'] as String,
      wages: (json['wages'] as num).toInt(),
      wageType: json['wageType'] as String,
      wageTypeName: json['wageTypeName'] as String,
      workStartDate: json['workStartDate'] as String,
      workEndDate: json['workEndDate'] as String,
      recruitmentCount: (json['recruitmentCount'] as num).toInt(),
      contactPhone: json['contactPhone'] as String?,
      contactEmail: json['contactEmail'] as String?,
      status: json['status'] as String,
      statusName: json['statusName'] as String,
      author: AuthorInfo.fromJson(json['author'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$JobPostingResponseToJson(JobPostingResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'farmName': instance.farmName,
      'address': instance.address,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'cropType': instance.cropType,
      'cropTypeName': instance.cropTypeName,
      'workType': instance.workType,
      'workTypeName': instance.workTypeName,
      'wages': instance.wages,
      'wageType': instance.wageType,
      'wageTypeName': instance.wageTypeName,
      'workStartDate': instance.workStartDate,
      'workEndDate': instance.workEndDate,
      'recruitmentCount': instance.recruitmentCount,
      'contactPhone': instance.contactPhone,
      'contactEmail': instance.contactEmail,
      'status': instance.status,
      'statusName': instance.statusName,
      'author': instance.author,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

JobPostingPageResponse _$JobPostingPageResponseFromJson(
  Map<String, dynamic> json,
) => JobPostingPageResponse(
  content: (json['content'] as List<dynamic>)
      .map((e) => JobPostingResponse.fromJson(e as Map<String, dynamic>))
      .toList(),
  totalElements: (json['totalElements'] as num).toInt(),
  totalPages: (json['totalPages'] as num).toInt(),
  size: (json['size'] as num).toInt(),
  number: (json['number'] as num).toInt(),
  first: json['first'] as bool,
  last: json['last'] as bool,
  empty: json['empty'] as bool,
);

Map<String, dynamic> _$JobPostingPageResponseToJson(
  JobPostingPageResponse instance,
) => <String, dynamic>{
  'content': instance.content,
  'totalElements': instance.totalElements,
  'totalPages': instance.totalPages,
  'size': instance.size,
  'number': instance.number,
  'first': instance.first,
  'last': instance.last,
  'empty': instance.empty,
};
