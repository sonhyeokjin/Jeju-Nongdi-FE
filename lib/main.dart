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
          '/main': (context) => const MainNavigation(),
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

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // 위치 권한 요청
      await _requestPermissions();

      // 스플래시 화면 시간 조정
      Timer(const Duration(milliseconds: 3000), _navigateToMain);
    } catch (e) {
      print('❌ 앱 초기화 중 오류: $e');
      // 오류가 있어도 앱은 계속 실행
      Timer(const Duration(milliseconds: 3000), _navigateToMain);
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

  void _navigateToMain() {
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/main');
    }
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
                Colors.black.withOpacity(0.1),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                
                // 로고 영역 (이미지에 이미 포함되어 있다면 생략 가능)
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      '🍊',
                      style: TextStyle(fontSize: 50),
                    ),
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // 앱 이름
                const Text(
                  '제주 농디',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.black54,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // 서브 타이틀
                const Text(
                  '제주 농촌의 기회를 잇다',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 8.0,
                        color: Colors.black54,
                      ),
                    ],
                  ),
                ),
                
                const Spacer(flex: 3),
                
                // 로딩 인디케이터
                Lottie.asset(
                  'lib/assets/lottie/loading_animation.json',
                  width: 150,
                  height: 220,
                  fit: BoxFit.fill,
                ),
                
                const SizedBox(height: 20),
                
                // 로딩 메시지
                Text(
                  kIsWeb ? '정적 지도와 권한을 설정하는 중...' : '네이버 지도와 권한을 설정하는 중...',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 5.0,
                        color: Colors.black54,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }
}