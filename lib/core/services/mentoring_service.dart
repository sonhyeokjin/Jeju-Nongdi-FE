import 'package:jejunongdi/core/network/api_client.dart';
import 'package:jejunongdi/core/network/api_exceptions.dart';
import 'package:jejunongdi/core/utils/logger.dart';
import 'package:jejunongdi/core/models/mentoring_models.dart';

class MentoringService {
  static MentoringService? _instance;
  final ApiClient _apiClient = ApiClient.instance;
  
  static MentoringService get instance {
    _instance ??= MentoringService._internal();
    return _instance!;
  }
  
  MentoringService._internal();
  
  // 멘토링 목록 조회 (페이징)
  Future<ApiResult<PageResponse<MentoringResponse>>> getMentorings({
    int page = 0,
    int size = 20,
    String sort = 'createdAt,desc',
  }) async {
    try {
      Logger.info('멘토링 목록 조회 - 페이지: $page, 크기: $size');
      
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/api/mentorings',
        queryParameters: {
          'page': page,
          'size': size,
          'sort': sort,
        },
      );
      
      if (response.data != null) {
        final pageResponse = PageResponse<MentoringResponse>.fromJson(
          response.data!,
          (json) => MentoringResponse.fromJson(json as Map<String, dynamic>),
        );
        
        Logger.info('멘토링 목록 조회 성공 - 총 ${pageResponse.totalElements}개');
        return ApiResult.success(pageResponse);
      } else {
        return ApiResult.failure(const UnknownException('멘토링 목록 응답 데이터가 없습니다.'));
      }
    } catch (e) {
      Logger.error('멘토링 목록 조회 실패', error: e);
      if (e is ApiException) {
        return ApiResult.failure(e);
      } else {
        return ApiResult.failure(UnknownException('멘토링 목록 조회 중 오류가 발생했습니다: $e'));
      }
    }
  }
  
  // 특정 멘토링 상세 조회
  Future<ApiResult<MentoringResponse>> getMentoringById(int id) async {
    try {
      Logger.info('멘토링 상세 조회 - ID: $id');
      
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/api/mentorings/$id',
      );
      
      if (response.data != null) {
        final mentoring = MentoringResponse.fromJson(response.data!);
        
        Logger.info('멘토링 상세 조회 성공 - ${mentoring.title}');
        return ApiResult.success(mentoring);
      } else {
        return ApiResult.failure(const UnknownException('멘토링 상세 응답 데이터가 없습니다.'));
      }
    } catch (e) {
      Logger.error('멘토링 상세 조회 실패', error: e);
      if (e is ApiException) {
        return ApiResult.failure(e);
      } else {
        return ApiResult.failure(UnknownException('멘토링 상세 조회 중 오류가 발생했습니다: $e'));
      }
    }
  }
  
  // 멘토링 검색 (페이징 지원)
  Future<ApiResult<List<MentoringResponse>>> getFilteredMentorings({
    int page = 0,
    int size = 20,
    String? category,
    String? mentoringType,
    String? experienceLevel,
    String? status,
    String? keyword,
  }) async {
    try {
      Logger.info('멘토링 검색 (페이징)');
      
      final Map<String, dynamic> queryParams = {};
      
      if (category != null) queryParams['category'] = category;
      if (mentoringType != null) queryParams['mentoringType'] = mentoringType;
      if (experienceLevel != null) queryParams['experienceLevel'] = experienceLevel;
      if (status != null) queryParams['status'] = status;
      if (keyword != null && keyword.isNotEmpty) queryParams['keyword'] = keyword;
      
      final response = await _apiClient.get<List<dynamic>>(
        '/api/mentorings/search',
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );
      
      if (response.data != null) {
        final mentorings = response.data!
            .map((item) => MentoringResponse.fromJson(item as Map<String, dynamic>))
            .toList();
        
        Logger.info('멘토링 검색 성공 - 총 ${mentorings.length}개');
        return ApiResult.success(mentorings);
      } else {
        return ApiResult.failure(const UnknownException('멘토링 검색 응답 데이터가 없습니다.'));
      }
    } catch (e) {
      Logger.error('멘토링 검색 실패', error: e);
      if (e is ApiException) {
        return ApiResult.failure(e);
      } else {
        return ApiResult.failure(UnknownException('멘토링 검색 중 오류가 발생했습니다: $e'));
      }
    }
  }
  
  // 내가 작성한 멘토링 목록 조회
  Future<ApiResult<List<MentoringResponse>>> getMyMentorings() async {
    try {
      Logger.info('내 멘토링 목록 조회');
      
      final response = await _apiClient.get<List<dynamic>>(
        '/api/mentorings/my',
      );
      
      if (response.data != null) {
        final mentorings = response.data!
            .map((item) => MentoringResponse.fromJson(item as Map<String, dynamic>))
            .toList();
        
        Logger.info('내 멘토링 목록 조회 성공 - 총 ${mentorings.length}개');
        return ApiResult.success(mentorings);
      } else {
        return ApiResult.failure(const UnknownException('내 멘토링 목록 응답 데이터가 없습니다.'));
      }
    } catch (e) {
      Logger.error('내 멘토링 목록 조회 실패', error: e);
      if (e is ApiException) {
        return ApiResult.failure(e);
      } else {
        return ApiResult.failure(UnknownException('내 멘토링 목록 조회 중 오류가 발생했습니다: $e'));
      }
    }
  }
  
  // 멘토링 생성
  Future<ApiResult<MentoringResponse>> createMentoring(Map<String, dynamic> data) async {
    try {
      Logger.info('멘토링 생성');
      
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/api/mentorings',
        data: data,
      );
      
      if (response.data != null) {
        final mentoring = MentoringResponse.fromJson(response.data!);
        
        Logger.info('멘토링 생성 성공 - ${mentoring.title}');
        return ApiResult.success(mentoring);
      } else {
        return ApiResult.failure(const UnknownException('멘토링 생성 응답 데이터가 없습니다.'));
      }
    } catch (e) {
      Logger.error('멘토링 생성 실패', error: e);
      if (e is ApiException) {
        return ApiResult.failure(e);
      } else {
        return ApiResult.failure(UnknownException('멘토링 생성 중 오류가 발생했습니다: $e'));
      }
    }
  }
  
  // 멘토링 수정
  Future<ApiResult<MentoringResponse>> updateMentoring(int id, Map<String, dynamic> data) async {
    try {
      Logger.info('멘토링 수정 - ID: $id');
      
      final response = await _apiClient.put<Map<String, dynamic>>(
        '/api/mentorings/$id',
        data: data,
      );
      
      if (response.data != null) {
        final mentoring = MentoringResponse.fromJson(response.data!);
        
        Logger.info('멘토링 수정 성공 - ${mentoring.title}');
        return ApiResult.success(mentoring);
      } else {
        return ApiResult.failure(const UnknownException('멘토링 수정 응답 데이터가 없습니다.'));
      }
    } catch (e) {
      Logger.error('멘토링 수정 실패', error: e);
      if (e is ApiException) {
        return ApiResult.failure(e);
      } else {
        return ApiResult.failure(UnknownException('멘토링 수정 중 오류가 발생했습니다: $e'));
      }
    }
  }
  
  // 멘토링 삭제
  Future<ApiResult<void>> deleteMentoring(int id) async {
    try {
      Logger.info('멘토링 삭제 - ID: $id');
      
      await _apiClient.delete<void>('/api/mentorings/$id');
      
      Logger.info('멘토링 삭제 성공');
      return ApiResult.success(null);
    } catch (e) {
      Logger.error('멘토링 삭제 실패', error: e);
      if (e is ApiException) {
        return ApiResult.failure(e);
      } else {
        return ApiResult.failure(UnknownException('멘토링 삭제 중 오류가 발생했습니다: $e'));
      }
    }
  }

  // 멘토링 상태 변경 (ACTIVE, MATCHED, CLOSED, CANCELLED, COMPLETED)
  Future<ApiResult<MentoringResponse>> updateMentoringStatus({
    required int id,
    required String status,
  }) async {
    try {
      Logger.info('멘토링 상태 변경 시도 - ID: $id, Status: $status');

      // 유효한 상태값 확인
      const validStatuses = ['ACTIVE', 'MATCHED', 'CLOSED', 'CANCELLED', 'COMPLETED'];
      if (!validStatuses.contains(status.toUpperCase())) {
        return ApiResult.failure(const BadRequestException('유효하지 않은 상태값입니다. (ACTIVE, MATCHED, CLOSED, CANCELLED, COMPLETED 중 하나)'));
      }

      final response = await _apiClient.patch<Map<String, dynamic>>(
        '/api/mentorings/$id/status',
        queryParameters: {'status': status.toUpperCase()},
      );

      if (response.data != null) {
        final updatedMentoring = MentoringResponse.fromJson(response.data!);
        Logger.info('멘토링 상태 변경 성공: ${updatedMentoring.title} -> $status');
        return ApiResult.success(updatedMentoring);
      } else {
        return ApiResult.failure(const UnknownException('멘토링 상태 변경 응답 데이터가 없습니다.'));
      }
    } catch (e) {
      Logger.error('멘토링 상태 변경 실패', error: e);
      if (e is ApiException) {
        return ApiResult.failure(e);
      } else {
        return ApiResult.failure(UnknownException('멘토링 상태 변경 중 오류가 발생했습니다: $e'));
      }
    }
  }

  // 멘토링 타입별 조회
  Future<ApiResult<List<MentoringResponse>>> getMentoringsByType(String mentoringType) async {
    try {
      Logger.info('멘토링 타입별 조회 - 타입: $mentoringType');
      
      final response = await _apiClient.get<List<dynamic>>(
        '/api/mentorings/type/$mentoringType',
      );
      
      if (response.data != null) {
        final mentorings = response.data!
            .map((item) => MentoringResponse.fromJson(item as Map<String, dynamic>))
            .toList();
        
        Logger.info('멘토링 타입별 조회 성공 - 총 ${mentorings.length}개');
        return ApiResult.success(mentorings);
      } else {
        return ApiResult.failure(const UnknownException('멘토링 타입별 조회 응답 데이터가 없습니다.'));
      }
    } catch (e) {
      Logger.error('멘토링 타입별 조회 실패', error: e);
      if (e is ApiException) {
        return ApiResult.failure(e);
      } else {
        return ApiResult.failure(UnknownException('멘토링 타입별 조회 중 오류가 발생했습니다: $e'));
      }
    }
  }

  // 카테고리별 멘토링 조회
  Future<ApiResult<List<MentoringResponse>>> getMentoringsByCategory(String category) async {
    try {
      Logger.info('카테고리별 멘토링 조회 - 카테고리: $category');
      
      final response = await _apiClient.get<List<dynamic>>(
        '/api/mentorings/category/$category',
      );
      
      if (response.data != null) {
        final mentorings = response.data!
            .map((item) => MentoringResponse.fromJson(item as Map<String, dynamic>))
            .toList();
        
        Logger.info('카테고리별 멘토링 조회 성공 - 총 ${mentorings.length}개');
        return ApiResult.success(mentorings);
      } else {
        return ApiResult.failure(const UnknownException('카테고리별 멘토링 조회 응답 데이터가 없습니다.'));
      }
    } catch (e) {
      Logger.error('카테고리별 멘토링 조회 실패', error: e);
      if (e is ApiException) {
        return ApiResult.failure(e);
      } else {
        return ApiResult.failure(UnknownException('카테고리별 멘토링 조회 중 오류가 발생했습니다: $e'));
      }
    }
  }

  // 멘토링 검색 (다양한 조건)
  Future<ApiResult<List<MentoringResponse>>> searchMentorings({
    String? mentoringType,
    String? category,
    String? experienceLevel,
    String? location,
    String? keyword,
  }) async {
    try {
      Logger.info('멘토링 검색');
      
      final Map<String, dynamic> queryParams = {};
      
      if (mentoringType != null) queryParams['mentoringType'] = mentoringType;
      if (category != null) queryParams['category'] = category;
      if (experienceLevel != null) queryParams['experienceLevel'] = experienceLevel;
      if (location != null) queryParams['location'] = location;
      if (keyword != null && keyword.isNotEmpty) queryParams['keyword'] = keyword;
      
      final response = await _apiClient.get<List<dynamic>>(
        '/api/mentorings/search',
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );
      
      if (response.data != null) {
        final mentorings = response.data!
            .map((item) => MentoringResponse.fromJson(item as Map<String, dynamic>))
            .toList();
        
        Logger.info('멘토링 검색 성공 - 총 ${mentorings.length}개');
        return ApiResult.success(mentorings);
      } else {
        return ApiResult.failure(const UnknownException('멘토링 검색 응답 데이터가 없습니다.'));
      }
    } catch (e) {
      Logger.error('멘토링 검색 실패', error: e);
      if (e is ApiException) {
        return ApiResult.failure(e);
      } else {
        return ApiResult.failure(UnknownException('멘토링 검색 중 오류가 발생했습니다: $e'));
      }
    }
  }

  // 멘토링 카테고리 목록 조회
  Future<ApiResult<List<String>>> getCategories() async {
    try {
      Logger.info('멘토링 카테고리 목록 조회');
      
      final response = await _apiClient.get<List<dynamic>>(
        '/api/mentorings/categories',
      );
      
      if (response.data != null) {
        final categories = response.data!.cast<String>();
        
        Logger.info('멘토링 카테고리 목록 조회 성공 - 총 ${categories.length}개');
        return ApiResult.success(categories);
      } else {
        return ApiResult.failure(const UnknownException('멘토링 카테고리 목록 응답 데이터가 없습니다.'));
      }
    } catch (e) {
      Logger.error('멘토링 카테고리 목록 조회 실패', error: e);
      if (e is ApiException) {
        return ApiResult.failure(e);
      } else {
        return ApiResult.failure(UnknownException('멘토링 카테고리 목록 조회 중 오류가 발생했습니다: $e'));
      }
    }
  }

  // 멘토링 타입 목록 조회
  Future<ApiResult<List<String>>> getMentoringTypes() async {
    try {
      Logger.info('멘토링 타입 목록 조회');
      
      final response = await _apiClient.get<List<dynamic>>(
        '/api/mentorings/mentoring-types',
      );
      
      if (response.data != null) {
        final types = response.data!.cast<String>();
        
        Logger.info('멘토링 타입 목록 조회 성공 - 총 ${types.length}개');
        return ApiResult.success(types);
      } else {
        return ApiResult.failure(const UnknownException('멘토링 타입 목록 응답 데이터가 없습니다.'));
      }
    } catch (e) {
      Logger.error('멘토링 타입 목록 조회 실패', error: e);
      if (e is ApiException) {
        return ApiResult.failure(e);
      } else {
        return ApiResult.failure(UnknownException('멘토링 타입 목록 조회 중 오류가 발생했습니다: $e'));
      }
    }
  }

  // 경험 수준 목록 조회
  Future<ApiResult<List<String>>> getExperienceLevels() async {
    try {
      Logger.info('경험 수준 목록 조회');
      
      final response = await _apiClient.get<List<dynamic>>(
        '/api/mentorings/experience-levels',
      );
      
      if (response.data != null) {
        final levels = response.data!.cast<String>();
        
        Logger.info('경험 수준 목록 조회 성공 - 총 ${levels.length}개');
        return ApiResult.success(levels);
      } else {
        return ApiResult.failure(const UnknownException('경험 수준 목록 응답 데이터가 없습니다.'));
      }
    } catch (e) {
      Logger.error('경험 수준 목록 조회 실패', error: e);
      if (e is ApiException) {
        return ApiResult.failure(e);
      } else {
        return ApiResult.failure(UnknownException('경험 수준 목록 조회 중 오류가 발생했습니다: $e'));
      }
    }
  }

  // 멘토링 상태 목록 조회
  Future<ApiResult<List<String>>> getMentoringStatuses() async {
    try {
      Logger.info('멘토링 상태 목록 조회');
      
      final response = await _apiClient.get<List<dynamic>>(
        '/api/mentorings/statuses',
      );
      
      if (response.data != null) {
        final statuses = response.data!.cast<String>();
        
        Logger.info('멘토링 상태 목록 조회 성공 - 총 ${statuses.length}개');
        return ApiResult.success(statuses);
      } else {
        return ApiResult.failure(const UnknownException('멘토링 상태 목록 응답 데이터가 없습니다.'));
      }
    } catch (e) {
      Logger.error('멘토링 상태 목록 조회 실패', error: e);
      if (e is ApiException) {
        return ApiResult.failure(e);
      } else {
        return ApiResult.failure(UnknownException('멘토링 상태 목록 조회 중 오류가 발생했습니다: $e'));
      }
    }
  }
}
