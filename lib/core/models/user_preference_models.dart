import 'package:json_annotation/json_annotation.dart';

part 'user_preference_models.g.dart';

/// 사용자 농업 개인화 설정 모델 (API 명세서 기준)
@JsonSerializable()
class UserPreferenceDto {
  final int? id;
  @JsonKey(name: 'userId')
  final int? userId;
  @JsonKey(name: 'primaryCrops')
  final List<String>? primaryCrops;
  @JsonKey(name: 'farmLocation')
  final String? farmLocation;
  @JsonKey(name: 'farmSize')
  final double? farmSize;
  @JsonKey(name: 'farmingExperience')
  final int? farmingExperience;
  @JsonKey(name: 'notificationWeather')
  final bool? notificationWeather;
  @JsonKey(name: 'notificationPest')
  final bool? notificationPest;
  @JsonKey(name: 'notificationMarket')
  final bool? notificationMarket;
  @JsonKey(name: 'notificationLabor')
  final bool? notificationLabor;
  @JsonKey(name: 'preferredTipTime')
  final String? preferredTipTime;
  @JsonKey(name: 'farmingType')
  final String? farmingType;
  @JsonKey(name: 'farmingTypeDescription')
  final String? farmingTypeDescription;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserPreferenceDto({
    this.id,
    this.userId,
    this.primaryCrops,
    this.farmLocation,
    this.farmSize,
    this.farmingExperience,
    this.notificationWeather,
    this.notificationPest,
    this.notificationMarket,
    this.notificationLabor,
    this.preferredTipTime,
    this.farmingType,
    this.farmingTypeDescription,
    this.createdAt,
    this.updatedAt,
  });

  factory UserPreferenceDto.fromJson(Map<String, dynamic> json) =>
      _$UserPreferenceDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UserPreferenceDtoToJson(this);

  /// 기본 설정을 생성합니다.
  factory UserPreferenceDto.createDefault(int userId) {
    return UserPreferenceDto(
      userId: userId,
      farmingType: 'CONVENTIONAL',
      farmingTypeDescription: '일반농업',
      primaryCrops: ['감귤'],
      farmSize: 1000.0, // 1000㎡
      farmLocation: '제주도',
      farmingExperience: 1, // 1년
      notificationWeather: true,
      notificationPest: true,
      notificationMarket: false,
      notificationLabor: true,
      preferredTipTime: 'MORNING', // 오전
    );
  }

  /// 설정을 업데이트합니다.
  UserPreferenceDto copyWith({
    int? id,
    int? userId,
    List<String>? primaryCrops,
    String? farmLocation,
    double? farmSize,
    int? farmingExperience,
    bool? notificationWeather,
    bool? notificationPest,
    bool? notificationMarket,
    bool? notificationLabor,
    String? preferredTipTime,
    String? farmingType,
    String? farmingTypeDescription,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserPreferenceDto(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      primaryCrops: primaryCrops ?? this.primaryCrops,
      farmLocation: farmLocation ?? this.farmLocation,
      farmSize: farmSize ?? this.farmSize,
      farmingExperience: farmingExperience ?? this.farmingExperience,
      notificationWeather: notificationWeather ?? this.notificationWeather,
      notificationPest: notificationPest ?? this.notificationPest,
      notificationMarket: notificationMarket ?? this.notificationMarket,
      notificationLabor: notificationLabor ?? this.notificationLabor,
      preferredTipTime: preferredTipTime ?? this.preferredTipTime,
      farmingType: farmingType ?? this.farmingType,
      farmingTypeDescription: farmingTypeDescription ?? this.farmingTypeDescription,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// 농업 유형 정보 모델 (API 명세서 기준)
@JsonSerializable()
class FarmingTypeInfo {
  final String code;
  final String name;
  final String description;

  const FarmingTypeInfo({
    required this.code,
    required this.name,
    required this.description,
  });

  factory FarmingTypeInfo.fromJson(Map<String, dynamic> json) =>
      _$FarmingTypeInfoFromJson(json);

  Map<String, dynamic> toJson() => _$FarmingTypeInfoToJson(this);
}

/// 농업 유형 enum
enum FarmingType {
  @JsonValue('ORGANIC')
  organic('ORGANIC', '유기농업'),
  
  @JsonValue('CONVENTIONAL')
  conventional('CONVENTIONAL', '일반농업'),
  
  @JsonValue('HYDROPONIC')
  hydroponic('HYDROPONIC', '수경재배'),
  
  @JsonValue('GREENHOUSE')
  greenhouse('GREENHOUSE', '시설원예'),
  
  @JsonValue('LIVESTOCK')
  livestock('LIVESTOCK', '축산업');

  const FarmingType(this.value, this.displayName);
  
  final String value;
  final String displayName;
}

/// 농장 규모 enum
enum FarmSize {
  @JsonValue('SMALL')
  small('SMALL', '소규모 (1,000㎡ 미만)'),
  
  @JsonValue('MEDIUM')
  medium('MEDIUM', '중규모 (1,000㎡ ~ 10,000㎡)'),
  
  @JsonValue('LARGE')
  large('LARGE', '대규모 (10,000㎡ 이상)');

  const FarmSize(this.value, this.displayName);
  
  final String value;
  final String displayName;
}

/// 경험 수준 enum
enum ExperienceLevel {
  @JsonValue('BEGINNER')
  beginner('BEGINNER', '초급 (1년 미만)'),
  
  @JsonValue('INTERMEDIATE')
  intermediate('INTERMEDIATE', '중급 (1-5년)'),
  
  @JsonValue('ADVANCED')
  advanced('ADVANCED', '고급 (5년 이상)'),
  
  @JsonValue('EXPERT')
  expert('EXPERT', '전문가 (10년 이상)');

  const ExperienceLevel(this.value, this.displayName);
  
  final String value;
  final String displayName;
}