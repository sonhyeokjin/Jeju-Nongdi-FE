// lib/redux/app_state.dart

import 'package:jejunongdi/redux/user/user_state.dart';
import 'package:jejunongdi/redux/mentoring/mentoring_state.dart';
import 'package:jejunongdi/redux/chat/chat_state.dart';

import 'package:jejunongdi/redux/idle_farmland/idle_farmland_state.dart';
import 'package:jejunongdi/redux/job_posting/job_posting_state.dart';

class AppState {
  final UserState userState;
  final MentoringState mentoringState;
  final ChatState chatState;
  final IdleFarmlandState idleFarmlandState;
  final JobPostingState jobPostingState;


  const AppState({
    required this.userState,
    required this.mentoringState,
    required this.chatState,
    required this.idleFarmlandState,
    required this.jobPostingState,
  });

  factory AppState.initial() {
    return AppState(
      userState: UserState.initial(),
      mentoringState: MentoringState.initial(),
      chatState: ChatState.initial(),
      idleFarmlandState: IdleFarmlandState.initial(),
      jobPostingState: JobPostingState.initial(),
    );
  }

  // [수정] copyWith 메서드에 idleFarmlandState 추가
  AppState copyWith({
    UserState? userState,
    MentoringState? mentoringState,
    ChatState? chatState,
    IdleFarmlandState? idleFarmlandState,
    JobPostingState? jobPostingState,
  }) {
    return AppState(
      userState: userState ?? this.userState,
      mentoringState: mentoringState ?? this.mentoringState,
      chatState: chatState ?? this.chatState,
      idleFarmlandState: idleFarmlandState ?? this.idleFarmlandState,
      jobPostingState: jobPostingState ?? this.jobPostingState,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is AppState &&
              runtimeType == other.runtimeType &&
              userState == other.userState &&
              mentoringState == other.mentoringState &&
              chatState == other.chatState &&
              idleFarmlandState == other.idleFarmlandState; // [수정] 추가

  @override
  int get hashCode =>
      userState.hashCode ^
      mentoringState.hashCode ^
      chatState.hashCode ^
      idleFarmlandState.hashCode; // [수정] 추가

  @override
  String toString() =>
      'AppState{userState: $userState, mentoringState: $mentoringState, chatState: $chatState, idleFarmlandState: $idleFarmlandState}'; // [수정] 추가
}