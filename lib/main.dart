import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:jejunongdi/redux/app_state.dart';
import 'package:jejunongdi/redux/store.dart' as redux_store;
import 'package:jejunongdi/features/home/home_screen.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Redux Store 초기화
  redux_store.initializeStore();
  print('✅ Redux Store 초기화 완료');

  // 카카오맵 초기화 (에러 처리 포함)
  try {
    AuthRepository.initialize(appKey: '752d47c1d500b05f00d22e33448215a9');
    print('✅ 카카오맵 초기화 완료');
  } catch (e) {
    print('❌ 카카오맵 초기화 실패: $e');
    // 초기화 실패해도 앱은 계속 실행
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreProvider<AppState>(
      store: redux_store.store,
      child: MaterialApp(
        title: '제주농디',
        debugShowCheckedModeBanner: false, // 디버그 배너 제거
        theme: ThemeData(
          // 앱의 기본 색상은 깔끔한 흰색 테마로 되돌립니다.
          primaryColor: const Color(0xFFF2711C), // 진한 감귤색 (버튼 등에서 사용)
          scaffoldBackgroundColor: const Color(0xFFFFFFFF), // 기본 배경 흰색
          // fontFamily: 'G굵은둥근모', // 폰트 파일이 없어서 주석 처리
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            foregroundColor: Color(0xFF333333),
          ),
        ),
        home: const SplashScreen(),
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
    // 위치 권한 요청
    await _requestPermissions();
    
    // 스플래시 화면 시간을 좀 더 늘려서 카카오맵 초기화 시간 확보
    Timer(const Duration(milliseconds: 2000), navigateToHome);
  }

  Future<void> _requestPermissions() async {
    try {
      final permissions = [
        Permission.location,
        Permission.locationWhenInUse,
      ];
      
      await permissions.request();
      print('✅ 권한 요청 완료');
    } catch (e) {
      print('❌ 권한 요청 실패: $e');
    }
  }

  void navigateToHome() {
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 스플래시 배경 이미지
          Image.asset(
            'lib/assets/images/splash_screen_for_nongdi.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              // 이미지 로드 실패 시 대체 화면
              return Container(
                color: const Color(0xFFF2711C),
                child: const Center(
                  child: Text(
                    '제주 농디🍊',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            },
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 80.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 기존 앱 이름
                    Text(
                      '제주 농디🍊',
                      style: TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.bold,
                        color: Colors.black.withOpacity(0.75),
                        shadows: const [
                          Shadow(blurRadius: 8.0, color: Colors.white)
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // [신규] 앱 설명 텍스트
                    Text(
                      '제주 농촌의 기회를 잇다',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                        color: Colors.black.withOpacity(0.6),
                        shadows: const [
                          Shadow(blurRadius: 8.0, color: Colors.white)
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // 로딩 인디케이터 추가
          const Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF2711C)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
