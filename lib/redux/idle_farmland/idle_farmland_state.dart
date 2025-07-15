import 'package:jejunongdi/core/models/idle_farmland_models.dart';

class IdleFarmlandState {
  final bool isLoading;
  final String? error;
  // 여러 농지 목록이 아닌, 상세 화면에서 볼 단일 농지 정보를 저장
  final IdleFarmlandResponse? selectedFarmland;

  const IdleFarmlandState({
    required this.isLoading,
    this.error,
    this.selectedFarmland,
  });

  factory IdleFarmlandState.initial() {
    return const IdleFarmlandState(
      isLoading: false,
      error: null,
      selectedFarmland: null,
    );
  }

  IdleFarmlandState copyWith({
    bool? isLoading,
    String? error,
    IdleFarmlandResponse? selectedFarmland,
    bool clearError = false,
    bool clearFarmland = false,
  }) {
    return IdleFarmlandState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
      selectedFarmland: clearFarmland ? null : selectedFarmland ?? this.selectedFarmland,
    );
  }
}