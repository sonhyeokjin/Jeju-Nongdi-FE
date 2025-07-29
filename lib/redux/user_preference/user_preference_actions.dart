import 'package:jejunongdi/core/models/user_preference_models.dart';

// 로딩 상태 관리
class SetUserPreferenceLoadingAction {
  final bool isLoading;
  SetUserPreferenceLoadingAction(this.isLoading);
}

// 에러 관리
class SetUserPreferenceErrorAction {
  final String? error;
  SetUserPreferenceErrorAction(this.error);
}

class ClearUserPreferenceErrorAction {}

// 내 설정 조회
class LoadMyPreferenceAction {}

class LoadMyPreferenceSuccessAction {
  final UserPreferenceDto preference;
  LoadMyPreferenceSuccessAction(this.preference);
}

class LoadMyPreferenceFailureAction {
  final String error;
  LoadMyPreferenceFailureAction(this.error);
}

// 내 설정 수정
class UpdateMyPreferenceAction {
  final UserPreferenceDto preference;
  UpdateMyPreferenceAction(this.preference);
}

class UpdateMyPreferenceSuccessAction {
  final UserPreferenceDto preference;
  UpdateMyPreferenceSuccessAction(this.preference);
}

class UpdateMyPreferenceFailureAction {
  final String error;
  UpdateMyPreferenceFailureAction(this.error);
}

// 사용자 설정 조회
class LoadUserPreferenceAction {
  final int userId;
  LoadUserPreferenceAction(this.userId);
}

class LoadUserPreferenceSuccessAction {
  final UserPreferenceDto preference;
  LoadUserPreferenceSuccessAction(this.preference);
}

class LoadUserPreferenceFailureAction {
  final String error;
  LoadUserPreferenceFailureAction(this.error);
}

// 사용자 설정 생성/수정
class CreateOrUpdatePreferenceAction {
  final int userId;
  final UserPreferenceDto preference;
  CreateOrUpdatePreferenceAction(this.userId, this.preference);
}

class CreateOrUpdatePreferenceSuccessAction {
  final UserPreferenceDto preference;
  CreateOrUpdatePreferenceSuccessAction(this.preference);
}

class CreateOrUpdatePreferenceFailureAction {
  final String error;
  CreateOrUpdatePreferenceFailureAction(this.error);
}

// 사용자 설정 삭제
class DeletePreferenceAction {
  final int userId;
  DeletePreferenceAction(this.userId);
}

class DeletePreferenceSuccessAction {
  final int userId;
  DeletePreferenceSuccessAction(this.userId);
}

class DeletePreferenceFailureAction {
  final String error;
  DeletePreferenceFailureAction(this.error);
}

// 기본 설정 생성
class CreateDefaultPreferenceAction {
  final int userId;
  CreateDefaultPreferenceAction(this.userId);
}

class CreateDefaultPreferenceSuccessAction {
  final UserPreferenceDto preference;
  CreateDefaultPreferenceSuccessAction(this.preference);
}

class CreateDefaultPreferenceFailureAction {
  final String error;
  CreateDefaultPreferenceFailureAction(this.error);
}

// 설정 유효성 검사 (로컬)
class ValidatePreferenceAction {
  final UserPreferenceDto preference;
  ValidatePreferenceAction(this.preference);
}

class ValidatePreferenceSuccessAction {
  final bool isValid;
  ValidatePreferenceSuccessAction(this.isValid);
}

class ValidatePreferenceFailureAction {
  final String error;
  ValidatePreferenceFailureAction(this.error);
}

// 설정 유효성 검사 (서버)
class ValidatePreferenceOnServerAction {
  final UserPreferenceDto preference;
  ValidatePreferenceOnServerAction(this.preference);
}

class ValidatePreferenceOnServerSuccessAction {
  final bool isValid;
  ValidatePreferenceOnServerSuccessAction(this.isValid);
}

class ValidatePreferenceOnServerFailureAction {
  final String error;
  ValidatePreferenceOnServerFailureAction(this.error);
}

// 농업 유형 목록 조회
class LoadFarmingTypesAction {}

class LoadFarmingTypesSuccessAction {
  final List<FarmingTypeInfo> farmingTypes;
  LoadFarmingTypesSuccessAction(this.farmingTypes);
}

class LoadFarmingTypesFailureAction {
  final String error;
  LoadFarmingTypesFailureAction(this.error);
}

// 지역별 사용자 조회
class LoadUsersByLocationAction {
  final String location;
  LoadUsersByLocationAction(this.location);
}

class LoadUsersByLocationSuccessAction {
  final List<UserPreferenceDto> users;
  LoadUsersByLocationSuccessAction(this.users);
}

class LoadUsersByLocationFailureAction {
  final String error;
  LoadUsersByLocationFailureAction(this.error);
}

// 작물별 사용자 조회
class LoadUsersByCropAction {
  final String cropName;
  LoadUsersByCropAction(this.cropName);
}

class LoadUsersByCropSuccessAction {
  final List<UserPreferenceDto> users;
  LoadUsersByCropSuccessAction(this.users);
}

class LoadUsersByCropFailureAction {
  final String error;
  LoadUsersByCropFailureAction(this.error);
}

// 알림 유형별 사용자 조회
class LoadUsersByNotificationTypeAction {
  final String type;
  LoadUsersByNotificationTypeAction(this.type);
}

class LoadUsersByNotificationTypeSuccessAction {
  final List<UserPreferenceDto> users;
  LoadUsersByNotificationTypeSuccessAction(this.users);
}

class LoadUsersByNotificationTypeFailureAction {
  final String error;
  LoadUsersByNotificationTypeFailureAction(this.error);
}

// 상태 초기화
class ResetUserPreferenceStateAction {}

// 선택된 설정 관리
class SetSelectedPreferenceAction {
  final UserPreferenceDto? preference;
  SetSelectedPreferenceAction(this.preference);
}

class ClearSelectedPreferenceAction {}