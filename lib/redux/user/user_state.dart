// 사용자 상태 모델
import 'package:jejunongdi/redux/user/user_model.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class UserState {
  final AuthStatus authStatus;
  final User? user;
  final String? accessToken;
  final String? refreshToken;
  final String? errorMessage;
  final bool isLoading;
  final bool? isNicknameAvailable;
  final String? nicknameCheckMessage;

  const UserState({
    required this.authStatus,
    this.user,
    this.accessToken,
    this.refreshToken,
    this.errorMessage,
    required this.isLoading,
    this.isNicknameAvailable,
    this.nicknameCheckMessage,
  });

  // 초기 상태
  const UserState.initial()
      : authStatus = AuthStatus.initial,
        user = null,
        accessToken = null,
        refreshToken = null,
        errorMessage = null,
        isLoading = false,
        isNicknameAvailable = null,
        nicknameCheckMessage = null;

  // copyWith 메서드
  UserState copyWith({
    AuthStatus? authStatus,
    User? user,
    String? accessToken,
    String? refreshToken,
    String? errorMessage,
    bool? isLoading,
    bool? isNicknameAvailable,
    String? nicknameCheckMessage,
  }) {
    return UserState(
      authStatus: authStatus ?? this.authStatus,
      user: user ?? this.user,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
      isNicknameAvailable: isNicknameAvailable ?? this.isNicknameAvailable,
      nicknameCheckMessage: nicknameCheckMessage ?? this.nicknameCheckMessage,
    );
  }

  // 편의 메서드들
  bool get isAuthenticated => authStatus == AuthStatus.authenticated && user != null && accessToken != null;
  bool get isUnauthenticated => authStatus == AuthStatus.unauthenticated;
  bool get hasError => authStatus == AuthStatus.error && errorMessage != null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserState &&
          runtimeType == other.runtimeType &&
          authStatus == other.authStatus &&
          user == other.user &&
          accessToken == other.accessToken &&
          refreshToken == other.refreshToken &&
          errorMessage == other.errorMessage &&
          isLoading == other.isLoading &&
          isNicknameAvailable == other.isNicknameAvailable &&
          nicknameCheckMessage == other.nicknameCheckMessage;

  @override
  int get hashCode =>
      authStatus.hashCode ^
      user.hashCode ^
      accessToken.hashCode ^
      refreshToken.hashCode ^
      errorMessage.hashCode ^
      isLoading.hashCode ^
      isNicknameAvailable.hashCode ^
      nicknameCheckMessage.hashCode;

  @override
  String toString() {
    return 'UserState{'
        'authStatus: $authStatus, '
        'user: ${user?.name}, '
        'hasAccessToken: ${accessToken != null}, '
        'hasRefreshToken: ${refreshToken != null}, '
        'errorMessage: $errorMessage, '
        'isLoading: $isLoading'
        '}';
  }
}
