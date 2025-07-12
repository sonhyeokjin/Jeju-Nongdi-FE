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
}
