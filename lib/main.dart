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
import 'package:jejunongdi/core/services/websocket_service.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 환경 감지 및 설정
  _detectAndSetEnvironment();

  // 한국어 로케일 데이터 초기화
  await initializeDateFormatting('ko_KR', null);
  print('✅ 한국어 로케일 초기화 완료');

  // Redux Store 초기화
  redux_store.initializeStore();
  print('✅ Redux Store 초기화 완료');

  // WebSocketService에 Redux Store 설정
  WebSocketService.instance.setStore(redux_store.store);
  print('✅ WebSocketService Redux Store 연동 완료');

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
      body: Stack(
        children: [
          // 상단 이미지 영역
          Positioned(
            top: -50, // 상단 이미지 일부를 잘라냄
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.65,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('lib/assets/images/splash_screen_for_nongdi.png'),
                  fit: BoxFit.cover,
                  alignment: Alignment.bottomCenter, // 하단 부분이 보이도록 정렬
                ),
              ),
            ),
          ),
          // 하단 컨텐츠 영역
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.45,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 60),
                child: Column(
                  children: [
                    // 타이틀
                    const Text(
                      '제주 농디',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFF2711C),
                        height: 1.2,
                        letterSpacing: -0.8,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 서브 타이틀
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        '제주 농촌의 기회를 잇다',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFF2711C).withOpacity(0.85),
                          height: 1.3,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),

                    const Spacer(),

                    // 로딩 중일 때
                    if (_isLoading) ...[
                      const CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE8785A)),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        kIsWeb ? '앱을 준비하고 있어요...' : '지도와 권한을 설정하는 중...',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],

                    // 로딩 완료 후 버튼 표시
                    if (_showAuthButtons) ...[
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Column(
                            children: [
                              // Log in 버튼
                              Container(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: () => Navigator.pushNamed(context, '/login'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFF2711C),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(28),
                                    ),
                                  ),
                                  child: const Text(
                                    '로그인',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 8),

                              // 회원가입 버튼
                              Container(
                                width: double.infinity,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(28),
                                  border: Border.all(
                                    color: const Color(0xFFF2711C).withOpacity(0.4),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFF2711C).withOpacity(0.15),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: () => Navigator.pushNamed(context, '/signup'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: const Color(0xFFF2711C),
                                    elevation: 0,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(28),
                                    ),
                                  ),
                                  child: const Text(
                                    '회원가입',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFFF2711C),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthGuard extends StatelessWidget {
  final Widget child;
  const AuthGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AppState>(
      converter: (store) => store.state,
      builder: (context, state) {
        final isAuthenticated = state.userState.isAuthenticated;
        final isLoading = state.userState.isLoading;
        
        if (isAuthenticated) {
          return child;
        } else if (isLoading) {
          // 로딩 중일 때는 로딩 화면 표시
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFFF2711C),
              ),
            ),
          );
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