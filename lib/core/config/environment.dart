// 환경 설정 관리
enum Environment {
  development,
  staging,
  production,
}

class EnvironmentConfig {
  static Environment _current = Environment.development;
  
  static Environment get current => _current;
  
  static void setEnvironment(Environment env) {
    _current = env;
  }
  
  // API Base URLs
  static String get apiBaseUrl {
    switch (_current) {
      case Environment.development:
        return 'https://jeju-nongdi-be.onrender.com/api';
      case Environment.staging:
        return 'https://staging-api.jejunongdi.com/api';
      case Environment.production:
        return 'https://api.jejunongdi.com/api';
    }
  }
  
  // Kakao Map API Key
  static String get kakaoMapApiKey {
    switch (_current) {
      case Environment.development:
        return '752d47c1d500b05f00d22e33448215a9';
      case Environment.staging:
        return 'staging_kakao_map_api_key';
      case Environment.production:
        return 'production_kakao_map_api_key';
    }
  }
  
  // Firebase Config (if needed)
  static String get firebaseProjectId {
    switch (_current) {
      case Environment.development:
        return 'jejunongdi-dev';
      case Environment.staging:
        return 'jejunongdi-staging';
      case Environment.production:
        return 'jejunongdi-prod';
    }
  }
  
  // Debug settings
  static bool get isDebugMode => _current == Environment.development;
  static bool get enableLogging => _current != Environment.production;
  static bool get enableCrashlytics => _current == Environment.production;
  
  // Network timeout settings
  static int get connectTimeout => _current == Environment.development ? 30000 : 15000;
  static int get receiveTimeout => _current == Environment.development ? 30000 : 15000;
  
  // Cache settings
  static int get cacheMaxAge => _current == Environment.development ? 300 : 3600; // seconds
  
  @override
  String toString() => 'Environment: ${_current.name}';
}
