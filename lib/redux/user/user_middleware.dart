import 'package:jejunongdi/core/models/auth_models.dart' as auth_models;
import 'package:jejunongdi/core/services/auth_service.dart';
import 'package:jejunongdi/redux/app_state.dart';
import 'package:jejunongdi/redux/user/user_actions.dart';
import 'package:redux/redux.dart';

List<Middleware<AppState>> createUserMiddleware() {
  final authService = AuthService.instance;

  return [
    TypedMiddleware<AppState, LoginRequestAction>(_createLoginMiddleware(authService)),
    TypedMiddleware<AppState, SignUpRequestAction>(_createSignUpMiddleware(authService)),
    TypedMiddleware<AppState, CheckNicknameRequestAction>(_createCheckNicknameMiddleware(authService)),
    TypedMiddleware<AppState, UpdateNicknameRequestAction>(_createUpdateNicknameMiddleware(authService)),
    TypedMiddleware<AppState, UpdateProfileImageRequestAction>(_createUpdateProfileImageMiddleware(authService)),
    TypedMiddleware<AppState, ChangePasswordRequestAction>(_createChangePasswordMiddleware(authService)),
    TypedMiddleware<AppState, GetCurrentUserRequestAction>(_createGetCurrentUserMiddleware(authService)),
  ];
}

void Function(Store<AppState> store, LoginRequestAction action, NextDispatcher next) _createLoginMiddleware(
  AuthService authService,
) {
  return (store, action, next) async {
    next(SetUserLoadingAction(true));

    try {
      final result = await authService.login(
        email: action.email,
        password: action.password,
      );

      result.onSuccess((authResponse) {
        store.dispatch(LoginSuccessAction(
          user: authResponse.user,
          accessToken: authResponse.accessToken,
          refreshToken: authResponse.refreshToken,
        ));
      });

      result.onFailure((error) {
        store.dispatch(SetUserErrorAction(error.message));
      });
    } catch (e) {
      store.dispatch(SetUserErrorAction(e.toString()));
    }

    next(SetUserLoadingAction(false));
  };
}

void Function(Store<AppState> store, SignUpRequestAction action, NextDispatcher next) _createSignUpMiddleware(
  AuthService authService,
) {
  return (store, action, next) async {
    next(SetUserLoadingAction(true));

    try {
      final signupRequest = auth_models.SignupRequest(
        email: action.email,
        password: action.password,
        name: action.name,
        nickname: action.nickname,
        phone: action.phone.replaceAll(RegExp(r'[^0-9]'), ''), // 하이픈 및 공백 제거
      );

      final result = await authService.register(signupRequest);

      result.onSuccess((authResponse) {
        store.dispatch(SignUpSuccessAction(
          user: authResponse.user,
          accessToken: authResponse.accessToken,
          refreshToken: authResponse.refreshToken,
        ));
      });

      result.onFailure((error) {
        store.dispatch(SignUpFailureAction(error.message));
      });
    } catch (e) {
      store.dispatch(SignUpFailureAction(e.toString()));
    }

    next(SetUserLoadingAction(false));
  };
}

// 닉네임 중복 확인 미들웨어
void Function(Store<AppState> store, CheckNicknameRequestAction action, NextDispatcher next) _createCheckNicknameMiddleware(
  AuthService authService,
) {
  return (store, action, next) async {
    // CheckNicknameRequestAction 자체가 리듀서에서 로딩 상태를 설정하므로 next()를 먼저 호출
    next(action);

    try {
      final result = await authService.checkNicknameAvailability(action.nickname);

      result.onSuccess((checkResult) {
        store.dispatch(CheckNicknameSuccessAction(
          available: checkResult.available,
          message: checkResult.message,
        ));
      });

      result.onFailure((error) {
        store.dispatch(SetUserErrorAction(error.message));
      });
    } catch (e) {
      store.dispatch(SetUserErrorAction(e.toString()));
    }
  };
}

// 닉네임 변경 미들웨어
void Function(Store<AppState> store, UpdateNicknameRequestAction action, NextDispatcher next) _createUpdateNicknameMiddleware(
  AuthService authService,
) {
  return (store, action, next) async {
    next(SetUserLoadingAction(true));

    try {
      final result = await authService.updateNickname(action.nickname);

      result.onSuccess((_) {
        store.dispatch(UpdateNicknameSuccessAction(action.nickname));
      });

      result.onFailure((error) {
        store.dispatch(SetUserErrorAction(error.message));
      });
    } catch (e) {
      store.dispatch(SetUserErrorAction(e.toString()));
    }

    next(SetUserLoadingAction(false));
  };
}

// 프로필 이미지 변경 미들웨어
void Function(Store<AppState> store, UpdateProfileImageRequestAction action, NextDispatcher next) _createUpdateProfileImageMiddleware(
  AuthService authService,
) {
  return (store, action, next) async {
    next(SetUserLoadingAction(true));

    try {
      final result = await authService.updateProfileImage(action.profileImageUrl);

      result.onSuccess((_) {
        store.dispatch(UpdateProfileImageSuccessAction());
      });

      result.onFailure((error) {
        store.dispatch(SetUserErrorAction(error.message));
      });
    } catch (e) {
      store.dispatch(SetUserErrorAction(e.toString()));
    }

    next(SetUserLoadingAction(false));
  };
}

// 비밀번호 변경 미들웨어
void Function(Store<AppState> store, ChangePasswordRequestAction action, NextDispatcher next) _createChangePasswordMiddleware(
  AuthService authService,
) {
  return (store, action, next) async {
    next(SetUserLoadingAction(true));

    try {
      final result = await authService.changePassword(
        currentPassword: action.currentPassword,
        newPassword: action.newPassword,
      );

      result.onSuccess((_) {
        // 비밀번호 변경 성공 시 특별한 액션은 없고, 로딩만 해제
        store.dispatch(ClearUserErrorAction());
      });

      result.onFailure((error) {
        store.dispatch(SetUserErrorAction(error.message));
      });
    } catch (e) {
      store.dispatch(SetUserErrorAction(e.toString()));
    }

    next(SetUserLoadingAction(false));
  };
}

// 현재 사용자 정보 조회 미들웨어
void Function(Store<AppState> store, GetCurrentUserRequestAction action, NextDispatcher next) _createGetCurrentUserMiddleware(
  AuthService authService,
) {
  return (store, action, next) async {
    next(SetUserLoadingAction(true));

    try {
      final result = await authService.getCurrentUser();

      result.onSuccess((user) {
        store.dispatch(UpdateUserAction(user));
      });

      result.onFailure((error) {
        store.dispatch(SetUserErrorAction(error.message));
      });
    } catch (e) {
      store.dispatch(SetUserErrorAction(e.toString()));
    }

    next(SetUserLoadingAction(false));
  };
}
