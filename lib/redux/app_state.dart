// Redux App State - 전역 앱 상태 정의
import 'package:jejunongdi/redux/user/user_state.dart';

class AppState {
  final UserState userState;

  const AppState({
    required this.userState,
  });

  // 초기 상태 정의
  factory AppState.initial() {
    return const AppState(
      userState: UserState.initial(),
    );
  }

  // copyWith 메서드 - 상태 복사 및 수정
  AppState copyWith({
    UserState? userState,
  }) {
    return AppState(
      userState: userState ?? this.userState,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppState &&
          runtimeType == other.runtimeType &&
          userState == other.userState;

  @override
  int get hashCode => userState.hashCode;

  @override
  String toString() => 'AppState{userState: $userState}';
}
