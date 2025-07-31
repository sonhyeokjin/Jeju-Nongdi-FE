import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:jejunongdi/core/models/place_search_models.dart';

class PlaceSearchService {
  static PlaceSearchService? _instance;

  static PlaceSearchService get instance =>
      _instance ??= PlaceSearchService._internal();

  PlaceSearchService._internal();

  // 네이버 Search API 키
  static const String _clientId = 'IsNbqEANfYeQY0CgiA0F';
  static const String _clientSecret = 'QUHI_f0i9Y';
  static const String _baseUrl = 'https://openapi.naver.com/v1/search';

  bool get isApiKeyConfigured =>
      _clientId != 'YOUR_NAVER_SEARCH_CLIENT_ID' && _clientId.isNotEmpty;

  Dio? _dio;

  Dio _getDio() {
    _dio ??= Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        // connectTimeout: const Duration(seconds: 10),
        // receiveTimeout: const Duration(seconds: 10),
        headers: {
          'X-Naver-Client-Id': _clientId,
          'X-Naver-Client-Secret': _clientSecret,
        },
      ),
    );
    return _dio!;
  }

  void _log(String message) {
    if (kDebugMode) print('[PlaceSearchService] $message');
  }

  void _logError(String message, dynamic error) {
    if (kDebugMode) print('[PlaceSearchService ERROR] $message: $error');
  }

  /// 네이버 API 연결 테스트
  Future<bool> testNaverApiConnection() async {
    if (!isApiKeyConfigured) {
      _log('API 키가 설정되지 않았습니다');
      return false;
    }

    try {
      _log('네이버 API 연결 테스트 시작...');
      final dio = _getDio();

      final response = await dio.get(
        '/local.json',
        queryParameters: {
          'query': '제주 농장',
          'display': 5,
          'start': 1,
          'sort': 'comment',
        },
      );

      _log('API 테스트 응답: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data;
        _log('API 테스트 성공! 전체 결과: ${data['total']}개');
        return true;
      } else {
        _logError('API 테스트 실패', '상태코드: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      _logError('API 테스트 중 오류', e);
      return false;
    }
  }

  Future<List<NaverPlace>> searchFarmsInBounds({
    required double minLat,
    required double maxLat,
    required double minLng,
    required double maxLng,
  }) async {
    _log('지도 영역 내 농장 검색: ($minLat,$minLng) ~ ($maxLat,$maxLng)');

    // API 키가 설정되지 않았으면 샘플 데이터 사용
    if (!isApiKeyConfigured) {
      _log('네이버 Search API 키가 설정되지 않아 샘플 데이터를 사용합니다');
      return getSampleFarmsInBounds(
        minLat: minLat,
        maxLat: maxLat,
        minLng: minLng,
        maxLng: maxLng,
      );
    }

    try {
      final List<NaverPlace> allFarms = [];

      // 중심점 계산으로 지역 추정
      final centerLat = (minLat + maxLat) / 2;

      // 여러 검색 쿼리로 더 많은 결과 얻기
      final List<String> searchQueries = [
        centerLat > 33.4 ? '제주시 농장' : '서귀포 농장',
        centerLat > 33.4 ? '제주시 농원' : '서귀포 농원',
        '제주 체험농장',
        '제주 목장',
        '제주 과수원',
      ];

      final dio = _getDio();

      for (String searchQuery in searchQueries) {
        try {
          _log('검색 쿼리: $searchQuery');

          final response = await dio.get(
            '/local.json',
            queryParameters: {
              'query': searchQuery,
              'display': 5, // 네이버 API 최대값
              'start': 1,
              'sort': 'comment', // 정확도순
            },
          );

          _log('네이버 API 응답: ${response.statusCode}');

          if (response.statusCode == 200) {
            try {
              final naverResponse = NaverPlaceSearchResponse.fromJson(
                response.data,
              );
              _log(
                '$searchQuery 파싱 성공! 전체 ${naverResponse.total}개 중 ${naverResponse.items.length}개 수신',
              );

              // 농장 관련 장소만 필터링
              final farmPlaces = naverResponse.items.where((place) {
                final lowerTitle = place.cleanTitle.toLowerCase();
                final lowerCategory = place.cleanCategory.toLowerCase();
                final lowerDescription = place.cleanDescription.toLowerCase();

                final isFarm =
                    lowerTitle.contains('농장') ||
                    lowerTitle.contains('농원') ||
                    lowerTitle.contains('목장') ||
                    lowerTitle.contains('체험장') ||
                    lowerTitle.contains('관광농원') ||
                    lowerCategory.contains('농업') ||
                    lowerCategory.contains('농장') ||
                    lowerCategory.contains('목장') ||
                    lowerCategory.contains('과수원') ||
                    lowerDescription.contains('농장') ||
                    lowerDescription.contains('농원');

                // 지역 범위 내 필터링
                final isInBounds =
                    place.latitude >= minLat &&
                    place.latitude <= maxLat &&
                    place.longitude >= minLng &&
                    place.longitude <= maxLng;

                if (isFarm) {
                  _log(
                    '농장 발견: ${place.cleanTitle} (${place.latitude}, ${place.longitude}) - 범위내: $isInBounds',
                  );
                }

                return isFarm && isInBounds;
              }).toList();

              allFarms.addAll(farmPlaces);
            } catch (parseError) {
              _logError('$searchQuery JSON 파싱 오류', parseError);
              _log('원본 응답 키들: ${(response.data as Map).keys.toList()}');
              if (response.data['items'] != null) {
                _log('items 타입: ${response.data['items'].runtimeType}');
                if (response.data['items'] is List &&
                    (response.data['items'] as List).isNotEmpty) {
                  _log('첫 번째 item: ${response.data['items'][0]}');
                }
              }
            }
          } else {
            _logError(
              '$searchQuery 네이버 API 호출 실패',
              '상태코드: ${response.statusCode}',
            );
          }

          // API 호출 간격 조절 (Rate Limit 방지)
          await Future.delayed(const Duration(milliseconds: 300));
        } catch (queryError) {
          _logError('$searchQuery 검색 중 오류', queryError);
          continue;
        }
      }

      // 중복 제거
      final uniqueFarms = <NaverPlace>[];
      final seenCoordinates = <String>{};

      for (final farm in allFarms) {
        final coordKey =
            '${farm.latitude.toStringAsFixed(4)}_${farm.longitude.toStringAsFixed(4)}';
        if (!seenCoordinates.contains(coordKey)) {
          seenCoordinates.add(coordKey);
          uniqueFarms.add(farm);
        }
      }

      _log('최종 필터링된 농장: ${uniqueFarms.length}개 (중복 제거 후)');
      return uniqueFarms;
    } catch (e) {
      if (e is DioException) {
        _logError(
          '네이버 API 오류',
          '${e.response?.statusCode}: ${e.response?.data}',
        );
        _logError('error 메시지', e.message);
        _logError(
          '요청 URL',
          '${e.requestOptions.baseUrl}${e.requestOptions.path}',
        );
        _logError('요청 헤더', e.requestOptions.headers);
        _logError('요청 파라미터', e.requestOptions.queryParameters);
      } else {
        _logError('네이버 API 호출 중 오류', e);
      }
      // 에러 발생 시 샘플 데이터라도 반환
      return getSampleFarmsInBounds(
        minLat: minLat,
        maxLat: maxLat,
        minLng: minLng,
        maxLng: maxLng,
      );
    }
  }

  Future<List<NaverPlace>> searchFarms({required String query}) async {
    _log('농장 검색: $query');

    if (!isApiKeyConfigured) {
      _log('네이버 Search API 키가 설정되지 않아 샘플 데이터에서 검색합니다');
      final allFarms = await getSampleFarms();
      return allFarms.where((farm) {
        final lowerQuery = query.toLowerCase();
        return farm.cleanTitle.toLowerCase().contains(lowerQuery) ||
            farm.cleanDescription.toLowerCase().contains(lowerQuery);
      }).toList();
    }

    try {
      final searchQuery = '$query 농장';
      final dio = _getDio();

      final response = await dio.get(
        '/local.json',
        queryParameters: {
          'query': searchQuery,
          'display': 5, // 네이버 API 최대값
          'start': 1,
          'sort': 'comment',
        },
      );

      if (response.statusCode == 200) {
        final naverResponse = NaverPlaceSearchResponse.fromJson(response.data);

        final farmPlaces = naverResponse.items.where((place) {
          final lowerTitle = place.cleanTitle.toLowerCase();
          final lowerCategory = place.cleanCategory.toLowerCase();
          final lowerDescription = place.cleanDescription.toLowerCase();

          return lowerTitle.contains('농장') ||
              lowerTitle.contains('농원') ||
              lowerTitle.contains('목장') ||
              lowerTitle.contains('체험장') ||
              lowerCategory.contains('농업') ||
              lowerCategory.contains('농장') ||
              lowerCategory.contains('목장') ||
              lowerDescription.contains('농장') ||
              lowerDescription.contains('농원');
        }).toList();

        _log('검색된 농장: ${farmPlaces.length}개');
        return farmPlaces;
      } else {
        _logError('검색 실패', '상태코드: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      if (e is DioException) {
        _logError(
          '농장 검색 API 오류',
          '${e.response?.statusCode}: ${e.response?.data}',
        );
      } else {
        _logError('검색 중 오류', e);
      }
      return [];
    }
  }

  Future<List<NaverPlace>> getSampleFarms() async {
    return [
      // 제주시 지역 농장들
      NaverPlace(
        title: '제주 올레 농장',
        link: '',
        category: '농업>체험농장',
        description: '제주도 대표 체험농장으로 다양한 농촌체험을 할 수 있습니다.',
        telephone: '064-123-4567',
        address: '제주특별자치도 제주시 한림읍 올레길 123',
        roadAddress: '제주특별자치도 제주시 한림읍 올레길 123',
        mapx: 1264900000,
        mapy: 333750000,
      ),
      NaverPlace(
        title: '한라산 감귤농장',
        link: '',
        category: '농업>과수원',
        description: '신선한 제주 감귤을 재배하는 농장입니다.',
        telephone: '064-234-5678',
        address: '제주특별자치도 제주시 애월읍 한라산로 456',
        roadAddress: '제주특별자치도 제주시 애월읍 한라산로 456',
        mapx: 1264800000,
        mapy: 333850000,
      ),
      NaverPlace(
        title: '제주 무궁화 농원',
        link: '',
        category: '농업>농장',
        description: '유기농 채소를 재배하는 친환경 농원입니다.',
        telephone: '064-345-6789',
        address: '제주특별자치도 제주시 조천읍 함덕리 789',
        roadAddress: '제주특별자치도 제주시 조천읍 함덕리 789',
        mapx: 1265100000,
        mapy: 333900000,
      ),
      NaverPlace(
        title: '제주 백록담 목장',
        link: '',
        category: '농업>목장',
        description: '제주 흑돼지와 한우를 기르는 목장입니다.',
        telephone: '064-456-7890',
        address: '제주특별자치도 제주시 구좌읍 종달리 101',
        roadAddress: '제주특별자치도 제주시 구좌읍 종달리 101',
        mapx: 1265300000,
        mapy: 333820000,
      ),

      // 서귀포시 지역 농장들
      NaverPlace(
        title: '성산일출봉 체험농장',
        link: '',
        category: '농업>체험농장',
        description: '성산일출봉 근처의 아름다운 체험농장입니다.',
        telephone: '064-567-8901',
        address: '제주특별자치도 서귀포시 성산읍 성산리 202',
        roadAddress: '제주특별자치도 서귀포시 성산읍 성산리 202',
        mapx: 1265400000,
        mapy: 333500000,
      ),
      NaverPlace(
        title: '천지연 농원',
        link: '',
        category: '농업>농원',
        description: '서귀포 천지연 폭포 근처의 농원입니다.',
        telephone: '064-678-9012',
        address: '제주특별자치도 서귀포시 서귀동 천지연로 303',
        roadAddress: '제주특별자치도 서귀포시 서귀동 천지연로 303',
        mapx: 1264700000,
        mapy: 333300000,
      ),
      NaverPlace(
        title: '중문 관광농원',
        link: '',
        category: '농업>관광농원',
        description: '중문 관광단지의 대표 관광농원입니다.',
        telephone: '064-789-0123',
        address: '제주특별자치도 서귀포시 색달동 중문관광로 404',
        roadAddress: '제주특별자치도 서귀포시 색달동 중문관광로 404',
        mapx: 1264600000,
        mapy: 333200000,
      ),
      NaverPlace(
        title: '한라봉 농장',
        link: '',
        category: '농업>과수원',
        description: '제주 특산품 한라봉을 재배하는 농장입니다.',
        telephone: '064-890-1234',
        address: '제주특별자치도 서귀포시 남원읍 하례리 505',
        roadAddress: '제주특별자치도 서귀포시 남원읍 하례리 505',
        mapx: 1265000000,
        mapy: 333400000,
      ),
      NaverPlace(
        title: '서귀포 말목장',
        link: '',
        category: '농업>목장',
        description: '제주 조랑말을 기르는 전통 목장입니다.',
        telephone: '064-901-2345',
        address: '제주특별자치도 서귀포시 표선면 표선리 606',
        roadAddress: '제주특별자치도 서귀포시 표선면 표선리 606',
        mapx: 1265200000,
        mapy: 333350000,
      ),
      NaverPlace(
        title: '정방폭포 농원',
        link: '',
        category: '농업>농원',
        description: '정방폭포 인근의 조용한 농원입니다.',
        telephone: '064-012-3456',
        address: '제주특별자치도 서귀포시 정방동 폭포로 707',
        roadAddress: '제주특별자치도 서귀포시 정방동 폭포로 707',
        mapx: 1264800000,
        mapy: 333250000,
      ),

      // 추가 농장들
      NaverPlace(
        title: '제주 유기농 체험장',
        link: '',
        category: '농업>체험농장',
        description: '유기농 농법으로 운영되는 친환경 체험농장입니다.',
        telephone: '064-123-9876',
        address: '제주특별자치도 제주시 한경면 저지리 808',
        roadAddress: '제주특별자치도 제주시 한경면 저지리 808',
        mapx: 1264500000,
        mapy: 333700000,
      ),
      NaverPlace(
        title: '곶자왈 농장',
        link: '',
        category: '농업>농장',
        description: '제주 곶자왈 숲 속의 신비로운 농장입니다.',
        telephone: '064-234-8765',
        address: '제주특별자치도 서귀포시 안덕면 덕수리 909',
        roadAddress: '제주특별자치도 서귀포시 안덕면 덕수리 909',
        mapx: 1264400000,
        mapy: 333150000,
      ),
    ];
  }

  Future<List<NaverPlace>> getSampleFarmsInBounds({
    required double minLat,
    required double maxLat,
    required double minLng,
    required double maxLng,
  }) async {
    final allFarms = await getSampleFarms();
    final filtered = allFarms.where((farm) {
      return farm.latitude >= minLat &&
          farm.latitude <= maxLat &&
          farm.longitude >= minLng &&
          farm.longitude <= maxLng;
    }).toList();

    _log('영역 내 샘플 농장: ${filtered.length}개');
    return filtered;
  }

  /// 제주도 전체 농장 검색
  Future<List<NaverPlace>> searchJejuFarms({
    String? specificQuery,
    int display = 25,
    String sortType = 'comment',
  }) async {
    _log('제주도 농장 검색 시작 - 특정 쿼리: $specificQuery');

    // API 키가 설정되지 않았으면 샘플 데이터 사용
    if (!isApiKeyConfigured) {
      _log('네이버 Search API 키가 설정되지 않아 샘플 데이터를 사용합니다');
      return await getSampleFarms();
    }

    try {
      final List<NaverPlace> allFarms = [];

      // 제주도 지역별 검색 쿼리 목록
      final List<String> searchQueries = [
        specificQuery != null ? '$specificQuery 제주 농장' : '제주시 농장',
        specificQuery != null ? '$specificQuery 서귀포 농장' : '서귀포 농장',
        specificQuery != null ? '$specificQuery 제주 농원' : '제주 농원',
        specificQuery != null ? '$specificQuery 제주 목장' : '제주 목장',
        specificQuery != null ? '$specificQuery 제주 체험농장' : '제주 체험농장',
      ];

      final dio = _getDio();

      // 각 쿼리별로 검색 수행
      for (String query in searchQueries) {
        try {
          _log('검색 쿼리: $query');

          final response = await dio.get(
            '/local.json',
            queryParameters: {
              'query': query,
              'display': 5, // 네이버 API 최대값
              'start': 1,
              'sort': sortType == 'random' ? 'comment' : sortType,
            },
          );

          if (response.statusCode == 200) {
            try {
              final naverResponse = NaverPlaceSearchResponse.fromJson(
                response.data,
              );
              _log('$query 검색 결과: ${naverResponse.items.length}개');

              // 농장 관련 장소만 필터링하고 제주도 범위 내 확인
              final farmPlaces = naverResponse.items.where((place) {
                // 농장 키워드 체크
                final lowerTitle = place.cleanTitle.toLowerCase();
                final lowerCategory = place.cleanCategory.toLowerCase();
                final lowerDescription = place.cleanDescription.toLowerCase();

                final isFarm =
                    lowerTitle.contains('농장') ||
                    lowerTitle.contains('농원') ||
                    lowerTitle.contains('체험장') ||
                    lowerTitle.contains('관광농원') ||
                    lowerCategory.contains('농업') ||
                    lowerCategory.contains('농장') ||
                    lowerCategory.contains('목장') ||
                    lowerCategory.contains('과수원') ||
                    lowerDescription.contains('농장') ||
                    lowerDescription.contains('농원');

                // 제주도 지역 범위 확인 (대략적인 제주도 좌표 범위)
                final isInJeju =
                    place.latitude >= 33.1 &&
                    place.latitude <= 33.6 &&
                    place.longitude >= 126.0 &&
                    place.longitude <= 127.0;

                // 주소에 제주 포함 여부 확인
                final addressContainsJeju =
                    place.address.contains('제주') ||
                    place.roadAddress.contains('제주');

                if (isFarm && (isInJeju || addressContainsJeju)) {
                  _log(
                    '제주 농장 발견: ${place.cleanTitle} (${place.latitude}, ${place.longitude})',
                  );
                  return true;
                }

                return false;
              }).toList();

              allFarms.addAll(farmPlaces);
            } catch (parseError) {
              _logError('$query JSON 파싱 오류', parseError);
            }
          } else {
            _logError('$query 검색 실패', '상태코드: ${response.statusCode}');
          }

          // API 호출 간격 조절 (Rate Limit 방지)
          await Future.delayed(const Duration(milliseconds: 500));
        } catch (queryError) {
          _logError('$query 검색 중 오류', queryError);
          continue; // 다음 쿼리 계속 진행
        }
      }

      // 중복 제거 (같은 좌표나 같은 제목의 농장)
      final uniqueFarms = <NaverPlace>[];
      final seenTitles = <String>{};
      final seenCoordinates = <String>{};

      for (final farm in allFarms) {
        final coordKey =
            '${farm.latitude.toStringAsFixed(4)}_${farm.longitude.toStringAsFixed(4)}';
        final titleKey = farm.cleanTitle.toLowerCase().trim();

        if (!seenTitles.contains(titleKey) &&
            !seenCoordinates.contains(coordKey)) {
          seenTitles.add(titleKey);
          seenCoordinates.add(coordKey);
          uniqueFarms.add(farm);
        }
      }

      _log('제주도 농장 검색 완료: 총 ${uniqueFarms.length}개 (중복 제거 후)');
      return uniqueFarms;
    } catch (e) {
      if (e is DioException) {
        _logError(
          '제주 농장 검색 API 오류',
          '${e.response?.statusCode}: ${e.response?.data}',
        );
        _logError(
          '요청 URL',
          '${e.requestOptions.baseUrl}${e.requestOptions.path}',
        );
        _logError('요청 파라미터', e.requestOptions.queryParameters);
      } else {
        _logError('제주 농장 검색 중 오류', e);
      }

      // 에러 발생 시 샘플 데이터라도 반환
      _log('API 오류로 인해 샘플 데이터를 반환합니다');
      return await getSampleFarms();
    }
  }
}
