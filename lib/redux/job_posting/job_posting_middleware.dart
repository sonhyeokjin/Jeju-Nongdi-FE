// Job Posting Middleware - 일자리 공고 관련 미들웨어 정의
import 'package:redux/redux.dart';
import 'package:jejunongdi/redux/app_state.dart';
import 'package:jejunongdi/redux/job_posting/job_posting_actions.dart';
import 'package:jejunongdi/core/services/job_posting_service.dart';

class JobPostingMiddleware {
  static List<Middleware<AppState>> createMiddleware() {
    return [
      TypedMiddleware<AppState, CreateJobPostingAction>(_createJobPosting),
    ];
  }

  // 일자리 공고 생성 미들웨어
  static void _createJobPosting(Store<AppState> store, CreateJobPostingAction action, NextDispatcher next) async {
    next(action);
    
    try {
      // 로딩 상태 시작
      store.dispatch(const SetJobPostingLoadingAction(true));
      
      // API 호출
      final result = await JobPostingService.instance.createJobPosting(action.request);
      
      result.onSuccess((response) {
        // 성공 액션 디스패치
        store.dispatch(CreateJobPostingSuccessAction(response));
        print('✅ 일자리 공고 생성 성공: ${response.id}');
      });
      
      result.onFailure((error) {
        // 실패 액션 디스패치
        store.dispatch(CreateJobPostingFailureAction(error.message));
        print('❌ 일자리 공고 생성 실패: ${error.message}');
      });
      
    } catch (e) {
      // 예외 처리
      store.dispatch(CreateJobPostingFailureAction('일자리 공고 생성 중 오류가 발생했습니다: $e'));
      print('❌ 일자리 공고 생성 중 예외 발생: $e');
    } finally {
      // 로딩 상태 종료
      store.dispatch(const SetJobPostingLoadingAction(false));
    }
  }
}
