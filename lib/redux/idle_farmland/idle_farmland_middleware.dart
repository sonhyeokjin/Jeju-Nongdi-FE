// lib/redux/idle_farmland/idle_farmland_middleware.dart
import 'package:jejunongdi/core/services/idle_farmland_service.dart';
import 'package:jejunongdi/redux/app_state.dart';
import 'package:jejunongdi/redux/idle_farmland/idle_farmland_actions.dart';
import 'package:redux/redux.dart';

List<Middleware<AppState>> createIdleFarmlandMiddleware() {
  return [
    TypedMiddleware<AppState, LoadIdleFarmlandsAction>(_loadList),
    TypedMiddleware<AppState, LoadIdleFarmlandDetailAction>(_loadDetail),
    TypedMiddleware<AppState, UpdateIdleFarmlandAction>(_update),
    TypedMiddleware<AppState, DeleteIdleFarmlandAction>(_delete),
    TypedMiddleware<AppState, CreateIdleFarmlandAction>(_create), // [추가]
  ];
}

void _loadList(Store<AppState> store, LoadIdleFarmlandsAction action, NextDispatcher next) async {
  next(action);
  final currentState = store.state.idleFarmlandState;
  if (!action.refresh && (currentState.isLoading || !currentState.hasMore)) return;
  final pageToLoad = action.refresh ? 0 : currentState.currentPage + 1;
  store.dispatch(SetIdleFarmlandLoadingAction(true));
  final result = await IdleFarmlandService.instance.getIdleFarmlands(page: pageToLoad);
  result.onSuccess((pageResponse) {
    store.dispatch(LoadIdleFarmlandsSuccessAction(
      farmlands: pageResponse.content,
      page: pageResponse.number,
      hasMore: !pageResponse.last,
    ));
  }).onFailure((error) {
    store.dispatch(SetIdleFarmlandErrorAction(error.message));
  });
}

void _create(Store<AppState> store, CreateIdleFarmlandAction action, NextDispatcher next) async {
  next(action);
  store.dispatch(SetIdleFarmlandLoadingAction(true));
  final result = await IdleFarmlandService.instance.createIdleFarmland(action.request);
  result.onSuccess((farmland) { // farmland가 null일 수 있음
    // [수정] 성공 시, 특정 객체를 추가하는 대신 전체 목록을 새로고침합니다.
    // 이렇게 하면 방금 등록한 농지가 목록에 자동으로 나타납니다.
    store.dispatch(LoadIdleFarmlandsAction(refresh: true));

    // 로딩 상태를 여기서 바로 해제하고, 에러가 있다면 지워줍니다.
    store.dispatch(SetIdleFarmlandLoadingAction(false));

  }).onFailure((error) {
    store.dispatch(SetIdleFarmlandErrorAction(error.message));
  });
}

void _loadDetail(Store<AppState> store, LoadIdleFarmlandDetailAction action, NextDispatcher next) async {
  next(action);
  store.dispatch(SetIdleFarmlandLoadingAction(true));
  final result = await IdleFarmlandService.instance.getIdleFarmlandById(action.farmlandId);
  result.onSuccess((farmland) {
    store.dispatch(LoadIdleFarmlandDetailSuccessAction(farmland));
  }).onFailure((error) {
    store.dispatch(SetIdleFarmlandErrorAction(error.message));
  });
}

void _update(Store<AppState> store, UpdateIdleFarmlandAction action, NextDispatcher next) async {
  next(action);
  store.dispatch(SetIdleFarmlandLoadingAction(true));
  final result = await IdleFarmlandService.instance.updateIdleFarmland(
    id: action.farmlandId,
    request: action.request,
  );
  result.onSuccess((farmland) {
    store.dispatch(UpdateIdleFarmlandSuccessAction(farmland));
  }).onFailure((error) {
    store.dispatch(SetIdleFarmlandErrorAction(error.message));
  });
}

void _delete(Store<AppState> store, DeleteIdleFarmlandAction action, NextDispatcher next) async {
  next(action);
  store.dispatch(SetIdleFarmlandLoadingAction(true));
  final result = await IdleFarmlandService.instance.deleteIdleFarmland(action.farmlandId);
  result.onSuccess((_) {
    store.dispatch(DeleteIdleFarmlandSuccessAction(action.farmlandId));
  }).onFailure((error) {
    store.dispatch(SetIdleFarmlandErrorAction(error.message));
  });
}