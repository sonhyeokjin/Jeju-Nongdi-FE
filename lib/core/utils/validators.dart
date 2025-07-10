// 폼 검증 유틸리티
class Validators {
  // 이메일 검증
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return '이메일을 입력해주세요.';
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
      caseSensitive: false,
    );
    
    if (!emailRegex.hasMatch(value)) {
      return '올바른 이메일 형식을 입력해주세요.';
    }
    
    return null;
  }
  
  // 비밀번호 검증
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return '비밀번호를 입력해주세요.';
    }
    
    if (value.length < 8) {
      return '비밀번호는 최소 8자 이상이어야 합니다.';
    }
    
    if (value.length > 128) {
      return '비밀번호는 최대 128자까지 입력 가능합니다.';
    }
    
    // 영문, 숫자 포함 검증
    final hasLowerCase = value.contains(RegExp(r'[a-z]'));
    final hasDigit = value.contains(RegExp(r'[0-9]'));
    
    if (!hasLowerCase || !hasDigit) {
      return '비밀번호는 영문 소문자와 숫자를 포함해야 합니다.';
    }
    
    return null;
  }
  
  // 강한 비밀번호 검증
  static String? strongPassword(String? value) {
    final basicValidation = password(value);
    if (basicValidation != null) return basicValidation;
    
    final hasLowerCase = value!.contains(RegExp(r'[a-z]'));
    final hasUpperCase = value.contains(RegExp(r'[A-Z]'));
    final hasDigit = value.contains(RegExp(r'[0-9]'));
    final hasSpecialChar = value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    
    final requirements = [hasLowerCase, hasUpperCase, hasDigit, hasSpecialChar];
    final metRequirements = requirements.where((req) => req).length;
    
    if (metRequirements < 3) {
      return '비밀번호는 영문 대소문자, 숫자, 특수문자 중 3가지 이상을 포함해야 합니다.';
    }
    
    return null;
  }
  
  // 비밀번호 확인 검증
  static String? passwordConfirm(String? value, String? originalPassword) {
    if (value == null || value.isEmpty) {
      return '비밀번호 확인을 입력해주세요.';
    }
    
    if (value != originalPassword) {
      return '비밀번호가 일치하지 않습니다.';
    }
    
    return null;
  }
  
  // 이름 검증
  static String? name(String? value) {
    if (value == null || value.isEmpty) {
      return '이름을 입력해주세요.';
    }
    
    if (value.length < 2) {
      return '이름은 최소 2자 이상이어야 합니다.';
    }
    
    if (value.length > 50) {
      return '이름은 최대 50자까지 입력 가능합니다.';
    }
    
    // 한글, 영문만 허용
    final nameRegex = RegExp(r'^[가-힣a-zA-Z\s]+$');
    if (!nameRegex.hasMatch(value)) {
      return '이름은 한글 또는 영문만 입력 가능합니다.';
    }
    
    return null;
  }
  
  // 전화번호 검증
  static String? phoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return '전화번호를 입력해주세요.';
    }
    
    // 숫자와 하이픈만 허용
    final digitsOnly = value.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (digitsOnly.length < 10 || digitsOnly.length > 11) {
      return '올바른 전화번호를 입력해주세요.';
    }
    
    // 한국 전화번호 형식 검증
    final phoneRegex = RegExp(r'^01[0-9]-?[0-9]{3,4}-?[0-9]{4}$');
    if (!phoneRegex.hasMatch(value.replaceAll(' ', ''))) {
      return '올바른 전화번호 형식을 입력해주세요. (예: 010-1234-5678)';
    }
    
    return null;
  }
  
  // 필수 입력 검증
  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? '필수 항목'}을(를) 입력해주세요.';
    }
    return null;
  }
  
  // 최소 길이 검증
  static String? minLength(String? value, int minLength, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return null; // required와 함께 사용
    }
    
    if (value.length < minLength) {
      return '${fieldName ?? '입력값'}은(는) 최소 $minLength자 이상이어야 합니다.';
    }
    
    return null;
  }
  
  // 최대 길이 검증
  static String? maxLength(String? value, int maxLength, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return null; // required와 함께 사용
    }
    
    if (value.length > maxLength) {
      return '${fieldName ?? '입력값'}은(는) 최대 $maxLength자까지 입력 가능합니다.';
    }
    
    return null;
  }
  
  // 숫자만 허용
  static String? numbersOnly(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return null; // required와 함께 사용
    }
    
    final numberRegex = RegExp(r'^[0-9]+$');
    if (!numberRegex.hasMatch(value)) {
      return '${fieldName ?? '입력값'}은(는) 숫자만 입력 가능합니다.';
    }
    
    return null;
  }
  
  // 영문만 허용
  static String? alphabetOnly(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return null; // required와 함께 사용
    }
    
    final alphabetRegex = RegExp(r'^[a-zA-Z]+$');
    if (!alphabetRegex.hasMatch(value)) {
      return '${fieldName ?? '입력값'}은(는) 영문만 입력 가능합니다.';
    }
    
    return null;
  }
  
  // 한글만 허용
  static String? koreanOnly(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return null; // required와 함께 사용
    }
    
    final koreanRegex = RegExp(r'^[가-힣\s]+$');
    if (!koreanRegex.hasMatch(value)) {
      return '${fieldName ?? '입력값'}은(는) 한글만 입력 가능합니다.';
    }
    
    return null;
  }
  
  // URL 검증
  static String? url(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return null; // required와 함께 사용
    }
    
    final urlRegex = RegExp(
      r'^https?://(?:www\.)?[-a-zA-Z0-9@:%._+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b[-a-zA-Z0-9()@:%_+.~#?&=]*$',
      caseSensitive: false,
    );
    
    if (!urlRegex.hasMatch(value)) {
      return '올바른 URL 형식을 입력해주세요.';
    }
    
    return null;
  }
  
  // 생년월일 검증
  static String? birthDate(String? value) {
    if (value == null || value.isEmpty) {
      return '생년월일을 입력해주세요.';
    }
    
    try {
      final date = DateTime.parse(value);
      final now = DateTime.now();
      
      if (date.isAfter(now)) {
        return '생년월일은 현재 날짜보다 이전이어야 합니다.';
      }
      
      final minDate = DateTime(now.year - 120, now.month, now.day);
      if (date.isBefore(minDate)) {
        return '올바른 생년월일을 입력해주세요.';
      }
      
      return null;
    } catch (e) {
      return '올바른 날짜 형식을 입력해주세요. (YYYY-MM-DD)';
    }
  }
  
  // 여러 검증 조합
  static String? combine(String? value, List<String? Function(String?)> validators) {
    for (final validator in validators) {
      final result = validator(value);
      if (result != null) return result;
    }
    return null;
  }
}

// 폼 필드 래퍼 클래스
class FormField<T> {
  T? value;
  String? error;
  bool hasBeenTouched;
  
  FormField({this.value, this.error, this.hasBeenTouched = false});
  
  bool get isValid => error == null;
  bool get isInvalid => error != null;
  bool get showError => hasBeenTouched && isInvalid;
  
  void setValue(T? newValue) {
    value = newValue;
    hasBeenTouched = true;
  }
  
  void setError(String? newError) {
    error = newError;
  }
  
  void validate(String? Function(T?) validator) {
    error = validator(value);
  }
  
  void touch() {
    hasBeenTouched = true;
  }
  
  void reset() {
    value = null;
    error = null;
    hasBeenTouched = false;
  }
}

// 폼 관리 클래스
class FormManager {
  final Map<String, FormField> _fields = {};
  
  // 필드 추가
  void addField(String name, {dynamic initialValue}) {
    _fields[name] = FormField(value: initialValue);
  }
  
  // 필드 값 설정
  void setFieldValue(String name, dynamic value) {
    _fields[name]?.setValue(value);
  }
  
  // 필드 검증
  void validateField(String name, String? Function(dynamic) validator) {
    _fields[name]?.validate(validator);
  }
  
  // 모든 필드 검증
  bool validateAll(Map<String, String? Function(dynamic)> validators) {
    bool isValid = true;
    
    validators.forEach((fieldName, validator) {
      validateField(fieldName, validator);
      if (_fields[fieldName]?.isInvalid == true) {
        isValid = false;
      }
    });
    
    return isValid;
  }
  
  // 필드 값 가져오기
  T? getFieldValue<T>(String name) {
    return _fields[name]?.value as T?;
  }
  
  // 필드 에러 가져오기
  String? getFieldError(String name) {
    return _fields[name]?.error;
  }
  
  // 필드 에러 표시 여부
  bool shouldShowFieldError(String name) {
    return _fields[name]?.showError ?? false;
  }
  
  // 폼 데이터 가져오기
  Map<String, dynamic> getFormData() {
    final data = <String, dynamic>{};
    _fields.forEach((name, field) {
      data[name] = field.value;
    });
    return data;
  }
  
  // 폼 유효성 확인
  bool get isValid {
    return _fields.values.every((field) => field.isValid);
  }
  
  // 폼 초기화
  void reset() {
    for (final field in _fields.values) {
      field.reset();
    }
  }
  
  // 모든 필드 터치 처리
  void touchAll() {
    for (final field in _fields.values) {
      field.touch();
    }
  }
}
