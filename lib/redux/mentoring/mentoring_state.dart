import 'package:jejunongdi/core/models/mentoring_models.dart';

class MentoringState {
  final List<MentoringResponse> mentorings;
  final List<MentoringResponse> myMentorings;
  final MentoringResponse? selectedMentoring;
  final bool isLoading;
  final bool isCreateLoading;
  final String? error;
  final int currentPage;
  final bool hasMore;
  final int totalElements;

  const MentoringState({
    required this.mentorings,
    required this.myMentorings,
    this.selectedMentoring,
    required this.isLoading,
    required this.isCreateLoading,
    this.error,
    required this.currentPage,
    required this.hasMore,
    required this.totalElements,
  });

  // 초기 상태
  factory MentoringState.initial() {
    return const MentoringState(
      mentorings: [],
      myMentorings: [],
      selectedMentoring: null,
      isLoading: false,
      isCreateLoading: false,
      error: null,
      currentPage: 0,
      hasMore: true,
      totalElements: 0,
    );
  }

  // copyWith 메서드
  MentoringState copyWith({
    List<MentoringResponse>? mentorings,
    List<MentoringResponse>? myMentorings,
    MentoringResponse? selectedMentoring,
    bool? isLoading,
    bool? isCreateLoading,
    String? error,
    int? currentPage,
    bool? hasMore,
    int? totalElements,
    bool clearError = false,
    bool clearSelectedMentoring = false,
  }) {
    return MentoringState(
      mentorings: mentorings ?? this.mentorings,
      myMentorings: myMentorings ?? this.myMentorings,
      selectedMentoring: clearSelectedMentoring ? null : (selectedMentoring ?? this.selectedMentoring),
      isLoading: isLoading ?? this.isLoading,
      isCreateLoading: isCreateLoading ?? this.isCreateLoading,
      error: clearError ? null : (error ?? this.error),
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      totalElements: totalElements ?? this.totalElements,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MentoringState &&
          runtimeType == other.runtimeType &&
          mentorings == other.mentorings &&
          myMentorings == other.myMentorings &&
          selectedMentoring == other.selectedMentoring &&
          isLoading == other.isLoading &&
          isCreateLoading == other.isCreateLoading &&
          error == other.error &&
          currentPage == other.currentPage &&
          hasMore == other.hasMore &&
          totalElements == other.totalElements;

  @override
  int get hashCode =>
      mentorings.hashCode ^
      myMentorings.hashCode ^
      selectedMentoring.hashCode ^
      isLoading.hashCode ^
      isCreateLoading.hashCode ^
      error.hashCode ^
      currentPage.hashCode ^
      hasMore.hashCode ^
      totalElements.hashCode;

  @override
  String toString() {
    return 'MentoringState{'
        'mentorings: ${mentorings.length} items, '
        'myMentorings: ${myMentorings.length} items, '
        'selectedMentoring: $selectedMentoring, '
        'isLoading: $isLoading, '
        'isCreateLoading: $isCreateLoading, '
        'error: $error, '
        'currentPage: $currentPage, '
        'hasMore: $hasMore, '
        'totalElements: $totalElements'
        '}';
  }
}
