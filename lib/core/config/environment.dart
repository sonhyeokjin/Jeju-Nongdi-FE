enum Environment { development, staging, production }

class EnvironmentConfig {
  static Environment _current = Environment.development;

  static Environment get current => _current;

  static void setEnvironment(Environment env) {
    _current = env;
  }

  /// 네이버 지도 Client ID
  static String get naverMapClientId {
    switch (_current) {
      case Environment.development:
        return 'be8jif7owm'; // ← 실제 네이버 클라우드 플랫폼 Client ID
      case Environment.staging:
        return 'staging_naver_map_client_id';
      case Environment.production:
        return 'production_naver_map_client_id';
    }
  }

  /// API 베이스 URL
  static String get apiBaseUrl {
    switch (_current) {
      case Environment.development:
        return 'https://jeju-nongdi-be.onrender.com';
      case Environment.staging:
        return 'https://jeju-nongdi-be.onrender.com';
      case Environment.production:
        return 'https://jeju-nongdi-be.onrender.com';
    }
  }

  /// 디버그 모드 여부
  static bool get isDebug {
    switch (_current) {
      case Environment.development:
        return true;
      case Environment.staging:
        return true;
      case Environment.production:
        return false;
    }
  }

  /// 네트워크 연결 타임아웃 (밀리초)
  static int get connectTimeout {
    switch (_current) {
      case Environment.development:
        return 10000; // 10초
      case Environment.staging:
        return 8000;  // 8초
      case Environment.production:
        return 5000;  // 5초
    }
  }

  /// 네트워크 수신 타임아웃 (밀리초)
  static int get receiveTimeout {
    switch (_current) {
      case Environment.development:
        return 15000; // 15초
      case Environment.staging:
        return 12000; // 12초
      case Environment.production:
        return 10000; // 10초
    }
  }

  /// 디버그 모드 여부 (호환성을 위한 별칭)
  static bool get isDebugMode => isDebug;

  /// 로깅 활성화 여부
  static bool get enableLogging {
    switch (_current) {
      case Environment.development:
        return true;
      case Environment.staging:
        return true;
      case Environment.production:
        return false; // 프로덕션에서는 로깅 비활성화
    }
  }

}

/// 전역 인스턴스
final environmentConfig = EnvironmentConfig();
