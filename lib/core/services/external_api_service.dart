import 'package:jejunongdi/core/network/api_client.dart';
import 'package:jejunongdi/core/network/api_exceptions.dart';
import 'package:jejunongdi/core/utils/logger.dart';

class ExternalApiService {
  static ExternalApiService? _instance;
  final ApiClient _apiClient = ApiClient.instance;
  
  static ExternalApiService get instance {
    _instance ??= ExternalApiService._internal();
    return _instance!;
  }
  
  ExternalApiService._internal();
  
  /// 사용자의 작물들에 대한 AI 수익성 분석을 제공합니다.
  Future<ApiResult<String>> getProfitAnalysis(int userId) async {
    try {
      Logger.info('AI 수익성 분석 요청 시도 - userId: $userId');
      
      final response = await _apiClient.post<String>(
        '/api/v1/external/ai/profit-analysis/$userId',
      );
      
      if (response.data != null) {
        Logger.info('AI 수익성 분석 응답 수신 성공');
        return ApiResult.success(response.data!);
      } else {
        return ApiResult.failure(const UnknownException('수익성 분석 응답이 없습니다.'));
      }
    } catch (e) {
      Logger.error('AI 수익성 분석 요청 실패', error: e);
      if (e is ApiException) {
        return ApiResult.failure(e);
      } else {
        return ApiResult.failure(UnknownException('수익성 분석 중 오류가 발생했습니다: $e'));
      }
    }
  }
  
  /// OpenAI를 활용한 농업 조언을 생성합니다.
  Future<ApiResult<String>> getAiAdvice({
    required String question,
    int? userId,
  }) async {
    try {
      Logger.info('AI 농업 조언 요청 시도 - question: $question, userId: $userId');
      
      final queryParameters = <String, dynamic>{
        'question': question,
      };
      
      if (userId != null) {
        queryParameters['userId'] = userId;
      }
      
      final response = await _apiClient.post<String>(
        '/api/v1/external/ai/advice',
        queryParameters: queryParameters,
      );
      
      if (response.data != null) {
        Logger.info('AI 농업 조언 응답 수신 성공');
        return ApiResult.success(response.data!);
      } else {
        return ApiResult.failure(const UnknownException('AI 조언 응답이 없습니다.'));
      }
    } catch (e) {
      Logger.error('AI 농업 조언 요청 실패', error: e);
      if (e is ApiException) {
        return ApiResult.failure(e);
      } else {
        return ApiResult.failure(UnknownException('AI 조언 요청 중 오류가 발생했습니다: $e'));
      }
    }
  }
  
  /// 질문의 유효성을 검사합니다.
  bool validateQuestion(String question) {
    // 빈 문자열 검사
    if (question.trim().isEmpty) {
      Logger.warning('질문이 비어있습니다.');
      return false;
    }
    
    // 너무 짧은 질문 검사 (최소 5자)
    if (question.trim().length < 5) {
      Logger.warning('질문이 너무 짧습니다: ${question.length}자');
      return false;
    }
    
    // 너무 긴 질문 검사 (최대 1000자)
    if (question.length > 1000) {
      Logger.warning('질문이 너무 깁니다: ${question.length}자');
      return false;
    }
    
    // 부적절한 내용 간단 검사 (실제로는 더 정교한 필터링 필요)
    final inappropriateWords = ['스팸', '광고', '욕설'];
    final lowerQuestion = question.toLowerCase();
    
    for (final word in inappropriateWords) {
      if (lowerQuestion.contains(word.toLowerCase())) {
        Logger.warning('부적절한 내용이 포함된 질문입니다.');
        return false;
      }
    }
    
    Logger.info('질문 유효성 검사 통과');
    return true;
  }
  
  /// 농업 관련 질문인지 확인합니다.
  bool isAgricultureRelated(String question) {
    final agricultureKeywords = [
      '농업', '농사', '작물', '재배', '수확', '씨앗', '파종', '비료', '농약', '병해충',
      '토양', '물주기', '가지치기', '접목', '온실', '시설원예', '유기농', '친환경',
      '감귤', '귤', '오렌지', '채소', '과일', '쌀', '벼', '밭', '논', '농장',
      '농부', '일손', '농기계', '트랙터', '수확기', '날씨', '기후', '온도', '습도'
    ];
    
    final lowerQuestion = question.toLowerCase();
    
    for (final keyword in agricultureKeywords) {
      if (lowerQuestion.contains(keyword)) {
        Logger.info('농업 관련 질문으로 확인됨');
        return true;
      }
    }
    
    Logger.info('농업과 관련이 없는 질문일 수 있습니다.');
    return false;
  }
  
  /// 질문을 전처리합니다.
  String preprocessQuestion(String question) {
    // 앞뒤 공백 제거
    String processed = question.trim();
    
    // 연속된 공백을 하나로 변환
    processed = processed.replaceAll(RegExp(r'\s+'), ' ');
    
    // 질문 끝에 물음표가 없으면 추가
    if (!processed.endsWith('?') && !processed.endsWith('？')) {
      processed += '?';
    }
    
    Logger.info('질문 전처리 완료: $processed');
    return processed;
  }

  /// 작물별 AI 재배 가이드를 조회합니다.
  Future<ApiResult<String>> getCropGuide(String cropName) async {
    try {
      Logger.info('작물별 AI 재배 가이드 조회 시도 - cropName: $cropName');
      
      final response = await _apiClient.get<String>(
        '/api/v1/external/ai/crop-guide/$cropName',
      );
      
      if (response.data != null) {
        Logger.info('작물별 AI 재배 가이드 조회 성공');
        return ApiResult.success(response.data!);
      } else {
        return ApiResult.failure(const UnknownException('작물별 AI 재배 가이드 조회 응답이 없습니다.'));
      }
    } catch (e) {
      Logger.error('작물별 AI 재배 가이드 조회 실패', error: e);
      if (e is ApiException) {
        return ApiResult.failure(e);
      } else {
        return ApiResult.failure(UnknownException('작물별 AI 재배 가이드 조회 중 오류가 발생했습니다: $e'));
      }
    }
  }

  /// 사용자별 날씨 기반 AI 조언을 조회합니다.
  Future<ApiResult<String>> getWeatherAdvice(int userId) async {
    try {
      Logger.info('사용자별 날씨 기반 AI 조언 조회 시도 - userId: $userId');
      
      final response = await _apiClient.get<String>(
        '/api/v1/external/ai/weather-advice/$userId',
      );
      
      if (response.data != null) {
        Logger.info('사용자별 날씨 기반 AI 조언 조회 성공');
        return ApiResult.success(response.data!);
      } else {
        return ApiResult.failure(const UnknownException('날씨 기반 AI 조언 조회 응답이 없습니다.'));
      }
    } catch (e) {
      Logger.error('사용자별 날씨 기반 AI 조언 조회 실패', error: e);
      if (e is ApiException) {
        return ApiResult.failure(e);
      } else {
        return ApiResult.failure(UnknownException('날씨 기반 AI 조언 조회 중 오류가 발생했습니다: $e'));
      }
    }
  }

  /// 제주 특산품 가격 정보를 조회합니다.
  Future<ApiResult<Map<String, dynamic>>> getJejuSpecialtiesPrice() async {
    try {
      Logger.info('제주 특산품 가격 정보 조회 시도');
      
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/api/v1/external/price/jeju-specialties',
      );
      
      if (response.data != null) {
        Logger.info('제주 특산품 가격 정보 조회 성공');
        return ApiResult.success(response.data!);
      } else {
        return ApiResult.failure(const UnknownException('제주 특산품 가격 정보 조회 응답이 없습니다.'));
      }
    } catch (e) {
      Logger.error('제주 특산품 가격 정보 조회 실패', error: e);
      if (e is ApiException) {
        return ApiResult.failure(e);
      } else {
        return ApiResult.failure(UnknownException('제주 특산품 가격 정보 조회 중 오류가 발생했습니다: $e'));
      }
    }
  }

  /// 작물별 가격 추이를 조회합니다.
  Future<ApiResult<Map<String, dynamic>>> getPriceTrend(String cropName) async {
    try {
      Logger.info('작물별 가격 추이 조회 시도 - cropName: $cropName');
      
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/api/v1/external/price/trend/$cropName',
      );
      
      if (response.data != null) {
        Logger.info('작물별 가격 추이 조회 성공');
        return ApiResult.success(response.data!);
      } else {
        return ApiResult.failure(const UnknownException('작물별 가격 추이 조회 응답이 없습니다.'));
      }
    } catch (e) {
      Logger.error('작물별 가격 추이 조회 실패', error: e);
      if (e is ApiException) {
        return ApiResult.failure(e);
      } else {
        return ApiResult.failure(UnknownException('작물별 가격 추이 조회 중 오류가 발생했습니다: $e'));
      }
    }
  }

  /// 작물별 현재 가격을 조회합니다.
  Future<ApiResult<Map<String, dynamic>>> getCropPrice(String cropName) async {
    try {
      Logger.info('작물별 현재 가격 조회 시도 - cropName: $cropName');
      
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/api/v1/external/price/$cropName',
      );
      
      if (response.data != null) {
        Logger.info('작물별 현재 가격 조회 성공');
        return ApiResult.success(response.data!);
      } else {
        return ApiResult.failure(const UnknownException('작물별 현재 가격 조회 응답이 없습니다.'));
      }
    } catch (e) {
      Logger.error('작물별 현재 가격 조회 실패', error: e);
      if (e is ApiException) {
        return ApiResult.failure(e);
      } else {
        return ApiResult.failure(UnknownException('작물별 현재 가격 조회 중 오류가 발생했습니다: $e'));
      }
    }
  }

  /// 모든 외부 API 테스트를 실행합니다.
  Future<ApiResult<Map<String, dynamic>>> testAllExternalApis(int userId) async {
    try {
      Logger.info('모든 외부 API 테스트 실행 시도 - userId: $userId');
      
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/api/v1/external/test/all/$userId',
      );
      
      if (response.data != null) {
        Logger.info('모든 외부 API 테스트 실행 성공');
        return ApiResult.success(response.data!);
      } else {
        return ApiResult.failure(const UnknownException('외부 API 테스트 실행 응답이 없습니다.'));
      }
    } catch (e) {
      Logger.error('모든 외부 API 테스트 실행 실패', error: e);
      if (e is ApiException) {
        return ApiResult.failure(e);
      } else {
        return ApiResult.failure(UnknownException('외부 API 테스트 실행 중 오류가 발생했습니다: $e'));
      }
    }
  }

  /// 농업 작업 추천 날씨 정보를 조회합니다.
  Future<ApiResult<Map<String, dynamic>>> getFarmWorkWeather() async {
    try {
      Logger.info('농업 작업 추천 날씨 정보 조회 시도');
      
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/api/v1/external/weather/farm-work',
      );
      
      if (response.data != null) {
        Logger.info('농업 작업 추천 날씨 정보 조회 성공');
        return ApiResult.success(response.data!);
      } else {
        return ApiResult.failure(const UnknownException('농업 작업 추천 날씨 정보 조회 응답이 없습니다.'));
      }
    } catch (e) {
      Logger.error('농업 작업 추천 날씨 정보 조회 실패', error: e);
      if (e is ApiException) {
        return ApiResult.failure(e);
      } else {
        return ApiResult.failure(UnknownException('농업 작업 추천 날씨 정보 조회 중 오류가 발생했습니다: $e'));
      }
    }
  }

  /// 제주 날씨 정보를 조회합니다.
  Future<ApiResult<Map<String, dynamic>>> getJejuWeather() async {
    try {
      Logger.info('제주 날씨 정보 조회 시도');
      
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/api/v1/external/weather/jeju',
      );
      
      if (response.data != null) {
        Logger.info('제주 날씨 정보 조회 성공');
        return ApiResult.success(response.data!);
      } else {
        return ApiResult.failure(const UnknownException('제주 날씨 정보 조회 응답이 없습니다.'));
      }
    } catch (e) {
      Logger.error('제주 날씨 정보 조회 실패', error: e);
      if (e is ApiException) {
        return ApiResult.failure(e);
      } else {
        return ApiResult.failure(UnknownException('제주 날씨 정보 조회 중 오류가 발생했습니다: $e'));
      }
    }
  }

  /// 날씨 요약 정보를 조회합니다.
  Future<ApiResult<Map<String, dynamic>>> getWeatherSummary() async {
    try {
      Logger.info('날씨 요약 정보 조회 시도');
      
      final response = await _apiClient.get<Map<String, dynamic>>(
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
}