// Job Posting Reducer - 일자리 공고 관련 리듀서 정의
import 'package:redux/redux.dart';
import 'package:jejunongdi/redux/job_posting/job_posting_state.dart';
import 'package:jejunongdi/redux/job_posting/job_posting_actions.dart';

final jobPostingReducer = combineReducers<JobPostingState>([
  TypedReducer<JobPostingState, SelectAddressAction>(_selectAddress),
  TypedReducer<JobPostingState, ClearAddressAction>(_clearAddress),
  TypedReducer<JobPostingState, CreateJobPostingAction>(_createJobPosting),
  TypedReducer<JobPostingState, CreateJobPostingSuccessAction>(_createJobPostingSuccess),
  TypedReducer<JobPostingState, CreateJobPostingFailureAction>(_createJobPostingFailure),
  TypedReducer<JobPostingState, SetJobPostingLoadingAction>(_setLoading),
  TypedReducer<JobPostingState, SetJobPostingErrorAction>(_setError),
]);

// 주소 선택 리듀서
JobPostingState _selectAddress(JobPostingState state, SelectAddressAction action) {
  return JobPostingState(
    isLoading: state.isLoading,
    error: null, // 에러 초기화
    selectedAddress: action.address,
    selectedLatitude: action.latitude,
    selectedLongitude: action.longitude,
    isCreateLoading: state.isCreateLoading,
  );
}

// 주소 정보 클리어 리듀서
JobPostingState _clearAddress(JobPostingState state, ClearAddressAction action) {
  return state.clearAddress();
}

// 일자리 공고 생성 시작 리듀서
JobPostingState _createJobPosting(JobPostingState state, CreateJobPostingAction action) {
  return state.copyWith(
    isCreateLoading: true,
  ).clearError();
}

// 일자리 공고 생성 성공 리듀서
JobPostingState _createJobPostingSuccess(JobPostingState state, CreateJobPostingSuccessAction action) {
  return state.copyWith(
    isCreateLoading: false,
  ).clearError();
}

// 일자리 공고 생성 실패 리듀서
JobPostingState _createJobPostingFailure(JobPostingState state, CreateJobPostingFailureAction action) {
  return JobPostingState(
    isLoading: state.isLoading,
    error: action.error,
    selectedAddress: state.selectedAddress,
    selectedLatitude: state.selectedLatitude,
    selectedLongitude: state.selectedLongitude,
    isCreateLoading: false,
  );
}

// 로딩 상태 설정 리듀서
JobPostingState _setLoading(JobPostingState state, SetJobPostingLoadingAction action) {
  return state.copyWith(
    isLoading: action.isLoading,
  );
}

// 에러 상태 설정 리듀서
JobPostingState _setError(JobPostingState state, SetJobPostingErrorAction action) {
  return JobPostingState(
    isLoading: state.isLoading,
    error: action.error,
    selectedAddress: state.selectedAddress,
    selectedLatitude: state.selectedLatitude,
    selectedLongitude: state.selectedLongitude,
    isCreateLoading: state.isCreateLoading,
  );
}
