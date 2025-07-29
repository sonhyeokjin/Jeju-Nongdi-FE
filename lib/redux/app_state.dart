// lib/redux/app_state.dart

import 'package:jejunongdi/redux/user/user_state.dart';
import 'package:jejunongdi/redux/mentoring/mentoring_state.dart';
import 'package:jejunongdi/redux/chat/chat_state.dart';
import 'package:jejunongdi/redux/user_preference/user_preference_state.dart';
import 'package:jejunongdi/redux/idle_farmland/idle_farmland_state.dart';
import 'package:jejunongdi/redux/job_posting/job_posting_state.dart';

class AppState {
  final UserState userState;
  final MentoringState mentoringState;
  final ChatState chatState;
  final UserPreferenceState userPreferenceState;
  final IdleFarmlandState idleFarmlandState;
  final JobPostingState jobPostingState;

  const AppState({
    required this.userState,
    required this.mentoringState,
    required this.chatState,
    required this.userPreferenceState,
    required this.idleFarmlandState,
    required this.jobPostingState,
  });

  factory AppState.initial() {
    return AppState(
      userState: UserState.initial(),
      mentoringState: MentoringState.initial(),
      chatState: ChatState.initial(),
      userPreferenceState: UserPreferenceState.initial(),
      idleFarmlandState: IdleFarmlandState.initial(),
      jobPostingState: JobPostingState.initial(),
    );
  }

  AppState copyWith({
    UserState? userState,
    MentoringState? mentoringState,
    ChatState? chatState,
    UserPreferenceState? userPreferenceState,
    IdleFarmlandState? idleFarmlandState,
    JobPostingState? jobPostingState,
  }) {
    return AppState(
      userState: userState ?? this.userState,
      mentoringState: mentoringState ?? this.mentoringState,
      chatState: chatState ?? this.chatState,
      userPreferenceState: userPreferenceState ?? this.userPreferenceState,
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
              userPreferenceState == other.userPreferenceState &&
              idleFarmlandState == other.idleFarmlandState &&
              jobPostingState == other.jobPostingState;

  @override
  int get hashCode =>
      userState.hashCode ^
      mentoringState.hashCode ^
      chatState.hashCode ^
      userPreferenceState.hashCode ^
      idleFarmlandState.hashCode ^
      jobPostingState.hashCode;

  @override
  String toString() =>
      'AppState{userState: $userState, mentoringState: $mentoringState, chatState: $chatState, userPreferenceState: $userPreferenceState, idleFarmlandState: $idleFarmlandState, jobPostingState: $jobPostingState}';
}