// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'idle_farmland_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IdleFarmlandResponse _$IdleFarmlandResponseFromJson(
  Map<String, dynamic> json,
) => IdleFarmlandResponse(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  description: json['description'] as String,
  farmlandName: json['farmlandName'] as String,
  address: json['address'] as String,
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  areaSize: (json['areaSize'] as num).toDouble(),
  soilType: json['soilType'] as String?,
  usageType: json['usageType'] as String?,
  monthlyRent: (json['monthlyRent'] as num?)?.toInt(),
  availableStartDate: json['availableStartDate'] as String,
  availableEndDate: json['availableEndDate'] as String,
  waterSupply: json['waterSupply'] as bool?,
  electricitySupply: json['electricitySupply'] as bool?,
  farmingToolsIncluded: json['farmingToolsIncluded'] as bool?,
  contactPhone: json['contactPhone'] as String?,
  contactEmail: json['contactEmail'] as String?,
  status: json['status'] as String,
  imageUrls: (json['imageUrls'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  author: UserResponse.fromJson(json['author'] as Map<String, dynamic>),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$IdleFarmlandResponseToJson(
  IdleFarmlandResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'farmlandName': instance.farmlandName,
  'address': instance.address,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'areaSize': instance.areaSize,
  'soilType': instance.soilType,
  'usageType': instance.usageType,
  'monthlyRent': instance.monthlyRent,
  'availableStartDate': instance.availableStartDate,
  'availableEndDate': instance.availableEndDate,
  'waterSupply': instance.waterSupply,
  'electricitySupply': instance.electricitySupply,
  'farmingToolsIncluded': instance.farmingToolsIncluded,
  'contactPhone': instance.contactPhone,
  'contactEmail': instance.contactEmail,
  'status': instance.status,
  'imageUrls': instance.imageUrls,
  'author': instance.author,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

IdleFarmlandRequest _$IdleFarmlandRequestFromJson(Map<String, dynamic> json) =>
    IdleFarmlandRequest(
      title: json['title'] as String,
      description: json['description'] as String,
      farmlandName: json['farmlandName'] as String,
      address: json['address'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      areaSize: (json['areaSize'] as num).toDouble(),
      monthlyRent: (json['monthlyRent'] as num).toInt(),
      availableStartDate: json['availableStartDate'] as String,
      availableEndDate: json['availableEndDate'] as String,
      contactPhone: json['contactPhone'] as String?,
      soilType: json['soilType'] as String,
      usageType: json['usageType'] as String,
      waterSupply: json['waterSupply'] as bool,
      electricitySupply: json['electricitySupply'] as bool,
      farmingToolsIncluded: json['farmingToolsIncluded'] as bool,
      contactEmail: json['contactEmail'] as String?,
    );

Map<String, dynamic> _$IdleFarmlandRequestToJson(
  IdleFarmlandRequest instance,
) => <String, dynamic>{
  'title': instance.title,
  'description': instance.description,
  'farmlandName': instance.farmlandName,
  'address': instance.address,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'areaSize': instance.areaSize,
  'monthlyRent': instance.monthlyRent,
  'availableStartDate': instance.availableStartDate,
  'availableEndDate': instance.availableEndDate,
  'contactPhone': instance.contactPhone,
  'soilType': instance.soilType,
  'usageType': instance.usageType,
  'waterSupply': instance.waterSupply,
  'electricitySupply': instance.electricitySupply,
  'farmingToolsIncluded': instance.farmingToolsIncluded,
  'contactEmail': instance.contactEmail,
};
