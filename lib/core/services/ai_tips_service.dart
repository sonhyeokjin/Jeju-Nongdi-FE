import 'package:jejunongdi/core/models/ai_tip_model.dart';
import 'package:jejunongdi/core/network/api_exceptions.dart';
import 'package:jejunongdi/core/network/api_client.dart';
import 'package:jejunongdi/core/services/auth_service.dart';
import 'package:jejunongdi/core/utils/logger.dart';

class AiTipsService {
  static const String basePath = '/api/v1/ai-tips';
  static AiTipsService? _instance;
  
  static AiTipsService get instance {
    _instance ??= AiTipsService._internal();
    return _instance!;
  }
  
  AiTipsService._internal();

  // 현재 사용자 숫자 ID 가져오기
  Future<int?> _getCurrentUserId() async {
    try {
      final userResult = await AuthService.instance.getCurrentUser();
      if (userResult.isSuccess) {
        final userId = int.tryParse(userResult.data!.id);
        if (userId == null) {
          Logger.error('사용자 ID를 숫자로 변환할 수 없음: ${userResult.data!.id}');
        }
        return userId;
      }
      return null;
    } catch (e) {
      Logger.error('사용자 ID 조회 오류', error: e);
      return null;
    }
  }

  // 1. 날씨 기반 알림 조회
  Future<ApiResult<WeatherBasedTipModel>> getWeatherBasedTips({
    int? userId,
    DateTime? targetDate,
  }) async {
    try {
      final currentUserId = userId ?? await _getCurrentUserId();
      if (currentUserId == null) {
        return ApiResult.failure(const UnauthorizedException('사용자 정보를 찾을 수 없습니다.'));
      }

      String path = '$basePath/weather/$currentUserId';
      Map<String, dynamic> queryParams = {};
      if (targetDate != null) {
        queryParams['targetDate'] = targetDate.toIso8601String();
      }

      final response = await ApiClient.instance.get(
        path,
        queryParameters: queryParams,
      );

      Logger.info('날씨 기반 알림 조회 응답: ${response.statusCode}');
      return ApiResult.success(WeatherBasedTipModel.fromJson(response.data));
    } catch (e) {
      Logger.error('날씨 기반 알림 조회 오류', error: e);
      return ApiResult.failure(UnknownException(e.toString()));
    }
  }

  // 2. 팁 유형 목록 조회
  Future<ApiResult<List<TipTypeModel>>> getTipTypes() async {
    try {
      final response = await ApiClient.instance.get('$basePath/types');

      Logger.info('팁 유형 목록 조회 응답: ${response.statusCode}');
      final List<dynamic> data = response.data;
      final tipTypes = data.map((item) => TipTypeModel.fromJson(item)).toList();
      return ApiResult.success(tipTypes);
    } catch (e) {
      Logger.error('팁 유형 목록 조회 오류', error: e);
      return ApiResult.failure(UnknownException(e.toString()));
    }
  }

  // 3. 오늘의 농업 팁 조회 (메인 화면용)
  Future<ApiResult<TodayFarmLifeModel>> getTodayFarmLife([int? userId]) async {
    try {
      final currentUserId = userId ?? await _getCurrentUserId();
      if (currentUserId == null) {
        return ApiResult.failure(const UnauthorizedException('사용자 정보를 찾을 수 없습니다.'));
      }

      final response = await ApiClient.instance.get('$basePath/today/$currentUserId');

      Logger.info('오늘의 농업 팁 조회 응답: ${response.statusCode}');
      return ApiResult.success(TodayFarmLifeModel.fromJson(response.data));
    } catch (e) {
      Logger.error('오늘의 농업 팁 조회 오류', error: e);
      return ApiResult.failure(UnknownException(e.toString()));
    }
  }

  // 4. 병해충 경보 조회
  Future<ApiResult<List<PestAlertModel>>> getPestAlert({
    required String region,
    DateTime? targetDate,
  }) async {
    try {
      String path = '$basePath/pest-alert/$region';
      Map<String, dynamic> queryParams = {};
      if (targetDate != null) {
        queryParams['targetDate'] = targetDate.toIso8601String();
      }

      final response = await ApiClient.instance.get(
        path,
        queryParameters: queryParams,
      );

      Logger.info('병해충 경보 조회 응답: ${response.statusCode}');
      final List<dynamic> data = response.data;
      final alerts = data.map((item) => PestAlertModel.fromJson(item)).toList();
      return ApiResult.success(alerts);
    } catch (e) {
      Logger.error('병해충 경보 조회 오류', error: e);
      return ApiResult.failure(UnknownException(e.toString()));
    }
  }

  // 5. 알림 리스트 조회 (돌하르방 클릭용)
  Future<ApiResult<List<AiTipModel>>> getNotifications({
    int? userId,
    int page = 0,
    int size = 20,
    List<String>? tipTypes,
  }) async {
    try {
      final currentUserId = userId ?? await _getCurrentUserId();
      if (currentUserId == null) {
        return ApiResult.failure(const UnauthorizedException('사용자 정보를 찾을 수 없습니다.'));
      }

      String path = '$basePath/notifications/$currentUserId';
      Map<String, dynamic> queryParams = {
        'page': page,
        'size': size,
      };
      if (tipTypes != null && tipTypes.isNotEmpty) {
        queryParams['tipTypes'] = tipTypes.join(',');
      }

      final response = await ApiClient.instance.get(
        path,
        queryParameters: queryParams,
      );

      Logger.info('알림 리스트 조회 응답: ${response.statusCode}');
      final List<dynamic> data = response.data;
      final notifications = data.map((item) => AiTipModel.fromJson(item)).toList();
      return ApiResult.success(notifications);
    } catch (e) {
      Logger.error('알림 리스트 조회 오류', error: e);
      return ApiResult.failure(UnknownException(e.toString()));
    }
  }

  // 6. 일일 맞춤 팁 조회
  Future<ApiResult<List<AiTipModel>>> getDailyTips([int? userId]) async {
    try {
      final currentUserId = userId ?? await _getCurrentUserId();
      if (currentUserId == null) {
        return ApiResult.failure(const UnauthorizedException('사용자 정보를 찾을 수 없습니다.'));
      }

      final response = await ApiClient.instance.get('$basePath/daily/$currentUserId');

      Logger.info('일일 맞춤 팁 조회 응답: ${response.statusCode}');
      final List<dynamic> data = response.data;
      final tips = data.map((item) => AiTipModel.fromJson(item)).toList();
      return ApiResult.success(tips);
    } catch (e) {
      Logger.error('일일 맞춤 팁 조회 오류', error: e);
      return ApiResult.failure(UnknownException(e.toString()));
    }
  }

  // 7. 작물별 가이드 조회
  Future<ApiResult<CropGuideModel>> getCropGuide(String cropType) async {
    try {
      final response = await ApiClient.instance.get('$basePath/crop-guide/$cropType');

      Logger.info('작물별 가이드 조회 응답: ${response.statusCode}');
      return ApiResult.success(CropGuideModel.fromJson(response.data));
    } catch (e) {
      Logger.error('작물별 가이드 조회 오류', error: e);
      return ApiResult.failure(UnknownException(e.toString()));
    }
  }

  // 8. 일일 팁 생성
  Future<ApiResult<AiTipModel>> generateDailyTip([int? userId]) async {
    try {
      final currentUserId = userId ?? await _getCurrentUserId();
      if (currentUserId == null) {
        return ApiResult.failure(const UnauthorizedException('사용자 정보를 찾을 수 없습니다.'));
      }

      final response = await ApiClient.instance.post('$basePath/generate/$currentUserId');

      Logger.info('일일 팁 생성 응답: ${response.statusCode}');
      return ApiResult.success(AiTipModel.fromJson(response.data));
    } catch (e) {
      Logger.error('일일 팁 생성 오류', error: e);
      return ApiResult.failure(UnknownException(e.toString()));
    }
  }

  // 9. 수동 팁 생성 (관리자용)
  Future<ApiResult<AiTipModel>> createManualTip({
    int? userId,
    required String tipType,
    required String title,
    required String content,
    String? cropType,
  }) async {
    try {
      final currentUserId = userId ?? await _getCurrentUserId();
      if (currentUserId == null) {
        return ApiResult.failure(const UnauthorizedException('사용자 정보를 찾을 수 없습니다.'));
      }

      Map<String, dynamic> queryParams = {
        'userId': currentUserId,
        'tipType': tipType,
        'title': title,
        'content': content,
      };
      if (cropType != null) {
        queryParams['cropType'] = cropType;
      }

      final response = await ApiClient.instance.post(
        '$basePath/create',
        queryParameters: queryParams,
      );

      Logger.info('수동 팁 생성 응답: ${response.statusCode}');
      return ApiResult.success(AiTipModel.fromJson(response.data));
    } catch (e) {
      Logger.error('수동 팁 생성 오류', error: e);
      return ApiResult.failure(UnknownException(e.toString()));
    }
  }

  // 10. AI 팁 읽음 처리
  Future<ApiResult<void>> markTipAsRead(int tipId) async {
    try {
      final response = await ApiClient.instance.put('$basePath/$tipId/read');

      Logger.info('AI 팁 읽음 처리 응답: ${response.statusCode}');
      return ApiResult.success(null);
    } catch (e) {
      Logger.error('AI 팁 읽음 처리 오류', error: e);
      return ApiResult.failure(UnknownException(e.toString()));
    }
  }
}