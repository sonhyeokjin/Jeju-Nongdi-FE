import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:jejunongdi/redux/app_state.dart';
import 'package:jejunongdi/redux/user/user_state.dart';
import 'package:jejunongdi/features/home/home_screen.dart';
import 'package:jejunongdi/screens/login_screen.dart';
import 'package:jejunongdi/screens/mentoring_list_screen.dart';
import 'package:jejunongdi/screens/chat_screen.dart';
import 'package:jejunongdi/screens/my_page_screen.dart';
import 'package:jejunongdi/screens/chat_list_screen.dart';
import 'package:jejunongdi/screens/idle_farmland_list_screen.dart';
import 'package:jejunongdi/screens/ai_tips_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  // GNav 위젯을 강제로 새로고침하기 위한 Key입니다.
  Key _bottomNavKey = UniqueKey();

  /// 탭 변경 이벤트를 처리하는 비동기 함수입니다.
  Future<void> _handleTabChange(int index) async {
    final userState = StoreProvider.of<AppState>(context, listen: false).state.userState;

    // 'MY농디' 탭(인덱스 3)을 눌렀고, 로그인이 되어있지 않은 경우
    if (index == 3 && !userState.isAuthenticated) {
      // 로그인 화면으로 이동하고, 화면이 닫힐 때까지 기다립니다.
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );

      // 로그인 화면에서 돌아온 후, Key를 변경하여 GNav 위젯을 강제로 다시 그리도록 합니다.
      // 이렇게 하면 GNav의 내부 시각적 상태가 초기화되고, _currentIndex를 정확히 따르게 됩니다.
      setState(() {
        _bottomNavKey = UniqueKey();
      });
    } else {
      // 그 외의 경우에는 정상적으로 탭 상태를 변경합니다.
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, UserState>(
      converter: (store) => store.state.userState,
      // Redux 스토어의 인증 상태가 변경될 때마다 UI를 업데이트합니다.
      onWillChange: (previousState, newState) {
        // 1. 로그인 성공 시: 'MY농디' 탭으로 이동
        if (previousState?.isAuthenticated == false && newState.isAuthenticated) {
          setState(() {
            _currentIndex = 3;
          });
        }
        // 2. 로그아웃 성공 시: '홈' 탭으로 이동
        else if (previousState?.isAuthenticated == true && newState.isAuthenticated == false) {
          // 사용자가 로그인이 필요한 페이지에 있었다면 홈으로 보냅니다.
          if (_currentIndex == 3) {
            setState(() {
              _currentIndex = 0;
            });
          }
        }
      },
      builder: (context, userState) {
        return Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: [
              const HomeScreen(),
              const MentoringListScreen(),
              const ChatListScreen(),
              // MY농디 탭: 로그인 상태에 따라 다른 화면 표시
              userState.isAuthenticated
                  ? const MyPageScreen()
                  : Container(
                color: const Color(0xFFF8F9FA),
                child: const Center(
                  child: Text(
                    '로그인이 필요한 서비스입니다',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: SafeArea(
              child: GNav(
                // Key를 위젯에 할당합니다.
                key: _bottomNavKey,
                gap: 3,
                activeColor: Colors.white,
                iconSize: 24,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                duration: const Duration(milliseconds: 400),
                tabBackgroundColor: const Color(0xFFF2711C),
                color: Colors.grey[600],
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  fontFamily: 'Pretendard',
                  letterSpacing: -0.2,
                ),
                tabs: [
                  GButton(
                    icon: FontAwesomeIcons.house,
                    text: '밭터오라',
                  ),
                  GButton(
                    icon: FontAwesomeIcons.clipboardList,
                    text: '말벗방',
                  ),
                  GButton(
                    icon: FontAwesomeIcons.solidCommentDots,
                    text: '궁시렁',
                  ),
                  GButton(
                    icon: userState.isAuthenticated
                        ? FontAwesomeIcons.solidUser
                        : FontAwesomeIcons.user,
                    text: 'MY농디',
                  ),
                ],
                selectedIndex: _currentIndex,
                // onTabChange는 새로 만든 비동기 함수를 호출합니다.
                onTabChange: _handleTabChange,
              ),
            ),
          ),
        );
      },
    );
  }
}
