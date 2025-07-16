// Job Posting State - 일자리 공고 관련 상태 정의
class JobPostingState {
  final bool isLoading;
  final String? error;
  final String? selectedAddress;
  final double? selectedLatitude;
  final double? selectedLongitude;
  final bool isCreateLoading;

  const JobPostingState({
    required this.isLoading,
    this.error,
    this.selectedAddress,
    this.selectedLatitude,
    this.selectedLongitude,
    required this.isCreateLoading,
  });

  // 초기 상태 정의
  factory JobPostingState.initial() {
    return const JobPostingState(
      isLoading: false,
      error: null,
      selectedAddress: null,
      selectedLatitude: null,
      selectedLongitude: null,
      isCreateLoading: false,
    );
  }

  // copyWith 메서드 - 상태 복사 및 수정
  JobPostingState copyWith({
    bool? isLoading,
    String? error,
    String? selectedAddress,
    double? selectedLatitude,
    double? selectedLongitude,
    bool? isCreateLoading,
  }) {
    return JobPostingState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      selectedAddress: selectedAddress ?? this.selectedAddress,
      selectedLatitude: selectedLatitude ?? this.selectedLatitude,
      selectedLongitude: selectedLongitude ?? this.selectedLongitude,
      isCreateLoading: isCreateLoading ?? this.isCreateLoading,
    );
  }

  // 주소 정보 클리어
  JobPostingState clearAddress() {
    return JobPostingState(
      isLoading: isLoading,
      error: error,
      selectedAddress: null,
      selectedLatitude: null,
      selectedLongitude: null,
      isCreateLoading: isCreateLoading,
    );
  }

  // 에러 클리어
  JobPostingState clearError() {
    return JobPostingState(
      isLoading: isLoading,
      error: null,
      selectedAddress: selectedAddress,
      selectedLatitude: selectedLatitude,
      selectedLongitude: selectedLongitude,
      isCreateLoading: isCreateLoading,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JobPostingState &&
          runtimeType == other.runtimeType &&
          isLoading == other.isLoading &&
          error == other.error &&
          selectedAddress == other.selectedAddress &&
          selectedLatitude == other.selectedLatitude &&
          selectedLongitude == other.selectedLongitude &&
          isCreateLoading == other.isCreateLoading;

  @override
  int get hashCode =>
      isLoading.hashCode ^
      error.hashCode ^
      selectedAddress.hashCode ^
      selectedLatitude.hashCode ^
      selectedLongitude.hashCode ^
      isCreateLoading.hashCode;

  @override
  String toString() {
    return 'JobPostingState{isLoading: $isLoading, error: $error, selectedAddress: $selectedAddress, selectedLatitude: $selectedLatitude, selectedLongitude: $selectedLongitude, isCreateLoading: $isCreateLoading}';
  }
}
