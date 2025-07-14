// Redux App State - 전역 앱 상태 정의
import 'package:jejunongdi/redux/user/user_state.dart';
import 'package:jejunongdi/redux/mentoring/mentoring_state.dart';

class AppState {
  final UserState userState;
  final MentoringState mentoringState;

  const AppState({
    required this.userState,
    required this.mentoringState,
  });

  // 초기 상태 정의
  factory AppState.initial() {
    return AppState(
      userState: UserState.initial(),
      mentoringState: MentoringState.initial(),
    );
  }

  // copyWith 메서드 - 상태 복사 및 수정
  AppState copyWith({
    UserState? userState,
    MentoringState? mentoringState,
  }) {
    return AppState(
      userState: userState ?? this.userState,
      mentoringState: mentoringState ?? this.mentoringState,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppState &&
          runtimeType == other.runtimeType &&
          userState == other.userState &&
          mentoringState == other.mentoringState;

  @override
  int get hashCode => userState.hashCode ^ mentoringState.hashCode;

  @override
  String toString() => 'AppState{userState: $userState, mentoringState: $mentoringState}';
}
