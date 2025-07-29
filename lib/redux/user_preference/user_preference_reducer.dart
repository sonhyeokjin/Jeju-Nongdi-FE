import 'package:redux/redux.dart';
import 'package:jejunongdi/redux/user_preference/user_preference_state.dart';
import 'package:jejunongdi/redux/user_preference/user_preference_actions.dart';

final userPreferenceReducer = combineReducers<UserPreferenceState>([
  TypedReducer<UserPreferenceState, SetUserPreferenceLoadingAction>(_setLoading),
  TypedReducer<UserPreferenceState, SetUserPreferenceErrorAction>(_setError),
  TypedReducer<UserPreferenceState, ClearUserPreferenceErrorAction>(_clearError),
  
  // 내 설정 관련
  TypedReducer<UserPreferenceState, LoadMyPreferenceSuccessAction>(_loadMyPreferenceSuccess),
  TypedReducer<UserPreferenceState, LoadMyPreferenceFailureAction>(_loadMyPreferenceFailure),
  TypedReducer<UserPreferenceState, UpdateMyPreferenceSuccessAction>(_updateMyPreferenceSuccess),
  TypedReducer<UserPreferenceState, UpdateMyPreferenceFailureAction>(_updateMyPreferenceFailure),
  
  // 사용자 설정 관련
  TypedReducer<UserPreferenceState, LoadUserPreferenceSuccessAction>(_loadUserPreferenceSuccess),
  TypedReducer<UserPreferenceState, LoadUserPreferenceFailureAction>(_loadUserPreferenceFailure),
  TypedReducer<UserPreferenceState, CreateOrUpdatePreferenceSuccessAction>(_createOrUpdatePreferenceSuccess),
  TypedReducer<UserPreferenceState, CreateOrUpdatePreferenceFailureAction>(_createOrUpdatePreferenceFailure),
  TypedReducer<UserPreferenceState, DeletePreferenceSuccessAction>(_deletePreferenceSuccess),
  TypedReducer<UserPreferenceState, DeletePreferenceFailureAction>(_deletePreferenceFailure),
  
  // 기본 설정 생성
  TypedReducer<UserPreferenceState, CreateDefaultPreferenceSuccessAction>(_createDefaultPreferenceSuccess),
  TypedReducer<UserPreferenceState, CreateDefaultPreferenceFailureAction>(_createDefaultPreferenceFailure),
  
  // 유효성 검사
  TypedReducer<UserPreferenceState, ValidatePreferenceSuccessAction>(_validatePreferenceSuccess),
  TypedReducer<UserPreferenceState, ValidatePreferenceFailureAction>(_validatePreferenceFailure),
  
  // 서버 유효성 검사
  TypedReducer<UserPreferenceState, ValidatePreferenceOnServerSuccessAction>(_validatePreferenceOnServerSuccess),
  TypedReducer<UserPreferenceState, ValidatePreferenceOnServerFailureAction>(_validatePreferenceOnServerFailure),
  
  // 농업 유형 목록
  TypedReducer<UserPreferenceState, LoadFarmingTypesSuccessAction>(_loadFarmingTypesSuccess),
  TypedReducer<UserPreferenceState, LoadFarmingTypesFailureAction>(_loadFarmingTypesFailure),
  
  // 사용자 조회
  TypedReducer<UserPreferenceState, LoadUsersByLocationSuccessAction>(_loadUsersByLocationSuccess),
  TypedReducer<UserPreferenceState, LoadUsersByLocationFailureAction>(_loadUsersByLocationFailure),
  TypedReducer<UserPreferenceState, LoadUsersByCropSuccessAction>(_loadUsersByCropSuccess),
  TypedReducer<UserPreferenceState, LoadUsersByCropFailureAction>(_loadUsersByCropFailure),
  TypedReducer<UserPreferenceState, LoadUsersByNotificationTypeSuccessAction>(_loadUsersByNotificationTypeSuccess),
  TypedReducer<UserPreferenceState, LoadUsersByNotificationTypeFailureAction>(_loadUsersByNotificationTypeFailure),
  
  // 선택된 설정 관리
  TypedReducer<UserPreferenceState, SetSelectedPreferenceAction>(_setSelectedPreference),
  TypedReducer<UserPreferenceState, ClearSelectedPreferenceAction>(_clearSelectedPreference),
  
  // 상태 초기화
  TypedReducer<UserPreferenceState, ResetUserPreferenceStateAction>(_resetState),
]);

// 로딩 상태 관리
UserPreferenceState _setLoading(UserPreferenceState state, SetUserPreferenceLoadingAction action) {
  return state.copyWith(isLoading: action.isLoading);
}

UserPreferenceState _setError(UserPreferenceState state, SetUserPreferenceErrorAction action) {
  return state.copyWith(error: action.error);
}

UserPreferenceState _clearError(UserPreferenceState state, ClearUserPreferenceErrorAction action) {
  return state.copyWith(clearError: true);
}

// 내 설정 관련
UserPreferenceState _loadMyPreferenceSuccess(UserPreferenceState state, LoadMyPreferenceSuccessAction action) {
  return state.copyWith(
    myPreference: action.preference,
    clearError: true,
  );
}

UserPreferenceState _loadMyPreferenceFailure(UserPreferenceState state, LoadMyPreferenceFailureAction action) {
  return state.copyWith(error: action.error);
}

UserPreferenceState _updateMyPreferenceSuccess(UserPreferenceState state, UpdateMyPreferenceSuccessAction action) {
  return state.copyWith(
    myPreference: action.preference,
    clearError: true,
  );
}

UserPreferenceState _updateMyPreferenceFailure(UserPreferenceState state, UpdateMyPreferenceFailureAction action) {
  return state.copyWith(error: action.error);
}

// 사용자 설정 관련
UserPreferenceState _loadUserPreferenceSuccess(UserPreferenceState state, LoadUserPreferenceSuccessAction action) {
  return state.copyWith(
    selectedPreference: action.preference,
    clearError: true,
  );
}

UserPreferenceState _loadUserPreferenceFailure(UserPreferenceState state, LoadUserPreferenceFailureAction action) {
  return state.copyWith(error: action.error);
}

UserPreferenceState _createOrUpdatePreferenceSuccess(UserPreferenceState state, CreateOrUpdatePreferenceSuccessAction action) {
  return state.copyWith(
    selectedPreference: action.preference,
    clearError: true,
  );
}

UserPreferenceState _createOrUpdatePreferenceFailure(UserPreferenceState state, CreateOrUpdatePreferenceFailureAction action) {
  return state.copyWith(error: action.error);
}

UserPreferenceState _deletePreferenceSuccess(UserPreferenceState state, DeletePreferenceSuccessAction action) {
  return state.copyWith(
    clearSelectedPreference: true,
    clearError: true,
  );
}

UserPreferenceState _deletePreferenceFailure(UserPreferenceState state, DeletePreferenceFailureAction action) {
  return state.copyWith(error: action.error);
}

// 기본 설정 생성
UserPreferenceState _createDefaultPreferenceSuccess(UserPreferenceState state, CreateDefaultPreferenceSuccessAction action) {
  return state.copyWith(
    selectedPreference: action.preference,
    clearError: true,
  );
}

UserPreferenceState _createDefaultPreferenceFailure(UserPreferenceState state, CreateDefaultPreferenceFailureAction action) {
  return state.copyWith(error: action.error);
}

// 유효성 검사
UserPreferenceState _validatePreferenceSuccess(UserPreferenceState state, ValidatePreferenceSuccessAction action) {
  return state.copyWith(
    isValid: action.isValid,
    isValidationPassed: action.isValid,
    clearError: true,
  );
}

UserPreferenceState _validatePreferenceFailure(UserPreferenceState state, ValidatePreferenceFailureAction action) {
  return state.copyWith(
    isValidationPassed: false,
    error: action.error,
  );
}

// 서버 유효성 검사
UserPreferenceState _validatePreferenceOnServerSuccess(UserPreferenceState state, ValidatePreferenceOnServerSuccessAction action) {
  return state.copyWith(
    isServerValidationPassed: action.isValid,
    clearError: true,
  );
}

UserPreferenceState _validatePreferenceOnServerFailure(UserPreferenceState state, ValidatePreferenceOnServerFailureAction action) {
  return state.copyWith(
    isServerValidationPassed: false,
    error: action.error,
  );
}

// 농업 유형 목록
UserPreferenceState _loadFarmingTypesSuccess(UserPreferenceState state, LoadFarmingTypesSuccessAction action) {
  return state.copyWith(
    farmingTypes: action.farmingTypes,
    clearError: true,
  );
}

UserPreferenceState _loadFarmingTypesFailure(UserPreferenceState state, LoadFarmingTypesFailureAction action) {
  return state.copyWith(error: action.error);
}

// 사용자 조회
UserPreferenceState _loadUsersByLocationSuccess(UserPreferenceState state, LoadUsersByLocationSuccessAction action) {
  return state.copyWith(
    usersByLocation: action.users,
    clearError: true,
  );
}

UserPreferenceState _loadUsersByLocationFailure(UserPreferenceState state, LoadUsersByLocationFailureAction action) {
  return state.copyWith(error: action.error);
}

UserPreferenceState _loadUsersByCropSuccess(UserPreferenceState state, LoadUsersByCropSuccessAction action) {
  return state.copyWith(
    usersByCrop: action.users,
    clearError: true,
  );
}

UserPreferenceState _loadUsersByCropFailure(UserPreferenceState state, LoadUsersByCropFailureAction action) {
  return state.copyWith(error: action.error);
}

UserPreferenceState _loadUsersByNotificationTypeSuccess(UserPreferenceState state, LoadUsersByNotificationTypeSuccessAction action) {
  return state.copyWith(
    usersByNotificationType: action.users,
    clearError: true,
  );
}

UserPreferenceState _loadUsersByNotificationTypeFailure(UserPreferenceState state, LoadUsersByNotificationTypeFailureAction action) {
  return state.copyWith(error: action.error);
}

// 선택된 설정 관리
UserPreferenceState _setSelectedPreference(UserPreferenceState state, SetSelectedPreferenceAction action) {
  return state.copyWith(selectedPreference: action.preference);
}

UserPreferenceState _clearSelectedPreference(UserPreferenceState state, ClearSelectedPreferenceAction action) {
  return state.copyWith(clearSelectedPreference: true);
}

// 상태 초기화
UserPreferenceState _resetState(UserPreferenceState state, ResetUserPreferenceStateAction action) {
  return const UserPreferenceState();
}