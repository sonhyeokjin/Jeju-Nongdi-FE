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
  
  // 멘토링 필터링 조회
  Future<ApiResult<PageResponse<MentoringResponse>>> getFilteredMentorings({
    int page = 0,
    int size = 20,
    String? category,
    String? mentoringType,
    String? experienceLevel,
    String? status,
    String? keyword,
  }) async {
    try {
      Logger.info('멘토링 필터링 조회');
      
      final Map<String, dynamic> queryParams = {
        'page': page,
        'size': size,
        'sort': 'createdAt,desc',
      };
      
      if (category != null) queryParams['category'] = category;
      if (mentoringType != null) queryParams['mentoringType'] = mentoringType;
      if (experienceLevel != null) queryParams['experienceLevel'] = experienceLevel;
      if (status != null) queryParams['status'] = status;
      if (keyword != null && keyword.isNotEmpty) queryParams['keyword'] = keyword;
      
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/api/mentorings/search',
        queryParameters: queryParams,
      );
      
      if (response.data != null) {
        final pageResponse = PageResponse<MentoringResponse>.fromJson(
          response.data!,
          (json) => MentoringResponse.fromJson(json as Map<String, dynamic>),
        );
        
        Logger.info('멘토링 필터링 조회 성공 - 총 ${pageResponse.totalElements}개');
        return ApiResult.success(pageResponse);
      } else {
        return ApiResult.failure(const UnknownException('멘토링 필터링 응답 데이터가 없습니다.'));
      }
    } catch (e) {
      Logger.error('멘토링 필터링 조회 실패', error: e);
      if (e is ApiException) {
        return ApiResult.failure(e);
      } else {
        return ApiResult.failure(UnknownException('멘토링 필터링 조회 중 오류가 발생했습니다: $e'));
      }
    }
  }
  
  // 내가 작성한 멘토링 목록 조회
  Future<ApiResult<PageResponse<MentoringResponse>>> getMyMentorings({
    int page = 0,
    int size = 20,
  }) async {
    try {
      Logger.info('내 멘토링 목록 조회');
      
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/api/mentorings/my',
        queryParameters: {
          'page': page,
          'size': size,
          'sort': 'createdAt,desc',
        },
      );
      
      if (response.data != null) {
        final pageResponse = PageResponse<MentoringResponse>.fromJson(
          response.data!,
          (json) => MentoringResponse.fromJson(json as Map<String, dynamic>),
        );
        
        Logger.info('내 멘토링 목록 조회 성공 - 총 ${pageResponse.totalElements}개');
        return ApiResult.success(pageResponse);
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
}
