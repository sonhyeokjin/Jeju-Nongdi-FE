// API 클라이언트 - Dio 기반
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jejunongdi/core/config/environment.dart';
import 'package:jejunongdi/core/network/api_interceptors.dart';
import 'package:jejunongdi/core/utils/logger.dart';

class ApiClient {
  static ApiClient? _instance;
  late Dio _dio;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  static ApiClient get instance {
    _instance ??= ApiClient._internal();
    return _instance!;
  }
  
  ApiClient._internal() {
    _dio = Dio();
    _setupDio();
  }
  
  // Dio 설정
  void _setupDio() {
    _dio.options = BaseOptions(
      baseUrl: EnvironmentConfig.apiBaseUrl,
      connectTimeout: Duration(milliseconds: EnvironmentConfig.connectTimeout),
      receiveTimeout: Duration(milliseconds: EnvironmentConfig.receiveTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    
    // 인터셉터 추가
    _dio.interceptors.add(AuthInterceptor(_secureStorage, _dio));
    _dio.interceptors.add(LoggingInterceptor());
    _dio.interceptors.add(ErrorInterceptor());
    
    // 개발 환경에서만 로그 인터셉터 추가
    if (EnvironmentConfig.isDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: false,
        error: true,
      ));
    }
  }
  
  // GET 요청
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      Logger.apiRequest('GET', path);
      
      final response = await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      
      Logger.apiResponse('GET', path, response.statusCode ?? 0, data: response.data);
      return response;
    } catch (e) {
      Logger.error('GET request failed: $path', error: e);
      rethrow;
    }
  }
  
  // POST 요청
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      Logger.apiRequest('POST', path, data: data);
      
      final response = await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      
      Logger.apiResponse('POST', path, response.statusCode ?? 0, data: response.data);
      return response;
    } catch (e) {
      Logger.error('POST request failed: $path', error: e);
      rethrow;
    }
  }
  
  // PUT 요청
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      Logger.apiRequest('PUT', path, data: data);
      
      final response = await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      
      Logger.apiResponse('PUT', path, response.statusCode ?? 0, data: response.data);
      return response;
    } catch (e) {
      Logger.error('PUT request failed: $path', error: e);
      rethrow;
    }
  }
  
  // DELETE 요청
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      Logger.apiRequest('DELETE', path, data: data);
      
      final response = await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      
      Logger.apiResponse('DELETE', path, response.statusCode ?? 0, data: response.data);
      return response;
    } catch (e) {
      Logger.error('DELETE request failed: $path', error: e);
      rethrow;
    }
  }
  
  // PATCH 요청
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      Logger.apiRequest('PATCH', path, data: data);
      
      final response = await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      
      Logger.apiResponse('PATCH', path, response.statusCode ?? 0, data: response.data);
      return response;
    } catch (e) {
      Logger.error('PATCH request failed: $path', error: e);
      rethrow;
    }
  }
  
  // 파일 업로드
  Future<Response<T>> uploadFile<T>(
    String path,
    String filePath, {
    String fieldName = 'file',
    Map<String, dynamic>? data,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      final formData = FormData.fromMap({
        ...?data,
        fieldName: await MultipartFile.fromFile(filePath),
      });
      
      Logger.apiRequest('POST', path, data: {'file': filePath});
      
      final response = await _dio.post<T>(
        path,
        data: formData,
        onSendProgress: onSendProgress,
      );
      
      Logger.apiResponse('POST', path, response.statusCode ?? 0);
      return response;
    } catch (e) {
      Logger.error('File upload failed: $path', error: e);
      rethrow;
    }
  }
  
  // 파일 다운로드
  Future<Response> downloadFile(
    String path,
    String savePath, {
    ProgressCallback? onReceiveProgress,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      Logger.apiRequest('GET', path);
      
      final response = await _dio.download(
        path,
        savePath,
        queryParameters: queryParameters,
        onReceiveProgress: onReceiveProgress,
      );
      
      Logger.apiResponse('GET', path, response.statusCode ?? 0);
      return response;
    } catch (e) {
      Logger.error('File download failed: $path', error: e);
      rethrow;
    }
  }
  
  // 토큰 갱신
  Future<void> refreshToken() async {
    try {
      final refreshToken = await _secureStorage.read(key: 'refresh_token');
      if (refreshToken == null) {
        throw Exception('No refresh token found');
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
      
      Logger.info('Token refreshed successfully');
    } catch (e) {
      Logger.error('Token refresh failed', error: e);
      await _secureStorage.deleteAll();
      rethrow;
    }
  }
  
  // 토큰 가져오기
  Future<String?> getToken() async {
    try {
      return await _secureStorage.read(key: 'access_token');
    } catch (e) {
      Logger.error('Failed to get token', error: e);
      return null;
    }
  }
  
  // Dio 인스턴스 직접 접근 (필요한 경우)
  Dio get dio => _dio;
}
