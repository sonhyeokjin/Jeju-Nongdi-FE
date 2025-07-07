import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
          bottomNavigationBar: Transform.translate(
            offset: const Offset(0.0, -20.0), // Adjusted vertical offset
            child: Padding( // Added Padding for horizontal adjustment
              padding: const EdgeInsets.symmetric(horizontal: 20.0), // Adjust this value for horizontal size
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 20,
                      color: Colors.black.withOpacity(.1),
                    )
                  ],
                  borderRadius: BorderRadius.circular(20.0), // All corners rounded
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
                  child: GNav(
                    gap: 8,
                    activeColor: Colors.white,
                    iconSize: 24,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    duration: const Duration(milliseconds: 400),
                    tabBackgroundColor: const Color(0xFFF2711C), // Accent color for selected tab
                    color: Colors.grey[600], // Unselected icon color
                    tabs: [
                      GButton(
                        icon: FontAwesomeIcons.house,
                        text: '홈',
                      ),
                      GButton(
                        icon: FontAwesomeIcons.clipboardList,
                        text: '내 활동',
                      ),
                      GButton(
                        icon: FontAwesomeIcons.solidCommentDots,
                        text: '채팅',
                      ),
                      GButton(
                        icon: userState.isAuthenticated
                            ? FontAwesomeIcons.solidUser
                            : FontAwesomeIcons.user,
                        text: 'MY농디',
                      ),
                    ],
                    selectedIndex: _currentIndex,
                    onTabChange: (index) {
                      if (index == 3 && !userState.isAuthenticated) {
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
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
