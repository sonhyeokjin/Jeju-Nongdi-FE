import 'package:jejunongdi/core/network/api_client.dart';
import 'package:jejunongdi/core/network/api_exceptions.dart';
import 'package:jejunongdi/core/utils/logger.dart';

/// 농산물 가격 정보를 나타내는 모델 클래스
class CropPrice {
  final String cropName;
  final double currentPrice;
  final String unit;
  final DateTime lastUpdated;
  final double? changeRate;
  final String? trend;

  CropPrice({
    required this.cropName,
    required this.currentPrice,
    required this.unit,
    required this.lastUpdated,
    this.changeRate,
    this.trend,
  });

  factory CropPrice.fromJson(Map<String, dynamic> json) {
    return CropPrice(
      cropName: json['cropName'] as String,
      currentPrice: (json['currentPrice'] as num).toDouble(),
      unit: json['unit'] as String,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      changeRate: json['changeRate'] != null ? (json['changeRate'] as num).toDouble() : null,
      trend: json['trend'] as String?,
    );
  }
}

/// 가격 트렌드 정보를 나타내는 모델 클래스
class PriceTrend {
  final String cropName;
  final List<PricePoint> priceHistory;
  final String analysis;
  final String forecast;

  PriceTrend({
    required this.cropName,
    required this.priceHistory,
    required this.analysis,
    required this.forecast,
  });

  factory PriceTrend.fromJson(Map<String, dynamic> json) {
    return PriceTrend(
      cropName: json['cropName'] as String,
      priceHistory: (json['priceHistory'] as List)
          .map((item) => PricePoint.fromJson(item as Map<String, dynamic>))
          .toList(),
      analysis: json['analysis'] as String,
      forecast: json['forecast'] as String,
    );
  }
}

/// 가격 포인트를 나타내는 모델 클래스
class PricePoint {
  final DateTime date;
  final double price;

  PricePoint({
    required this.date,
    required this.price,
  });

  factory PricePoint.fromJson(Map<String, dynamic> json) {
    return PricePoint(
      date: DateTime.parse(json['date'] as String),
      price: (json['price'] as num).toDouble(),
    );
  }
}

/// 제주 특산품 정보를 나타내는 모델 클래스
class JejuSpecialty {
  final String name;
  final String description;
  final double currentPrice;
  final String season;
  final String region;

  JejuSpecialty({
    required this.name,
    required this.description,
    required this.currentPrice,
    required this.season,
    required this.region,
  });

  factory JejuSpecialty.fromJson(Map<String, dynamic> json) {
    return JejuSpecialty(
      name: json['name'] as String,
      description: json['description'] as String,
      currentPrice: (json['currentPrice'] as num).toDouble(),
      season: json['season'] as String,
      region: json['region'] as String,
    );
  }
}

class PriceService {
  static PriceService? _instance;
  final ApiClient _apiClient = ApiClient.instance;
  
  static PriceService get instance {
    _instance ??= PriceService._internal();
    return _instance!;
  }
  
  PriceService._internal();

  /// 특정 작물의 현재 가격을 조회합니다.
  Future<ApiResult<CropPrice>> getCropPrice(String cropName) async {
    try {
      Logger.info('작물 가격 정보 조회 시도 - cropName: $cropName');
      
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/api/v1/external/price/$cropName',
      );
      
      if (response.data != null) {
        final price = CropPrice.fromJson(response.data!);
        Logger.info('작물 가격 정보 조회 성공: ${price.cropName} - ${price.currentPrice}${price.unit}');
        return ApiResult.success(price);
      } else {
        return ApiResult.failure(const UnknownException('작물 가격 정보 조회 응답이 없습니다.'));
      }
    } catch (e) {
      Logger.error('작물 가격 정보 조회 실패', error: e);
      if (e is ApiException) {
        return ApiResult.failure(e);
      } else {
        return ApiResult.failure(UnknownException('작물 가격 정보 조회 중 오류가 발생했습니다: $e'));
      }
    }
  }

  /// 특정 작물의 가격 동향 분석을 조회합니다.
  Future<ApiResult<String>> getPriceTrend(String cropName) async {
    try {
      Logger.info('가격 동향 분석 조회 시도 - cropName: $cropName');
      
      final response = await _apiClient.get<String>(
        '/api/v1/external/price/trend/$cropName',
      );
      
      if (response.data != null) {
        Logger.info('가격 동향 분석 조회 성공');
        return ApiResult.success(response.data!);
      } else {
        return ApiResult.failure(const UnknownException('가격 동향 분석 조회 응답이 없습니다.'));
      }
    } catch (e) {
      Logger.error('가격 동향 분석 조회 실패', error: e);
      if (e is ApiException) {
        return ApiResult.failure(e);
      } else {
        return ApiResult.failure(UnknownException('가격 동향 분석 조회 중 오류가 발생했습니다: $e'));
      }
    }
  }

  /// 제주 특산품 목록을 조회합니다.
  Future<ApiResult<List<JejuSpecialty>>> getJejuSpecialties() async {
    try {
      Logger.info('제주 특산품 목록 조회 시도');
      
      final response = await _apiClient.get<List<dynamic>>(
        '/api/v1/external/price/jeju-specialties',
      );
      
      if (response.data != null) {
        final specialties = response.data!
            .map((json) => JejuSpecialty.fromJson(json as Map<String, dynamic>))
            .toList();
        Logger.info('제주 특산품 목록 조회 성공: ${specialties.length}개');
        return ApiResult.success(specialties);
      } else {
        return ApiResult.failure(const UnknownException('제주 특산품 목록 조회 응답이 없습니다.'));
      }
    } catch (e) {
      Logger.error('제주 특산품 목록 조회 실패', error: e);
      if (e is ApiException) {
        return ApiResult.failure(e);
      } else {
        return ApiResult.failure(UnknownException('제주 특산품 목록 조회 중 오류가 발생했습니다: $e'));
      }
    }
  }

  /// 작물별 AI 가이드를 조회합니다.
  Future<ApiResult<String>> getCropGuide(String cropName) async {
    try {
      Logger.info('작물별 AI 가이드 조회 시도 - cropName: $cropName');
      
      final response = await _apiClient.get<String>(
        '/api/v1/external/ai/crop-guide/$cropName',
      );
      
      if (response.data != null) {
        Logger.info('작물별 AI 가이드 조회 성공');
        return ApiResult.success(response.data!);
      } else {
        return ApiResult.failure(const UnknownException('작물별 AI 가이드 조회 응답이 없습니다.'));
      }
    } catch (e) {
      Logger.error('작물별 AI 가이드 조회 실패', error: e);
      if (e is ApiException) {
        return ApiResult.failure(e);
      } else {
        return ApiResult.failure(UnknownException('작물별 AI 가이드 조회 중 오류가 발생했습니다: $e'));
      }
    }
  }
}