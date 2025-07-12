import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:lottie/lottie.dart';
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
  double _sheetExtent = 0.3;
  Set<NMarker> markers = {};

  // 제주시 중심 좌표
  static const NLatLng jejuCenter = NLatLng(33.4996, 126.5312);

  @override
  void initState() {
    super.initState();
    print('🏠 HomeScreen 초기화 시작');
    _checkInternetConnection();
    
    // 웹 환경에서는 지도가 바로 준비된 것으로 간주
    if (kIsWeb) {
      setState(() {
        isMapReady = true;
      });
    }
  }

  // 인터넷 연결 확인
  Future<void> _checkInternetConnection() async {
    try {
      if (kIsWeb) {
        setState(() {
          internetConnected = true;
        });
        print('✅ 웹 플랫폼: 인터넷 연결됨으로 가정');
        return;
      }
      
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
          return false;
        },
        child: Stack(
          children: [
            // 1. Map (takes full background)
            Positioned.fill(
              child: IgnorePointer(
                ignoring: _sheetExtent > 0.8,
                child: _buildMap(),
              ),
            ),

            // 2. Top floating UI (app bar like)
            if (isMapReady) _buildFloatingUi(context),

            // 3. Draggable bottom sheet
            DraggableScrollableSheet(
              initialChildSize: 0.3,
              minChildSize: 0.1,
              maxChildSize: 0.8,
              expand: true,
              snap: true,
              snapSizes: const [0.1, 0.3, 0.8],
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
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          controller: scrollController,
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // 플랫폼 정보 표시
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  margin: const EdgeInsets.only(bottom: 16),
                                  decoration: BoxDecoration(
                                    color: kIsWeb ? Colors.blue[50] : Colors.green[50],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: kIsWeb ? Colors.blue[200]! : Colors.green[200]!,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        kIsWeb ? Icons.web : Icons.phone_android,
                                        color: kIsWeb ? Colors.blue[600] : Colors.green[600],
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        kIsWeb ? '웹 버전 - 네이버 정적 지도' : '모바일 버전 - 네이버 지도',
                                        style: TextStyle(
                                          color: kIsWeb ? Colors.blue[700] : Colors.green[700],
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                
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
                                    child: const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        SizedBox(width: 12),
                                        Text(
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
                                    child: const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        SizedBox(width: 12),
                                        Text(
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

  // 지도 위젯 빌드 (플랫폼별 분기)
  Widget _buildMap() {
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

    // 웹 환경이면 정적 지도 이미지 사용
    if (kIsWeb) {
      return _buildStaticMap();
    }

    // 모바일 환경 (기존 네이버맵)
    return _buildNaverMap();
  }

  // 정적 지도 이미지 (웹용)
  Widget _buildStaticMap() {
    final apiKey = EnvironmentConfig.naverMapClientId;
    
    // 제주시 중심의 정적 지도 URL
    final staticMapUrl = 'https://navermaps.apigw.ntruss.com/map-static/v2/raster-cors?'
        'w=800&h=600'
        '&center=${jejuCenter.longitude},${jejuCenter.latitude}'
        '&level=11'
        '&markers=type:t|size:mid|pos:${jejuCenter.longitude}%20${jejuCenter.latitude}|label:제주농디'
        '&X-NCP-APIGW-API-KEY-ID=$apiKey';

    return Stack(
      children: [
        // 정적 지도 이미지
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.grey,
          ),
          child: Image.network(
            staticMapUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(
                child: CircularProgressIndicator(),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              print('❌ 정적 지도 로딩 실패: $error');
              return Container(
                color: Colors.grey[300],
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.map, size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        '지도를 불러올 수 없습니다',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '네이버 클라우드 플랫폼에서\n도메인 등록이 필요합니다',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        
        // 클릭 가능한 마커 영역들
        ..._buildClickableMarkers(),
      ],
    );
  }

  // 클릭 가능한 마커 영역들 (웹용)
  List<Widget> _buildClickableMarkers() {
    return [
      // 제주시 감귤농장 마커
      Positioned(
        left: MediaQuery.of(context).size.width * 0.45,
        top: MediaQuery.of(context).size.height * 0.35,
        child: GestureDetector(
          onTap: () => _showMarkerInfo('farm1', '제주시 감귤농장 - 감귤 수확 일자리'),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF2711C),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Text(
              '🍊 감귤농장',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
      
      // 서귀포 브로콜리농장 마커
      Positioned(
        left: MediaQuery.of(context).size.width * 0.50,
        top: MediaQuery.of(context).size.height * 0.55,
        child: GestureDetector(
          onTap: () => _showMarkerInfo('farm2', '서귀포 브로콜리농장 - 브로콜리 포장 일자리'),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF2711C),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Text(
              '🥦 브로콜리농장',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    ];
  }

  // 네이버맵 (모바일용)
  Widget _buildNaverMap() {
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

  // 샘플 마커들 추가 (모바일용)
  void _addSampleMarkers() {
    if (mapController == null) {
      print('❌ mapController가 null임');
      return;
    }

    print('📍 마커 추가 시작');

    try {
      final markerList = [
        NMarker(
          id: 'farm1',
          position: const NLatLng(33.5012, 126.5297),
          caption: NOverlayCaption(text: '제주시 감귤농장'),
          subCaption: NOverlayCaption(text: '🍊 감귤 수확 일자리'),
        ),
        NMarker(
          id: 'farm2',
          position: const NLatLng(33.2541, 126.5596),
          caption: NOverlayCaption(text: '서귀포 브로콜리농장'),
          subCaption: NOverlayCaption(text: '🥦 브로콜리 포장 일자리'),
        ),
      ];

      for (final marker in markerList) {
        marker.setOnTapListener((NMarker tappedMarker) {
          final farmNames = {
            'farm1': '제주시 감귤농장 - 감귤 수확 일자리',
            'farm2': '서귀포 브로콜리농장 -  브로콜리 포장 일자리',
          };
          
          final info = farmNames[tappedMarker.info.id] ?? '농장 정보';
          _showMarkerInfo(tappedMarker.info.id, info);
        });
        
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
                Text('플랫폼: ${kIsWeb ? "웹" : "모바일"}'),
                Text('지도 타입: ${kIsWeb ? "정적 이미지" : "네이버맵"}'),
                Text('인터넷: ${_getInternetStatusText()}'),
                Text('지도 준비: ${isMapReady ? "✅ 완료" : "⏳ 로딩 중"}'),
                if (!kIsWeb) ...[
                  Text('지도 컨트롤러: ${mapController != null ? "✅ 활성" : "❌ 없음"}'),
                  Text('마커 개수: $markerCount개'),
                ],
                const SizedBox(height: 8),
                if (!kIsWeb) ...[
                  const Text('🔧 네이버 지도 설정:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('Client ID: ${EnvironmentConfig.naverMapClientId}'),
                ],
                Text('환경: ${EnvironmentConfig.current.name}'),
                const SizedBox(height: 8),
                if (mapError.isNotEmpty) ...[
                  const Text('❌ 에러:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                  Text(mapError, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 8),
                ],
                const Text('💡 웹에서 사용법:', style: TextStyle(fontWeight: FontWeight.bold)),
                const Text('• 웹에서는 정적 지도 이미지 사용'),
                const Text('• 마커 클릭 시 농장 정보 표시'),
                const Text('• GitHub Pages 배포 지원'),
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

  // 현재 위치로 이동
  void _moveToCurrentLocation() {
    if (isMapReady) {
      print('📍 제주시 중심으로 이동');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(kIsWeb ? 
            '📍 정적 지도는 이동할 수 없습니다' : 
            '📍 제주시 중심으로 이동했습니다'
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
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
