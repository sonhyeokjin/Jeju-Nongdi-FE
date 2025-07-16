import 'package:jejunongdi/core/models/idle_farmland_models.dart';

class IdleFarmlandState {
  final bool isLoading;
  final String? error;
  final IdleFarmlandResponse? selectedFarmland;

  // [추가] 목록 관련 상태
  final List<IdleFarmlandResponse> farmlands;
  final int currentPage;
  final bool hasMore;

  const IdleFarmlandState({
    required this.isLoading,
    this.error,
    this.selectedFarmland,
    required this.farmlands,
    required this.currentPage,
    required this.hasMore,
  });

  factory IdleFarmlandState.initial() {
    return const IdleFarmlandState(
      isLoading: false,
      error: null,
      selectedFarmland: null,
      farmlands: [],
      currentPage: 0,
      hasMore: true,
    );
  }

  IdleFarmlandState copyWith({
    bool? isLoading,
    String? error,
    IdleFarmlandResponse? selectedFarmland,
    List<IdleFarmlandResponse>? farmlands,
    int? currentPage,
    bool? hasMore,
    bool clearError = false,
    bool clearFarmland = false,
  }) {
    return IdleFarmlandState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
      selectedFarmland: clearFarmland ? null : selectedFarmland ?? this.selectedFarmland,
      farmlands: farmlands ?? this.farmlands,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}