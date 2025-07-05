//User Actions - 사용자 관련 액션들
import 'package:jejunongdi/redux/user/user_model.dart';

//추상 클래스 - 모든 사용자 액션의 부모
abstract class UserAction {}

//로딩 상태 액션
class SetUserLoadingAction extends UserAction {
  final bool isLoading;
  
  SetUserLoadingAction(this.isLoading);
  
  @override
  String toString() => 'SetUserLoadingAction{isLoading: $isLoading}';
}

// 에러액션
class SetUserErrorAction extends UserAction {
  final String errorMessage;
  
  SetUserErrorAction(this.errorMessage);
  
  @override
  String toString() => 'SetUserErrorAction{errorMessage: $errorMessage}';
}

// 에러클리어 액션
class ClearUserErrorAction extends UserAction {
  @override
  String toString() => 'ClearUserErrorAction{}';
}

// 로그인 요청 액션 (API 호출용 나중에 백엔드 구현 시 사용)
class LoginRequestAction extends UserAction {
  final String email;
  final String password;
  
  LoginRequestAction({
    required this.email,
    required this.password,
  });
  
  @override
  String toString() => 'LoginRequestAction{email: $email}';
}

// 로그인 성공 액션
class LoginSuccessAction extends UserAction {
  final User user;
  final String accessToken;
  final String? refreshToken;
  
  LoginSuccessAction({
    required this.user,
    required this.accessToken,
    this.refreshToken,
  });
  
  @override
  String toString() => 'LoginSuccessAction{user: ${user.name}, hasToken: ${accessToken.isNotEmpty}}';
}

// 로그아웃 요청 액션 (API 호출용)
class LogoutRequestAction extends UserAction {
  @override
  String toString() => 'LogoutRequestAction{}';
}

// 로그아웃 액션 (즉시 처리)
class LogoutAction extends UserAction {
  @override
  String toString() => 'LogoutAction{}';
}

// 사용자 정보 업데이트 요청 액션 (API 호출용)
class UpdateUserRequestAction extends UserAction {
  final User user;
  
  UpdateUserRequestAction(this.user);
  
  @override
  String toString() => 'UpdateUserRequestAction{user: ${user.name}}';
}

// 사용자 정보 업데이트 액션 (즉시 처리)
class UpdateUserAction extends UserAction {
  final User user;
  
  UpdateUserAction(this.user);
  
  @override
  String toString() => 'UpdateUserAction{user: ${user.name}}';
}

// 토큰 업데이트 액션
class UpdateTokenAction extends UserAction {
  final String accessToken;
  final String? refreshToken;
  
  UpdateTokenAction({
    required this.accessToken,
    this.refreshToken,
  });
  
  @override
  String toString() => 'UpdateTokenAction{hasAccessToken: ${accessToken.isNotEmpty}}';
}

// 토큰 갱신 요청 액션 (API 호출용)
class RefreshTokenRequestAction extends UserAction {
  final String refreshToken;
  
  RefreshTokenRequestAction(this.refreshToken);
  
  @override
  String toString() => 'RefreshTokenRequestAction{}';
}

// 자동 로그인 시도 액션 (앱 시작 시)
class TryAutoLoginAction extends UserAction {
  @override
  String toString() => 'TryAutoLoginAction{}';
}

// 비밀번호 변경 요청 액션
class ChangePasswordRequestAction extends UserAction {
  final String currentPassword;
  final String newPassword;
  
  ChangePasswordRequestAction({
    required this.currentPassword,
    required this.newPassword,
  });
  
  @override
  String toString() => 'ChangePasswordRequestAction{}';
}

// 회원가입 요청 액션
class SignUpRequestAction extends UserAction {
  final String email;
  final String password;
  final String name;
  final String? phoneNumber;
  final UserRole role;
  
  SignUpRequestAction({
    required this.email,
    required this.password,
    required this.name,
    this.phoneNumber,
    required this.role,
  });
  
  @override
  String toString() => 'SignUpRequestAction{email: $email, name: $name, role: $role}';
}
