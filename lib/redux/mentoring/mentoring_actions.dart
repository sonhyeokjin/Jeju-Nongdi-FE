import 'package:jejunongdi/core/models/mentoring_models.dart';

// 로딩 상태 관리
class SetMentoringLoadingAction {
  final bool isLoading;
  SetMentoringLoadingAction(this.isLoading);
}

class SetMentoringCreateLoadingAction {
  final bool isLoading;
  SetMentoringCreateLoadingAction(this.isLoading);
}

// 에러 관리
class SetMentoringErrorAction {
  final String? error;
  SetMentoringErrorAction(this.error);
}

class ClearMentoringErrorAction {}

// 멘토링 목록 관련
class LoadMentoringsAction {
  final int page;
  final int size;
  final bool refresh;
  
  LoadMentoringsAction({
    this.page = 0,
    this.size = 20,
    this.refresh = false,
  });
}

class LoadMentoringsSuccessAction {
  final PageResponse<MentoringResponse> pageResponse;
  final bool refresh;
  
  LoadMentoringsSuccessAction(this.pageResponse, {this.refresh = false});
}

class LoadMentoringsFailureAction {
  final String error;
  LoadMentoringsFailureAction(this.error);
}

// 내 멘토링 목록 관련
class LoadMyMentoringsAction {
  final int page;
  final int size;
  final bool refresh;
  
  LoadMyMentoringsAction({
    this.page = 0,
    this.size = 20,
    this.refresh = false,
  });
}

class LoadMyMentoringsSuccessAction {
  final PageResponse<MentoringResponse> pageResponse;
  final bool refresh;
  
  LoadMyMentoringsSuccessAction(this.pageResponse, {this.refresh = false});
}

class LoadMyMentoringsFailureAction {
  final String error;
  LoadMyMentoringsFailureAction(this.error);
}

// 멘토링 상세 조회
class LoadMentoringDetailAction {
  final int id;
  LoadMentoringDetailAction(this.id);
}

class LoadMentoringDetailSuccessAction {
  final MentoringResponse mentoring;
  LoadMentoringDetailSuccessAction(this.mentoring);
}

class LoadMentoringDetailFailureAction {
  final String error;
  LoadMentoringDetailFailureAction(this.error);
}

// 멘토링 생성
class CreateMentoringAction {
  final MentoringRequest request;
  CreateMentoringAction(this.request);
}

class CreateMentoringSuccessAction {
  final MentoringResponse mentoring;
  CreateMentoringSuccessAction(this.mentoring);
}

class CreateMentoringFailureAction {
  final String error;
  CreateMentoringFailureAction(this.error);
}

// 멘토링 수정
class UpdateMentoringAction {
  final int id;
  final MentoringRequest request;
  UpdateMentoringAction(this.id, this.request);
}

class UpdateMentoringSuccessAction {
  final MentoringResponse mentoring;
  UpdateMentoringSuccessAction(this.mentoring);
}

class UpdateMentoringFailureAction {
  final String error;
  UpdateMentoringFailureAction(this.error);
}

// 멘토링 삭제
class DeleteMentoringAction {
  final int id;
  DeleteMentoringAction(this.id);
}

class DeleteMentoringSuccessAction {
  final int id;
  DeleteMentoringSuccessAction(this.id);
}

class DeleteMentoringFailureAction {
  final String error;
  DeleteMentoringFailureAction(this.error);
}

// 필터링 검색
class SearchMentoringsAction {
  final int page;
  final int size;
  final String? category;
  final String? mentoringType;
  final String? experienceLevel;
  final String? status;
  final String? keyword;
  final bool refresh;
  
  SearchMentoringsAction({
    this.page = 0,
    this.size = 20,
    this.category,
    this.mentoringType,
    this.experienceLevel,
    this.status,
    this.keyword,
    this.refresh = false,
  });
}

// 선택된 멘토링 설정/해제
class SetSelectedMentoringAction {
  final MentoringResponse? mentoring;
  SetSelectedMentoringAction(this.mentoring);
}

class ClearSelectedMentoringAction {}

// 상태 초기화
class ResetMentoringStateAction {}
