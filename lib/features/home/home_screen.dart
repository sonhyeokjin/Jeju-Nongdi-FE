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

  // 웹용 static API 관련 설정
  static const String _naverApiKey = 'be8jif7owm';
  static const double _initialLat = 33.375;
  static const double _initialLng = 126.49;
  static const int _initialZoom = 11;

  double _currentLat = _initialLat;
  double _currentLng = _initialLng;
  int _currentZoom = _initialZoom;
  String? _mapImageUrl;

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
      _generateMapImageUrl();
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

  // 웹용 static API 관련 메서드들
  void _generateMapImageUrl() {
    if (!kIsWeb) return;

    _mapImageUrl = 'https://maps.apigw.ntruss.com/map-static/v2/raster?'
        'w=400&h=400'
        '&center=$_currentLng,$_currentLat'
        '&level=$_currentZoom'
        '&X-NCP-APIGW-API-KEY-ID=$_naverApiKey';

    Logger.info('지도 이미지 URL 생성: $_mapImageUrl');
  }

  double _getLatitudeRange() {
    // 줌 레벨에 따른 위도 범위 계산 (근사치)
    switch (_currentZoom) {
      case 9: return 0.5;
      case 10: return 0.25;
      case 11: return 0.125;
      case 12: return 0.0625;
      case 13: return 0.03125;
      case 14: return 0.015625;
      case 15: return 0.0078125;
      default: return 0.125;
    }
  }

  double _getLongitudeRange() {
    // 줌 레벨에 따른 경도 범위 계산 (근사치)
    switch (_currentZoom) {
      case 9: return 0.6;
      case 10: return 0.3;
      case 11: return 0.15;
      case 12: return 0.075;
      case 13: return 0.0375;
      case 14: return 0.01875;
      case 15: return 0.009375;
      default: return 0.15;
    }
  }

  void _onWebMapTapped(TapUpDetails details, BoxConstraints constraints) {
    if (!kIsWeb) return;

    // 탭한 위치를 기준으로 근처의 일자리 찾기
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final localPosition = renderBox.globalToLocal(details.globalPosition);

    // 지도 영역 내에서의 상대적 위치 계산
    final mapWidth = constraints.maxWidth;
    final mapHeight = constraints.maxHeight;

    final relativeX = localPosition.dx / mapWidth;
    final relativeY = localPosition.dy / mapHeight;

    // 상대적 위치를 실제 좌표로 변환
    final latRange = _getLatitudeRange() * 2;
    final lngRange = _getLongitudeRange() * 2;

    final tappedLat = _currentLat + (0.5 - relativeY) * latRange;
    final tappedLng = _currentLng + (relativeX - 0.5) * lngRange;

    // 근처의 일자리 찾기 (100m 반경 내)
    JobPostingResponse? nearestJob;
    double minDistance = double.infinity;

    for (final job in _jobPostings) {
      final distance = _calculateDistance(
          tappedLat, tappedLng,
          job.latitude, job.longitude
      );

      if (distance < 0.001 && distance < minDistance) { // 100m 이내
        minDistance = distance;
        nearestJob = job;
      }
    }

    if (nearestJob != null) {
      final isAuthenticated = StoreProvider.of<AppState>(context, listen: false)
          .state
          .userState
          .isAuthenticated;

      if (isAuthenticated) {
        _showJobPostingDetails(nearestJob);
      } else {
        _showLoginRequiredDialog();
      }
    }
  }

  double _calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    // 두 지점 간의 거리 계산 (단순한 유클리드 거리)
    final deltaLat = lat1 - lat2;
    final deltaLng = lng1 - lng2;
    return math.sqrt(deltaLat * deltaLat + deltaLng * deltaLng);
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
        // 웹: 현재 지도 범위 계산 (대략적)
        double latRange = _getLatitudeRange();
        double lngRange = _getLongitudeRange();

        minLat = _currentLat - latRange;
        maxLat = _currentLat + latRange;
        minLng = _currentLng - lngRange;
        maxLng = _currentLng + lngRange;
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
          _generateMapImageUrl();
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
      setState(() {
        _currentLat = _initialLat;
        _currentLng = _initialLng;
        _currentZoom = _initialZoom;
      });
      _generateMapImageUrl();
      _loadJobPostingsForCurrentView();
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
    return Container(
      color: Colors.grey[300],
      child: LayoutBuilder(
        builder: (context, constraints) {
          return GestureDetector(
            onTapUp: (details) => _onWebMapTapped(details, constraints),
            child: _mapImageUrl != null
                ? Image.network(
              _mapImageUrl!,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, size: 64, color: Colors.red),
                      SizedBox(height: 16),
                      Text('지도를 불러올 수 없습니다'),
                    ],
                  ),
                );
              },
            )
                : const Center(child: CircularProgressIndicator()),
          );
        },
      ),
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