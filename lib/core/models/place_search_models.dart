import 'package:json_annotation/json_annotation.dart';

part 'place_search_models.g.dart';

@JsonSerializable()
class PlaceSearchResponse {
  final String status;
  final String? errorMessage;
  final List<PlaceSearchResult> places;

  PlaceSearchResponse({
    required this.status,
    this.errorMessage,
    required this.places,
  });

  factory PlaceSearchResponse.fromJson(Map<String, dynamic> json) =>
      _$PlaceSearchResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PlaceSearchResponseToJson(this);
}

@JsonSerializable()
class PlaceSearchResult {
  final String id;
  final String name;
  final String? category;
  final String? address;
  final String? roadAddress;
  final String? phoneNumber;
  final Location location;
  final String? distance;

  PlaceSearchResult({
    required this.id,
    required this.name,
    this.category,
    this.address,
    this.roadAddress,
    this.phoneNumber,
    required this.location,
    this.distance,
  });

  factory PlaceSearchResult.fromJson(Map<String, dynamic> json) =>
      _$PlaceSearchResultFromJson(json);

  Map<String, dynamic> toJson() => _$PlaceSearchResultToJson(this);
}

@JsonSerializable()
class Location {
  final double lat;
  final double lng;

  Location({required this.lat, required this.lng});

  factory Location.fromJson(Map<String, dynamic> json) =>
      _$LocationFromJson(json);

  Map<String, dynamic> toJson() => _$LocationToJson(this);
}

// 네이버 지도 API 실제 응답 형태에 맞는 모델
@JsonSerializable()
class NaverPlaceSearchResponse {
  final String lastBuildDate;
  final int total;
  final int start;
  final int display;
  final List<NaverPlace> items;

  NaverPlaceSearchResponse({
    required this.lastBuildDate,
    required this.total,
    required this.start,
    required this.display,
    required this.items,
  });

  // 수동으로 fromJson 구현 (더 안전한 파싱)
  factory NaverPlaceSearchResponse.fromJson(Map<String, dynamic> json) {
    try {
      final itemsList = json['items'] as List<dynamic>? ?? [];
      final naverPlaces = <NaverPlace>[];

      for (var item in itemsList) {
        try {
          if (item is Map<String, dynamic>) {
            naverPlaces.add(NaverPlace.fromJson(item));
          }
        } catch (e) {
          print('[NaverPlaceSearchResponse] 개별 item 파싱 실패: $e');
          print('실패한 item: $item');
        }
      }

      return NaverPlaceSearchResponse(
        lastBuildDate: json['lastBuildDate']?.toString() ?? '',
        total: (json['total'] as num?)?.toInt() ?? 0,
        start: (json['start'] as num?)?.toInt() ?? 0,
        display: (json['display'] as num?)?.toInt() ?? 0,
        items: naverPlaces,
      );
    } catch (e) {
      print('[NaverPlaceSearchResponse] 전체 파싱 실패: $e');
      return NaverPlaceSearchResponse(
        lastBuildDate: '',
        total: 0,
        start: 0,
        display: 0,
        items: [],
      );
    }
  }

  Map<String, dynamic> toJson() => _$NaverPlaceSearchResponseToJson(this);
}

@JsonSerializable()
class NaverPlace {
  final String title;
  final String link;
  final String category;
  final String description;
  final String telephone;
  final String address;
  final String roadAddress;
  final int mapx; // 네이버 지도 X 좌표 (경도 * 10^7)
  final int mapy; // 네이버 지도 Y 좌표 (위도 * 10^7)

  NaverPlace({
    required this.title,
    required this.link,
    required this.category,
    required this.description,
    required this.telephone,
    required this.address,
    required this.roadAddress,
    required this.mapx,
    required this.mapy,
  });

  // 수동으로 fromJson 구현 (mapx, mapy가 문자열로 올 수 있음)
  factory NaverPlace.fromJson(Map<String, dynamic> json) {
    // mapx, mapy를 안전하게 변환
    int parseCoordinate(dynamic value) {
      if (value is int) {
        return value;
      } else if (value is String) {
        return int.tryParse(value) ?? 0;
      } else if (value is double) {
        return value.toInt();
      } else {
        print('[NaverPlace] 좌표 파싱 실패: $value (${value.runtimeType})');
        return 0;
      }
    }

    return NaverPlace(
      title: json['title']?.toString() ?? '',
      link: json['link']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      telephone: json['telephone']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      roadAddress: json['roadAddress']?.toString() ?? '',
      mapx: parseCoordinate(json['mapx']),
      mapy: parseCoordinate(json['mapy']),
    );
  }

  Map<String, dynamic> toJson() => _$NaverPlaceToJson(this);

  // 네이버 좌표를 일반 위경도로 변환 (더 안전하게)
  double get latitude {
    if (mapy == 0) return 33.375; // 제주도 기본 위도
    return mapy / 10000000.0;
  }

  double get longitude {
    if (mapx == 0) return 126.49; // 제주도 기본 경도
    return mapx / 10000000.0;
  }

  // HTML 태그 제거 (더 안전하게)
  String get cleanTitle {
    try {
      return title.replaceAll(RegExp(r'<[^>]*>'), '');
    } catch (e) {
      return title;
    }
  }

  String get cleanCategory {
    try {
      return category.replaceAll(RegExp(r'<[^>]*>'), '');
    } catch (e) {
      return category;
    }
  }

  String get cleanDescription {
    try {
      return description.replaceAll(RegExp(r'<[^>]*>'), '');
    } catch (e) {
      return description;
    }
  }
}
