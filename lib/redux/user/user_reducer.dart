// User Reducer - 사용자 상태 관리
import 'package:redux/redux.dart';
import 'package:jejunongdi/redux/user/user_state.dart';
import 'package:jejunongdi/redux/user/user_actions.dart';

// User Reducer 함수
UserState userReducer(UserState state, dynamic action) {
  if (action is SetUserLoadingAction) {
    return state.copyWith(
      isLoading: action.isLoading,
      authStatus: action.isLoading ? AuthStatus.loading : state.authStatus,
    );
  }
  
  if (action is SetUserErrorAction) {
    return state.copyWith(
      authStatus: AuthStatus.error,
      errorMessage: action.errorMessage,
      isLoading: false,
    );
  }
  
  if (action is ClearUserErrorAction) {
    return state.copyWith(
      authStatus: state.user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated,
      errorMessage: null,
    );
  }
  
  if (action is LoginSuccessAction) {
    return state.copyWith(
      authStatus: AuthStatus.authenticated,
      user: action.user,
      accessToken: action.accessToken,
      refreshToken: action.refreshToken,
      errorMessage: null,
      isLoading: false,
    );
  }
  
  if (action is SignUpSuccessAction) {
    return state.copyWith(
      authStatus: AuthStatus.authenticated,
      user: action.user,
      accessToken: action.accessToken,
      refreshToken: action.refreshToken,
      errorMessage: null,
      isLoading: false,
    );
  }

  if (action is SignUpFailureAction) {
    return state.copyWith(
      authStatus: AuthStatus.error,
      errorMessage: action.error,
      isLoading: false,
    );
  }

  if (action is LogoutAction) {
    return const UserState.initial().copyWith(
      authStatus: AuthStatus.unauthenticated,
    );
  }
  
  if (action is UpdateUserAction) {
    return state.copyWith(
      user: action.user,
    );
  }
  
  if (action is UpdateTokenAction) {
    return state.copyWith(
      accessToken: action.accessToken,
      refreshToken: action.refreshToken,
    );
  }
  
  return state;
}

// 타입 안전성을 위한 Reducer 생성
final Reducer<UserState> userStateReducer = combineReducers<UserState>([
  TypedReducer<UserState, SetUserLoadingAction>(_setUserLoading),
  TypedReducer<UserState, SetUserErrorAction>(_setUserError),
  TypedReducer<UserState, ClearUserErrorAction>(_clearUserError),
  TypedReducer<UserState, LoginSuccessAction>(_loginSuccess),
  TypedReducer<UserState, LogoutAction>(_logout),
  TypedReducer<UserState, UpdateUserAction>(_updateUser),
  TypedReducer<UserState, UpdateTokenAction>(_updateToken),
]);

// 개별 리듀서 함수들 네이밍 확인 필요
UserState _setUserLoading(UserState state, SetUserLoadingAction action) {
  return state.copyWith(
    isLoading: action.isLoading,
    authStatus: action.isLoading ? AuthStatus.loading : state.authStatus,
  );
}

UserState _setUserError(UserState state, SetUserErrorAction action) {
  return state.copyWith(
    authStatus: AuthStatus.error,
    errorMessage: action.errorMessage,
    isLoading: false,
  );
}

UserState _clearUserError(UserState state, ClearUserErrorAction action) {
  return state.copyWith(
    authStatus: state.user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated,
    errorMessage: null,
  );
}

UserState _loginSuccess(UserState state, LoginSuccessAction action) {
  return state.copyWith(
    authStatus: AuthStatus.authenticated,
    user: action.user,
    accessToken: action.accessToken,
    refreshToken: action.refreshToken,
    errorMessage: null,
    isLoading: false,
  );
}

UserState _logout(UserState state, LogoutAction action) {
  return const UserState.initial().copyWith(
    authStatus: AuthStatus.unauthenticated,
  );
}

UserState _updateUser(UserState state, UpdateUserAction action) {
  return state.copyWith(
    user: action.user,
  );
}

UserState _updateToken(UserState state, UpdateTokenAction action) {
  return state.copyWith(
    accessToken: action.accessToken,
    refreshToken: action.refreshToken,
  );
}
