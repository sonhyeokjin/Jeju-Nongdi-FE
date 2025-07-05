import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  KakaoMapController? mapController;
  bool isMapReady = false;
  String mapError = '';

  @override
  Widget build(BuildContext context) {
    // 버튼의 포인트 색상 (감귤 꼭지색)
    const Color buttonPointColor = Color(0xFF006400);

    return Scaffold(
      body: Stack(
        children: [
          // 지도 위젯이 가장 아래에 깔립니다.
          _buildMapWidget(),

          // [변경] 지도 위에 떠 있는 플로팅 UI 요소들
          _buildFloatingUi(context),
        ],
      ),

      // [변경] 하단 네비게이션 바는 원래의 흰색 배경으로 되돌립니다.
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor, // 선택된 아이템은 감귤색
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: '내 활동'),
          BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline), label: '채팅'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: 'MY농디'),
        ],
      ),

      // 바텀 시트는 그대로 유지합니다.
      bottomSheet: _buildBottomSheet(context, buttonPointColor),
    );
  }

  // 지도 위젯 빌드 (에러 처리 포함)
  Widget _buildMapWidget() {
    if (mapError.isNotEmpty) {
      // 지도 로드 실패 시 대체 화면
      return Container(
        color: Colors.green[50],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.map_outlined,
                size: 64,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              const Text(
                '🗺️ 제주 지도',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '지도를 불러오는 중...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              if (mapError.isNotEmpty) ...[
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    '오류: $mapError',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.red,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    try {
      return KakaoMap(
        center: LatLng(33.4996, 126.5312), // 제주시 중심
        maxLevel: 10,
        onMapCreated: (KakaoMapController controller) {
          setState(() {
            mapController = controller;
            isMapReady = true;
          });
          print('✅ 카카오맵 생성 완료');
        },
        onMapTap: (LatLng position) {
          print('🗺️ 지도 탭: ${position.latitude}, ${position.longitude}');
        },
        // 추가 설정들
      );
    } catch (e) {
      // 카카오맵 생성 실패 시
      setState(() {
        mapError = e.toString();
      });
      return Container(
        color: Colors.green[50],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              const Text(
                '지도 로드 실패',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  e.toString(),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  // [신규] 플로팅 UI를 만드는 별도의 위젯
  Widget _buildFloatingUi(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // [수정 적용된] 왼쪽 로고
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30), // 둥글게
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 5)
                ],
              ),
              child: const Text(
                '제주 농디🍊',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),

            // [수정된] 오른쪽 아이콘 버튼 그룹
            Container(
              // 로고와 높이를 맞추기 위해 패딩을 추가합니다.
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30), // 둥글게
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 5)
                ],
              ),
              child: Row(
                children: [
                  // IconButton은 자체적인 크기가 있으므로, 아이콘 크기를 조절합니다.
                  IconButton(
                    onPressed: () {
                      // 현재 위치로 이동 (구현 예정)
                      print('📍 현재 위치 버튼 클릭');
                    },
                    icon: const Icon(Icons.my_location, size: 26),
                  ),
                  Container(height: 20, width: 1, color: Colors.grey[300]),
                  IconButton(
                    onPressed: () {
                      // 알림 (구현 예정)
                      print('🔔 알림 버튼 클릭');
                    },
                    icon: const Icon(Icons.notifications_none_outlined, size: 26),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 바텀 시트 UI를 만드는 별도의 메소드
  Widget _buildBottomSheet(BuildContext context, Color buttonColor) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            const Text( // [변경] 텍스트 색상 원래대로
              '어떤 일자리를 찾으시나요?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                print('🍊 일자리 찾기 버튼 클릭');
              },
              icon: const Text('🍊', style: TextStyle(fontSize: 24)),
              label: const Text('일자리 찾기'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF2711C),
                foregroundColor: Colors.white,
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                print('🚜 일손 구하기 버튼 클릭');
              },
              icon: const Text('🚜', style: TextStyle(fontSize: 24)),
              label: const Text('일손 구하기'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF333333),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  side: const BorderSide(color: Color(0xFFDDDDDD))),
            ),
          ],
        ),
      ),
    );
  }
}
