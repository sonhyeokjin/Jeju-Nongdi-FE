import 'package:redux/redux.dart';
import 'package:jejunongdi/redux/mentoring/mentoring_state.dart';
import 'package:jejunongdi/redux/mentoring/mentoring_actions.dart';

final mentoringReducer = combineReducers<MentoringState>([
  // 로딩 상태
  TypedReducer<MentoringState, SetMentoringLoadingAction>(_setLoading),
  TypedReducer<MentoringState, SetMentoringCreateLoadingAction>(_setCreateLoading),
  
  // 에러 관리
  TypedReducer<MentoringState, SetMentoringErrorAction>(_setError),
  TypedReducer<MentoringState, ClearMentoringErrorAction>(_clearError),
  
  // 멘토링 목록
  TypedReducer<MentoringState, LoadMentoringsSuccessAction>(_loadMentoringsSuccess),
  TypedReducer<MentoringState, LoadMentoringsFailureAction>(_loadMentoringsFailure),
  
  // 내 멘토링 목록
  TypedReducer<MentoringState, LoadMyMentoringsSuccessAction>(_loadMyMentoringsSuccess),
  TypedReducer<MentoringState, LoadMyMentoringsFailureAction>(_loadMyMentoringsFailure),
  
  // 멘토링 상세
  TypedReducer<MentoringState, LoadMentoringDetailSuccessAction>(_loadMentoringDetailSuccess),
  TypedReducer<MentoringState, LoadMentoringDetailFailureAction>(_loadMentoringDetailFailure),
  
  // 멘토링 생성
  TypedReducer<MentoringState, CreateMentoringSuccessAction>(_createMentoringSuccess),
  TypedReducer<MentoringState, CreateMentoringFailureAction>(_createMentoringFailure),
  
  // 멘토링 수정
  TypedReducer<MentoringState, UpdateMentoringSuccessAction>(_updateMentoringSuccess),
  TypedReducer<MentoringState, UpdateMentoringFailureAction>(_updateMentoringFailure),
  
  // 멘토링 삭제
  TypedReducer<MentoringState, DeleteMentoringSuccessAction>(_deleteMentoringSuccess),
  TypedReducer<MentoringState, DeleteMentoringFailureAction>(_deleteMentoringFailure),
  
  // 선택된 멘토링
  TypedReducer<MentoringState, SetSelectedMentoringAction>(_setSelectedMentoring),
  TypedReducer<MentoringState, ClearSelectedMentoringAction>(_clearSelectedMentoring),
  
  // 상태 초기화
  TypedReducer<MentoringState, ResetMentoringStateAction>(_resetState),
]);

// 로딩 상태 관리
MentoringState _setLoading(MentoringState state, SetMentoringLoadingAction action) {
  return state.copyWith(isLoading: action.isLoading);
}

MentoringState _setCreateLoading(MentoringState state, SetMentoringCreateLoadingAction action) {
  return state.copyWith(isCreateLoading: action.isLoading);
}

// 에러 관리
MentoringState _setError(MentoringState state, SetMentoringErrorAction action) {
  return state.copyWith(error: action.error);
}

MentoringState _clearError(MentoringState state, ClearMentoringErrorAction action) {
  return state.copyWith(clearError: true);
}

// 멘토링 목록
MentoringState _loadMentoringsSuccess(MentoringState state, LoadMentoringsSuccessAction action) {
  final newMentorings = action.refresh 
      ? action.pageResponse.content
      : [...state.mentorings, ...action.pageResponse.content];
      
  return state.copyWith(
    mentorings: newMentorings,
    currentPage: action.pageResponse.number,
    hasMore: !action.pageResponse.last,
    totalElements: action.pageResponse.totalElements,
    clearError: true,
  );
}

MentoringState _loadMentoringsFailure(MentoringState state, LoadMentoringsFailureAction action) {
  return state.copyWith(error: action.error);
}

// 내 멘토링 목록
MentoringState _loadMyMentoringsSuccess(MentoringState state, LoadMyMentoringsSuccessAction action) {
  return state.copyWith(
    myMentorings: action.mentorings,
    clearError: true,
  );
}

MentoringState _loadMyMentoringsFailure(MentoringState state, LoadMyMentoringsFailureAction action) {
  return state.copyWith(error: action.error);
}

// 멘토링 상세
MentoringState _loadMentoringDetailSuccess(MentoringState state, LoadMentoringDetailSuccessAction action) {
  return state.copyWith(
    selectedMentoring: action.mentoring,
    clearError: true,
  );
}

MentoringState _loadMentoringDetailFailure(MentoringState state, LoadMentoringDetailFailureAction action) {
  return state.copyWith(error: action.error);
}

// 멘토링 생성
MentoringState _createMentoringSuccess(MentoringState state, CreateMentoringSuccessAction action) {
  return state.copyWith(
    mentorings: [action.mentoring, ...state.mentorings],
    myMentorings: [action.mentoring, ...state.myMentorings],
    clearError: true,
  );
}

MentoringState _createMentoringFailure(MentoringState state, CreateMentoringFailureAction action) {
  return state.copyWith(error: action.error);
}

// 멘토링 수정
MentoringState _updateMentoringSuccess(MentoringState state, UpdateMentoringSuccessAction action) {
  final updatedMentorings = state.mentorings.map((m) => 
      m.id == action.mentoring.id ? action.mentoring : m
  ).toList();
  
  final updatedMyMentorings = state.myMentorings.map((m) => 
      m.id == action.mentoring.id ? action.mentoring : m
  ).toList();
  
  return state.copyWith(
    mentorings: updatedMentorings,
    myMentorings: updatedMyMentorings,
    selectedMentoring: state.selectedMentoring?.id == action.mentoring.id 
        ? action.mentoring 
        : state.selectedMentoring,
    clearError: true,
  );
}

MentoringState _updateMentoringFailure(MentoringState state, UpdateMentoringFailureAction action) {
  return state.copyWith(error: action.error);
}

// 멘토링 삭제
MentoringState _deleteMentoringSuccess(MentoringState state, DeleteMentoringSuccessAction action) {
  final filteredMentorings = state.mentorings.where((m) => m.id != action.id).toList();
  final filteredMyMentorings = state.myMentorings.where((m) => m.id != action.id).toList();
  
  return state.copyWith(
    mentorings: filteredMentorings,
    myMentorings: filteredMyMentorings,
    selectedMentoring: state.selectedMentoring?.id == action.id 
        ? null 
        : state.selectedMentoring,
    clearError: true,
  );
}

MentoringState _deleteMentoringFailure(MentoringState state, DeleteMentoringFailureAction action) {
  return state.copyWith(error: action.error);
}

// 선택된 멘토링
MentoringState _setSelectedMentoring(MentoringState state, SetSelectedMentoringAction action) {
  return state.copyWith(selectedMentoring: action.mentoring);
}

MentoringState _clearSelectedMentoring(MentoringState state, ClearSelectedMentoringAction action) {
  return state.copyWith(clearSelectedMentoring: true);
}

// 상태 초기화
MentoringState _resetState(MentoringState state, ResetMentoringStateAction action) {
  return MentoringState.initial();
}
