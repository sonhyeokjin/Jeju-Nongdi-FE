import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:jejunongdi/redux/app_state.dart';
import 'package:jejunongdi/redux/store.dart' as redux_store;
import 'package:jejunongdi/screens/main_navigation.dart';
import 'package:jejunongdi/screens/login_screen.dart';
import 'package:jejunongdi/screens/signup_screen.dart';
import 'package:jejunongdi/core/config/environment.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 환경 감지 및 설정
  _detectAndSetEnvironment();

  // Redux Store 초기화
  redux_store.initializeStore();
  print('✅ Redux Store 초기화 완료');

  // 모바일 환경에서만 네이버 지도 API 키 초기화
  if (!kIsWeb) {
    print('📱 모바일 플랫폼: 네이버 지도 네이티브 SDK 사용');
    await FlutterNaverMap().init(
        clientId: EnvironmentConfig.naverMapClientId,
        onAuthFailed: (ex) => switch (ex) {
          NQuotaExceededException(:final message) =>
              print("사용량 초과 (message: $message)"),
          NUnauthorizedClientException() ||
          NClientUnspecifiedException() ||
          NAnotherAuthFailedException() =>
              print("인증 실패: $ex"),
        });
    print('✅ 네이버 지도 API 키 초기화 완료');
  } else {
    print('🌐 웹 플랫폼: 네이버 정적 지도 이미지 사용');
  }

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

/// 환경 감지 및 설정
void _detectAndSetEnvironment() {
  if (kIsWeb) {
    // 웹 환경에서 GitHub Pages 도메인 감지
    try {
      EnvironmentConfig.setEnvironment(Environment.githubPages);
      print('🌐 GitHub Pages 환경으로 설정됨');
    } catch (e) {
      print('⚠️ 환경 감지 실패, 개발 환경으로 설정: $e');
      EnvironmentConfig.setEnvironment(Environment.development);
    }
  } else {
    // 모바일 환경에서는 기본적으로 개발 환경
    EnvironmentConfig.setEnvironment(Environment.development);
    print('📱 모바일 개발 환경으로 설정됨');
  }
  
  print('현재 환경: ${EnvironmentConfig.current.name}');
  print('네이버맵 Client ID: ${EnvironmentConfig.naverMapClientId}');
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreProvider<AppState>(
      store: redux_store.store,
      child: MaterialApp(
        title: '제주농디',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: const Color(0xFFF2711C), // 감귤색
          scaffoldBackgroundColor: const Color(0xFFFFFFFF),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            foregroundColor: Color(0xFF333333),
          ),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFF2711C),
            brightness: Brightness.light,
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/main': (context) => const AuthGuard(child: MainNavigation()),
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignupScreen(), // 회원가입 라우트 추가
        },
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> 
    with TickerProviderStateMixin {
  bool _isLoading = true;
  bool _showAuthButtons = false;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeApp();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
  }

  Future<void> _initializeApp() async {
    try {
      // 위치 권한 요청
      await _requestPermissions();

      // 스플래시 화면 시간 조정 - 로딩 완료 후 버튼 표시
      Timer(const Duration(milliseconds: 3000), _showAuthenticationButtons);
    } catch (e) {
      print('❌ 앱 초기화 중 오류: $e');
      // 오류가 있어도 앱은 계속 실행
      Timer(const Duration(milliseconds: 3000), _showAuthenticationButtons);
    }
  }

  void _showAuthenticationButtons() {
    if (mounted) {
      setState(() {
        _isLoading = false;
        _showAuthButtons = true;
      });
      _fadeController.forward();
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) _slideController.forward();
      });
    }
  }

  Future<void> _requestPermissions() async {
    try {
      // 웹에서는 권한 요청 건너뛰기
      if (kIsWeb) {
        print('🌐 웹 플랫폼: 권한 요청 건너뜀');
        return;
      }
      
      final permissions = [
        Permission.location,
        Permission.locationWhenInUse,
      ];

      Map<Permission, PermissionStatus> results = await permissions.request();

      results.forEach((permission, status) {
        print('권한 $permission: $status');
      });

      print('✅ 권한 요청 완료');
    } catch (e) {
      print('❌ 권한 요청 실패: $e');
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          // 배경 이미지 사용
          image: DecorationImage(
            image: AssetImage('lib/assets/images/splash_screen_for_nongdi.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          // 이미지 위에 약간의 오버레이 추가 (선택사항)
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withValues(alpha: 0.1),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                
                // 앱 이름 - 하늘색 배경 영역에 자연스럽게 배치
                const Text(
                  '제주 농디',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF2C5530), // 짙은 녹색 (자연스러운 색상)
                    letterSpacing: 2.0,
                    shadows: [
                      Shadow(
                        offset: Offset(0, 2),
                        blurRadius: 8.0,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // 서브 타이틀 - 자연스러운 색상
                const Text(
                  '제주 농촌의 기회를 잇다',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4A7C59), // 중간 녹색
                    letterSpacing: 0.8,
                    shadows: [
                      Shadow(
                        offset: Offset(0, 1),
                        blurRadius: 4.0,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
                
                const Spacer(flex: 3),
                
                // 조건부 렌더링: 로딩 중이면 로딩 애니메이션, 완료되면 인증 버튼들
                if (_isLoading) ...[
                  // 로딩 인디케이터
                  Lottie.asset(
                    'lib/assets/lottie/loading_animation.json',
                    width: 150,
                    height: 220,
                    fit: BoxFit.fill,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // 로딩 메시지 - 자연스러운 색상
                  Text(
                    kIsWeb ? '정적 지도와 권한을 설정하는 중...' : '네이버 지도와 권한을 설정하는 중...',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C5530), // 짙은 녹색
                      letterSpacing: 0.5,
                      shadows: [
                        Shadow(
                          offset: Offset(0, 1),
                          blurRadius: 4.0,
                          color: Colors.white,
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ] else if (_showAuthButtons) ...[
                  // 인증 버튼들
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        children: [
                          // 웰컴 메시지 - 자연스러운 색상
                          const Text(
                            '제주 농디에 오신 것을 환영합니다!',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF2C5530), // 짙은 녹색
                              letterSpacing: 0.8,
                              shadows: [
                                Shadow(
                                  offset: Offset(0, 2),
                                  blurRadius: 6.0,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          
                          const SizedBox(height: 8),
                          
                          const Text(
                            '계속하려면 로그인하거나 회원가입하세요',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF4A7C59), // 중간 녹색
                              letterSpacing: 0.5,
                              shadows: [
                                Shadow(
                                  offset: Offset(0, 1),
                                  blurRadius: 4.0,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          
                          const SizedBox(height: 40),
                          
                          // 로그인 버튼
                          _buildAuthButton(
                            text: '로그인',
                            onPressed: () => Navigator.pushNamed(context, '/login'),
                            isPrimary: true,
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // 회원가입 버튼
                          _buildAuthButton(
                            text: '회원가입',
                            onPressed: () => Navigator.pushNamed(context, '/signup'),
                            isPrimary: false,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAuthButton({
    required String text,
    required VoidCallback onPressed,
    required bool isPrimary,
  }) {
    return Container(
      width: double.infinity,
      height: 56,
      margin: const EdgeInsets.symmetric(horizontal: 40),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary 
              ? const Color(0xFFF2711C)
              : Colors.white.withOpacity(0.9),
          foregroundColor: isPrimary 
              ? Colors.white
              : const Color(0xFFF2711C),
          elevation: isPrimary ? 8 : 4,
          shadowColor: isPrimary 
              ? const Color(0xFFF2711C).withOpacity(0.4)
              : Colors.black.withOpacity(0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: isPrimary 
                ? BorderSide.none
                : const BorderSide(color: Color(0xFFF2711C), width: 2),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: isPrimary 
                ? Colors.white
                : const Color(0xFFF2711C),
          ),
        ),
      ),
    );
  }
}

class AuthGuard extends StatelessWidget {
  final Widget child;
  
  const AuthGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, bool>(
      converter: (store) => store.state.userState.isAuthenticated,
      builder: (context, isAuthenticated) {
        if (isAuthenticated) {
          return child;
        } else {
          // 인증되지 않은 경우 스플래시 화면으로 리다이렉트
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed('/');
          });
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFFF2711C),
              ),
            ),
          );
        }
      },
    );
  }
}