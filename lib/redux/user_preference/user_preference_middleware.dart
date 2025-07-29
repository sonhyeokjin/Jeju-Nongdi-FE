import 'package:redux/redux.dart';
import 'package:jejunongdi/redux/app_state.dart';
import 'package:jejunongdi/redux/user_preference/user_preference_actions.dart';
import 'package:jejunongdi/core/services/user_preference_service.dart';
import 'package:jejunongdi/core/network/api_exceptions.dart';
import 'package:jejunongdi/core/utils/logger.dart';

class UserPreferenceMiddleware {
  static List<Middleware<AppState>> createMiddleware() {
    return [
      TypedMiddleware<AppState, LoadMyPreferenceAction>(_loadMyPreference),
      TypedMiddleware<AppState, UpdateMyPreferenceAction>(_updateMyPreference),
      TypedMiddleware<AppState, LoadUserPreferenceAction>(_loadUserPreference),
      TypedMiddleware<AppState, CreateOrUpdatePreferenceAction>(_createOrUpdatePreference),
      TypedMiddleware<AppState, DeletePreferenceAction>(_deletePreference),
      TypedMiddleware<AppState, CreateDefaultPreferenceAction>(_createDefaultPreference),
      TypedMiddleware<AppState, ValidatePreferenceAction>(_validatePreference),
      TypedMiddleware<AppState, ValidatePreferenceOnServerAction>(_validatePreferenceOnServer),
      TypedMiddleware<AppState, LoadFarmingTypesAction>(_loadFarmingTypes),
      TypedMiddleware<AppState, LoadUsersByLocationAction>(_loadUsersByLocation),
      TypedMiddleware<AppState, LoadUsersByCropAction>(_loadUsersByCrop),
      TypedMiddleware<AppState, LoadUsersByNotificationTypeAction>(_loadUsersByNotificationType),
    ];
  }

  static void _loadMyPreference(
    Store<AppState> store,
    LoadMyPreferenceAction action,
    NextDispatcher next,
  ) async {
    next(action);
    
    store.dispatch(SetUserPreferenceLoadingAction(true));
    
    try {
      final result = await UserPreferenceService.instance.getMyPreference();
      
      result.when(
        success: (preference) {
          store.dispatch(LoadMyPreferenceSuccessAction(preference));
        },
        failure: (exception) {
          store.dispatch(LoadMyPreferenceFailureAction(_getErrorMessage(exception)));
        },
      );
    } catch (e) {
      Logger.error('내 설정 조회 실패', error: e);
      store.dispatch(LoadMyPreferenceFailureAction('내 설정을 불러오는데 실패했습니다.'));
    } finally {
      store.dispatch(SetUserPreferenceLoadingAction(false));
    }
  }

  static void _updateMyPreference(
    Store<AppState> store,
    UpdateMyPreferenceAction action,
    NextDispatcher next,
  ) async {
    next(action);
    
    store.dispatch(SetUserPreferenceLoadingAction(true));
    
    try {
      final result = await UserPreferenceService.instance.updateMyPreference(action.preference);
      
      result.when(
        success: (preference) {
          store.dispatch(UpdateMyPreferenceSuccessAction(preference));
        },
        failure: (exception) {
          store.dispatch(UpdateMyPreferenceFailureAction(_getErrorMessage(exception)));
        },
      );
    } catch (e) {
      Logger.error('내 설정 수정 실패', error: e);
      store.dispatch(UpdateMyPreferenceFailureAction('설정 수정에 실패했습니다.'));
    } finally {
      store.dispatch(SetUserPreferenceLoadingAction(false));
    }
  }

  static void _loadUserPreference(
    Store<AppState> store,
    LoadUserPreferenceAction action,
    NextDispatcher next,
  ) async {
    next(action);
    
    store.dispatch(SetUserPreferenceLoadingAction(true));
    
    try {
      final result = await UserPreferenceService.instance.getUserPreference(action.userId);
      
      result.when(
        success: (preference) {
          store.dispatch(LoadUserPreferenceSuccessAction(preference));
        },
        failure: (exception) {
          store.dispatch(LoadUserPreferenceFailureAction(_getErrorMessage(exception)));
        },
      );
    } catch (e) {
      Logger.error('사용자 설정 조회 실패', error: e);
      store.dispatch(LoadUserPreferenceFailureAction('사용자 설정을 불러오는데 실패했습니다.'));
    } finally {
      store.dispatch(SetUserPreferenceLoadingAction(false));
    }
  }

  static void _createOrUpdatePreference(
    Store<AppState> store,
    CreateOrUpdatePreferenceAction action,
    NextDispatcher next,
  ) async {
    next(action);
    
    store.dispatch(SetUserPreferenceLoadingAction(true));
    
    try {
      final result = await UserPreferenceService.instance.createOrUpdatePreference(
        userId: action.userId,
        preference: action.preference,
      );
      
      result.when(
        success: (preference) {
          store.dispatch(CreateOrUpdatePreferenceSuccessAction(preference));
        },
        failure: (exception) {
          store.dispatch(CreateOrUpdatePreferenceFailureAction(_getErrorMessage(exception)));
        },
      );
    } catch (e) {
      Logger.error('설정 생성/수정 실패', error: e);
      store.dispatch(CreateOrUpdatePreferenceFailureAction('설정 생성/수정에 실패했습니다.'));
    } finally {
      store.dispatch(SetUserPreferenceLoadingAction(false));
    }
  }

  static void _deletePreference(
    Store<AppState> store,
    DeletePreferenceAction action,
    NextDispatcher next,
  ) async {
    next(action);
    
    store.dispatch(SetUserPreferenceLoadingAction(true));
    
    try {
      final result = await UserPreferenceService.instance.deletePreference(action.userId);
      
      result.when(
        success: (_) {
          store.dispatch(DeletePreferenceSuccessAction(action.userId));
        },
        failure: (exception) {
          store.dispatch(DeletePreferenceFailureAction(_getErrorMessage(exception)));
        },
      );
    } catch (e) {
      Logger.error('설정 삭제 실패', error: e);
      store.dispatch(DeletePreferenceFailureAction('설정 삭제에 실패했습니다.'));
    } finally {
      store.dispatch(SetUserPreferenceLoadingAction(false));
    }
  }

  static void _createDefaultPreference(
    Store<AppState> store,
    CreateDefaultPreferenceAction action,
    NextDispatcher next,
  ) async {
    next(action);
    
    store.dispatch(SetUserPreferenceLoadingAction(true));
    
    try {
      final result = await UserPreferenceService.instance.createDefaultPreference(action.userId);
      
      result.when(
        success: (preference) {
          store.dispatch(CreateDefaultPreferenceSuccessAction(preference));
        },
        failure: (exception) {
          store.dispatch(CreateDefaultPreferenceFailureAction(_getErrorMessage(exception)));
        },
      );
    } catch (e) {
      Logger.error('기본 설정 생성 실패', error: e);
      store.dispatch(CreateDefaultPreferenceFailureAction('기본 설정 생성에 실패했습니다.'));
    } finally {
      store.dispatch(SetUserPreferenceLoadingAction(false));
    }
  }

  static void _validatePreference(
    Store<AppState> store,
    ValidatePreferenceAction action,
    NextDispatcher next,
  ) async {
    next(action);
    
    try {
      // 로컬 유효성 검사
      final isValid = UserPreferenceService.instance.validatePreference(action.preference);
      store.dispatch(ValidatePreferenceSuccessAction(isValid));
    } catch (e) {
      Logger.error('로컬 설정 유효성 검사 실패', error: e);
      store.dispatch(ValidatePreferenceFailureAction('설정 유효성 검사에 실패했습니다.'));
    }
  }

  static void _validatePreferenceOnServer(
    Store<AppState> store,
    ValidatePreferenceOnServerAction action,
    NextDispatcher next,
  ) async {
    next(action);
    
    store.dispatch(SetUserPreferenceLoadingAction(true));
    
    try {
      final result = await UserPreferenceService.instance.validatePreferenceOnServer(action.preference);
      
      result.when(
        success: (isValid) {
          store.dispatch(ValidatePreferenceOnServerSuccessAction(isValid));
        },
        failure: (exception) {
          store.dispatch(ValidatePreferenceOnServerFailureAction(_getErrorMessage(exception)));
        },
      );
    } catch (e) {
      Logger.error('서버 설정 유효성 검사 실패', error: e);
      store.dispatch(ValidatePreferenceOnServerFailureAction('서버 설정 유효성 검사에 실패했습니다.'));
    } finally {
      store.dispatch(SetUserPreferenceLoadingAction(false));
    }
  }

  static void _loadFarmingTypes(
    Store<AppState> store,
    LoadFarmingTypesAction action,
    NextDispatcher next,
  ) async {
    next(action);
    
    try {
      final result = await UserPreferenceService.instance.getFarmingTypes();
      
      result.when(
        success: (farmingTypes) {
          store.dispatch(LoadFarmingTypesSuccessAction(farmingTypes));
        },
        failure: (exception) {
          store.dispatch(LoadFarmingTypesFailureAction(_getErrorMessage(exception)));
        },
      );
    } catch (e) {
      Logger.error('농업 유형 목록 조회 실패', error: e);
      store.dispatch(LoadFarmingTypesFailureAction('농업 유형 목록을 불러오는데 실패했습니다.'));
    }
  }

  static void _loadUsersByLocation(
    Store<AppState> store,
    LoadUsersByLocationAction action,
    NextDispatcher next,
  ) async {
    next(action);
    
    store.dispatch(SetUserPreferenceLoadingAction(true));
    
    try {
      final result = await UserPreferenceService.instance.getUsersByLocation(action.location);
      
      result.when(
        success: (users) {
          store.dispatch(LoadUsersByLocationSuccessAction(users));
        },
        failure: (exception) {
          store.dispatch(LoadUsersByLocationFailureAction(_getErrorMessage(exception)));
        },
      );
    } catch (e) {
      Logger.error('지역별 사용자 조회 실패', error: e);
      store.dispatch(LoadUsersByLocationFailureAction('지역별 사용자 조회에 실패했습니다.'));
    } finally {
      store.dispatch(SetUserPreferenceLoadingAction(false));
    }
  }

  static void _loadUsersByCrop(
    Store<AppState> store,
    LoadUsersByCropAction action,
    NextDispatcher next,
  ) async {
    next(action);
    
    store.dispatch(SetUserPreferenceLoadingAction(true));
    
    try {
      final result = await UserPreferenceService.instance.getUsersByCrop(action.cropName);
      
      result.when(
        success: (users) {
          store.dispatch(LoadUsersByCropSuccessAction(users));
        },
        failure: (exception) {
          store.dispatch(LoadUsersByCropFailureAction(_getErrorMessage(exception)));
        },
      );
    } catch (e) {
      Logger.error('작물별 사용자 조회 실패', error: e);
      store.dispatch(LoadUsersByCropFailureAction('작물별 사용자 조회에 실패했습니다.'));
    } finally {
      store.dispatch(SetUserPreferenceLoadingAction(false));
    }
  }

  static void _loadUsersByNotificationType(
    Store<AppState> store,
    LoadUsersByNotificationTypeAction action,
    NextDispatcher next,
  ) async {
    next(action);
    
    store.dispatch(SetUserPreferenceLoadingAction(true));
    
    try {
      final result = await UserPreferenceService.instance.getUsersByNotificationType(action.type);
      
      result.when(
        success: (users) {
          store.dispatch(LoadUsersByNotificationTypeSuccessAction(users));
        },
        failure: (exception) {
          store.dispatch(LoadUsersByNotificationTypeFailureAction(_getErrorMessage(exception)));
        },
      );
    } catch (e) {
      Logger.error('알림 유형별 사용자 조회 실패', error: e);
      store.dispatch(LoadUsersByNotificationTypeFailureAction('알림 유형별 사용자 조회에 실패했습니다.'));
    } finally {
      store.dispatch(SetUserPreferenceLoadingAction(false));
    }
  }

  static String _getErrorMessage(ApiException exception) {
    if (exception is UnauthorizedException) {
      return '로그인이 필요합니다.';
    } else if (exception is ForbiddenException) {
      return '권한이 없습니다.';
    } else if (exception is NotFoundException) {
      return '요청한 데이터를 찾을 수 없습니다.';
    } else if (exception is ValidationException) {
      return '입력값을 확인해주세요.';
    } else if (exception is NetworkException) {
      return '네트워크 연결을 확인해주세요.';
    } else {
      return '오류가 발생했습니다. 잠시 후 다시 시도해주세요.';
    }
  }
}