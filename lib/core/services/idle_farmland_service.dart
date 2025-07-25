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

  /// 전체 유휴 농지 목록 조회 (페이징 지원)
  Future<ApiResult<PageResponse<IdleFarmlandResponse>>> getIdleFarmlands({
    int page = 0,
    int size = 20,
    String sort = 'createdAt,desc',
  }) async {
    try {
      Logger.info('유휴 농지 목록 조회 시도: page=$page');
      final response = await _apiClient.get<dynamic>(
        '/api/idle-farmlands',
        queryParameters: {
          'page': page,
          'size': size,
          'sort': sort,
        },
      );

      // [수정] null과 타입을 이중으로 확인하여 안정성 강화
      if (response.data != null && response.data is Map<String, dynamic>) {
        final pageResponse = PageResponse<IdleFarmlandResponse>.fromJson(
          response.data,
              (json) => IdleFarmlandResponse.fromJson(json as Map<String, dynamic>),
        );
        Logger.info('유휴 농지 목록 조회 성공: ${pageResponse.content.length}개');
        return ApiResult.success(pageResponse);
      } else {
        // 성공 응답이지만 데이터가 비어있거나 형식이 다른 경우
        return ApiResult.failure(const UnknownException('서버로부터 유효한 목록 데이터를 받지 못했습니다.'));
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

  /// 유휴 농지 생성
  Future<ApiResult<IdleFarmlandResponse?>> createIdleFarmland(IdleFarmlandRequest request) async {
    try {
      Logger.info('유휴 농지 생성 시도');
      final response = await _apiClient.post<dynamic>(
        '/api/idle-farmlands',
        data: request.toJson(),
      );

      // [수정] null과 타입을 이중으로 확인하여 안정성 강화
      if (response.data != null && response.data is Map<String, dynamic>) {
        final newFarmland = IdleFarmlandResponse.fromJson(response.data);
        Logger.info('유휴 농지 생성 성공: ${newFarmland.address}');
        return ApiResult.success(newFarmland);
      } else {
        // 201 Created 등 성공 코드가 왔지만, body가 비어있는 경우를 성공으로 간주
        if (response.statusCode! >= 200 && response.statusCode! < 300) {
          Logger.info('유휴 농지 생성 성공 (응답 본문 없음)');
          return ApiResult.success(null);
        }
        return ApiResult.failure(const UnknownException('서버로부터 유효한 생성 응답을 받지 못했습니다.'));
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
      if (e is ApiException) {
        return ApiResult.failure(e);
      } else {
        return ApiResult.failure(UnknownException('유휴 농지 삭제 중 오류가 발생했습니다: $e'));
      }
    }
  }

  /// 유휴 농지 상태 변경 (Swagger 명세서에 따름)
  Future<ApiResult<IdleFarmlandResponse>> updateIdleFarmlandStatus({
    required int id,
    required String status,
  }) async {
    try {
      Logger.info('유휴 농지 상태 변경 시도: id=$id, status=$status');

      // 유효한 상태값 확인
      const validStatuses = ['AVAILABLE', 'RENTED', 'MAINTENANCE', 'SUSPENDED', 'UNAVAILABLE'];
      if (!validStatuses.contains(status.toUpperCase())) {
        return ApiResult.failure(const BadRequestException('유효하지 않은 상태값입니다. (AVAILABLE, RENTED, MAINTENANCE, SUSPENDED, UNAVAILABLE 중 하나)'));
      }

      final response = await _apiClient.patch<Map<String, dynamic>>(
        '/api/idle-farmlands/$id/status',
        queryParameters: {'status': status.toUpperCase()},
      );

      if (response.data != null) {
        final updatedFarmland = IdleFarmlandResponse.fromJson(response.data!);
        Logger.info('유휴 농지 상태 변경 성공: ${updatedFarmland.farmlandName} -> $status');
        return ApiResult.success(updatedFarmland);
      } else {
        return ApiResult.failure(const UnknownException('유휴 농지 상태 변경 응답이 없습니다.'));
      }
    } catch (e) {
      Logger.error('유휴 농지 상태 변경 실패', error: e);
      if (e is ApiException) {
        return ApiResult.failure(e);
      } else {
        return ApiResult.failure(UnknownException('유휴 농지 상태 변경 중 오류가 발생했습니다: $e'));
      }
    }
  }

  /// 지도 범위 내 유휴 농지 목록 조회 (추가 기능)
  Future<ApiResult<List<IdleFarmlandResponse>>> getIdleFarmlandsByBounds({
    required double minLat,
    required double maxLat,
    required double minLng,
    required double maxLng,
    int page = 0,
    int size = 50,
  }) async {
    try {
      Logger.info('지도 범위 내 유휴 농지 조회 시도: minLat=$minLat, maxLat=$maxLat, minLng=$minLng, maxLng=$maxLng');

      final response = await _apiClient.get<dynamic>(
        '/api/idle-farmlands/bounds',
        queryParameters: {
          'minLat': minLat,
          'maxLat': maxLat,
          'minLng': minLng,
          'maxLng': maxLng,
          'page': page,
          'size': size,
        },
      );

      if (response.data != null) {
        List<dynamic> farmlandsData;

        // 응답 데이터 타입에 따라 처리
        if (response.data is List) {
          farmlandsData = response.data as List<dynamic>;
        } else if (response.data is Map<String, dynamic>) {
          final responseMap = response.data as Map<String, dynamic>;
          farmlandsData = responseMap['content'] as List<dynamic>? ?? [];
        } else {
          farmlandsData = [];
        }

        final farmlands = farmlandsData
            .map((item) => IdleFarmlandResponse.fromJson(item as Map<String, dynamic>))
            .toList();

        Logger.info('지도 범위 내 유휴 농지 조회 성공: ${farmlands.length}개');
        return ApiResult.success(farmlands);
      } else {
        return ApiResult.failure(const UnknownException('범위 내 유휴 농지 목록 데이터가 없습니다.'));
      }
    } catch (e) {
      Logger.error('지도 범위 내 유휴 농지 조회 실패', error: e);
      if (e is ApiException) {
        return ApiResult.failure(e);
      } else {
        return ApiResult.failure(UnknownException('범위 내 유휴 농지 조회 중 오류가 발생했습니다: $e'));
      }
    }
  }

  /// 유휴 농지 검색 (추가 기능)
  Future<ApiResult<PageResponse<IdleFarmlandResponse>>> searchIdleFarmlands({
    String? keyword,
    String? location,
    double? minArea,
    double? maxArea,
    int? maxRent,
    String? soilType,
    String? usageType,
    String? status,
    bool? waterSupply,
    bool? electricitySupply,
    int page = 0,
    int size = 20,
  }) async {
    try {
      Logger.info('유휴 농지 검색 시도: keyword=$keyword');

      final Map<String, dynamic> queryParams = {
        'page': page,
        'size': size,
        'sort': 'createdAt,desc',
      };

      if (keyword != null && keyword.isNotEmpty) queryParams['keyword'] = keyword;
      if (location != null && location.isNotEmpty) queryParams['location'] = location;
      if (minArea != null) queryParams['minArea'] = minArea;
      if (maxArea != null) queryParams['maxArea'] = maxArea;
      if (maxRent != null) queryParams['maxRent'] = maxRent;
      if (soilType != null && soilType.isNotEmpty) queryParams['soilType'] = soilType;
      if (usageType != null && usageType.isNotEmpty) queryParams['usageType'] = usageType;
      if (status != null && status.isNotEmpty) queryParams['status'] = status;
      if (waterSupply != null) queryParams['waterSupply'] = waterSupply;
      if (electricitySupply != null) queryParams['electricitySupply'] = electricitySupply;

      final response = await _apiClient.get<Map<String, dynamic>>(
        '/api/idle-farmlands/search',
        queryParameters: queryParams,
      );

      if (response.data != null) {
        final pageResponse = PageResponse<IdleFarmlandResponse>.fromJson(
          response.data!,
          (json) => IdleFarmlandResponse.fromJson(json as Map<String, dynamic>),
        );

        Logger.info('유휴 농지 검색 성공: 총 ${pageResponse.totalElements}개');
        return ApiResult.success(pageResponse);
      } else {
        return ApiResult.failure(const UnknownException('유휴 농지 검색 데이터가 없습니다.'));
      }
    } catch (e) {
      Logger.error('유휴 농지 검색 실패', error: e);
      if (e is ApiException) {
        return ApiResult.failure(e);
      } else {
        return ApiResult.failure(UnknownException('유휴 농지 검색 중 오류가 발생했습니다: $e'));
      }
    }
  }
}