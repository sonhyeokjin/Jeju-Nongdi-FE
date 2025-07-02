import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jejunongdi/features/home/home_screen.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:permission_handler/permission_handler.dart';


Future<void> main() async { // async 키워드 추가
  WidgetsFlutterBinding.ensureInitialized(); // Flutter 엔진 초기화 보장
  await NaverMapSdk.instance.initialize( // 네이버 지도 SDK 초기화
      clientId: 'dbf70fdp3p', // Client ID
      onAuthFailed: (ex) {
        print("********* 네이버맵 인증오류 : $ex *********");
      });

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
      title: '제주농디',
      theme: ThemeData(
        primaryColor: const Color(0xFFFF8A3D),
        scaffoldBackgroundColor: const Color(0xFFF7F6F2),
        fontFamily: 'Pretendard',
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
    _requestPermission();
  }

  Future<void> _requestPermission() async {
    await [
      Permission.location,
    ].request();

    navigateToHome();
  }

  void navigateToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const HomeScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          'lib/assets/images/splash_screen_for_nongdi.png',
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      ),
    );
  }
}
