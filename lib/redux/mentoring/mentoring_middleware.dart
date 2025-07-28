import 'package:redux/redux.dart';
import 'package:jejunongdi/redux/app_state.dart';
import 'package:jejunongdi/redux/mentoring/mentoring_actions.dart';
import 'package:jejunongdi/core/services/mentoring_service.dart';
import 'package:jejunongdi/core/network/api_exceptions.dart';
import 'package:jejunongdi/core/utils/logger.dart';
import 'package:jejunongdi/core/models/mentoring_models.dart';

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
      TypedMiddleware<AppState, LoadMentoringsByTypeAction>(_loadMentoringsByType),
      TypedMiddleware<AppState, LoadMentoringsByCategoryAction>(_loadMentoringsByCategory),
      TypedMiddleware<AppState, SearchMentoringsAdvancedAction>(_searchMentoringsAdvanced),
      TypedMiddleware<AppState, LoadCategoriesAction>(_loadCategories),
      TypedMiddleware<AppState, LoadMentoringTypesAction>(_loadMentoringTypes),
      TypedMiddleware<AppState, LoadExperienceLevelsAction>(_loadExperienceLevels),
      TypedMiddleware<AppState, LoadMentoringStatusesAction>(_loadMentoringStatuses),
      TypedMiddleware<AppState, UpdateMentoringStatusAction>(_updateMentoringStatus),
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
      final result = await MentoringService.instance.getMyMentorings();
      
      result.when(
        success: (mentorings) {
          store.dispatch(LoadMyMentoringsSuccessAction(mentorings));
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
        success: (mentorings) {
          // List를 PageResponse로 변환
          final pageResponse = PageResponse<MentoringResponse>(
            content: mentorings,
            number: action.page,
            size: action.size,
            totalElements: mentorings.length,
            totalPages: mentorings.isEmpty ? 0 : 1,
            first: action.page == 0,
            last: true,
            numberOfElements: mentorings.length,
          );
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

  static void _loadMentoringsByType(
    Store<AppState> store,
    LoadMentoringsByTypeAction action,
    NextDispatcher next,
  ) async {
    next(action);
    
    store.dispatch(SetMentoringLoadingAction(true));
    
    try {
      final result = await MentoringService.instance.getMentoringsByType(action.mentoringType);
      
      result.when(
        success: (mentorings) {
          store.dispatch(LoadMentoringsByTypeSuccessAction(mentorings));
        },
        failure: (exception) {
          store.dispatch(LoadMentoringsByTypeFailureAction(_getErrorMessage(exception)));
        },
      );
    } catch (e) {
      Logger.error('멘토링 타입별 조회 실패', error: e);
      store.dispatch(LoadMentoringsByTypeFailureAction('멘토링 타입별 조회에 실패했습니다.'));
    } finally {
      store.dispatch(SetMentoringLoadingAction(false));
    }
  }

  static void _loadMentoringsByCategory(
    Store<AppState> store,
    LoadMentoringsByCategoryAction action,
    NextDispatcher next,
  ) async {
    next(action);
    
    store.dispatch(SetMentoringLoadingAction(true));
    
    try {
      final result = await MentoringService.instance.getMentoringsByCategory(action.category);
      
      result.when(
        success: (mentorings) {
          store.dispatch(LoadMentoringsByCategorySuccessAction(mentorings));
        },
        failure: (exception) {
          store.dispatch(LoadMentoringsByCategoryFailureAction(_getErrorMessage(exception)));
        },
      );
    } catch (e) {
      Logger.error('카테고리별 멘토링 조회 실패', error: e);
      store.dispatch(LoadMentoringsByCategoryFailureAction('카테고리별 멘토링 조회에 실패했습니다.'));
    } finally {
      store.dispatch(SetMentoringLoadingAction(false));
    }
  }

  static void _searchMentoringsAdvanced(
    Store<AppState> store,
    SearchMentoringsAdvancedAction action,
    NextDispatcher next,
  ) async {
    next(action);
    
    store.dispatch(SetMentoringLoadingAction(true));
    
    try {
      final result = await MentoringService.instance.searchMentorings(
        mentoringType: action.mentoringType,
        category: action.category,
        experienceLevel: action.experienceLevel,
        location: action.location,
        keyword: action.keyword,
      );
      
      result.when(
        success: (mentorings) {
          store.dispatch(SearchMentoringsAdvancedSuccessAction(mentorings));
        },
        failure: (exception) {
          store.dispatch(SearchMentoringsAdvancedFailureAction(_getErrorMessage(exception)));
        },
      );
    } catch (e) {
      Logger.error('고급 멘토링 검색 실패', error: e);
      store.dispatch(SearchMentoringsAdvancedFailureAction('멘토링 검색에 실패했습니다.'));
    } finally {
      store.dispatch(SetMentoringLoadingAction(false));
    }
  }

  static void _loadCategories(
    Store<AppState> store,
    LoadCategoriesAction action,
    NextDispatcher next,
  ) async {
    next(action);
    
    try {
      final result = await MentoringService.instance.getCategories();
      
      result.when(
        success: (categories) {
          store.dispatch(LoadCategoriesSuccessAction(categories));
        },
        failure: (exception) {
          store.dispatch(LoadCategoriesFailureAction(_getErrorMessage(exception)));
        },
      );
    } catch (e) {
      Logger.error('카테고리 목록 로드 실패', error: e);
      store.dispatch(LoadCategoriesFailureAction('카테고리 목록을 불러오는데 실패했습니다.'));
    }
  }

  static void _loadMentoringTypes(
    Store<AppState> store,
    LoadMentoringTypesAction action,
    NextDispatcher next,
  ) async {
    next(action);
    
    try {
      final result = await MentoringService.instance.getMentoringTypes();
      
      result.when(
        success: (types) {
          store.dispatch(LoadMentoringTypesSuccessAction(types));
        },
        failure: (exception) {
          store.dispatch(LoadMentoringTypesFailureAction(_getErrorMessage(exception)));
        },
      );
    } catch (e) {
      Logger.error('멘토링 타입 목록 로드 실패', error: e);
      store.dispatch(LoadMentoringTypesFailureAction('멘토링 타입 목록을 불러오는데 실패했습니다.'));
    }
  }

  static void _loadExperienceLevels(
    Store<AppState> store,
    LoadExperienceLevelsAction action,
    NextDispatcher next,
  ) async {
    next(action);
    
    try {
      final result = await MentoringService.instance.getExperienceLevels();
      
      result.when(
        success: (levels) {
          store.dispatch(LoadExperienceLevelsSuccessAction(levels));
        },
        failure: (exception) {
          store.dispatch(LoadExperienceLevelsFailureAction(_getErrorMessage(exception)));
        },
      );
    } catch (e) {
      Logger.error('경험 수준 목록 로드 실패', error: e);
      store.dispatch(LoadExperienceLevelsFailureAction('경험 수준 목록을 불러오는데 실패했습니다.'));
    }
  }

  static void _loadMentoringStatuses(
    Store<AppState> store,
    LoadMentoringStatusesAction action,
    NextDispatcher next,
  ) async {
    next(action);
    
    try {
      final result = await MentoringService.instance.getMentoringStatuses();
      
      result.when(
        success: (statuses) {
          store.dispatch(LoadMentoringStatusesSuccessAction(statuses));
        },
        failure: (exception) {
          store.dispatch(LoadMentoringStatusesFailureAction(_getErrorMessage(exception)));
        },
      );
    } catch (e) {
      Logger.error('멘토링 상태 목록 로드 실패', error: e);
      store.dispatch(LoadMentoringStatusesFailureAction('멘토링 상태 목록을 불러오는데 실패했습니다.'));
    }
  }

  static void _updateMentoringStatus(
    Store<AppState> store,
    UpdateMentoringStatusAction action,
    NextDispatcher next,
  ) async {
    next(action);
    
    store.dispatch(SetMentoringLoadingAction(true));
    
    try {
      final result = await MentoringService.instance.updateMentoringStatus(
        id: action.id,
        status: action.status,
      );
      
      result.when(
        success: (mentoring) {
          store.dispatch(UpdateMentoringStatusSuccessAction(mentoring));
          // 목록 새로고침
          store.dispatch(LoadMentoringsAction(refresh: true));
          store.dispatch(LoadMyMentoringsAction(refresh: true));
        },
        failure: (exception) {
          store.dispatch(UpdateMentoringStatusFailureAction(_getErrorMessage(exception)));
        },
      );
    } catch (e) {
      Logger.error('멘토링 상태 변경 실패', error: e);
      store.dispatch(UpdateMentoringStatusFailureAction('멘토링 상태 변경에 실패했습니다.'));
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
