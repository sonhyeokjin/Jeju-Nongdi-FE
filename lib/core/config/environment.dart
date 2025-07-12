enum Environment { development, staging, production, githubPages }

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
        return 'be8jif7owm'; // ← 개발용 네이버 클라우드 플랫폼 Client ID
      case Environment.staging:
        return 'be8jif7owm'; // ← 스테이징용
      case Environment.production:
        return 'be8jif7owm'; // ← 운영용 (실제 배포 시 변경 필요)
      case Environment.githubPages:
        return 'be8jif7owm'; // ← GitHub Pages용 (도메인 등록 후 사용)
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
      case Environment.githubPages:
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
      case Environment.githubPages:
        return false; // GitHub Pages에서는 디버그 비활성화
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
      case Environment.githubPages:
        return 8000;  // 8초 (안정성을 위해 조금 여유있게)
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
      case Environment.githubPages:
        return 12000; // 12초
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
      case Environment.githubPages:
        return false; // GitHub Pages에서도 로깅 비활성화
    }
  }

  /// GitHub Pages 환경인지 확인
  static bool get isGitHubPages => _current == Environment.githubPages;

  /// 웹 환경에서 GitHub Pages 도메인인지 자동 감지
  static void autoDetectEnvironment() {
    try {
      // 웹 환경에서만 실행
      if (identical(0, 0.0)) return; // 이는 항상 false이므로 웹이 아닌 경우 실행 안됨
      
      // 실제 웹 환경 감지 로직은 main.dart에서 처리
    } catch (e) {
      // 웹이 아닌 환경에서는 기본값 유지
    }
  }
}

/// 전역 인스턴스
final environmentConfig = EnvironmentConfig();
