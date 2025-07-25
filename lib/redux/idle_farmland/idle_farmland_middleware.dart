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
    TypedMiddleware<AppState, CreateIdleFarmlandAction>(_create),
    TypedMiddleware<AppState, UpdateIdleFarmlandStatusAction>(_updateStatus),
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
  result.onSuccess((farmland) {
    // 성공 시 전체 목록을 새로고침하여 새로 생성된 농지를 표시
    store.dispatch(LoadIdleFarmlandsAction(refresh: true));
    store.dispatch(SetIdleFarmlandLoadingAction(false));
    store.dispatch(ClearIdleFarmlandErrorAction()); // 에러 상태 정리
  }).onFailure((error) {
    store.dispatch(SetIdleFarmlandLoadingAction(false));
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
  store.dispatch(SetIdleFarmlandDeletingAction(true));
  final result = await IdleFarmlandService.instance.deleteIdleFarmland(action.farmlandId);
  result.onSuccess((_) {
    store.dispatch(DeleteIdleFarmlandSuccessAction(action.farmlandId));
  }).onFailure((error) {
    store.dispatch(SetIdleFarmlandDeletingAction(false));
    store.dispatch(SetIdleFarmlandErrorAction(error.message));
  });
}

void _updateStatus(Store<AppState> store, UpdateIdleFarmlandStatusAction action, NextDispatcher next) async {
  next(action);
  store.dispatch(SetIdleFarmlandLoadingAction(true));
  final result = await IdleFarmlandService.instance.updateIdleFarmlandStatus(
    id: action.farmlandId,
    status: action.status,
  );
  result.onSuccess((farmland) {
    store.dispatch(UpdateIdleFarmlandStatusSuccessAction(farmland));
    store.dispatch(SetIdleFarmlandLoadingAction(false));
  }).onFailure((error) {
    store.dispatch(SetIdleFarmlandLoadingAction(false));
    store.dispatch(SetIdleFarmlandErrorAction(error.message));
  });
}