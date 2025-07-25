import 'package:json_annotation/json_annotation.dart';

part 'user_preference_models.g.dart';

/// 사용자 농업 개인화 설정 모델
@JsonSerializable()
class UserPreferenceDto {
  final int? id;
  final int userId;
  final String? farmingType;
  final List<String>? interestedCrops;
  final String? farmSize;
  final String? farmLocation;
  final String? experienceLevel;
  final Map<String, dynamic>? weatherSettings;
  final Map<String, dynamic>? notificationSettings;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserPreferenceDto({
    this.id,
    required this.userId,
    this.farmingType,
    this.interestedCrops,
    this.farmSize,
    this.farmLocation,
    this.experienceLevel,
    this.weatherSettings,
    this.notificationSettings,
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
      farmingType: '일반농업',
      interestedCrops: ['감귤'],
      farmSize: '소규모',
      farmLocation: '제주도',
      experienceLevel: '초급',
      weatherSettings: {
        'enableWeatherAlerts': true,
        'temperatureUnit': 'celsius',
        'precipitationUnit': 'mm',
      },
      notificationSettings: {
        'enablePushNotifications': true,
        'enableEmailNotifications': false,
        'enableSMSNotifications': false,
        'notificationHours': [9, 18], // 오전 9시, 오후 6시
        'weekendNotifications': true,
      },
    );
  }

  /// 설정을 업데이트합니다.
  UserPreferenceDto copyWith({
    int? id,
    int? userId,
    String? farmingType,
    List<String>? interestedCrops,
    String? farmSize,
    String? farmLocation,
    String? experienceLevel,
    Map<String, dynamic>? weatherSettings,
    Map<String, dynamic>? notificationSettings,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserPreferenceDto(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      farmingType: farmingType ?? this.farmingType,
      interestedCrops: interestedCrops ?? this.interestedCrops,
      farmSize: farmSize ?? this.farmSize,
      farmLocation: farmLocation ?? this.farmLocation,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      weatherSettings: weatherSettings ?? this.weatherSettings,
      notificationSettings: notificationSettings ?? this.notificationSettings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
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