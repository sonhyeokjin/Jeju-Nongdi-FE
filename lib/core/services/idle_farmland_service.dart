import 'package:jejunongdi/core/models/idle_farmland_models.dart';
import 'package:jejunongdi/core/models/mentoring_models.dart'; // PageResponse를 위해 추가
import 'package:jejunongdi/core/network/api_client.dart';
import 'package:jejunongdi/core/network/api_exceptions.dart';
import 'package:jejunongdi/core/utils/logger.dart';

class IdleFarmlandService {
  static IdleFarmlandService? _instance;
  final ApiClient _apiClient = ApiClient.instance;

  static IdleFarmlandService get instance {
    _instance ??= IdleFarmlandService._internal();
    return _instance!;
  }

  IdleFarmlandService._internal();

  /// [추가] 전체 유휴 농지 목록 조회 (페이징 지원)
  Future<ApiResult<PageResponse<IdleFarmlandResponse>>> getIdleFarmlands({
    int page = 0,
    int size = 20,
    String sort = 'createdAt,desc',
  }) async {
    try {
      Logger.info('유휴 농지 목록 조회 시도: page=$page');
      final response = await _apiClient.get<dynamic>( // [수정] 어떤 타입이 올지 모르므로 dynamic으로 받습니다.
        '/api/idle-farmlands',
        queryParameters: {
          'page': page,
          'size': size,
          'sort': sort,
        },
      );

      // [수정] null 체크와 함께 타입 체크를 강화합니다.
      if (response.data is Map<String, dynamic>) {
        final pageResponse = PageResponse<IdleFarmlandResponse>.fromJson(
          response.data,
              (json) => IdleFarmlandResponse.fromJson(json as Map<String, dynamic>),
        );
        Logger.info('유휴 농지 목록 조회 성공: ${pageResponse.content.length}개');
        return ApiResult.success(pageResponse);
      } else {
        // 응답이 있지만, 예상한 Map 형태가 아닌 경우
        return ApiResult.failure(const UnknownException('유효하지 않은 응답 데이터입니다.'));
      }
    } catch (e) {
      Logger.error('유휴 농지 목록 조회 실패', error: e);
      return ApiResult.failure(e is ApiException ? e : UnknownException(e.toString()));
    }
  }

  /// 특정 유휴 농지의 상세 정보 조회
  Future<ApiResult<IdleFarmlandResponse>> getIdleFarmlandById(int id) async {
    try {
      Logger.info('유휴 농지 상세 조회 시도: id=$id');
      final response = await _apiClient.get<Map<String, dynamic>>('/api/idle-farmlands/$id');

      if (response.data != null) {
        final farmland = IdleFarmlandResponse.fromJson(response.data!);
        Logger.info('유휴 농지 상세 조회 성공: ${farmland.address}');
        return ApiResult.success(farmland);
      } else {
        return ApiResult.failure(const UnknownException('유휴 농지 상세 정보 데이터가 없습니다.'));
      }
    } catch (e) {
      Logger.error('유휴 농지 상세 조회 실패', error: e);
      return ApiResult.failure(e is ApiException ? e : UnknownException(e.toString()));
    }
  }

  /// 유휴 농지 정보 수정
  Future<ApiResult<IdleFarmlandResponse>> updateIdleFarmland({
    required int id,
    required IdleFarmlandRequest request,
  }) async {
    try {
      Logger.info('유휴 농지 수정 시도: id=$id');
      final response = await _apiClient.put<Map<String, dynamic>>(
        '/api/idle-farmlands/$id',
        data: request.toJson(),
      );

      if (response.data != null) {
        final updatedFarmland = IdleFarmlandResponse.fromJson(response.data!);
        Logger.info('유휴 농지 수정 성공: ${updatedFarmland.address}');
        return ApiResult.success(updatedFarmland);
      } else {
        return ApiResult.failure(const UnknownException('유휴 농지 수정 응답이 없습니다.'));
      }
    } catch (e) {
      Logger.error('유휴 농지 수정 실패', error: e);
      return ApiResult.failure(e is ApiException ? e : UnknownException(e.toString()));
    }
  }

  // 유휴 농지 생성
  Future<ApiResult<IdleFarmlandResponse>> createIdleFarmland(IdleFarmlandRequest request) async {
    try {
      Logger.info('유휴 농지 생성 시도');
      final response = await _apiClient.post<dynamic>( // [수정] dynamic으로 받습니다.
        '/api/idle-farmlands',
        data: request.toJson(),
      );

      // [수정] null 체크와 함께 타입 체크를 강화합니다.
      if (response.data is Map<String, dynamic>) {
        final newFarmland = IdleFarmlandResponse.fromJson(response.data);
        Logger.info('유휴 농지 생성 성공: ${newFarmland.address}');
        return ApiResult.success(newFarmland);
      } else {
        // 201 Created 등 성공 코드가 왔지만, body가 비어있는 경우를 성공으로 간주
        if (response.statusCode! >= 200 && response.statusCode! < 300) {
          Logger.info('유휴 농지 생성 성공 (응답 본문 없음)');
          // 성공했지만 반환할 데이터가 없으므로 null을 전달
          // 미들웨어에서 이 신호를 받고 목록을 새로고침하게 됩니다.
          return ApiResult.success(null);
        }
        return ApiResult.failure(const UnknownException('유효하지 않은 응답 데이터입니다.'));
      }
    } catch (e) {
      Logger.error('유휴 농지 생성 실패', error: e);
      return ApiResult.failure(e is ApiException ? e : UnknownException(e.toString()));
    }
  }

  /// 유휴 농지 삭제
  Future<ApiResult<void>> deleteIdleFarmland(int id) async {
    try {
      Logger.info('유휴 농지 삭제 시도: id=$id');
      await _apiClient.delete('/api/idle-farmlands/$id');
      Logger.info('유휴 농지 삭제 성공');
      return ApiResult.success(null);
    } catch (e) {
      Logger.error('유휴 농지 삭제 실패', error: e);
      return ApiResult.failure(e is ApiException ? e : UnknownException(e.toString()));
    }
  }
}