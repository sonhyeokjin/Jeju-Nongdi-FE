// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'place_search_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlaceSearchResponse _$PlaceSearchResponseFromJson(Map<String, dynamic> json) =>
    PlaceSearchResponse(
      status: json['status'] as String,
      errorMessage: json['errorMessage'] as String?,
      places: (json['places'] as List<dynamic>)
          .map((e) => PlaceSearchResult.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PlaceSearchResponseToJson(
  PlaceSearchResponse instance,
) => <String, dynamic>{
  'status': instance.status,
  'errorMessage': instance.errorMessage,
  'places': instance.places,
};

PlaceSearchResult _$PlaceSearchResultFromJson(Map<String, dynamic> json) =>
    PlaceSearchResult(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String?,
      address: json['address'] as String?,
      roadAddress: json['roadAddress'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      location: Location.fromJson(json['location'] as Map<String, dynamic>),
      distance: json['distance'] as String?,
    );

Map<String, dynamic> _$PlaceSearchResultToJson(PlaceSearchResult instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'category': instance.category,
      'address': instance.address,
      'roadAddress': instance.roadAddress,
      'phoneNumber': instance.phoneNumber,
      'location': instance.location,
      'distance': instance.distance,
    };

Location _$LocationFromJson(Map<String, dynamic> json) => Location(
  lat: (json['lat'] as num).toDouble(),
  lng: (json['lng'] as num).toDouble(),
);

Map<String, dynamic> _$LocationToJson(Location instance) => <String, dynamic>{
  'lat': instance.lat,
  'lng': instance.lng,
};

NaverPlaceSearchResponse _$NaverPlaceSearchResponseFromJson(
  Map<String, dynamic> json,
) => NaverPlaceSearchResponse(
  lastBuildDate: json['lastBuildDate'] as String,
  total: (json['total'] as num).toInt(),
  start: (json['start'] as num).toInt(),
  display: (json['display'] as num).toInt(),
  items: (json['items'] as List<dynamic>)
      .map((e) => NaverPlace.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$NaverPlaceSearchResponseToJson(
  NaverPlaceSearchResponse instance,
) => <String, dynamic>{
  'lastBuildDate': instance.lastBuildDate,
  'total': instance.total,
  'start': instance.start,
  'display': instance.display,
  'items': instance.items,
};

NaverPlace _$NaverPlaceFromJson(Map<String, dynamic> json) => NaverPlace(
  title: json['title'] as String,
  link: json['link'] as String,
  category: json['category'] as String,
  description: json['description'] as String,
  telephone: json['telephone'] as String,
  address: json['address'] as String,
  roadAddress: json['roadAddress'] as String,
  mapx: (json['mapx'] as num).toInt(),
  mapy: (json['mapy'] as num).toInt(),
);

Map<String, dynamic> _$NaverPlaceToJson(NaverPlace instance) =>
    <String, dynamic>{
      'title': instance.title,
      'link': instance.link,
      'category': instance.category,
      'description': instance.description,
      'telephone': instance.telephone,
      'address': instance.address,
      'roadAddress': instance.roadAddress,
      'mapx': instance.mapx,
      'mapy': instance.mapy,
    };
