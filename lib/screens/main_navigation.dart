import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:jejunongdi/redux/app_state.dart';
import 'package:jejunongdi/redux/user/user_state.dart';
import 'package:jejunongdi/features/home/home_screen.dart';
import 'package:jejunongdi/screens/login_screen.dart';
import 'package:jejunongdi/screens/my_activities_screen.dart';
import 'package:jejunongdi/screens/chat_screen.dart';
import 'package:jejunongdi/screens/my_page_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, UserState>(
      converter: (store) => store.state.userState,
      builder: (context, userState) {
        return Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: [
              const HomeScreen(),
              const MyActivitiesScreen(),
              const ChatScreen(),
              // MY농디 탭: 로그인 상태에 따라 다른 화면 표시
              userState.isAuthenticated 
                  ? const MyPageScreen() 
                  : const LoginScreen(),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _currentIndex,
            onTap: (index) {
              // MY농디 탭(index 3) 클릭 시 로그인 상태 확인
              if (index == 3 && !userState.isAuthenticated) {
                // 로그인되지 않은 상태에서 MY농디 탭 클릭 시 로그인 화면으로 이동
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                );
                return;
              }
              
              setState(() {
                _currentIndex = index;
              });
            },
            selectedItemColor: const Color(0xFFF2711C),
            unselectedItemColor: Colors.grey,
            backgroundColor: Colors.white,
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home_filled),
                label: '홈',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.list_alt),
                label: '내 활동',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.chat_bubble_outline),
                label: '채팅',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  userState.isAuthenticated 
                      ? Icons.person 
                      : Icons.person_outline,
                ),
                label: 'MY농디',
              ),
            ],
          ),
        );
      },
    );
  }
}
