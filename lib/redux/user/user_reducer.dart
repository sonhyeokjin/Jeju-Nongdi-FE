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
      errorMessage: null, // 로딩 시작할 때 에러 메시지 클리어
    );
  }
  
  if (action is CheckNicknameRequestAction) {
    // 닉네임 중복 확인 시작 시 기존 결과 초기화
    return state.copyWith(
      isLoading: true,
      isNicknameAvailable: null,
      nicknameCheckMessage: null,
      errorMessage: null,
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
  
  if (action is CheckNicknameSuccessAction) {
    return state.copyWith(
      isNicknameAvailable: action.available,
      nicknameCheckMessage: action.message,
      isLoading: false,
    );
  }
  
  if (action is UpdateNicknameSuccessAction) {
    // 닉네임 변경 성공 후 사용자 정보 업데이트
    if (state.user != null) {
      final updatedUser = state.user!.copyWith(nickname: action.nickname);
      return state.copyWith(
        user: updatedUser,
        isLoading: false,
      );
    }
    return state.copyWith(isLoading: false);
  }
  
  return state;
}

// 메인 userStateReducer를 사용
final Reducer<UserState> userStateReducer = userReducer;

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
