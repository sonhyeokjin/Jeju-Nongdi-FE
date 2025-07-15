// lib/redux/idle_farmland/idle_farmland_middleware.dart

import 'package:jejunongdi/core/services/idle_farmland_service.dart';
import 'package:jejunongdi/redux/app_state.dart';
import 'package:jejunongdi/redux/idle_farmland/idle_farmland_actions.dart';
import 'package:redux/redux.dart';

List<Middleware<AppState>> createIdleFarmlandMiddleware() {
  // [수정] 함수 호출이 아닌 함수 참조를 전달하도록 변경
  return [
    TypedMiddleware<AppState, LoadIdleFarmlandDetailAction>(_loadDetail),
    TypedMiddleware<AppState, UpdateIdleFarmlandAction>(_update),
    TypedMiddleware<AppState, DeleteIdleFarmlandAction>(_delete),
  ];
}

// [수정] 미들웨어 함수 구조 변경
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

// [수정] 미들웨어 함수 구조 변경
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

// [수정] 미들웨어 함수 구조 변경
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