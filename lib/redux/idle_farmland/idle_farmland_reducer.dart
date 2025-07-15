import 'package:jejunongdi/redux/idle_farmland/idle_farmland_actions.dart';
import 'package:jejunongdi/redux/idle_farmland/idle_farmland_state.dart';
import 'package:redux/redux.dart';

final idleFarmlandReducer = combineReducers<IdleFarmlandState>([
  TypedReducer<IdleFarmlandState, SetIdleFarmlandLoadingAction>(_setLoading),
  TypedReducer<IdleFarmlandState, SetIdleFarmlandErrorAction>(_setError),
  TypedReducer<IdleFarmlandState, LoadIdleFarmlandDetailSuccessAction>(_loadDetailSuccess),
  TypedReducer<IdleFarmlandState, UpdateIdleFarmlandSuccessAction>(_updateSuccess),
  TypedReducer<IdleFarmlandState, DeleteIdleFarmlandSuccessAction>(_deleteSuccess),
]);

IdleFarmlandState _setLoading(IdleFarmlandState state, SetIdleFarmlandLoadingAction action) {
  return state.copyWith(isLoading: action.isLoading, clearError: true);
}

IdleFarmlandState _setError(IdleFarmlandState state, SetIdleFarmlandErrorAction action) {
  return state.copyWith(isLoading: false, error: action.error);
}

IdleFarmlandState _loadDetailSuccess(IdleFarmlandState state, LoadIdleFarmlandDetailSuccessAction action) {
  return state.copyWith(isLoading: false, selectedFarmland: action.farmland);
}

IdleFarmlandState _updateSuccess(IdleFarmlandState state, UpdateIdleFarmlandSuccessAction action) {
  // 상세 정보가 현재 보고 있는 농지 정보와 같을 경우에만 상태를 업데이트
  if (state.selectedFarmland?.id == action.updatedFarmland.id) {
    return state.copyWith(isLoading: false, selectedFarmland: action.updatedFarmland);
  }
  return state.copyWith(isLoading: false);
}

IdleFarmlandState _deleteSuccess(IdleFarmlandState state, DeleteIdleFarmlandSuccessAction action) {
  return state.copyWith(isLoading: false, clearFarmland: true);
}