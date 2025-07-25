import 'package:jejunongdi/redux/idle_farmland/idle_farmland_actions.dart';
import 'package:jejunongdi/redux/idle_farmland/idle_farmland_state.dart';
import 'package:redux/redux.dart';

final idleFarmlandReducer = combineReducers<IdleFarmlandState>([
  TypedReducer<IdleFarmlandState, SetIdleFarmlandLoadingAction>(_setLoading),
  TypedReducer<IdleFarmlandState, SetIdleFarmlandDeletingAction>(_setDeleting),
  TypedReducer<IdleFarmlandState, SetIdleFarmlandErrorAction>(_setError),
  TypedReducer<IdleFarmlandState, ClearIdleFarmlandErrorAction>(_clearError),
  TypedReducer<IdleFarmlandState, LoadIdleFarmlandDetailSuccessAction>(_loadDetailSuccess),
  TypedReducer<IdleFarmlandState, UpdateIdleFarmlandSuccessAction>(_updateSuccess),
  TypedReducer<IdleFarmlandState, DeleteIdleFarmlandSuccessAction>(_deleteSuccess),
  TypedReducer<IdleFarmlandState, LoadIdleFarmlandsAction>(_loadList),
  TypedReducer<IdleFarmlandState, LoadIdleFarmlandsSuccessAction>(_loadListSuccess),
  TypedReducer<IdleFarmlandState, UpdateIdleFarmlandStatusSuccessAction>(_updateStatusSuccess),
]);

// 목록 로딩 시작 시 상태 변경
IdleFarmlandState _loadList(IdleFarmlandState state, LoadIdleFarmlandsAction action) {
  return state.copyWith(
    isLoading: true,
    farmlands: action.refresh ? [] : state.farmlands,
  );
}

// 목록 로딩 성공 시 상태 변경
IdleFarmlandState _loadListSuccess(IdleFarmlandState state, LoadIdleFarmlandsSuccessAction action) {
  return state.copyWith(
    isLoading: false,
    farmlands: [...state.farmlands, ...action.farmlands],
    currentPage: action.page,
    hasMore: action.hasMore,
  );
}


IdleFarmlandState _setLoading(IdleFarmlandState state, SetIdleFarmlandLoadingAction action) {
  return state.copyWith(isLoading: action.isLoading, clearError: true);
}

IdleFarmlandState _setDeleting(IdleFarmlandState state, SetIdleFarmlandDeletingAction action) {
  return state.copyWith(isDeleting: action.isDeleting);
}

IdleFarmlandState _setError(IdleFarmlandState state, SetIdleFarmlandErrorAction action) {
  return state.copyWith(isLoading: false, error: action.error);
}

IdleFarmlandState _clearError(IdleFarmlandState state, ClearIdleFarmlandErrorAction action) {
  return state.copyWith(clearError: true);
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
  return state.copyWith(isDeleting: false, clearFarmland: true);
}

IdleFarmlandState _updateStatusSuccess(IdleFarmlandState state, UpdateIdleFarmlandStatusSuccessAction action) {
  // 상세 정보가 현재 보고 있는 농지와 같을 경우 업데이트된 정보로 교체
  if (state.selectedFarmland?.id == action.farmland.id) {
    return state.copyWith(isLoading: false, selectedFarmland: action.farmland);
  }
  
  // 목록에서 해당 농지의 상태를 업데이트
  final updatedFarmlands = state.farmlands.map((farmland) {
    if (farmland.id == action.farmland.id) {
      return action.farmland;
    }
    return farmland;
  }).toList();
  
  return state.copyWith(isLoading: false, farmlands: updatedFarmlands);
}