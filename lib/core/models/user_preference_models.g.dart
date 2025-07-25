// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_preference_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserPreferenceDto _$UserPreferenceDtoFromJson(Map<String, dynamic> json) =>
    UserPreferenceDto(
      id: (json['id'] as num?)?.toInt(),
      userId: (json['userId'] as num).toInt(),
      farmingType: json['farmingType'] as String?,
      interestedCrops: (json['interestedCrops'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      farmSize: json['farmSize'] as String?,
      farmLocation: json['farmLocation'] as String?,
      experienceLevel: json['experienceLevel'] as String?,
      weatherSettings: json['weatherSettings'] as Map<String, dynamic>?,
      notificationSettings:
          json['notificationSettings'] as Map<String, dynamic>?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$UserPreferenceDtoToJson(UserPreferenceDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'farmingType': instance.farmingType,
      'interestedCrops': instance.interestedCrops,
      'farmSize': instance.farmSize,
      'farmLocation': instance.farmLocation,
      'experienceLevel': instance.experienceLevel,
      'weatherSettings': instance.weatherSettings,
      'notificationSettings': instance.notificationSettings,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
