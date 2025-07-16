// Job Posting Actions - 일자리 공고 관련 액션 정의
import 'package:jejunongdi/core/models/job_posting_model.dart';

// 주소 선택 액션
class SelectAddressAction {
  final String address;
  final double latitude;
  final double longitude;

  const SelectAddressAction({
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  @override
  String toString() {
    return 'SelectAddressAction{address: $address, latitude: $latitude, longitude: $longitude}';
  }
}

// 주소 정보 클리어 액션
class ClearAddressAction {
  const ClearAddressAction();

  @override
  String toString() => 'ClearAddressAction{}';
}

// 일자리 공고 생성 시작 액션
class CreateJobPostingAction {
  final JobPostingRequest request;

  const CreateJobPostingAction(this.request);

  @override
  String toString() => 'CreateJobPostingAction{request: $request}';
}

// 일자리 공고 생성 성공 액션
class CreateJobPostingSuccessAction {
  final JobPostingResponse response;

  const CreateJobPostingSuccessAction(this.response);

  @override
  String toString() => 'CreateJobPostingSuccessAction{response: $response}';
}

// 일자리 공고 생성 실패 액션
class CreateJobPostingFailureAction {
  final String error;

  const CreateJobPostingFailureAction(this.error);

  @override
  String toString() => 'CreateJobPostingFailureAction{error: $error}';
}

// 로딩 상태 설정 액션
class SetJobPostingLoadingAction {
  final bool isLoading;

  const SetJobPostingLoadingAction(this.isLoading);

  @override
  String toString() => 'SetJobPostingLoadingAction{isLoading: $isLoading}';
}

// 에러 상태 설정 액션
class SetJobPostingErrorAction {
  final String? error;

  const SetJobPostingErrorAction(this.error);

  @override
  String toString() => 'SetJobPostingErrorAction{error: $error}';
}
