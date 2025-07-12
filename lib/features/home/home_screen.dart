import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:jejunongdi/core/config/environment.dart';
import 'dart:io';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  NaverMapController? mapController;
  bool isMapReady = false;
  String mapError = '';
  int markerCount = 0;
  bool? internetConnected;
  double _sheetExtent = 0.3; // DraggableScrollableSheet의 초기 높이와 동일하게 설정
  Set<NMarker> markers = {};

  // 제주시 중심 좌표
  static const NLatLng jejuCenter = NLatLng(33.4996, 126.5312);

  @override
  void initState() {
    super.initState();
    print('🏠 HomeScreen 초기화 시작');
    _checkInternetConnection();
  }

  // 인터넷 연결 확인
  Future<void> _checkInternetConnection() async {
    try {
      print('🌐 인터넷 연결 확인 중...');
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        setState(() {
          internetConnected = true;
        });
        print('✅ 인터넷 연결됨');
      }
    } catch (e) {
      setState(() {
        internetConnected = false;
      });
      print('❌ 인터넷 연결 안됨: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NotificationListener<DraggableScrollableNotification>(
        onNotification: (notification) {
          setState(() {
            _sheetExtent = notification.extent;
          });
          return false; // 알림을 계속 전달
        },
        child: Stack(
          children: [
            // 1. Map (takes full background)
            Positioned.fill(
              child: IgnorePointer( // 시트가 확장될 때만 지도를 무시
                ignoring: _sheetExtent > 0.8, // 시트가 최소 높이 이상으로 올라왔을 때 지도를 무시
                child: _buildNaverMap(),
              ),
            ),

            // 2. Top floating UI (app bar like)
            if (isMapReady) _buildFloatingUi(context),

            // 3. Draggable bottom sheet
            DraggableScrollableSheet(
              initialChildSize: 0.3, // 초기 높이 (화면 높이의 30%)
              minChildSize: 0.1,    // 최소 높이 (아래로 드래그 시)
              maxChildSize: 0.8,    // 최대 높이 (위로 드래그 시)
              expand: true,
              // 중단점 설정
              snap: true,
              snapSizes: const [0.1,0.3, 0.8], // 스냅 포인트 설정
              builder: (BuildContext context, ScrollController scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, -2),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Drag handle
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.symmetric(vertical: 10), // 드래그 핸들 상하 마진 추가
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Expanded( // Expanded를 추가하여 남은 공간을 채우도록 함
                        child: SingleChildScrollView(
                          controller: scrollController,
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // 일자리 찾기 버튼
                                Container(
                                  height: 64,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFF2711C),
                                        Color(0xFFFF8C42),
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFF2711C).withOpacity(0.3),
                                        blurRadius: 20,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: _showJobSearch,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const SizedBox(width: 12),
                                        const Text(
                                          '일자리 찾기 🔍',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                
                                const SizedBox(height: 16),
                                
                                // 일손 구하기 버튼
                                Container(
                                  height: 64,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.white,
                                        Colors.grey[50]!,
                                      ],
                                    ),
                                    border: Border.all(
                                      color: const Color(0xFFF2711C).withOpacity(0.3),
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 15,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: _showWorkerRecruit,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const SizedBox(width: 12),
                                        const Text(
                                          '일손 구하기 👥',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFFF2711C),
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
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
              },
            ),
          ],
        ),
      ),
    );
  }

  // 네이버 지도 위젯 빌드
  Widget _buildNaverMap() {
    if (internetConnected == false) {
      return const Center(
        child: Text('❌ 인터넷에 연결되지 않았습니다.\n연결을 확인하고 앱을 다시 시작해주세요.'),
      );
    }

    if (mapError.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('❌ 지도 로딩 실패: $mapError'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _retryMapInitialization,
              child: const Text('재시도'),
            ),
          ],
        ),
      );
    }

    return NaverMap(
      options: NaverMapViewOptions(
        initialCameraPosition: NCameraPosition(
          target: jejuCenter,
          zoom: 15,
        ),
        mapType: NMapType.basic,
        activeLayerGroups: [NLayerGroup.building, NLayerGroup.traffic],
        minZoom: 5,
        maxZoom: 18,
      ),
      onMapReady: (NaverMapController controller) {
        if (!mounted) return;
        print('네이버 지도 onMapReady 콜백 호출됨');
        setState(() {
          mapController = controller;
          isMapReady = true;
        });
        print('네이버 지도 생성');
        _addSampleMarkers();
      },
      onMapTapped: (point, latLng) {
        print('지도 탭: ${latLng.latitude}, ${latLng.longitude}');
      },
      onCameraChange: (position, reason) {
        // 카메라 변경 시 필요한 로직
      },
      onCameraIdle: () {
        // 카메라 이동 완료 시 필요한 로직
      },
    );
  }

  // 플로팅 UI를 만드는 별도의 위젯
  Widget _buildFloatingUi(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 왼쪽 로고
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  )
                ],
              ),
              child: const Text(
                '제주 농디🍊',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Color(0xFFF2711C),
                ),
              ),
            ),

            // 오른쪽 아이콘 버튼 그룹
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  )
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      _moveToCurrentLocation();
                    },
                    icon: const Icon(Icons.my_location, size: 26),
                    color: const Color(0xFFF2711C),
                  ),
                  Container(height: 20, width: 1, color: Colors.grey[300]),
                  IconButton(
                    onPressed: () {
                      _showNotifications();
                    },
                    icon: const Icon(Icons.notifications_none_outlined, size: 26),
                    color: const Color(0xFFF2711C),
                  ),
                  Container(height: 20, width: 1, color: Colors.grey[300]),
                  IconButton(
                    onPressed: () {
                      _debugMapStatus();
                    },
                    icon: const Icon(Icons.info_outline, size: 26),
                    color: const Color(0xFFF2711C),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 샘플 마커들 추가
  void _addSampleMarkers() {
    if (mapController == null) {
      print('❌ mapController가 null임');
      return;
    }

    print('📍 마커 추가 시작');

    try {
      // 제주도 주요 농장 위치에 마커 추가
      final markerList = [
        // 제주시 감귤농장
        NMarker(
          id: 'farm1',
          position: const NLatLng(33.5012, 126.5297),
          caption: NOverlayCaption(text: '제주시 감귤농장'),
          subCaption: NOverlayCaption(text: '🍊 감귤 수확 일자리'),
        ),
        // 서귀포 브로콜리 농장
        NMarker(
          id: 'farm2',
          position: const NLatLng(33.2541, 126.5596),
          caption: NOverlayCaption(text: '서귀포 브로콜리농장'),
          subCaption: NOverlayCaption(text: '🥦 브로콜리 포장 일자리'),
        ),
      ];

      // 마커들을 지도에 추가 및 클릭 이벤트 설정
      for (final marker in markerList) {
        // 마커 클릭 이벤트 설정
        marker.setOnTapListener((NMarker tappedMarker) {
          final farmNames = {
            'farm1': '제주시 감귤농장 - 감귤 수확 일자리',
            'farm2': '서귀포 브로콜리농장 -  브로콜리 포장 일자리',
          };
          
          final info = farmNames[tappedMarker.info.id] ?? '농장 정보';
          _showMarkerInfo(tappedMarker.info.id, info);
        });
        
        // 지도에 마커 추가
        mapController!.addOverlay(marker);
      }
      
      setState(() {
        markerCount = markerList.length;
        markers = markerList.toSet();
      });
      
      print('✅ ${markerList.length}개 농장 마커 추가 완료');
    } catch (e) {
      print('❌ 마커 추가 실패: $e');
      setState(() {
        mapError = '마커 추가 실패: $e';
      });
    }
  }

  // 마커 정보 표시
  void _showMarkerInfo(String title, String description) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(description),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('확인'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showJobSearch();
              },
              child: const Text('자세히 보기'),
            ),
          ],
        );
      },
    );
  }

  // 지도 디버그 정보 표시
  void _debugMapStatus() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('🗺️ 지도 상태'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('📊 연결 상태:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('인터넷: ${_getInternetStatusText()}'),
                Text('지도 준비: ${isMapReady ? "✅ 완료" : "⏳ 로딩 중"}'),
                Text('지도 컨트롤러: ${mapController != null ? "✅ 활성" : "❌ 없음"}'),
                Text('마커 개수: $markerCount개'),
                const SizedBox(height: 8),
                const Text('🔧 네이버 지도 설정:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Client ID: ${EnvironmentConfig.naverMapClientId}'),
                Text('환경: ${EnvironmentConfig.current.name}'),
                const SizedBox(height: 8),
                if (mapError.isNotEmpty) ...[
                  const Text('❌ 에러:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                  Text(mapError, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 8),
                ],
                const Text('💡 문제 해결 방법:', style: TextStyle(fontWeight: FontWeight.bold)),
                const Text('1. 인터넷 연결 확인'),
                const Text('2. 위치 권한 승인'),
                const Text('3. 앱 재시작'),
                const Text('4. 네이버 클라우드 플랫폼 설정 확인'),
                const Text('5. VPN 또는 방화벽 확인'),
                const Text('6. API 사용량 한도 확인'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _checkInternetConnection();
              },
              child: const Text('연결 재확인'),
            ),
            if (!isMapReady)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _retryMapInitialization();
                },
                child: const Text('지도 재시도'),
              ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  String _getInternetStatusText() {
    if (internetConnected == null) return '⏳ 확인 중';
    if (internetConnected == true) return '✅ 연결됨';
    return '❌ 연결 안됨';
  }

  // 지도 초기화 재시도
  void _retryMapInitialization() {
    setState(() {
      isMapReady = false;
      mapError = '';
      mapController = null;
      markerCount = 0;
      markers.clear();
    });
    print('🔄 지도 초기화 재시도');
  }

  // 상태별 색상 및 메시지 헬퍼 메서드들
  Color _getStatusColor() {
    if (mapError.isNotEmpty) return Colors.red[50]!;
    if (isMapReady) return Colors.green[50]!;
    return Colors.orange[50]!;
  }

  Color _getStatusBorderColor() {
    if (mapError.isNotEmpty) return Colors.red[200]!;
    if (isMapReady) return Colors.green[200]!;
    return Colors.orange[200]!;
  }

  IconData _getStatusIcon() {
    if (mapError.isNotEmpty) return Icons.error;
    if (isMapReady) return Icons.check_circle;
    return Icons.access_time;
  }

  Color _getStatusIconColor() {
    if (mapError.isNotEmpty) return Colors.red[600]!;
    if (isMapReady) return Colors.green[600]!;
    return Colors.orange[600]!;
  }

  Color _getStatusTextColor() {
    if (mapError.isNotEmpty) return Colors.red[700]!;
    if (isMapReady) return Colors.green[700]!;
    return Colors.orange[700]!;
  }

  String _getStatusMessage() {
    if (mapError.isNotEmpty) return '❌ 지도 로드 실패';
    if (isMapReady) return '지도 로드 ($markerCount개 농장 표시)';
    return '⏳ 지도 로딩 중...';
  }

  // 현재 위치로 이동
  void _moveToCurrentLocation() {
    if (mapController != null && isMapReady) {
      // 제주시 중심으로 이동
      // mapController!.updateCamera(
        // NCameraUpdate.scrollTo(jejuCenter),
      // );
      print('📍 제주시 중심으로 이동');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('📍 제주시 중심으로 이동했습니다'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      print('❌ 지도 컨트롤러가 준비되지 않음 - isMapReady: $isMapReady, mapController: $mapController');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('지도가 아직 로딩 중입니다.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // 알림 표시
  void _showNotifications() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('📢 알림'),
          content: const Text('새로운 농장 일자리가 2건 등록되었습니다!\n\n🍊 감귤 수확 - 서귀포\n🥬 배추 심기 - 제주시'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  // 일자리 찾기
  void _showJobSearch() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(24),
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '🍊 일자리 찾기',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '제주도의 농장 일자리를 찾아보세요',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  children: [
                    _buildJobCard('감귤 수확', '서귀포시 남원읍', '시간당 15,000원', '🍊'),
                    _buildJobCard('배추 심기', '제주시 조천읍', '시간당 12,000원', '🥬'),
                    _buildJobCard('브로콜리 포장', '성산읍', '시간당 13,000원', '🥦'),
                    _buildJobCard('고구마 캐기', '한림읍', '시간당 14,000원', '🍠'),
                    _buildJobCard('양파 정리', '애월읍', '시간당 11,000원', '🧅'),
                    _buildJobCard('당근 수확', '구좌읍', '시간당 13,500원', '🥕'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 일손 구하기
  void _showWorkerRecruit() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(24),
          height: MediaQuery.of(context).size.height * 0.7,
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '🚜 일손 구하기',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Text(
                '농장에서 필요한 일손을 구해보세요',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 100),
              Center(
                child: Text(
                  '일손 구하기 기능은\n준비 중입니다.',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 일자리 카드 위젯
  Widget _buildJobCard(String title, String location, String pay, String emoji) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFF2711C).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    location,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    pay,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFF2711C),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
