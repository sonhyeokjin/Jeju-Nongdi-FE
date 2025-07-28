import 'package:jejunongdi/core/models/ai_tip_models.dart';
import 'package:jejunongdi/core/network/api_client.dart';
import 'package:jejunongdi/core/network/api_exceptions.dart';
import 'package:jejunongdi/core/utils/logger.dart';

class AiTipService {
  static AiTipService? _instance;
  final ApiClient _apiClient = ApiClient.instance;
  
  static AiTipService get instance {
    _instance ??= AiTipService._internal();
    return _instance!;
  }
  
  AiTipService._internal();
  
  /// 특정 사용자를 위한 일일 맞춤 팁을 생성합니다.
  Future<ApiResult<String>> generateDailyTips(int userId) async {
    try {
      Logger.info('일일 맞춤 팁 생성 시도 - userId: $userId');
      
      final response = await _apiClient.post<String>(
        '/api/v1/ai-tips/generate/$userId',
      );
      
      if (response.data != null) {
        Logger.info('일일 맞춤 팁 생성 성공');
        return ApiResult.success(response.data!);
      } else {
        return ApiResult.failure(const UnknownException('팁 생성 응답이 없습니다.'));
      }
    } catch (e) {
      Logger.error('일일 맞춤 팁 생성 실패', error: e);
      if (e is ApiException) {
        return ApiResult.failure(e);
      } else {
        return ApiResult.failure(UnknownException('팁 생성 중 오류가 발생했습니다: $e'));
      }
    }
  }
  
  /// 관리자가 수동으로 팁을 생성합니다.
  Future<ApiResult<AiTipResponseDto>> createTip({
    required int userId,
    required String tipType,
    required String title,
    required String content,
    String? cropType,
  }) async {
    try {
      Logger.info('수동 팁 생성 시도 - userId: $userId, tipType: $tipType');
      
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/api/v1/ai-tips/create',
        queryParameters: {
          'userId': userId,
          'tipType': tipType,
          'title': title,
          'content': content,
          if (cropType != null) 'cropType': cropType,
        },
      );
      
      if (response.data != null) {
        final tip = AiTipResponseDto.fromJson(response.data!);
        Logger.info('수동 팁 생성 성공: ${tip.title}');
        return ApiResult.success(tip);
      } else {
        return ApiResult.failure(const UnknownException('팁 생성 응답이 없습니다.'));
      }
    } catch (e) {
      Logger.error('수동 팁 생성 실패', error: e);
      if (e is ApiException) {
        return ApiResult.failure(e);
      } else {
        return ApiResult.failure(UnknownException('팁 생성 중 오류가 발생했습니다: $e'));
      }
    }
  }
  
  /// 특정 팁을 읽음 상태로 변경합니다.
  Future<ApiResult<String>> markTipAsRead(int tipId) async {
    try {
      Logger.info('팁 읽음 처리 시도 - tipId: $tipId');
      
      final response = await _apiClient.put<String>(
        '/api/v1/ai-tips/$tipId/read',
      );
      
      if (response.data != null) {
        Logger.info('팁 읽음 처리 성공');
        return ApiResult.success(response.data!);
      } else {
        return ApiResult.failure(const UnknownException('팁 읽음 처리 응답이 없습니다.'));
      }
    } catch (e) {
      Logger.error('팁 읽음 처리 실패', error: e);
      if (e is ApiException) {
        return ApiResult.failure(e);
      } else {
        return ApiResult.failure(UnknownException('팁 읽음 처리 중 오류가 발생했습니다: $e'));
      }
    }
  }
  
  /// 사용자의 읽지 않은 팁 목록을 조회합니다. (로컬 구현)
  Future<ApiResult<List<AiTipResponseDto>>> getUnreadTips(int userId) async {
    try {
      Logger.info('읽지 않은 팁 목록 조회 시도 - userId: $userId');
      
      // TODO: 백엔드에 읽지 않은 팁 목록 API가 추가되면 실제 API 호출로 변경
      // 현재는 빈 목록 반환
      const List<AiTipResponseDto> unreadTips = [];
      
      Logger.info('읽지 않은 팁 목록 조회 성공: ${unreadTips.length}개');
      return ApiResult.success(unreadTips);
    } catch (e) {
      Logger.error('읽지 않은 팁 목록 조회 실패', error: e);
      return ApiResult.failure(UnknownException('팁 목록 조회 중 오류가 발생했습니다: $e'));
    }
  }
  
  /// 사용자의 모든 팁 목록을 조회합니다. (로컬 구현)
  Future<ApiResult<List<AiTipResponseDto>>> getAllTips(int userId) async {
    try {
      Logger.info('모든 팁 목록 조회 시도 - userId: $userId');
      
      // TODO: 백엔드에 팁 목록 API가 추가되면 실제 API 호출로 변경
      // 현재는 빈 목록 반환
      const List<AiTipResponseDto> allTips = [];
      
      Logger.info('모든 팁 목록 조회 성공: ${allTips.length}개');
      return ApiResult.success(allTips);
    } catch (e) {
      Logger.error('모든 팁 목록 조회 실패', error: e);
      return ApiResult.failure(UnknownException('팁 목록 조회 중 오류가 발생했습니다: $e'));
    }
  }

  /// 사용자의 일일 팁 목록을 조회합니다.
  Future<ApiResult<Map<String, dynamic>>> getDailyTips({
    required int userId,
    String? targetDate,
    List<String>? tipTypes,
    String? cropType,
    int? priorityLevel,
    bool onlyUnread = false,
  }) async {
    try {
      Logger.info('일일 팁 목록 조회 시도 - userId: $userId');
      
      final queryParameters = <String, dynamic>{};
      if (targetDate != null) queryParameters['targetDate'] = targetDate;
      if (tipTypes != null) queryParameters['tipTypes'] = tipTypes;
      if (cropType != null) queryParameters['cropType'] = cropType;
      if (priorityLevel != null) queryParameters['priorityLevel'] = priorityLevel;
      queryParameters['onlyUnread'] = onlyUnread;
      
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/api/v1/ai-tips/daily/$userId',
        queryParameters: queryParameters,
      );
      
      if (response.data != null) {
        Logger.info('일일 팁 목록 조회 성공');
        return ApiResult.success(response.data!);
      } else {
        return ApiResult.failure(const UnknownException('일일 팁 조회 응답이 없습니다.'));
      }
    } catch (e) {
      Logger.error('일일 팁 목록 조회 실패', error: e);
      if (e is ApiException) {
        return ApiResult.failure(e);
      } else {
        return ApiResult.failure(UnknownException('일일 팁 조회 중 오류가 발생했습니다: $e'));
      }
    }
  }

  /// 오늘의 농살 - 메인 화면용 팁을 조회합니다.
  Future<ApiResult<Map<String, dynamic>>> getTodayFarmLife(int userId) async {
    try {
      Logger.info('오늘의 농살 조회 시도 - userId: $userId');
      
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/api/v1/ai-tips/today/$userId',
      );
      
      if (response.data != null) {
        Logger.info('오늘의 농살 조회 성공');
        return ApiResult.success(response.data!);
      } else {
        return ApiResult.failure(const UnknownException('오늘의 농살 조회 응답이 없습니다.'));
      }
    } catch (e) {
      Logger.error('오늘의 농살 조회 실패', error: e);
      if (e is ApiException) {
        return ApiResult.failure(e);
      } else {
        return ApiResult.failure(UnknownException('오늘의 농살 조회 중 오류가 발생했습니다: $e'));
      }
    }
  }

  /// 팁 유형 목록을 조회합니다.
  Future<ApiResult<List<Map<String, dynamic>>>> getTipTypes() async {
    try {
      Logger.info('팁 유형 목록 조회 시도');
      
      final response = await _apiClient.get<List<dynamic>>(
        '/api/v1/ai-tips/types',
      );
      
      if (response.data != null) {
        final types = response.data!.cast<Map<String, dynamic>>();
        Logger.info('팁 유형 목록 조회 성공: ${types.length}개');
        return ApiResult.success(types);
      } else {
        return ApiResult.failure(const UnknownException('팁 유형 조회 응답이 없습니다.'));
      }
    } catch (e) {
      Logger.error('팁 유형 목록 조회 실패', error: e);
      if (e is ApiException) {
        return ApiResult.failure(e);
      } else {
        return ApiResult.failure(UnknownException('팁 유형 조회 중 오류가 발생했습니다: $e'));
      }
    }
  }

  /// 돌하르방 클릭시 표시할 알림 리스트를 조회합니다.
  Future<ApiResult<Map<String, dynamic>>> getNotificationList({
    required int userId,
    int page = 0,
    int size = 20,
    List<String>? tipTypes,
  }) async {
    try {
      Logger.info('알림 리스트 조회 시도 - userId: $userId');
      
      final queryParameters = <String, dynamic>{
        'page': page,
        'size': size,
      };
      if (tipTypes != null) queryParameters['tipTypes'] = tipTypes;
      
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/api/v1/ai-tips/notifications/$userId',
        queryParameters: queryParameters,
      );
      
      if (response.data != null) {
        Logger.info('알림 리스트 조회 성공');
        return ApiResult.success(response.data!);
      } else {
        return ApiResult.failure(const UnknownException('알림 리스트 조회 응답이 없습니다.'));
      }
    } catch (e) {
      Logger.error('알림 리스트 조회 실패', error: e);
      if (e is ApiException) {
        return ApiResult.failure(e);
      } else {
        return ApiResult.failure(UnknownException('알림 리스트 조회 중 오류가 발생했습니다: $e'));
      }
    }
  }

  /// 지역별 병해충 경보를 조회합니다.
  Future<ApiResult<Map<String, dynamic>>> getPestAlert({
    required String region,
    String? targetDate,
  }) async {
    try {
      Logger.info('병해충 경보 조회 시도 - region: $region');
      
      final queryParameters = <String, dynamic>{};
      if (targetDate != null) queryParameters['targetDate'] = targetDate;
      
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/api/v1/ai-tips/pest-alert/$region',
        queryParameters: queryParameters,
      );
      
      if (response.data != null) {
        Logger.info('병해충 경보 조회 성공');
        return ApiResult.success(response.data!);
      } else {
        return ApiResult.failure(const UnknownException('병해충 경보 조회 응답이 없습니다.'));
      }
    } catch (e) {
      Logger.error('병해충 경보 조회 실패', error: e);
      if (e is ApiException) {
        return ApiResult.failure(e);
      } else {
        return ApiResult.failure(UnknownException('병해충 경보 조회 중 오류가 발생했습니다: $e'));
      }
    }
  }

  /// 농장별 날씨 기반 알림을 조회합니다.
  Future<ApiResult<Map<String, dynamic>>> getWeatherBasedTips({
    required int farmId,
    String? targetDate,
  }) async {
    try {
      Logger.info('농장별 날씨 기반 알림 조회 시도 - farmId: $farmId');
      
      final queryParameters = <String, dynamic>{};
      if (targetDate != null) queryParameters['targetDate'] = targetDate;
      
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/api/v1/ai-tips/weather/$farmId',
        queryParameters: queryParameters,
      );
      
      if (response.data != null) {
        Logger.info('농장별 날씨 기반 알림 조회 성공');
        return ApiResult.success(response.data!);
      } else {
        return ApiResult.failure(const UnknownException('날씨 기반 알림 조회 응답이 없습니다.'));
      }
    } catch (e) {
      Logger.error('농장별 날씨 기반 알림 조회 실패', error: e);
      if (e is ApiException) {
        return ApiResult.failure(e);
      } else {
        return ApiResult.failure(UnknownException('날씨 기반 알림 조회 중 오류가 발생했습니다: $e'));
      }
    }
  }

  /// 작물별 가이드를 조회합니다.
  Future<ApiResult<Map<String, dynamic>>> getCropGuide(String cropType) async {
    try {
      Logger.info('작물별 가이드 조회 시도 - cropType: $cropType');
      
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/api/v1/ai-tips/crop-guide/$cropType',
      );
      
      if (response.data != null) {
        Logger.info('작물별 가이드 조회 성공');
        return ApiResult.success(response.data!);
      } else {
        return ApiResult.failure(const UnknownException('작물별 가이드 조회 응답이 없습니다.'));
      }
    } catch (e) {
      Logger.error('작물별 가이드 조회 실패', error: e);
      if (e is ApiException) {
        return ApiResult.failure(e);
      } else {
        return ApiResult.failure(UnknownException('작물별 가이드 조회 중 오류가 발생했습니다: $e'));
      }
    }
  }
}