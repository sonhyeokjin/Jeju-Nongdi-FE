import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jejunongdi/redux/app_state.dart';
import 'package:jejunongdi/redux/store.dart' as redux_store;
import 'package:jejunongdi/screens/main_navigation.dart';
import 'package:jejunongdi/screens/login_screen.dart';
import 'package:jejunongdi/core/config/environment.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Redux Store 초기화
  redux_store.initializeStore();
  print('✅ Redux Store 초기화 완료');

  // 카카오맵 API 키 초기화
  try {
    AuthRepository.initialize(appKey: EnvironmentConfig.kakaoMapApiKey);
    print('✅ 카카오맵 API 키 초기화 완료: ${EnvironmentConfig.kakaoMapApiKey}');
  } catch (e) {
    print('❌ 카카오맵 API 키 초기화 실패: $e');
  }

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
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
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 3,
                ),
                
                const SizedBox(height: 20),
                
                // 로딩 메시지
                const Text(
                  '지도와 권한을 설정하는 중...',
                  style: TextStyle(
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