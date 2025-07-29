import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:jejunongdi/core/models/job_posting_model.dart';
import 'package:jejunongdi/core/services/job_posting_service.dart';
import 'package:jejunongdi/core/utils/logger.dart';
import 'package:jejunongdi/redux/app_state.dart';
import 'package:jejunongdi/screens/job_list_screen.dart';
import 'package:jejunongdi/screens/login_screen.dart';
import 'package:jejunongdi/screens/widgets/job_posting_detail_sheet.dart';
import 'package:jejunongdi/screens/job_posting_create_screen.dart';
import 'package:jejunongdi/screens/ai_tips_screen.dart';
import 'package:jejunongdi/screens/weather_dashboard_screen.dart';
import 'package:jejunongdi/screens/price_monitoring_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:math' as math;

// 조건부 import
import 'dart:js' as js if (dart.library.html);
import 'dart:ui_web' as ui_web if (dart.library.html);
import 'dart:html' as html if (dart.library.html);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 공통 상태
  NaverMapController? _controller;
  final Set<NMarker> _markers = {};
  List<JobPostingResponse> _jobPostings = [];
  final JobPostingService _jobPostingService = JobPostingService.instance;
  Timer? _debounceTimer;
  bool _isLoading = false;
  double _sheetExtent = 0.3;

  // 웹용 JavaScript API 관련 설정
  static const double _initialLat = 33.375;
  static const double _initialLng = 126.49;
  static const int _initialZoom = 11;
  
  String? _webMapElementId;
  js.JsObject? _webMap;

  // [추가] 새로운 카드를 위한 상태 변수들
  Timer? _infoTimer;
  int _currentInfoIndex = 0;
  final List<String> _infoMessages = [
    "제주 당근은 지금이 제철이에요!",
    "한라봉 농장에서 일손을 구하고 있어요.",
    "밭터오라에 새로운 농지가 등록되었어요!",
    "서귀포에서 열리는 감귤 축제에 참여해보세요!",
  ];

  static const NLatLng _initialPosition = NLatLng(_initialLat, _initialLng);

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _initWebMap();
    }
    _loadJobPostingsForCurrentView();

    // [추가] 3초마다 메시지를 변경하는 타이머 설정
    _infoTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          _currentInfoIndex = (_currentInfoIndex + 1) % _infoMessages.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _infoTimer?.cancel();
    super.dispose();
  }

  // 웹용 JavaScript API 관련 메서드들
  void _initWebMap() {
    if (!kIsWeb) return;
    
    _webMapElementId = 'navermap_${DateTime.now().millisecondsSinceEpoch}';
    
    // HTML Element를 Flutter에 등록
    if (kIsWeb) {
      ui_web.platformViewRegistry.registerViewFactory(
        _webMapElementId!,
        (int viewId) {
          final mapDiv = html.DivElement()
            ..id = 'map$viewId'
            ..style.width = '100%'
            ..style.height = '100%';
          
          // 지도 초기화를 다음 프레임에서 실행
          Timer(Duration.zero, () => _createWebMap(mapDiv));
          
          return mapDiv;
        },
      );
    }
  }

  void _createWebMap(html.DivElement mapDiv) {
    if (!kIsWeb) return;
    
    try {
      // naver.maps가 로드되었는지 확인
      if (js.context['naver'] == null || js.context['naver']['maps'] == null) {
        Logger.error('Naver Maps API가 로드되지 않았습니다.');
        return;
      }

      final mapOptions = js.JsObject.jsify({
        'center': js.JsObject(js.context['naver']['maps']['LatLng'], [_initialLat, _initialLng]),
        'zoom': _initialZoom,
        'mapTypeControl': true,
        'mapTypeControlOptions': {
          'style': js.context['naver']['maps']['MapTypeControlStyle']['BUTTON'],
          'position': js.context['naver']['maps']['Position']['TOP_RIGHT']
        },
        'zoomControl': true,
        'zoomControlOptions': {
          'position': js.context['naver']['maps']['Position']['TOP_LEFT']
        }
      });

      _webMap = js.JsObject(js.context['naver']['maps']['Map'], [mapDiv, mapOptions]);

      // 지도 이벤트 리스너 추가
      js.context['naver']['maps']['Event'].callMethod('addListener', [
        _webMap,
        'idle',
        js.allowInterop(() => _onWebMapIdle())
      ]);

      Logger.info('웹 지도 초기화 완료');
      _loadJobPostingsForCurrentView();
    } catch (e) {
      Logger.error('웹 지도 생성 실패', error: e);
    }
  }

  void _onWebMapIdle() {
    if (!kIsWeb) return;
    
    Logger.debug('웹 지도 이동 완료');
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 800), () {
      _loadJobPostingsForCurrentView();
    });
  }

  void _updateWebMapMarkers() {
    if (_webMap == null || !kIsWeb) return;

    try {
      // 기존 마커들 제거 (웹에서는 마커 배열을 따로 관리해야 함)
      // 여기서는 간단히 구현
      
      for (final job in _jobPostings) {
        final position = js.JsObject(js.context['naver']['maps']['LatLng'], [job.latitude, job.longitude]);
        
        final marker = js.JsObject(js.context['naver']['maps']['Marker'], [
          js.JsObject.jsify({
            'position': position,
            'map': _webMap,
            'title': job.title,
            'icon': js.JsObject.jsify({
              'content': '<div style="background: #F2711C; color: white; padding: 4px 8px; border-radius: 4px; font-size: 12px;">${job.title.length > 10 ? '${job.title.substring(0, 10)}...' : job.title}</div>',
              'anchor': js.JsObject(js.context['naver']['maps']['Point'], [0, 0])
            })
          })
        ]);

        // 마커 클릭 이벤트
        js.context['naver']['maps']['Event'].callMethod('addListener', [
          marker,
          'click',
          js.allowInterop(() => _onWebMarkerClick(job))
        ]);
      }

      Logger.info('웹 마커 업데이트 완료: ${_jobPostings.length}개');
    } catch (e) {
      Logger.error('웹 마커 업데이트 실패', error: e);
    }
  }

  void _onWebMarkerClick(JobPostingResponse jobPosting) {
    final isAuthenticated = StoreProvider.of<AppState>(context, listen: false)
        .state
        .userState
        .isAuthenticated;

    if (isAuthenticated) {
      _showJobPostingDetails(jobPosting);
    } else {
      _showLoginRequiredDialog();
    }
  }

  // 기존 NaverMap 관련 메서드들
  void _onMapReady(NaverMapController controller) {
    _controller = controller;
    Logger.info('네이버 지도 초기화 완료');
    _loadJobPostingsForCurrentView();
  }

  void _onCameraChange(NCameraUpdateReason reason, bool animated) {
    Logger.debug('카메라 이동 중: $reason');
  }

  void _onCameraIdle() {
    Logger.debug('카메라 이동 완료');
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 800), () {
      _loadJobPostingsForCurrentView();
    });
  }

  Future<void> _loadJobPostingsForCurrentView() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      double minLat, maxLat, minLng, maxLng;

      if (kIsWeb) {
        if (_webMap != null) {
          try {
            // 웹: JavaScript API에서 bounds 가져오기
            final bounds = _webMap!.callMethod('getBounds');
            final sw = bounds.callMethod('getSW');
            final ne = bounds.callMethod('getNE');
            
            minLat = sw.callMethod('lat');
            maxLat = ne.callMethod('lat');
            minLng = sw.callMethod('lng');
            maxLng = ne.callMethod('lng');
          } catch (e) {
            Logger.error('웹 지도 bounds 가져오기 실패', error: e);
            // 실패 시 기본 범위 사용
            const latRange = 0.125;
            const lngRange = 0.15;
            minLat = _initialLat - latRange;
            maxLat = _initialLat + latRange;
            minLng = _initialLng - lngRange;
            maxLng = _initialLng + lngRange;
          }
        } else {
          // 웹 지도가 아직 초기화되지 않은 경우 기본 범위 사용
          const latRange = 0.125;
          const lngRange = 0.15;
          minLat = _initialLat - latRange;
          maxLat = _initialLat + latRange;
          minLng = _initialLng - lngRange;
          maxLng = _initialLng + lngRange;
        }
      } else {
        // 앱: NaverMapController에서 bounds 가져오기
        if (_controller == null) return;
        final bounds = await _controller!.getContentBounds();
        Logger.info('현재 지도 범위: ${bounds.southWest} ~ ${bounds.northEast}');

        minLat = bounds.southWest.latitude;
        maxLat = bounds.northEast.latitude;
        minLng = bounds.southWest.longitude;
        maxLng = bounds.northEast.longitude;
      }

      final result = await _jobPostingService.getJobPostingsByBounds(
        minLat: minLat,
        maxLat: maxLat,
        minLng: minLng,
        maxLng: maxLng,
      );

      if (result.isSuccess && mounted) {
        setState(() {
          _jobPostings = result.data!;
        });

        if (kIsWeb) {
          _updateWebMapMarkers();
        } else {
          await _updateMarkers(result.data!);
        }
      } else if (result.isFailure && mounted) {
        final errorMsg = result.error?.message ?? "알 수 없는 오류";
        _showErrorSnackBar('데이터를 불러오는데 실패했습니다: $errorMsg');
      }
    } catch (e) {
      Logger.error('일자리 데이터 로드 실패', error: e);
      if (mounted) {
        _showErrorSnackBar('데이터를 불러오는데 실패했습니다: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateMarkers(List<JobPostingResponse> jobPostings) async {
    if (_controller == null || kIsWeb) return;

    try {
      await _controller!.clearOverlays();
      _markers.clear();
      for (final jobPosting in jobPostings) {
        try {
          final marker = NMarker(
            id: jobPosting.id.toString(),
            position: NLatLng(jobPosting.latitude, jobPosting.longitude),
            caption: NOverlayCaption(
              text: jobPosting.title.length > 10
                  ? '${jobPosting.title.substring(0, 10)}...'
                  : jobPosting.title,
              textSize: 12,
              color: Colors.black,
              haloColor: Colors.white,
            ),
          );

          marker.setOnTapListener((NMarker marker) {
            final isAuthenticated = StoreProvider.of<AppState>(context, listen: false)
                .state
                .userState
                .isAuthenticated;

            if (isAuthenticated) {
              _showJobPostingDetails(jobPosting);
            } else {
              _showLoginRequiredDialog();
            }
          });

          _markers.add(marker);
          await _controller!.addOverlay(marker);
        } catch (e) {
          Logger.error('마커 생성 실패: ${jobPosting.id}', error: e);
        }
      }
      Logger.info('마커 업데이트 완료: ${jobPostings.length}개');
    } catch (e) {
      Logger.error('마커 업데이트 실패', error: e);
    }
  }

  void _showJobPostingDetails(JobPostingResponse jobPosting) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => JobPostingDetailSheet(jobPosting: jobPosting),
    );
  }

  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('로그인 필요'),
        content: const Text('상세 정보를 보려면 로그인이 필요합니다.\n로그인 페이지로 이동하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            child: const Text('로그인'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: '다시 시도',
          textColor: Colors.white,
          onPressed: _loadJobPostingsForCurrentView,
        ),
      ),
    );
  }

  void _moveToJejuCenter() {
    if (kIsWeb) {
      if (_webMap != null) {
        try {
          final center = js.JsObject(js.context['naver']['maps']['LatLng'], [_initialLat, _initialLng]);
          _webMap!.callMethod('setCenter', [center]);
          _webMap!.callMethod('setZoom', [_initialZoom]);
          _loadJobPostingsForCurrentView();
        } catch (e) {
          Logger.error('웹 지도 중심 이동 실패', error: e);
        }
      }
    } else {
      if (_controller != null) {
        _controller!.updateCamera(
          NCameraUpdate.fromCameraPosition(
            const NCameraPosition(
              target: _initialPosition,
              zoom: 11.0,
            ),
          ),
        );
      }
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
            Positioned.fill(
              child: IgnorePointer(
                ignoring: _sheetExtent > 0.8,
                child: kIsWeb ? _buildWebMap() : _buildNativeMap(),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
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
                        '밭터오라🍊',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Color(0xFFF2711C),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        if (_isLoading)
                          Container(
                            margin: const EdgeInsets.only(right: 12),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  )
                                ],
                              ),
                              child: const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF2711C)),
                                ),
                              ),
                            ),
                          ),
                        Container(
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
                                onPressed: _moveToJejuCenter,
                                icon: const Icon(Icons.my_location, size: 26),
                                color: const Color(0xFFF2711C),
                              ),
                              Container(height: 20, width: 1, color: Colors.grey[300]),
                              IconButton(
                                onPressed: _loadJobPostingsForCurrentView,
                                icon: const Icon(Icons.refresh, size: 26),
                                color: const Color(0xFFF2711C),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 130,
              left: 16,
              right: 16,
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.green[700]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '현재 화면에 ${_jobPostings.length}개의 일자리가 있습니다',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // [추가] 돌하르방 정보 카드
            Positioned(
              top: 190,
              left: 16,
              right: 16,
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Text('🗿', style: TextStyle(fontSize: 24)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 500),
                          transitionBuilder: (Widget child, Animation<double> animation) {
                            return FadeTransition(opacity: animation, child: child);
                          },
                          child: Text(
                            _infoMessages[_currentInfoIndex],
                            key: ValueKey<int>(_currentInfoIndex),
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
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
                                        color: const Color(0xFFF2711C).withValues(alpha: 0.3),
                                        blurRadius: 20,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: _navigateToJobList,
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
                                        Icon(Icons.search, color: Colors.white),
                                        SizedBox(width: 12),
                                        Text(
                                          '일자리 찾기',
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
                                      color: const Color(0xFFF2711C).withValues(alpha: 0.3),
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.05),
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
                                        Icon(Icons.people, color: Color(0xFFF2711C)),
                                        SizedBox(width: 12),
                                        Text(
                                          '일손 구하기',
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
                                const SizedBox(height: 16),
                                // AI 농업 도우미 버튼 추가
                                Container(
                                  height: 64,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF4CAF50),
                                        Color(0xFF66BB6A),
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
                                        blurRadius: 20,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: _navigateToAiTips,
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
                                        Icon(FontAwesomeIcons.robot, color: Colors.white),
                                        SizedBox(width: 12),
                                        Text(
                                          'AI 농업 도우미',
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
                                // 새로운 기능들을 위한 그리드 버튼
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        height: 80,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(12),
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFF2196F3),
                                              Color(0xFF42A5F5),
                                            ],
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFF2196F3).withValues(alpha: 0.3),
                                              blurRadius: 10,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: ElevatedButton(
                                          onPressed: _navigateToWeatherDashboard,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.transparent,
                                            shadowColor: Colors.transparent,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: const Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                FontAwesomeIcons.cloudSun,
                                                color: Colors.white,
                                                size: 24,
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                '날씨 정보',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Container(
                                        height: 80,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(12),
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFFFF9800),
                                              Color(0xFFFFB74D),
                                            ],
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFFFF9800).withValues(alpha: 0.3),
                                              blurRadius: 10,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: ElevatedButton(
                                          onPressed: _navigateToPriceMonitoring,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.transparent,
                                            shadowColor: Colors.transparent,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: const Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                FontAwesomeIcons.chartLine,
                                                color: Colors.white,
                                                size: 24,
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                '가격 정보',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
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

  Widget _buildNativeMap() {
    return NaverMap(
      options: const NaverMapViewOptions(
        initialCameraPosition: NCameraPosition(
          target: _initialPosition,
          zoom: 11.0,
        ),
        mapType: NMapType.basic,
        activeLayerGroups: [NLayerGroup.building, NLayerGroup.traffic],
        locationButtonEnable: true,
        consumeSymbolTapEvents: false,
      ),
      onMapReady: _onMapReady,
      onCameraChange: _onCameraChange,
      onCameraIdle: _onCameraIdle,
    );
  }

  Widget _buildWebMap() {
    if (_webMapElementId == null) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return HtmlElementView(
      viewType: _webMapElementId!,
    );
  }

  void _showWorkerRecruit() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const JobPostingCreateScreen(),
      ),
    ).then((success) {
      if (success == true) {
        _loadJobPostingsForCurrentView();
      }
    });
  }

  void _navigateToJobList() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const JobListScreen(),
      ),
    );
  }

  void _navigateToAiTips() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AiTipsScreen(),
      ),
    );
  }

  void _navigateToWeatherDashboard() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const WeatherDashboardScreen(),
      ),
    );
  }

  void _navigateToPriceMonitoring() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const PriceMonitoringScreen(),
      ),
    );
  }
}