// API 인터셉터들
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jejunongdi/core/utils/logger.dart';
import 'package:jejunongdi/core/network/api_exceptions.dart';

// 인증 인터셉터
class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _secureStorage;
  final Dio _dio;
  
  AuthInterceptor(this._secureStorage, this._dio);
  
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // 회원가입 경로를 백엔드 API에 맞게 변경
    if (options.path == '/auth/signup') {
      options.path = '/auth/signup';
    }
    
    // 인증이 필요 없는 엔드포인트들
    final publicEndpoints = [
      '/auth/login',
      '/api/auth/login',
      '/auth/register',
      '/auth/signup',
      '/api/auth/signup',
      '/auth/refresh',
      '/auth/forgot-password',
    ];
    
    final isPublicEndpoint = publicEndpoints.any((endpoint) => 
        options.path.contains(endpoint));
    
    if (!isPublicEndpoint) {
      final token = await _secureStorage.read(key: 'access_token');
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    
    handler.next(options);
  }
  
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      try {
        // 토큰 갱신 시도
        final refreshToken = await _secureStorage.read(key: 'refresh_token');
        if (refreshToken != null) {
          await _refreshToken();
          
          // 새 토큰으로 원래 요청 재시도
          final accessToken = await _secureStorage.read(key: 'access_token');
          if (accessToken != null) {
            err.requestOptions.headers['Authorization'] = 'Bearer $accessToken';
            
            final clonedRequest = await _dio.fetch(err.requestOptions);
            handler.resolve(clonedRequest);
            return;
          }
        }
      } catch (e) {
        Logger.error('Token refresh failed in interceptor', error: e);
        await _secureStorage.deleteAll();
      }
    }
    
    handler.next(err);
  }
  
  Future<void> _refreshToken() async {
    final refreshToken = await _secureStorage.read(key: 'refresh_token');
    if (refreshToken == null) {
      throw Exception('No refresh token available');
    }
    
    final response = await _dio.post('/auth/refresh', data: {
      'refreshToken': refreshToken,
    });
    
    final newAccessToken = response.data['accessToken'];
    final newRefreshToken = response.data['refreshToken'];
    
    await _secureStorage.write(key: 'access_token', value: newAccessToken);
    if (newRefreshToken != null) {
      await _secureStorage.write(key: 'refresh_token', value: newRefreshToken);
    }
  }
}

// 로깅 인터셉터
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    Logger.debug('Request: ${options.method} ${options.uri}');
    if (options.data != null) {
      Logger.debug('Request Data: ${options.data}');
    }
    handler.next(options);
  }
  
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    Logger.debug('Response: ${response.statusCode} ${response.requestOptions.uri}');
    Logger.debug('Response Data: ${response.data}');
    handler.next(response);
  }
  
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    Logger.error('Error: ${err.message}', error: err);
    handler.next(err);
  }
}

// 에러 인터셉터
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final apiException = _handleError(err);
    handler.reject(DioException(
      requestOptions: err.requestOptions,
      error: apiException,
      response: err.response,
      type: err.type,
    ));
  }
  
  ApiException _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutException('요청 시간이 초과되었습니다. 네트워크 연결을 확인해주세요.');
        
      case DioExceptionType.connectionError:
        return const NetworkException('네트워크 연결에 실패했습니다. 인터넷 연결을 확인해주세요.');
        
      case DioExceptionType.badResponse:
        return _handleResponseError(error.response);
        
      case DioExceptionType.unknown:
      default:
        return const UnknownException('알 수 없는 오류가 발생했습니다.');
    }
  }
  
  ApiException _handleResponseError(Response? response) {
    if (response == null) {
      return const UnknownException('응답을 받을 수 없습니다.');
    }
    
    final statusCode = response.statusCode ?? 0;
    final data = response.data;
    
    String message = '오류가 발생했습니다.';
    String? errorCode;
    
    // 서버에서 온 에러 메시지 파싱
    if (data is Map<String, dynamic>) {
      message = data['message'] ?? data['error'] ?? message;
      errorCode = data['errorCode']?.toString();
    }
    
    switch (statusCode) {
      case 400:
        return BadRequestException(message, errorCode: errorCode);
      case 401:
        return const UnauthorizedException('인증이 필요합니다. 다시 로그인해주세요.');
      case 403:
        return const ForbiddenException('접근 권한이 없습니다.');
      case 404:
        return const NotFoundException('요청한 리소스를 찾을 수 없습니다.');
      case 409:
        return ConflictException(message, errorCode: errorCode);
      case 422:
        return ValidationException(message, errorCode: errorCode);
      case 429:
        return const TooManyRequestsException('너무 많은 요청이 발생했습니다. 잠시 후 다시 시도해주세요.');
      case 500:
        return const ServerException('서버 내부 오류가 발생했습니다.');
      case 502:
      case 503:
      case 504:
        return const ServerException('서버에 일시적인 문제가 발생했습니다. 잠시 후 다시 시도해주세요.');
      default:
        return UnknownException('알 수 없는 오류가 발생했습니다. (코드: $statusCode)');
    }
  }
}

// 캐시 인터셉터 (선택사항)
class CacheInterceptor extends Interceptor {
  final Map<String, CacheItem> _cache = {};
  final Duration maxAge;
  
  CacheInterceptor({this.maxAge = const Duration(minutes: 5)});
  
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (options.method.toUpperCase() == 'GET') {
      final cacheKey = _getCacheKey(options);
      final cacheItem = _cache[cacheKey];
      
      if (cacheItem != null && !cacheItem.isExpired) {
        Logger.debug('📦 Cache hit: ${options.uri}');
        final response = Response(
          requestOptions: options,
          data: cacheItem.data,
          statusCode: 200,
        );
        handler.resolve(response);
        return;
      }
    }
    
    handler.next(options);
  }
  
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (response.requestOptions.method.toUpperCase() == 'GET' && 
        response.statusCode == 200) {
      final cacheKey = _getCacheKey(response.requestOptions);
      _cache[cacheKey] = CacheItem(
        data: response.data,
        expiredAt: DateTime.now().add(maxAge),
      );
      Logger.debug('💾 Cache stored: ${response.requestOptions.uri}');
    }
    
    handler.next(response);
  }
  
  String _getCacheKey(RequestOptions options) {
    return '${options.method}:${options.uri}';
  }
  
  void clearCache() {
    _cache.clear();
    Logger.debug('🗑️ Cache cleared');
  }
}

class CacheItem {
  final dynamic data;
  final DateTime expiredAt;
  
  CacheItem({required this.data, required this.expiredAt});
  
  bool get isExpired => DateTime.now().isAfter(expiredAt);
}
