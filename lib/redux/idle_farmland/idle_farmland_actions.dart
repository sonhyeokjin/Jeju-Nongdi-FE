import 'package:jejunongdi/core/models/idle_farmland_models.dart';

// --- 공통 액션 ---
class SetIdleFarmlandLoadingAction {
  final bool isLoading;
  SetIdleFarmlandLoadingAction(this.isLoading);
}

class SetIdleFarmlandErrorAction {
  final String error;
  SetIdleFarmlandErrorAction(this.error);
}

// --- 상세 조회 관련 액션 ---
class LoadIdleFarmlandDetailAction {
  final int farmlandId;
  LoadIdleFarmlandDetailAction(this.farmlandId);
}

class LoadIdleFarmlandDetailSuccessAction {
  final IdleFarmlandResponse farmland;
  LoadIdleFarmlandDetailSuccessAction(this.farmland);
}

// --- 수정 관련 액션 ---
class UpdateIdleFarmlandAction {
  final int farmlandId;
  final IdleFarmlandRequest request;
  UpdateIdleFarmlandAction(this.farmlandId, this.request);
}

class UpdateIdleFarmlandSuccessAction {
  final IdleFarmlandResponse updatedFarmland;
  UpdateIdleFarmlandSuccessAction(this.updatedFarmland);
}

// --- 삭제 관련 액션 ---
class DeleteIdleFarmlandAction {
  final int farmlandId;
  DeleteIdleFarmlandAction(this.farmlandId);
}

class DeleteIdleFarmlandSuccessAction {
  final int farmlandId;
  DeleteIdleFarmlandSuccessAction(this.farmlandId);
}