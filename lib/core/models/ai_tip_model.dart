class AiTipModel {
  final int id;
  final String title;
  final String content;
  final String tipType;
  final String? cropType;
  final DateTime createdAt;
  final bool isRead;
  final int userId;

  AiTipModel({
    required this.id,
    required this.title,
    required this.content,
    required this.tipType,
    this.cropType,
    required this.createdAt,
    required this.isRead,
    required this.userId,
  });

  factory AiTipModel.fromJson(Map<String, dynamic> json) {
    return AiTipModel(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      tipType: json['tipType'],
      cropType: json['cropType'],
      createdAt: DateTime.parse(json['createdAt']),
      isRead: json['isRead'] ?? false,
      userId: json['userId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'tipType': tipType,
      'cropType': cropType,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
      'userId': userId,
    };
  }

  AiTipModel copyWith({
    int? id,
    String? title,
    String? content,
    String? tipType,
    String? cropType,
    DateTime? createdAt,
    bool? isRead,
    int? userId,
  }) {
    return AiTipModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      tipType: tipType ?? this.tipType,
      cropType: cropType ?? this.cropType,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      userId: userId ?? this.userId,
    );
  }
}

class TodayFarmLifeModel {
  final String summary;
  final String weatherAlert;
  final String cropTip;
  final List<String> urgentTasks;
  final int unreadNotifications;

  TodayFarmLifeModel({
    required this.summary,
    required this.weatherAlert,
    required this.cropTip,
    required this.urgentTasks,
    required this.unreadNotifications,
  });

  factory TodayFarmLifeModel.fromJson(Map<String, dynamic> json) {
    return TodayFarmLifeModel(
      summary: json['summary'] ?? '',
      weatherAlert: json['weatherAlert'] ?? '',
      cropTip: json['cropTip'] ?? '',
      urgentTasks: List<String>.from(json['urgentTasks'] ?? []),
      unreadNotifications: json['unreadNotifications'] ?? 0,
    );
  }
}

class WeatherBasedTipModel {
  final String farmName;
  final String weatherCondition;
  final String recommendation;
  final String warning;
  final double temperature;
  final int humidity;
  final DateTime targetDate;

  WeatherBasedTipModel({
    required this.farmName,
    required this.weatherCondition,
    required this.recommendation,
    required this.warning,
    required this.temperature,
    required this.humidity,
    required this.targetDate,
  });

  factory WeatherBasedTipModel.fromJson(Map<String, dynamic> json) {
    return WeatherBasedTipModel(
      farmName: json['farmName'] ?? '',
      weatherCondition: json['weatherCondition'] ?? '',
      recommendation: json['recommendation'] ?? '',
      warning: json['warning'] ?? '',
      temperature: json['temperature']?.toDouble() ?? 0.0,
      humidity: json['humidity'] ?? 0,
      targetDate: DateTime.parse(json['targetDate']),
    );
  }
}

class PestAlertModel {
  final String region;
  final String pestName;
  final String severity;
  final String description;
  final List<String> preventionMethods;
  final DateTime alertDate;

  PestAlertModel({
    required this.region,
    required this.pestName,
    required this.severity,
    required this.description,
    required this.preventionMethods,
    required this.alertDate,
  });

  factory PestAlertModel.fromJson(Map<String, dynamic> json) {
    return PestAlertModel(
      region: json['region'] ?? '',
      pestName: json['pestName'] ?? '',
      severity: json['severity'] ?? '',
      description: json['description'] ?? '',
      preventionMethods: List<String>.from(json['preventionMethods'] ?? []),
      alertDate: DateTime.parse(json['alertDate']),
    );
  }
}

class CropGuideModel {
  final String cropType;
  final String currentStage;
  final String stageDescription;
  final List<String> tasks;
  final List<String> cautions;
  final String nextStage;
  final DateTime estimatedNextStageDate;

  CropGuideModel({
    required this.cropType,
    required this.currentStage,
    required this.stageDescription,
    required this.tasks,
    required this.cautions,
    required this.nextStage,
    required this.estimatedNextStageDate,
  });

  factory CropGuideModel.fromJson(Map<String, dynamic> json) {
    return CropGuideModel(
      cropType: json['cropType'] ?? '',
      currentStage: json['currentStage'] ?? '',
      stageDescription: json['stageDescription'] ?? '',
      tasks: List<String>.from(json['tasks'] ?? []),
      cautions: List<String>.from(json['cautions'] ?? []),
      nextStage: json['nextStage'] ?? '',
      estimatedNextStageDate: DateTime.parse(json['estimatedNextStageDate']),
    );
  }
}

class TipTypeModel {
  final String code;
  final String description;
  final String icon;

  TipTypeModel({
    required this.code,
    required this.description,
    required this.icon,
  });

  factory TipTypeModel.fromJson(Map<String, dynamic> json) {
    return TipTypeModel(
      code: json['code'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? '',
    );
  }

  // 하위 호환성을 위한 getter들
  String get type => code;
  String get displayName => description;
  String get iconName => icon;
}