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
  final bool refresh;
  
  LoadMyMentoringsAction({this.refresh = false});
}

class LoadMyMentoringsSuccessAction {
  final List<MentoringResponse> mentorings;
  
  LoadMyMentoringsSuccessAction(this.mentorings);
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

// 멘토링 타입별 조회
class LoadMentoringsByTypeAction {
  final String mentoringType;
  LoadMentoringsByTypeAction(this.mentoringType);
}

class LoadMentoringsByTypeSuccessAction {
  final List<MentoringResponse> mentorings;
  LoadMentoringsByTypeSuccessAction(this.mentorings);
}

class LoadMentoringsByTypeFailureAction {
  final String error;
  LoadMentoringsByTypeFailureAction(this.error);
}

// 카테고리별 조회
class LoadMentoringsByCategoryAction {
  final String category;
  LoadMentoringsByCategoryAction(this.category);
}

class LoadMentoringsByCategorySuccessAction {
  final List<MentoringResponse> mentorings;
  LoadMentoringsByCategorySuccessAction(this.mentorings);
}

class LoadMentoringsByCategoryFailureAction {
  final String error;
  LoadMentoringsByCategoryFailureAction(this.error);
}

// 멘토링 검색 (다양한 조건)
class SearchMentoringsAdvancedAction {
  final String? mentoringType;
  final String? category;
  final String? experienceLevel;
  final String? location;
  final String? keyword;
  
  SearchMentoringsAdvancedAction({
    this.mentoringType,
    this.category,
    this.experienceLevel,
    this.location,
    this.keyword,
  });
}

class SearchMentoringsAdvancedSuccessAction {
  final List<MentoringResponse> mentorings;
  SearchMentoringsAdvancedSuccessAction(this.mentorings);
}

class SearchMentoringsAdvancedFailureAction {
  final String error;
  SearchMentoringsAdvancedFailureAction(this.error);
}

// 메타데이터 조회 액션들
class LoadCategoriesAction {}

class LoadCategoriesSuccessAction {
  final List<String> categories;
  LoadCategoriesSuccessAction(this.categories);
}

class LoadCategoriesFailureAction {
  final String error;
  LoadCategoriesFailureAction(this.error);
}

class LoadMentoringTypesAction {}

class LoadMentoringTypesSuccessAction {
  final List<String> types;
  LoadMentoringTypesSuccessAction(this.types);
}

class LoadMentoringTypesFailureAction {
  final String error;
  LoadMentoringTypesFailureAction(this.error);
}

class LoadExperienceLevelsAction {}

class LoadExperienceLevelsSuccessAction {
  final List<String> levels;
  LoadExperienceLevelsSuccessAction(this.levels);
}

class LoadExperienceLevelsFailureAction {
  final String error;
  LoadExperienceLevelsFailureAction(this.error);
}

class LoadMentoringStatusesAction {}

class LoadMentoringStatusesSuccessAction {
  final List<String> statuses;
  LoadMentoringStatusesSuccessAction(this.statuses);
}

class LoadMentoringStatusesFailureAction {
  final String error;
  LoadMentoringStatusesFailureAction(this.error);
}

// 멘토링 상태 변경
class UpdateMentoringStatusAction {
  final int id;
  final String status;
  UpdateMentoringStatusAction(this.id, this.status);
}

class UpdateMentoringStatusSuccessAction {
  final MentoringResponse mentoring;
  UpdateMentoringStatusSuccessAction(this.mentoring);
}

class UpdateMentoringStatusFailureAction {
  final String error;
  UpdateMentoringStatusFailureAction(this.error);
}

// 상태 초기화
class ResetMentoringStateAction {}
