// lib/main.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:jejunongdi/features/home/home_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 앱이 시작될 때 단 한 번만, Javascript 키로 인증을 초기화합니다.
  AuthRepository.initialize(appKey: '752d47c1d500b05f00d22e33448215a9');

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
    return MaterialApp(
      title: '제주 농디',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // 앱의 기본 색상은 깔끔한 흰색 테마로 되돌립니다.
        primaryColor: const Color(0xFFF2711C), // 진한 감귤색 (버튼 등에서 사용)
        scaffoldBackgroundColor: const Color(0xFFFFFFFF), // 기본 배경 흰색
        fontFamily: 'G굵은둥근모', // 앱의 기본 폰트를 지정할 수도 있습니다.
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Color(0xFF333333),
        ),
      ),
      home: const SplashScreen(),
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
    Timer(const Duration(milliseconds: 1500), navigateToHome);
  }

  void navigateToHome() {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'lib/assets/images/splash_screen_for_nongdi.png',
            fit: BoxFit.cover,
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 80.0),
                // [수정] 텍스트 위젯들을 Column으로 묶어 세로로 배치합니다.
                child: Column(
                  mainAxisSize: MainAxisSize.min, // 내용만큼만 크기 차지
                  children: [
                    // 기존 앱 이름
                    Text(
                      '제주 농디🍊',
                      style: TextStyle(
                        fontFamily: 'G굵은둥근모',
                        fontSize: 64,
                        color: Colors.black.withOpacity(0.75),
                        shadows: const [
                          Shadow(blurRadius: 8.0, color: Colors.white)
                        ],
                      ),
                    ),
                    const SizedBox(height: 8), // 이름과 설명 사이의 간격

                    // [신규] 앱 설명 텍스트
                    Text(
                      '제주 농촌의 기회를 잇다',
                      style: TextStyle(
                        fontFamily: 'G굵은둥근모',
                        fontSize: 32,
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
        ],
      ),
    );
  }
}