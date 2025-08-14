import 'package:flutter/foundation.dart';
import 'package:jejunongdi/core/models/place_search_models.dart';

class PlaceSearchService {
  static PlaceSearchService? _instance;
  static PlaceSearchService get instance => _instance ??= PlaceSearchService._internal();
  PlaceSearchService._internal();

  static const String _clientId = 'IsNbqEANfYeQY0CgiA0F';
  static const String _clientSecret = 'QUHI_f0i9Y';

  bool get isApiKeyConfigured => _clientId != 'YOUR_NAVER_CLIENT_ID';

  void _log(String message) {
    if (kDebugMode) print('[PlaceSearchService] $message');
  }

  Future<List<NaverPlace>> searchFarmsInBounds({
    required double minLat,
    required double maxLat,
    required double minLng,
    required double maxLng,
  }) async {
    _log('지도 영역 내 농장 검색: ($minLat,$minLng) ~ ($maxLat,$maxLng)');
    
    // API 키가 없으면 샘플 데이터 필터링
    if (!isApiKeyConfigured) {
      return getSampleFarmsInBounds(
        minLat: minLat, maxLat: maxLat, minLng: minLng, maxLng: maxLng);
    }
    
    // 실제 API 호출은 네이버 개발자 키가 필요
    _log('실제 네이버 API 호출을 위해서는 개발자 키가 필요합니다');
    return [];
  }

  Future<List<NaverPlace>> getSampleFarms() async {
    return [
      NaverPlace(
        title: '제주 올레 농장',
        link: '',
        category: '농업>체험농장',
        description: '제주도 대표 체험농장',
        telephone: '064-123-4567',
        address: '제주특별자치도 제주시 올레길 123',
        roadAddress: '제주특별자치도 제주시 올레길 123',
        mapx: 1264900000,
        mapy: 333750000,
      ),
      NaverPlace(
        title: '한라산 감귤농장',
        link: '',
        category: '농업>과수원',  
        description: '신선한 제주 감귤을 재배하는 농장',
        telephone: '064-234-5678',
        address: '제주특별자치도 서귀포시 한라산로 456',
        roadAddress: '제주특별자치도 서귀포시 한라산로 456',
        mapx: 1264800000,
        mapy: 333650000,
      ),
      NaverPlace(
        title: '성산일출봉 체험농장',
        link: '',
        category: '농업>체험농장',
        description: '성산일출봉 근처의 아름다운 체험농장',  
        telephone: '064-345-6789',
        address: '제주특별자치도 서귀포시 성산읍 성산리 789',
        roadAddress: '제주특별자치도 서귀포시 성산읍 성산리 789',
        mapx: 1265000000,
        mapy: 333800000,
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
      return farm.latitude >= minLat && farm.latitude <= maxLat &&
             farm.longitude >= minLng && farm.longitude <= maxLng;
    }).toList();
    
    _log('영역 내 샘플 농장: ${filtered.length}개');
    return filtered;
  }

  Future<List<NaverPlace>> searchFarms({required String query}) async {
    _log('농장 검색: $query');
    final allFarms = await getSampleFarms();
    return allFarms.where((farm) {
      final lowerQuery = query.toLowerCase();
      return farm.cleanTitle.toLowerCase().contains(lowerQuery) ||
             farm.cleanDescription.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}
