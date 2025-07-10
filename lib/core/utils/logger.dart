// 로깅 시스템
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:jejunongdi/core/config/environment.dart';

enum LogLevel {
  debug,
  info,
  warning,
  error,
  fatal,
}

class Logger {
  static const String _name = 'JejuNongdi';
  
  // 로그 레벨별 색상 코드 (디버그 콘솔용)
  static const String _resetColor = '\x1B[0m';
  static const String _debugColor = '\x1B[37m'; // White
  static const String _infoColor = '\x1B[36m'; // Cyan
  static const String _warningColor = '\x1B[33m'; // Yellow
  static const String _errorColor = '\x1B[31m'; // Red
  static const String _fatalColor = '\x1B[35m'; // Magenta
  
  // Debug 로그
  static void debug(String message, {Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.debug, message, error: error, stackTrace: stackTrace);
  }
  
  // Info 로그
  static void info(String message, {Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.info, message, error: error, stackTrace: stackTrace);
  }
  
  // Warning 로그
  static void warning(String message, {Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.warning, message, error: error, stackTrace: stackTrace);
  }
  
  // Error 로그
  static void error(String message, {Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.error, message, error: error, stackTrace: stackTrace);
  }
  
  // Fatal 로그
  static void fatal(String message, {Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.fatal, message, error: error, stackTrace: stackTrace);
  }
  
  // API 요청 로그
  static void apiRequest(String method, String url, {Map<String, dynamic>? data}) {
    if (!EnvironmentConfig.enableLogging) return;
    
    final message = '🌐 API Request: $method $url';
    debug(message);
    
    if (data != null && data.isNotEmpty) {
      debug('📤 Request Data: $data');
    }
  }
  
  // API 응답 로그
  static void apiResponse(String method, String url, int statusCode, {dynamic data}) {
    if (!EnvironmentConfig.enableLogging) return;
    
    final emoji = statusCode >= 200 && statusCode < 300 ? '✅' : '❌';
    final message = '$emoji API Response: $method $url [$statusCode]';
    
    if (statusCode >= 200 && statusCode < 300) {
      info(message);
    } else {
      error(message);
    }
    
    if (data != null) {
      debug('📥 Response Data: $data');
    }
  }
  
  // Redux Action 로그
  static void reduxAction(String actionType, {dynamic payload}) {
    if (!EnvironmentConfig.enableLogging) return;
    
    debug('🔄 Redux Action: $actionType ${payload != null ? '- Payload: $payload' : ''}');
  }
  
  // Navigation 로그
  static void navigation(String route, {Map<String, dynamic>? arguments}) {
    if (!EnvironmentConfig.enableLogging) return;
    
    final message = '🧭 Navigation: $route';
    info(message);
    
    if (arguments != null && arguments.isNotEmpty) {
      debug('📦 Arguments: $arguments');
    }
  }
  
  // 내부 로그 처리 메서드
  static void _log(
    LogLevel level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    // 로깅이 비활성화된 경우 무시
    if (!EnvironmentConfig.enableLogging) return;
    
    // 프로덕션에서는 debug 로그 제외
    if (level == LogLevel.debug && EnvironmentConfig.current == Environment.production) {
      return;
    }
    
    final timestamp = DateTime.now().toIso8601String();
    final levelString = level.name.toUpperCase();
    
    // 색상 코드 적용 (디버그 모드에서만)
    String colorCode = '';
    if (kDebugMode) {
      switch (level) {
        case LogLevel.debug:
          colorCode = _debugColor;
          break;
        case LogLevel.info:
          colorCode = _infoColor;
          break;
        case LogLevel.warning:
          colorCode = _warningColor;
          break;
        case LogLevel.error:
          colorCode = _errorColor;
          break;
        case LogLevel.fatal:
          colorCode = _fatalColor;
          break;
      }
    }
    
    final formattedMessage = '$colorCode[$timestamp] [$levelString] $_name: $message$_resetColor';
    
    // Flutter의 developer.log 사용
    developer.log(
      formattedMessage,
      name: _name,
      level: _getLogLevel(level),
      error: error,
      stackTrace: stackTrace,
    );
    
    // 프로덕션에서는 외부 로깅 서비스로 전송 (예: Firebase Crashlytics, Sentry 등)
    if (EnvironmentConfig.current == Environment.production) {
      _sendToExternalLoggingService(level, message, error, stackTrace);
    }
  }
  
  // 로그 레벨을 Flutter의 로그 레벨로 변환
  static int _getLogLevel(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return 500;
      case LogLevel.info:
        return 800;
      case LogLevel.warning:
        return 900;
      case LogLevel.error:
        return 1000;
      case LogLevel.fatal:
        return 1200;
    }
  }
  
  // 외부 로깅 서비스로 전송 (프로덕션 환경)
  static void _sendToExternalLoggingService(
    LogLevel level,
    String message,
    Object? error,
    StackTrace? stackTrace,
  ) {
    // TODO: Firebase Crashlytics, Sentry 등 외부 로깅 서비스 연동
    // 예시:
    // if (level == LogLevel.error || level == LogLevel.fatal) {
    //   FirebaseCrashlytics.instance.recordError(error ?? message, stackTrace);
    // }
  }
}
