// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_tip_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AiTipResponseDto _$AiTipResponseDtoFromJson(Map<String, dynamic> json) =>
    AiTipResponseDto(
      id: (json['id'] as num).toInt(),
      userId: (json['userId'] as num).toInt(),
      tipType: json['tipType'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      cropType: json['cropType'] as String?,
      isRead: json['isRead'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$AiTipResponseDtoToJson(AiTipResponseDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'tipType': instance.tipType,
      'title': instance.title,
      'content': instance.content,
      'cropType': instance.cropType,
      'isRead': instance.isRead,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

AiTipCreateRequest _$AiTipCreateRequestFromJson(Map<String, dynamic> json) =>
    AiTipCreateRequest(
      userId: (json['userId'] as num).toInt(),
      tipType: json['tipType'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      cropType: json['cropType'] as String?,
    );

Map<String, dynamic> _$AiTipCreateRequestToJson(AiTipCreateRequest instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'tipType': instance.tipType,
      'title': instance.title,
      'content': instance.content,
      'cropType': instance.cropType,
    };
