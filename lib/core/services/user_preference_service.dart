import 'package:jejunongdi/core/models/user_preference_models.dart';
import 'package:jejunongdi/core/network/api_client.dart';
import 'package:jejunongdi/core/network/api_exceptions.dart';
import 'package:jejunongdi/core/utils/logger.dart';

class UserPreferenceService {
  static UserPreferenceService? _instance;
  final ApiClient _apiClient = ApiClient.instance;
  
  static UserPreferenceService get instance {
    _instance ??= UserPreferenceService._internal();
    return _instance!;
  }
  
  UserPreferenceService._internal();
  
  /// 현재 로그인한 사용자의 설정을 조회합니다.
  Future<ApiResult<UserPreferenceDto>> getMyPreference() async {
    try {
      Logger.info('내 설정 조회 시도');
      
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/api/v1/preferences/my',
      );
      
      if (response.data != null) {
        final preference = UserPreferenceDto.fromJson(response.data!);
        Logger.info('내 설정 조회 성공');
        return ApiResult.success(preference);
      } else {
        return ApiResult.failure(const UnknownException('설정 조회 응답이 없습니다.'));
      }
    } catch (e) {
      Logger.error('내 설정 조회 실패', error: e);
      if (e is ApiException) {
        return ApiResult.failure(e);
      } else {
        return ApiResult.failure(UnknownException('설정 조회 중 오류가 발생했습니다: $e'));
      }
    }
  }
  
  /// 현재 로그인한 사용자의 설정을 수정합니다.
  Future<ApiResult<UserPreferenceDto>> updateMyPreference(UserPreferenceDto preference) async {
    try {
      Logger.info('내 설정 수정 시도');
      
      final response = await _apiClient.put<Map<String, dynamic>>(
        '/api/v1/preferences/my',
        data: preference.toJson(),
      );
      
      if (response.data != null) {
        final updatedPreference = UserPreferenceDto.fromJson(response.data!);
        Logger.info('내 설정 수정 성공');
        return ApiResult.success(updatedPreference);
      } else {
        return ApiResult.failure(const UnknownException('설정 수정 응답이 없습니다.'));
      }
    } catch (e) {
      Logger.error('내 설정 수정 실패', error: e);
      if (e is ApiException) {
        return ApiResult.failure(e);
      } else {
        return ApiResult.failure(UnknownException('설정 수정 중 오류가 발생했습니다: $e'));
      }
    }
  }
  
  /// 특정 사용자의 농업 개인화 설정을 조회합니다.
  Future<ApiResult<UserPreferenceDto>> getUserPreference(int userId) async {
    try {
      Logger.info('사용자 설정 조회 시도 - userId: $userId');
      
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/api/v1/preferences/$userId',
      );
      
      if (response.data != null) {
        final preference = UserPreferenceDto.fromJson(response.data!);
        Logger.info('사용자 설정 조회 성공');
        return ApiResult.success(preference);
      } else {
        return ApiResult.failure(const UnknownException('설정 조회 응답이 없습니다.'));
      }
    } catch (e) {
      Logger.error('사용자 설정 조회 실패', error: e);
      if (e is ApiException) {
        return ApiResult.failure(e);
      } else {
        return ApiResult.failure(UnknownException('설정 조회 중 오류가 발생했습니다: $e'));
      }
    }
  }
  
  /// 사용자의 농업 개인화 설정을 생성하거나 수정합니다.
  Future<ApiResult<UserPreferenceDto>> createOrUpdatePreference({
    required int userId,
    required UserPreferenceDto preference,
  }) async {
    try {
      Logger.info('사용자 설정 생성/수정 시도 - userId: $userId');
      
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/api/v1/preferences/$userId',
        data: preference.toJson(),
      );
      
      if (response.data != null) {
        final updatedPreference = UserPreferenceDto.fromJson(response.data!);
        Logger.info('사용자 설정 생성/수정 성공');
        return ApiResult.success(updatedPreference);
      } else {
        return ApiResult.failure(const UnknownException('설정 생성/수정 응답이 없습니다.'));
      }
    } catch (e) {
      Logger.error('사용자 설정 생성/수정 실패', error: e);
      if (e is ApiException) {
        return ApiResult.failure(e);
      } else {
        return ApiResult.failure(UnknownException('설정 생성/수정 중 오류가 발생했습니다: $e'));
      }
    }
  }
  
  /// 특정 사용자의 설정을 삭제합니다.
  Future<ApiResult<String>> deletePreference(int userId) async {
    try {
      Logger.info('사용자 설정 삭제 시도 - userId: $userId');
      
      final response = await _apiClient.delete<String>(
        '/api/v1/preferences/$userId',
      );
      
      if (response.data != null) {
        Logger.info('사용자 설정 삭제 성공');
        return ApiResult.success(response.data!);
      } else {
        return ApiResult.failure(const UnknownException('설정 삭제 응답이 없습니다.'));
      }
    } catch (e) {
      Logger.error('사용자 설정 삭제 실패', error: e);
      if (e is ApiException) {
        return ApiResult.failure(e);
      } else {
        return ApiResult.failure(UnknownException('설정 삭제 중 오류가 발생했습니다: $e'));
      }
    }
  }
  
  /// 사용자에게 기본 농업 설정을 생성해줍니다.
  Future<ApiResult<UserPreferenceDto>> createDefaultPreference(int userId) async {
    try {
      Logger.info('기본 설정 생성 시도 - userId: $userId');
      
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/api/v1/preferences/$userId/default',
      );
      
      if (response.data != null) {
        final preference = UserPreferenceDto.fromJson(response.data!);
        Logger.info('기본 설정 생성 성공');
        return ApiResult.success(preference);
      } else {
        return ApiResult.failure(const UnknownException('기본 설정 생성 응답이 없습니다.'));
      }
    } catch (e) {
      Logger.error('기본 설정 생성 실패', error: e);
      if (e is ApiException) {
        return ApiResult.failure(e);
      } else {
        return ApiResult.failure(UnknownException('기본 설정 생성 중 오류가 발생했습니다: $e'));
      }
    }
  }
  
  /// 로컬에서 기본 설정을 생성합니다. (백엔드 API 없이도 사용 가능)
  UserPreferenceDto createLocalDefaultPreference(int userId) {
    Logger.info('로컬 기본 설정 생성 - userId: $userId');
    return UserPreferenceDto.createDefault(userId);
  }
  
  /// 설정 유효성을 검사합니다.
  bool validatePreference(UserPreferenceDto preference) {
    // 필수 필드 검사
    if (preference.userId <= 0) {
      Logger.warning('유효하지 않은 사용자 ID: ${preference.userId}');
      return false;
    }
    
    // 관심 작물이 너무 많은지 검사 (최대 10개)
    if (preference.interestedCrops != null && preference.interestedCrops!.length > 10) {
      Logger.warning('관심 작물이 너무 많습니다: ${preference.interestedCrops!.length}개');
      return false;
    }
    
    Logger.info('설정 유효성 검사 통과');
    return true;
  }

  /// 농업 유형 목록을 조회합니다.
  Future<ApiResult<List<String>>> getFarmingTypes() async {
    try {
      Logger.info('농업 유형 목록 조회 시도');
      
      final response = await _apiClient.get<List<dynamic>>(
        '/api/v1/preferences/farming-types',
      );
      
      if (response.data != null) {
        final farmingTypes = response.data!.cast<String>();
        Logger.info('농업 유형 목록 조회 성공: ${farmingTypes.length}개');
        return ApiResult.success(farmingTypes);
      } else {
        return ApiResult.failure(const UnknownException('농업 유형 목록 조회 응답이 없습니다.'));
      }
    } catch (e) {
      Logger.error('농업 유형 목록 조회 실패', error: e);
      if (e is ApiException) {
        return ApiResult.failure(e);
      } else {
        return ApiResult.failure(UnknownException('농업 유형 목록 조회 중 오류가 발생했습니다: $e'));
      }
    }
  }

  /// 위치별 설정을 조회합니다.
  Future<ApiResult<Map<String, dynamic>>> getLocationSettings(String location) async {
    try {
      Logger.info('위치별 설정 조회 시도 - location: $location');
      
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/api/v1/preferences/location/$location',
      );
      
      if (response.data != null) {
        Logger.info('위치별 설정 조회 성공');
        return ApiResult.success(response.data!);
      } else {
        return ApiResult.failure(const UnknownException('위치별 설정 조회 응답이 없습니다.'));
      }
    } catch (e) {
      Logger.error('위치별 설정 조회 실패', error: e);
      if (e is ApiException) {
        return ApiResult.failure(e);
      } else {
        return ApiResult.failure(UnknownException('위치별 설정 조회 중 오류가 발생했습니다: $e'));
      }
    }
  }

  /// 작물별 설정을 조회합니다.
  Future<ApiResult<Map<String, dynamic>>> getCropSettings(String cropName) async {
    try {
      Logger.info('작물별 설정 조회 시도 - cropName: $cropName');
      
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/api/v1/preferences/crop/$cropName',
      );
      
      if (response.data != null) {
        Logger.info('작물별 설정 조회 성공');
        return ApiResult.success(response.data!);
      } else {
        return ApiResult.failure(const UnknownException('작물별 설정 조회 응답이 없습니다.'));
      }
    } catch (e) {
      Logger.error('작물별 설정 조회 실패', error: e);
      if (e is ApiException) {
        return ApiResult.failure(e);
      } else {
        return ApiResult.failure(UnknownException('작물별 설정 조회 중 오류가 발생했습니다: $e'));
      }
    }
  }

  /// 알림 유형별 설정을 조회합니다.
  Future<ApiResult<Map<String, dynamic>>> getNotificationSettings(String type) async {
    try {
      Logger.info('알림 설정 조회 시도 - type: $type');
      
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/api/v1/preferences/notification/$type',
      );
      
      if (response.data != null) {
        Logger.info('알림 설정 조회 성공');
        return ApiResult.success(response.data!);
      } else {
        return ApiResult.failure(const UnknownException('알림 설정 조회 응답이 없습니다.'));
      }
    } catch (e) {
      Logger.error('알림 설정 조회 실패', error: e);
      if (e is ApiException) {
        return ApiResult.failure(e);
      } else {
        return ApiResult.failure(UnknownException('알림 설정 조회 중 오류가 발생했습니다: $e'));
      }
    }
  }

  /// 설정 유효성을 서버에서 검증합니다.
  Future<ApiResult<bool>> validatePreferenceOnServer(UserPreferenceDto preference) async {
    try {
      Logger.info('서버 설정 유효성 검증 시도');
      
      final response = await _apiClient.post<bool>(
        '/api/v1/preferences/validation',
        data: preference.toJson(),
      );
      
      if (response.data != null) {
        Logger.info('서버 설정 유효성 검증 완료: ${response.data}');
        return ApiResult.success(response.data!);
      } else {
        return ApiResult.failure(const UnknownException('설정 유효성 검증 응답이 없습니다.'));
      }
    } catch (e) {
      Logger.error('서버 설정 유효성 검증 실패', error: e);
      if (e is ApiException) {
        return ApiResult.failure(e);
      } else {
        return ApiResult.failure(UnknownException('설정 유효성 검증 중 오류가 발생했습니다: $e'));
      }
    }
  }
}