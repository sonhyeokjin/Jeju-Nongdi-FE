// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_preference_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserPreferenceDto _$UserPreferenceDtoFromJson(Map<String, dynamic> json) =>
    UserPreferenceDto(
      id: (json['id'] as num?)?.toInt(),
      userId: (json['userId'] as num?)?.toInt(),
      primaryCrops: (json['primaryCrops'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      farmLocation: json['farmLocation'] as String?,
      farmSize: (json['farmSize'] as num?)?.toDouble(),
      farmingExperience: (json['farmingExperience'] as num?)?.toInt(),
      notificationWeather: json['notificationWeather'] as bool?,
      notificationPest: json['notificationPest'] as bool?,
      notificationMarket: json['notificationMarket'] as bool?,
      notificationLabor: json['notificationLabor'] as bool?,
      preferredTipTime: json['preferredTipTime'] as String?,
      farmingType: json['farmingType'] as String?,
      farmingTypeDescription: json['farmingTypeDescription'] as String?,
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
      'primaryCrops': instance.primaryCrops,
      'farmLocation': instance.farmLocation,
      'farmSize': instance.farmSize,
      'farmingExperience': instance.farmingExperience,
      'notificationWeather': instance.notificationWeather,
      'notificationPest': instance.notificationPest,
      'notificationMarket': instance.notificationMarket,
      'notificationLabor': instance.notificationLabor,
      'preferredTipTime': instance.preferredTipTime,
      'farmingType': instance.farmingType,
      'farmingTypeDescription': instance.farmingTypeDescription,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

FarmingTypeInfo _$FarmingTypeInfoFromJson(Map<String, dynamic> json) =>
    FarmingTypeInfo(
      code: json['code'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
    );

Map<String, dynamic> _$FarmingTypeInfoToJson(FarmingTypeInfo instance) =>
    <String, dynamic>{
      'code': instance.code,
      'name': instance.name,
      'description': instance.description,
    };
