import 'package:jejunongdi/core/models/job_posting_model.dart';
import 'package:jejunongdi/core/network/api_client.dart';
import 'package:jejunongdi/core/network/api_exceptions.dart';
import 'package:jejunongdi/core/utils/logger.dart';

class JobPostingService {
  static JobPostingService? _instance;
  final ApiClient _apiClient = ApiClient.instance;

  static JobPostingService get instance {
    _instance ??= JobPostingService._internal();
    return _instance!;
  }

  JobPostingService._internal();

  /// 전체 일손 모집 공고 목록을 가져옵니다.
  Future<ApiResult<List<JobPostingResponse>>> getJobPostings() async {
    try {
      Logger.info('일손 모집 공고 목록 조회 시도');

      // GET 요청으로 공고 목록 데이터를 받아옵니다.
      final response = await _apiClient.get<List<dynamic>>('/api/job-postings');

      if (response.data != null) {
        // 받아온 List<dynamic> 데이터를 List<JobPostingResponse>로 변환합니다.
        final jobPostings = response.data!
            .map((item) => JobPostingResponse.fromJson(item as Map<String, dynamic>))
            .toList();

        Logger.info('일손 모집 공고 목록 조회 성공: ${jobPostings.length}개');
        return ApiResult.success(jobPostings);
      } else {
        return ApiResult.failure(const UnknownException('공고 목록 응답 데이터가 없습니다.'));
      }
    } catch (e) {
      Logger.error('일손 모집 공고 목록 조회 실패', error: e);
      if (e is ApiException) {
        return ApiResult.failure(e);
      } else {
        return ApiResult.failure(UnknownException('공고 목록 조회 중 오류가 발생했습니다: $e'));
      }
    }
  }

  /// 페이징 지원 일손 모집 공고 목록을 가져옵니다.
  Future<ApiResult<JobPostingPageResponse>> getJobPostingsPaged({
    int page = 0,
    int size = 20,
    String sort = 'createdAt',
    String direction = 'DESC',
  }) async {
    try {
      Logger.info('페이징 일손 모집 공고 목록 조회 시도: page=$page, size=$size');

      // GET 요청으로 페이징된 공고 목록 데이터를 받아옵니다.
      final response = await _apiClient.get(
        '/api/job-postings',
        queryParameters: {
          'page': page,
          'size': size,
          'sort': '$sort,$direction',
        },
      );

      if (response.data != null) {
        final pageData = JobPostingPageResponse.fromJson(response.data as Map<String, dynamic>);
        Logger.info('페이징 일손 모집 공고 목록 조회 성공: ${pageData.content.length}개 (총 ${pageData.totalElements}개)');
        return ApiResult.success(pageData);
      } else {
        return ApiResult.failure(const UnknownException('페이징 공고 목록 응답 데이터가 없습니다.'));
      }
    } catch (e) {
      Logger.error('페이징 일손 모집 공고 목록 조회 실패', error: e);
      if (e is ApiException) {
        return ApiResult.failure(e);
      } else {
        return ApiResult.failure(UnknownException('페이징 공고 목록 조회 중 오류가 발생했습니다: $e'));
      }
    }
  }

  /// 새로운 일손 모집 공고를 등록합니다.
  Future<ApiResult<JobPostingResponse>> createJobPosting(JobPostingRequest request) async {
    try {
      Logger.info('일손 모집 공고 등록 시도');

      // POST 요청으로 새 공고를 등록합니다.
      final response = await _apiClient.post(
        '/api/job-postings',
        data: request.toJson(),
      );

      if (response.data != null) {
        final jobPosting = JobPostingResponse.fromJson(response.data as Map<String, dynamic>);
        Logger.info('일손 모집 공고 등록 성공: ${jobPosting.id}');
        return ApiResult.success(jobPosting);
      } else {
        return ApiResult.failure(const UnknownException('공고 등록 응답 데이터가 없습니다.'));
      }
    } catch (e) {
      Logger.error('일손 모집 공고 등록 실패', error: e);
      if (e is ApiException) {
        return ApiResult.failure(e);
      } else {
        return ApiResult.failure(UnknownException('공고 등록 중 오류가 발생했습니다: $e'));
      }
    }
  }

  /// 지도 범위 내의 일손 모집 공고 목록을 가져옵니다.
  Future<ApiResult<List<JobPostingResponse>>> getJobPostingsByBounds({
    required double minLat,
    required double maxLat,
    required double minLng,
    required double maxLng,
    int page = 0,
    int size = 20,
  }) async {
    try {
      Logger.info('지도 범위 내 일손 모집 공고 조회 시도: minLat=$minLat, maxLat=$maxLat, minLng=$minLng, maxLng=$maxLng');

      // GET 요청으로 범위 내 공고 목록 데이터를 받아옵니다.
      final response = await _apiClient.get(
        '/api/job-postings/bounds',
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
        List<dynamic> jobPostingsData;
        
        // 응답 데이터 타입에 따라 처리
        if (response.data is List) {
          // 직접 리스트로 응답이 온 경우
          jobPostingsData = response.data as List<dynamic>;
        } else if (response.data is Map<String, dynamic>) {
          // 페이징된 응답으로 온 경우 (content 필드에 실제 데이터)
          final responseMap = response.data as Map<String, dynamic>;
          jobPostingsData = responseMap['content'] as List<dynamic>? ?? [];
        } else {
          jobPostingsData = [];
        }

        // 받아온 데이터를 List<JobPostingResponse>로 변환합니다.
        final jobPostings = jobPostingsData
            .map((item) => JobPostingResponse.fromJson(item as Map<String, dynamic>))
            .toList();

        Logger.info('지도 범위 내 일손 모집 공고 조회 성공: ${jobPostings.length}개');
        return ApiResult.success(jobPostings);
      } else {
        return ApiResult.failure(const UnknownException('범위 내 공고 목록 응답 데이터가 없습니다.'));
      }
    } catch (e) {
      Logger.error('지도 범위 내 일손 모집 공고 조회 실패', error: e);
      if (e is ApiException) {
        return ApiResult.failure(e);
      } else {
        return ApiResult.failure(UnknownException('범위 내 공고 조회 중 오류가 발생했습니다: $e'));
      }
    }
  }
}
