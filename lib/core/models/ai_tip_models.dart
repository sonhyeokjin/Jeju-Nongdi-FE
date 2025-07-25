import 'package:json_annotation/json_annotation.dart';

part 'ai_tip_models.g.dart';

/// AI 팁 응답 모델
@JsonSerializable()
class AiTipResponseDto {
  final int id;
  final int userId;
  final String tipType;
  final String title;
  final String content;
  final String? cropType;
  final bool isRead;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AiTipResponseDto({
    required this.id,
    required this.userId,
    required this.tipType,
    required this.title,
    required this.content,
    this.cropType,
    required this.isRead,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AiTipResponseDto.fromJson(Map<String, dynamic> json) =>
      _$AiTipResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$AiTipResponseDtoToJson(this);
}

/// AI 팁 생성 요청 모델
@JsonSerializable()
class AiTipCreateRequest {
  final int userId;
  final String tipType;
  final String title;
  final String content;
  final String? cropType;

  const AiTipCreateRequest({
    required this.userId,
    required this.tipType,
    required this.title,
    required this.content,
    this.cropType,
  });

  factory AiTipCreateRequest.fromJson(Map<String, dynamic> json) =>
      _$AiTipCreateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$AiTipCreateRequestToJson(this);
}

/// AI 팁 유형 enum
enum AiTipType {
  @JsonValue('WEATHER')
  weather('WEATHER', '날씨 정보'),
  
  @JsonValue('PEST_CONTROL')
  pestControl('PEST_CONTROL', '병해충 방제'),
  
  @JsonValue('HARVEST')
  harvest('HARVEST', '수확 시기'),
  
  @JsonValue('FERTILIZER')
  fertilizer('FERTILIZER', '비료 관리'),
  
  @JsonValue('IRRIGATION')
  irrigation('IRRIGATION', '관개 관리'),
  
  @JsonValue('GENERAL')
  general('GENERAL', '일반 농업 팁');

  const AiTipType(this.value, this.displayName);
  
  final String value;
  final String displayName;
}

/// 작물 유형 enum
enum CropType {
  @JsonValue('CITRUS')
  citrus('CITRUS', '감귤류'),
  
  @JsonValue('VEGETABLE')
  vegetable('VEGETABLE', '채소류'),
  
  @JsonValue('GRAIN')
  grain('GRAIN', '곡류'),
  
  @JsonValue('FRUIT')
  fruit('FRUIT', '과일류'),
  
  @JsonValue('HERB')
  herb('HERB', '허브류'),
  
  @JsonValue('ROOT')
  root('ROOT', '근채류');

  const CropType(this.value, this.displayName);
  
  final String value;
  final String displayName;
}