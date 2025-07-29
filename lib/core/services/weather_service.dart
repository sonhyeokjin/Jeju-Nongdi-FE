import 'package:jejunongdi/core/network/api_client.dart';
import 'package:jejunongdi/core/network/api_exceptions.dart';
import 'package:jejunongdi/core/utils/logger.dart';

/// 날씨 정보를 나타내는 모델 클래스
class WeatherInfo {
  final String location;
  final double temperature;
  final String description;
  final double humidity;
  final double windSpeed;
  final DateTime lastUpdated;

  WeatherInfo({
    required this.location,
    required this.temperature,
    required this.description,
    required this.humidity,
    required this.windSpeed,
    required this.lastUpdated,
  });

  factory WeatherInfo.fromJson(Map<String, dynamic> json) {
    return WeatherInfo(
      location: json['location'] as String,
      temperature: (json['temperature'] as num).toDouble(),
      description: json['description'] as String,
      humidity: (json['humidity'] as num).toDouble(),
      windSpeed: (json['windSpeed'] as num).toDouble(),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }
}

/// 농작업 날씨 정보를 나타내는 모델 클래스
class FarmWorkWeather {
  final String workType;
  final bool isRecommended;
  final String recommendation;
  final DateTime date;

  FarmWorkWeather({
    required this.workType,
    required this.isRecommended,
    required this.recommendation,
    required this.date,
  });

  factory FarmWorkWeather.fromJson(Map<String, dynamic> json) {
    return FarmWorkWeather(
      workType: json['workType'] as String,
      isRecommended: json['isRecommended'] as bool,
      recommendation: json['recommendation'] as String,
      date: DateTime.parse(json['date'] as String),
    );
  }
}

class WeatherService {
  static WeatherService? _instance;
  final ApiClient _apiClient = ApiClient.instance;
  
  static WeatherService get instance {
    _instance ??= WeatherService._internal();
    return _instance!;
  }
  
  WeatherService._internal();

  /// 날씨 요약 정보를 조회합니다.
  Future<ApiResult<String>> getWeatherSummary() async {
    try {
      Logger.info('날씨 요약 정보 조회 시도');
      
      final response = await _apiClient.get<String>(
        '/api/v1/external/weather/summary',
      );
      
      if (response.data != null) {
        Logger.info('날씨 요약 정보 조회 성공');
        return ApiResult.success(response.data!);
      } else {
        return ApiResult.failure(const UnknownException('날씨 요약 정보 조회 응답이 없습니다.'));
      }
    } catch (e) {
      Logger.error('날씨 요약 정보 조회 실패', error: e);
      if (e is ApiException) {
        return ApiResult.failure(e);
      } else {
        return ApiResult.failure(UnknownException('날씨 요약 정보 조회 중 오류가 발생했습니다: $e'));
      }
    }
  }

  /// 제주 지역 날씨 정보를 조회합니다.
  Future<ApiResult<WeatherInfo>> getJejuWeather() async {
    try {
      Logger.info('제주 지역 날씨 정보 조회 시도');
      
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/api/v1/external/weather/jeju',
      );
      
      if (response.data != null) {
        final weather = WeatherInfo.fromJson(response.data!);
        Logger.info('제주 지역 날씨 정보 조회 성공: ${weather.location}');
        return ApiResult.success(weather);
      } else {
        return ApiResult.failure(const UnknownException('제주 날씨 정보 조회 응답이 없습니다.'));
      }
    } catch (e) {
      Logger.error('제주 지역 날씨 정보 조회 실패', error: e);
      if (e is ApiException) {
        return ApiResult.failure(e);
      } else {
        return ApiResult.failure(UnknownException('제주 날씨 정보 조회 중 오류가 발생했습니다: $e'));
      }
    }
  }

  /// 농작업별 날씨 권장사항을 조회합니다.
  Future<ApiResult<String>> getFarmWorkWeather() async {
    try {
      Logger.info('농작업별 날씨 권장사항 조회 시도');
      
      final response = await _apiClient.get<String>(
        '/api/v1/external/weather/farm-work',
      );
      
      if (response.data != null) {
        Logger.info('농작업별 날씨 권장사항 조회 성공');
        return ApiResult.success(response.data!);
      } else {
        return ApiResult.failure(const UnknownException('농작업 날씨 권장사항 조회 응답이 없습니다.'));
      }
    } catch (e) {
      Logger.error('농작업별 날씨 권장사항 조회 실패', error: e);
      if (e is ApiException) {
        return ApiResult.failure(e);
      } else {
        return ApiResult.failure(UnknownException('농작업 날씨 권장사항 조회 중 오류가 발생했습니다: $e'));
      }
    }
  }

  /// 모든 외부 API를 테스트합니다.
  Future<ApiResult<String>> testAllApis(int userId) async {
    try {
      Logger.info('전체 API 테스트 시도 - userId: $userId');
      
      final response = await _apiClient.get<String>(
        '/api/v1/external/test/all/$userId',
      );
      
      if (response.data != null) {
        Logger.info('전체 API 테스트 성공');
        return ApiResult.success(response.data!);
      } else {
        return ApiResult.failure(const UnknownException('전체 API 테스트 응답이 없습니다.'));
      }
    } catch (e) {
      Logger.error('전체 API 테스트 실패', error: e);
      if (e is ApiException) {
        return ApiResult.failure(e);
      } else {
        return ApiResult.failure(UnknownException('전체 API 테스트 중 오류가 발생했습니다: $e'));
      }
    }
  }

  /// 사용자별 날씨 기반 AI 조언을 조회합니다.
  Future<ApiResult<String>> getWeatherAdvice(int userId) async {
    try {
      Logger.info('날씨 기반 AI 조언 조회 시도 - userId: $userId');
      
      final response = await _apiClient.get<String>(
        '/api/v1/external/ai/weather-advice/$userId',
      );
      
      if (response.data != null) {
        Logger.info('날씨 기반 AI 조언 조회 성공');
        return ApiResult.success(response.data!);
      } else {
        return ApiResult.failure(const UnknownException('날씨 기반 AI 조언 조회 응답이 없습니다.'));
      }
    } catch (e) {
      Logger.error('날씨 기반 AI 조언 조회 실패', error: e);
      if (e is ApiException) {
        return ApiResult.failure(e);
      } else {
        return ApiResult.failure(UnknownException('날씨 기반 AI 조언 조회 중 오류가 발생했습니다: $e'));
      }
    }
  }
}