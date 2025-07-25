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
}