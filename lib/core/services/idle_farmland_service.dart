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
      // 페이징 파라미터와 함께 GET 요청
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/api/idle-farmlands',
        queryParameters: {
          'page': page,
          'size': size,
          'sort': sort,
        },
      );

      if (response.data != null) {
        // 기존에 만들어둔 제네릭 PageResponse 모델로 파싱
        final pageResponse = PageResponse<IdleFarmlandResponse>.fromJson(
          response.data!,
              (json) => IdleFarmlandResponse.fromJson(json as Map<String, dynamic>),
        );
        Logger.info('유휴 농지 목록 조회 성공: ${pageResponse.content.length}개');
        return ApiResult.success(pageResponse);
      } else {
        return ApiResult.failure(const UnknownException('유휴 농지 목록 데이터가 없습니다.'));
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