// 인증 서비스
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jejunongdi/core/network/api_client.dart';
import 'package:jejunongdi/core/network/api_exceptions.dart';
import 'package:jejunongdi/core/utils/logger.dart';
import 'package:jejunongdi/redux/user/user_model.dart' as user_model;
import 'package:jejunongdi/core/models/auth_models.dart' as auth_models;

class AuthService {
  static AuthService? _instance;
  final ApiClient _apiClient = ApiClient.instance;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  static AuthService get instance {
    _instance ??= AuthService._internal();
    return _instance!;
  }
  
  AuthService._internal();
  
  // 로그인
  Future<ApiResult<user_model.AuthResponse>> login({
    required String email,
    required String password,
  }) async {
    try {
      Logger.info('로그인 시도: $email');
      
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );
      
      if (response.data != null) {
        // 서버 응답을 먼저 파싱
        final serverResponse = auth_models.ServerAuthResponse.fromJson(response.data!);
        
        // UserRole 변환
        user_model.UserRole userRole;
        switch (serverResponse.role.toUpperCase()) {
          case 'USER':
          case 'WORKER':
            userRole = user_model.UserRole.worker;
            break;
          case 'ADMIN':
          case 'MASTER':
            userRole = user_model.UserRole.master;
            break;
          default:
            userRole = user_model.UserRole.worker;
        }
        
        // User 모델 생성
        final user = user_model.User(
          id: serverResponse.email, // 서버에서 id를 제공하지 않으므로 email을 사용
          email: serverResponse.email,
          name: serverResponse.name,
          nickname: serverResponse.nickname,
          role: userRole,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        // AuthResponse 생성
        final authResponse = user_model.AuthResponse(
          user: user,
          accessToken: serverResponse.token,
          refreshToken: null, // 서버에서 refresh token을 제공하지 않음
          expiresIn: 86400, // 24시간 기본값
        );
        
        // 토큰 저장
        await _saveTokens(
          accessToken: authResponse.accessToken,
          refreshToken: authResponse.refreshToken,
        );
        
        // 사용자 정보 저장
        await _saveUserInfo(authResponse.user);
        
        Logger.info('로그인 성공: ${authResponse.user.email}');
        return ApiResult.success(authResponse);
      } else {
        return ApiResult.failure(const UnknownException('로그인 응답 데이터가 없습니다.'));
      }
    } catch (e) {
      Logger.error('로그인 실패', error: e);
      if (e is ApiException) {
        return ApiResult.failure(e);
      } else {
        return ApiResult.failure(UnknownException('로그인 중 오류가 발생했습니다: $e'));
      }
    }
  }
  
  // 회원가입
  Future<ApiResult<user_model.AuthResponse>> register(auth_models.SignupRequest request) async {
    try {
      Logger.info('회원가입 시도: ${request.email}');

      final response = await _apiClient.post<Map<String, dynamic>>(
        '/api/auth/signup',
        data: request.toJson(),
      );

      if (response.data != null) {
        // 서버 응답을 먼저 파싱
        final serverResponse = auth_models.ServerAuthResponse.fromJson(response.data!);

        // UserRole 변환
        user_model.UserRole userRole;
        switch (serverResponse.role.toUpperCase()) {
          case 'USER':
          case 'WORKER':
            userRole = user_model.UserRole.worker;
            break;
          case 'ADMIN':
          case 'MASTER':
            userRole = user_model.UserRole.master;
            break;
          default:
            userRole = user_model.UserRole.worker;
        }

        // User 모델 생성
        final user = user_model.User(
          id: serverResponse.email, // 서버에서 id를 제공하지 않으므로 email을 사용
          email: serverResponse.email,
          name: serverResponse.name,
          nickname: serverResponse.nickname,
          role: userRole,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // AuthResponse 생성
        final authResponse = user_model.AuthResponse(
          user: user,
          accessToken: serverResponse.token,
          refreshToken: null, // 서버에서 refresh token을 제공하지 않음
          expiresIn: 86400, // 24시간 기본값
        );

        // 토큰 저장
        await _saveTokens(
          accessToken: authResponse.accessToken,
          refreshToken: authResponse.refreshToken,
        );

        // 사용자 정보 저장
        await _saveUserInfo(authResponse.user);

        Logger.info('회원가입 성공: ${authResponse.user.email}');
        return ApiResult.success(authResponse);
      } else {
        return ApiResult.failure(const UnknownException('회원가입 응답 데이터가 없습니다.'));
      }
    } catch (e) {
      Logger.error('회원가입 실패', error: e);
      if (e is ApiException) {
        return ApiResult.failure(e);
      } else {
        return ApiResult.failure(UnknownException('회원가입 중 오류가 발생했습니다: $e'));
      }
    }
  }
  
  // 로그아웃
  Future<ApiResult<void>> logout() async {
    try {
      Logger.info('로그아웃 시도');
      
      // 서버에 로그아웃 요청
      try {
        await _apiClient.post('/auth/logout');
      } catch (e) {
        // 서버 요청 실패해도 로컬에서는 토큰 삭제
        Logger.warning('서버 로그아웃 요청 실패', error: e);
      }
      
      // 로컬 토큰 및 사용자 정보 삭제
      await _clearAuthData();
      
      Logger.info('로그아웃 완료');
      return ApiResult.success(null);
    } catch (e) {
      Logger.error('로그아웃 실패', error: e);
      return ApiResult.failure(UnknownException('로그아웃 중 오류가 발생했습니다: $e'));
    }
  }
  
  // 토큰 갱신
  Future<ApiResult<user_model.AuthResponse>> refreshToken() async {
    try {
      Logger.info('토큰 갱신 시도');
      
      final refreshToken = await _secureStorage.read(key: 'refresh_token');
      if (refreshToken == null) {
        return ApiResult.failure(const UnauthorizedException('리프레시 토큰이 없습니다.'));
      }
      
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {
          'refreshToken': refreshToken,
        },
      );
      
      if (response.data != null) {
        final authResponse = user_model.AuthResponse.fromJson(response.data!);
        
        // 새 토큰 저장
        await _saveTokens(
          accessToken: authResponse.accessToken,
          refreshToken: authResponse.refreshToken,
        );
        
        // 사용자 정보 업데이트
        await _saveUserInfo(authResponse.user);
        
        Logger.info('토큰 갱신 성공');
        return ApiResult.success(authResponse);
      } else {
        return ApiResult.failure(const UnknownException('토큰 갱신 응답 데이터가 없습니다.'));
      }
    } catch (e) {
      Logger.error('토큰 갱신 실패', error: e);
      
      // 토큰 갱신 실패 시 로그아웃 처리
      await _clearAuthData();
      
      if (e is ApiException) {
        return ApiResult.failure(e);
      } else {
        return ApiResult.failure(UnknownException('토큰 갱신 중 오류가 발생했습니다: $e'));
      }
    }
  }
  
  // 현재 사용자 정보 조회
  Future<ApiResult<user_model.User>> getCurrentUser() async {
    try {
      Logger.info('현재 사용자 정보 조회');
      
      final response = await _apiClient.get<Map<String, dynamic>>('/auth/me');
      
      if (response.data != null) {
        final user = user_model.User.fromJson(response.data!);
        
        // 로컬에 사용자 정보 업데이트
        await _saveUserInfo(user);
        
        Logger.info('사용자 정보 조회 성공: ${user.email}');
        return ApiResult.success(user);
      } else {
        return ApiResult.failure(const UnknownException('사용자 정보 응답 데이터가 없습니다.'));
      }
    } catch (e) {
      Logger.error('사용자 정보 조회 실패', error: e);
      if (e is ApiException) {
        return ApiResult.failure(e);
      } else {
        return ApiResult.failure(UnknownException('사용자 정보 조회 중 오류가 발생했습니다: $e'));
      }
    }
  }
  
  // 비밀번호 변경
  Future<ApiResult<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      Logger.info('비밀번호 변경 시도');
      
      await _apiClient.put('/auth/change-password', data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      });
      
      Logger.info('비밀번호 변경 성공');
      return ApiResult.success(null);
    } catch (e) {
      Logger.error('비밀번호 변경 실패', error: e);
      if (e is ApiException) {
        return ApiResult.failure(e);
      } else {
        return ApiResult.failure(UnknownException('비밀번호 변경 중 오류가 발생했습니다: $e'));
      }
    }
  }
  
  // 비밀번호 재설정 요청
  Future<ApiResult<void>> requestPasswordReset(String email) async {
    try {
      Logger.info('비밀번호 재설정 요청: $email');
      
      await _apiClient.post('/auth/forgot-password', data: {
        'email': email,
      });
      
      Logger.info('비밀번호 재설정 요청 성공');
      return ApiResult.success(null);
    } catch (e) {
      Logger.error('비밀번호 재설정 요청 실패', error: e);
      if (e is ApiException) {
        return ApiResult.failure(e);
      } else {
        return ApiResult.failure(UnknownException('비밀번호 재설정 요청 중 오류가 발생했습니다: $e'));
      }
    }
  }
  
  // 이메일 중복 확인
  Future<ApiResult<bool>> checkEmailAvailability(String email) async {
    try {
      Logger.info('이메일 중복 확인: $email');
      
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/auth/check-email',
        queryParameters: {'email': email},
      );
      
      final isAvailable = response.data?['available'] ?? false;
      
      Logger.info('이메일 중복 확인 결과: $isAvailable');
      return ApiResult.success(isAvailable);
    } catch (e) {
      Logger.error('이메일 중복 확인 실패', error: e);
      if (e is ApiException) {
        return ApiResult.failure(e);
      } else {
        return ApiResult.failure(UnknownException('이메일 중복 확인 중 오류가 발생했습니다: $e'));
      }
    }
  }
  
  // 로그인 상태 확인
  Future<bool> isLoggedIn() async {
    try {
      final accessToken = await _secureStorage.read(key: 'access_token');
      final userInfo = await _secureStorage.read(key: 'user_info');
      
      return accessToken != null && userInfo != null;
    } catch (e) {
      Logger.error('로그인 상태 확인 실패', error: e);
      return false;
    }
  }
  
  // 저장된 사용자 정보 조회
  Future<user_model.User?> getSavedUserInfo() async {
    try {
      final userInfoJson = await _secureStorage.read(key: 'user_info');
      if (userInfoJson != null) {
        final userInfoMap = Map<String, dynamic>.from(
          jsonDecode(userInfoJson)
        );
        return user_model.User.fromJson(userInfoMap);
      }
      return null;
    } catch (e) {
      Logger.error('저장된 사용자 정보 조회 실패', error: e);
      return null;
    }
  }
  
  // 토큰 저장
  Future<void> _saveTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    await _secureStorage.write(key: 'access_token', value: accessToken);
    if (refreshToken != null) {
      await _secureStorage.write(key: 'refresh_token', value: refreshToken);
    }
  }
  
  // 사용자 정보 저장
  Future<void> _saveUserInfo(user_model.User user) async {
    final userInfoJson = jsonEncode(user.toJson());
    await _secureStorage.write(key: 'user_info', value: userInfoJson);
  }
  
  // 인증 데이터 삭제
  Future<void> _clearAuthData() async {
    await _secureStorage.delete(key: 'access_token');
    await _secureStorage.delete(key: 'refresh_token');
    await _secureStorage.delete(key: 'user_info');
  }
}
