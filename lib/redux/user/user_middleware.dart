import 'package:jejunongdi/core/models/auth_models.dart' as auth_models;
import 'package:jejunongdi/core/services/auth_service.dart';
import 'package:jejunongdi/redux/app_state.dart';
import 'package:jejunongdi/redux/user/user_actions.dart';
import 'package:redux/redux.dart';

List<Middleware<AppState>> createUserMiddleware() {
  final authService = AuthService.instance;

  return [
    TypedMiddleware<AppState, SignUpRequestAction>(_createSignUpMiddleware(authService)),
  ];
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
        phone: action.phone,
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
