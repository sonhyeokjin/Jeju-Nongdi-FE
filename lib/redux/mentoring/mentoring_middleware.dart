import 'package:redux/redux.dart';
import 'package:jejunongdi/redux/app_state.dart';
import 'package:jejunongdi/redux/mentoring/mentoring_actions.dart';
import 'package:jejunongdi/core/services/mentoring_service.dart';
import 'package:jejunongdi/core/network/api_exceptions.dart';
import 'package:jejunongdi/core/utils/logger.dart';

class MentoringMiddleware {
  static List<Middleware<AppState>> createMiddleware() {
    return [
      TypedMiddleware<AppState, LoadMentoringsAction>(_loadMentorings),
      TypedMiddleware<AppState, LoadMyMentoringsAction>(_loadMyMentorings),
      TypedMiddleware<AppState, LoadMentoringDetailAction>(_loadMentoringDetail),
      TypedMiddleware<AppState, CreateMentoringAction>(_createMentoring),
      TypedMiddleware<AppState, UpdateMentoringAction>(_updateMentoring),
      TypedMiddleware<AppState, DeleteMentoringAction>(_deleteMentoring),
      TypedMiddleware<AppState, SearchMentoringsAction>(_searchMentorings),
    ];
  }

  static void _loadMentorings(
    Store<AppState> store,
    LoadMentoringsAction action,
    NextDispatcher next,
  ) async {
    next(action);
    
    store.dispatch(SetMentoringLoadingAction(true));
    
    try {
      final result = await MentoringService.instance.getMentorings(
        page: action.page,
        size: action.size,
      );
      
      result.when(
        success: (pageResponse) {
          store.dispatch(LoadMentoringsSuccessAction(
            pageResponse,
            refresh: action.refresh,
          ));
        },
        failure: (exception) {
          store.dispatch(LoadMentoringsFailureAction(_getErrorMessage(exception)));
        },
      );
    } catch (e) {
      Logger.error('멘토링 목록 로드 실패', error: e);
      store.dispatch(LoadMentoringsFailureAction('멘토링 목록을 불러오는데 실패했습니다.'));
    } finally {
      store.dispatch(SetMentoringLoadingAction(false));
    }
  }

  static void _loadMyMentorings(
    Store<AppState> store,
    LoadMyMentoringsAction action,
    NextDispatcher next,
  ) async {
    next(action);
    
    store.dispatch(SetMentoringLoadingAction(true));
    
    try {
      final result = await MentoringService.instance.getMyMentorings(
        page: action.page,
        size: action.size,
      );
      
      result.when(
        success: (pageResponse) {
          store.dispatch(LoadMyMentoringsSuccessAction(
            pageResponse,
            refresh: action.refresh,
          ));
        },
        failure: (exception) {
          store.dispatch(LoadMyMentoringsFailureAction(_getErrorMessage(exception)));
        },
      );
    } catch (e) {
      Logger.error('내 멘토링 목록 로드 실패', error: e);
      store.dispatch(LoadMyMentoringsFailureAction('내 멘토링 목록을 불러오는데 실패했습니다.'));
    } finally {
      store.dispatch(SetMentoringLoadingAction(false));
    }
  }

  static void _loadMentoringDetail(
    Store<AppState> store,
    LoadMentoringDetailAction action,
    NextDispatcher next,
  ) async {
    next(action);
    
    store.dispatch(SetMentoringLoadingAction(true));
    
    try {
      final result = await MentoringService.instance.getMentoringById(action.id);
      
      result.when(
        success: (mentoring) {
          store.dispatch(LoadMentoringDetailSuccessAction(mentoring));
        },
        failure: (exception) {
          store.dispatch(LoadMentoringDetailFailureAction(_getErrorMessage(exception)));
        },
      );
    } catch (e) {
      Logger.error('멘토링 상세 로드 실패', error: e);
      store.dispatch(LoadMentoringDetailFailureAction('멘토링 상세 정보를 불러오는데 실패했습니다.'));
    } finally {
      store.dispatch(SetMentoringLoadingAction(false));
    }
  }

  static void _createMentoring(
    Store<AppState> store,
    CreateMentoringAction action,
    NextDispatcher next,
  ) async {
    next(action);
    
    store.dispatch(SetMentoringCreateLoadingAction(true));
    
    try {
      final result = await MentoringService.instance.createMentoring(
        action.request.toJson(),
      );
      
      result.when(
        success: (mentoring) {
          store.dispatch(CreateMentoringSuccessAction(mentoring));
          // 목록 새로고침
          store.dispatch(LoadMentoringsAction(refresh: true));
          store.dispatch(LoadMyMentoringsAction(refresh: true));
        },
        failure: (exception) {
          store.dispatch(CreateMentoringFailureAction(_getErrorMessage(exception)));
        },
      );
    } catch (e) {
      Logger.error('멘토링 생성 실패', error: e);
      store.dispatch(CreateMentoringFailureAction('멘토링 생성에 실패했습니다.'));
    } finally {
      store.dispatch(SetMentoringCreateLoadingAction(false));
    }
  }

  static void _updateMentoring(
    Store<AppState> store,
    UpdateMentoringAction action,
    NextDispatcher next,
  ) async {
    next(action);
    
    store.dispatch(SetMentoringLoadingAction(true));
    
    try {
      final result = await MentoringService.instance.updateMentoring(
        action.id,
        action.request.toJson(),
      );
      
      result.when(
        success: (mentoring) {
          store.dispatch(UpdateMentoringSuccessAction(mentoring));
          // 목록 새로고침
          store.dispatch(LoadMentoringsAction(refresh: true));
          store.dispatch(LoadMyMentoringsAction(refresh: true));
        },
        failure: (exception) {
          store.dispatch(UpdateMentoringFailureAction(_getErrorMessage(exception)));
        },
      );
    } catch (e) {
      Logger.error('멘토링 수정 실패', error: e);
      store.dispatch(UpdateMentoringFailureAction('멘토링 수정에 실패했습니다.'));
    } finally {
      store.dispatch(SetMentoringLoadingAction(false));
    }
  }

  static void _deleteMentoring(
    Store<AppState> store,
    DeleteMentoringAction action,
    NextDispatcher next,
  ) async {
    next(action);
    
    store.dispatch(SetMentoringLoadingAction(true));
    
    try {
      final result = await MentoringService.instance.deleteMentoring(action.id);
      
      result.when(
        success: (_) {
          store.dispatch(DeleteMentoringSuccessAction(action.id));
          // 목록 새로고침
          store.dispatch(LoadMentoringsAction(refresh: true));
          store.dispatch(LoadMyMentoringsAction(refresh: true));
        },
        failure: (exception) {
          store.dispatch(DeleteMentoringFailureAction(_getErrorMessage(exception)));
        },
      );
    } catch (e) {
      Logger.error('멘토링 삭제 실패', error: e);
      store.dispatch(DeleteMentoringFailureAction('멘토링 삭제에 실패했습니다.'));
    } finally {
      store.dispatch(SetMentoringLoadingAction(false));
    }
  }

  static void _searchMentorings(
    Store<AppState> store,
    SearchMentoringsAction action,
    NextDispatcher next,
  ) async {
    next(action);
    
    store.dispatch(SetMentoringLoadingAction(true));
    
    try {
      final result = await MentoringService.instance.getFilteredMentorings(
        page: action.page,
        size: action.size,
        category: action.category,
        mentoringType: action.mentoringType,
        experienceLevel: action.experienceLevel,
        status: action.status,
        keyword: action.keyword,
      );
      
      result.when(
        success: (pageResponse) {
          store.dispatch(LoadMentoringsSuccessAction(
            pageResponse,
            refresh: action.refresh,
          ));
        },
        failure: (exception) {
          store.dispatch(LoadMentoringsFailureAction(_getErrorMessage(exception)));
        },
      );
    } catch (e) {
      Logger.error('멘토링 검색 실패', error: e);
      store.dispatch(LoadMentoringsFailureAction('멘토링 검색에 실패했습니다.'));
    } finally {
      store.dispatch(SetMentoringLoadingAction(false));
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
