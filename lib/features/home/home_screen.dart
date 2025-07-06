import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:jejunongdi/core/config/environment.dart';
import 'dart:io';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  KakaoMapController? mapController;
  bool isMapReady = false;
  String mapError = '';
  int markerCount = 0;
  bool? internetConnected;

  // 제주시 중심 좌표
  static final LatLng jejuCenter = LatLng(33.4996, 126.5312);

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
        
        // 카카오맵 API 연결 테스트
        _testKakaoMapConnection();
      }
    } catch (e) {
      setState(() {
        internetConnected = false;
      });
      print('❌ 인터넷 연결 안됨: $e');
    }
  }

  // 카카오맵 API 연결 테스트
  Future<void> _testKakaoMapConnection() async {
    try {
      print('🗺️ 카카오맵 API 연결 테스트 중...');
      final result = await InternetAddress.lookup('dapi.kakao.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('✅ 카카오맵 API 서버 연결됨');
      }
    } catch (e) {
      print('❌ 카카오맵 API 서버 연결 실패: $e');
      setState(() {
        mapError = '카카오맵 API 서버 연결 실패: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 메인 지도 위젯
          _buildKakaoMap(),
          
          // 지도 위에 떠 있는 플로팅 UI 요소들
          _buildFloatingUi(context),
        ],
      ),
      // 바텀 시트
      bottomSheet: _buildBottomSheet(context),
    );
  }

  // 카카오 지도 위젯 빌드
  Widget _buildKakaoMap() {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: KakaoMap(
        onMapCreated: (KakaoMapController controller) {
          print('🗺️ 카카오맵 onMapCreated 콜백 호출됨');
          setState(() {
            mapController = controller;
            isMapReady = true;
            mapError = '';
          });
          print('✅ 카카오맵 생성 완료 - 상태 업데이트됨');

          // 지도가 생성되면 샘플 마커들 추가
          Future.delayed(const Duration(milliseconds: 500), () {
            _addSampleMarkers();
          });
        },
        onMapTap: (LatLng position) {
          print('🗺️ 지도 탭: ${position.latitude}, ${position.longitude}');
        },
        center: jejuCenter
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
      final markers = [
        // 제주시 감귤농장
        Marker(
          markerId: 'farm1',
          latLng: LatLng(33.5012, 126.5297),
        ),
        // 서귀포 브로콜리 농장
        Marker(
          markerId: 'farm2',
          latLng: LatLng(33.2541, 126.5596),
        ),
        // 애월 고구마 농장
        Marker(
          markerId: 'farm3',
          latLng: LatLng(33.4619, 126.3309),
        ),
        // 성산 양파 농장
        Marker(
          markerId: 'farm4',
          latLng: LatLng(33.4593, 126.9419),
        ),
        // 한림 배추 농장
        Marker(
          markerId: 'farm5',
          latLng: LatLng(33.4141, 126.2692),
        ),
      ];

      // 마커들을 지도에 추가
      mapController!.addMarker(markers: markers);
      
      setState(() {
        markerCount = markers.length;
      });
      
      print('✅ ${markers.length}개 농장 마커 추가 완료');
    } catch (e) {
      print('❌ 마커 추가 실패: $e');
      setState(() {
        mapError = '마커 추가 실패: $e';
      });
    }
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
                const Text('🔧 카카오맵 설정:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('API 키: ${EnvironmentConfig.kakaoMapApiKey}'),
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
                const Text('4. 카카오 개발자 콘솔 설정 확인'),
                const Text('5. VPN 또는 방화벽 확인'),
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
    });
    print('🔄 지도 초기화 재시도');
  }

  // 바텀 시트 UI
  Widget _buildBottomSheet(BuildContext context) {
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
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '어떤 일자리를 찾으시나요?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                _showJobSearch();
              },
              icon: const Text('🍊', style: TextStyle(fontSize: 24)),
              label: const Text(
                '일자리 찾기',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF2711C),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                _showWorkerRecruit();
              },
              icon: const Text('🚜', style: TextStyle(fontSize: 24)),
              label: const Text(
                '일손 구하기',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF333333),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: const BorderSide(color: Color(0xFFDDDDDD)),
                elevation: 1,
              ),
            ),
            const SizedBox(height: 16),

            // 지도 상태 표시 (개선된 디버깅용)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getStatusColor(),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _getStatusBorderColor(),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _getStatusIcon(),
                    size: 16,
                    color: _getStatusIconColor(),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getStatusMessage(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: _getStatusTextColor(),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (mapError.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error, size: 16, color: Colors.red[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '❌ 지도 오류: $mapError',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
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
    if (isMapReady) return '✅ 지도 로드 완료 ($markerCount개 농장 표시)';
    return '⏳ 지도 로딩 중...';
  }

  // 현재 위치로 이동
  void _moveToCurrentLocation() {
    if (mapController != null && isMapReady) {
      // 제주시 중심으로 이동
      mapController!.panTo(jejuCenter);
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
