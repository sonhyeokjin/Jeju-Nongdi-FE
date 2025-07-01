import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';ㅇ

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // [상단] 앱 바 (로고, 내 위치, 알림)
      appBar: AppBar(
        title: const Text(
          '제주농디🍊', // 임시 로고
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: 내 위치 기능 구현
            },
            icon: const Icon(Icons.my_location),
          ),
          IconButton(
            onPressed: () {
              // TODO: 알림 화면으로 이동
            },
            icon: const Icon(Icons.notifications_none_outlined),
          ),
        ],
      ),
      // [중단] 지도와 핵심 기능 버튼
      body: Stack(
        children: [
          // Naver Map Widget
          const NaverMap(
            options: NaverMapViewOptions(
              initialCameraPosition: NCameraPosition(
                target: NLatLng(33.4996, 126.5312), // 제주시청 위치로 초기 설정
                zoom: 11, // 초기 확대 레벨
              ),
            ),
          ),
          // 핵심 기능 버튼들을 화면 중앙에 배치
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 일자리 찾기 버튼
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: 일자리 목록 화면으로 이동
                  },

                  icon: const Text('🍊', style: TextStyle(fontSize: 24)),
                  label: const Text('일자리 찾기'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor, // 감귤색
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
                const SizedBox(height: 16), // 버튼 사이 간격

                // 일손 구하기 버튼
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: 일손 구하기 화면으로 이동
                  },
                  icon: const Text('🚜', style: TextStyle(fontSize: 24)),
                  label: const Text('일손 구하기'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF333333),
                      textStyle: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      side: const BorderSide(color: Color(0xFFDDDDDD))
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      // [하단] 네비게이션 바
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // 탭이 움직이지 않도록 고정
        selectedItemColor: Theme.of(context).primaryColor, // 선택된 아이템 색상
        unselectedItemColor: Colors.grey, // 선택되지 않은 아이템 색상
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: '내 활동'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: '채팅'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'MY농디'),
        ],
        onTap: (index) {
          // TODO: 각 탭을 눌렀을 때 화면 이동 구현
        },
      ),
    );
  }
}