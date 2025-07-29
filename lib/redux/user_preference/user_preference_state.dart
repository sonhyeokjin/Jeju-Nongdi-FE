import 'package:jejunongdi/core/models/user_preference_models.dart';

class UserPreferenceState {
  final UserPreferenceDto? myPreference;
  final UserPreferenceDto? selectedPreference;
  final List<UserPreferenceDto> usersByLocation;
  final List<UserPreferenceDto> usersByCrop;
  final List<UserPreferenceDto> usersByNotificationType;
  final List<FarmingTypeInfo> farmingTypes;
  final bool isLoading;
  final bool isValidating;
  final bool? isValid;
  final bool? isValidationPassed;
  final bool? isServerValidationPassed;
  final String? error;

  const UserPreferenceState({
    this.myPreference,
    this.selectedPreference,
    this.usersByLocation = const [],
    this.usersByCrop = const [],
    this.usersByNotificationType = const [],
    this.farmingTypes = const [],
    this.isLoading = false,
    this.isValidating = false,
    this.isValid,
    this.isValidationPassed,
    this.isServerValidationPassed,
    this.error,
  });

  factory UserPreferenceState.initial() {
    return const UserPreferenceState();
  }

  UserPreferenceState copyWith({
    UserPreferenceDto? myPreference,
    UserPreferenceDto? selectedPreference,
    List<UserPreferenceDto>? usersByLocation,
    List<UserPreferenceDto>? usersByCrop,
    List<UserPreferenceDto>? usersByNotificationType,
    List<FarmingTypeInfo>? farmingTypes,
    bool? isLoading,
    bool? isValidating,
    bool? isValid,
    bool? isValidationPassed,
    bool? isServerValidationPassed,
    String? error,
    bool clearError = false,
    bool clearMyPreference = false,
    bool clearSelectedPreference = false,
    bool clearIsValid = false,
    bool clearIsValidationPassed = false,
    bool clearIsServerValidationPassed = false,
  }) {
    return UserPreferenceState(
      myPreference: clearMyPreference ? null : (myPreference ?? this.myPreference),
      selectedPreference: clearSelectedPreference ? null : (selectedPreference ?? this.selectedPreference),
      usersByLocation: usersByLocation ?? this.usersByLocation,
      usersByCrop: usersByCrop ?? this.usersByCrop,
      usersByNotificationType: usersByNotificationType ?? this.usersByNotificationType,
      farmingTypes: farmingTypes ?? this.farmingTypes,
      isLoading: isLoading ?? this.isLoading,
      isValidating: isValidating ?? this.isValidating,
      isValid: clearIsValid ? null : (isValid ?? this.isValid),
      isValidationPassed: clearIsValidationPassed ? null : (isValidationPassed ?? this.isValidationPassed),
      isServerValidationPassed: clearIsServerValidationPassed ? null : (isServerValidationPassed ?? this.isServerValidationPassed),
      error: clearError ? null : (error ?? this.error),
    );
  }

  // 편의 getter들
  bool get hasMyPreference => myPreference != null;
  bool get hasSelectedPreference => selectedPreference != null;
  bool get hasError => error != null && error!.isNotEmpty;
  bool get hasUsersData => usersByLocation.isNotEmpty || usersByCrop.isNotEmpty || usersByNotificationType.isNotEmpty;
  bool get hasFarmingTypes => farmingTypes.isNotEmpty;

  // 사용자 설정의 유효성 상태
  bool get isPreferenceValid => isValid == true;
  bool get isPreferenceInvalid => isValid == false;

  @override
  String toString() {
    return 'UserPreferenceState('
        'myPreference: ${myPreference != null ? "loaded" : "null"}, '
        'selectedPreference: ${selectedPreference != null ? "loaded" : "null"}, '
        'usersByLocation: ${usersByLocation.length}, '
        'usersByCrop: ${usersByCrop.length}, '
        'usersByNotificationType: ${usersByNotificationType.length}, '
        'farmingTypes: ${farmingTypes.length}, '
        'isLoading: $isLoading, '
        'isValidating: $isValidating, '
        'isValid: $isValid, '
        'isValidationPassed: $isValidationPassed, '
        'isServerValidationPassed: $isServerValidationPassed, '
        'error: $error'
        ')';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserPreferenceState &&
          runtimeType == other.runtimeType &&
          myPreference == other.myPreference &&
          selectedPreference == other.selectedPreference &&
          usersByLocation == other.usersByLocation &&
          usersByCrop == other.usersByCrop &&
          usersByNotificationType == other.usersByNotificationType &&
          farmingTypes == other.farmingTypes &&
          isLoading == other.isLoading &&
          isValidating == other.isValidating &&
          isValid == other.isValid &&
          isValidationPassed == other.isValidationPassed &&
          isServerValidationPassed == other.isServerValidationPassed &&
          error == other.error;

  @override
  int get hashCode =>
      myPreference.hashCode ^
      selectedPreference.hashCode ^
      usersByLocation.hashCode ^
      usersByCrop.hashCode ^
      usersByNotificationType.hashCode ^
      farmingTypes.hashCode ^
      isLoading.hashCode ^
      isValidating.hashCode ^
      isValid.hashCode ^
      isValidationPassed.hashCode ^
      isServerValidationPassed.hashCode ^
      error.hashCode;
}