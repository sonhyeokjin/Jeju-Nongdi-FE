import 'package:jejunongdi/core/models/idle_farmland_models.dart';
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