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
import 'package:jejunongdi/screens/chat_room_screen.dart';
import 'package:jejunongdi/screens/widgets/job_posting_detail_sheet.dart';
import 'package:jejunongdi/screens/job_posting_create_screen.dart';
import 'package:jejunongdi/screens/ai_assistant_screen.dart';
import 'package:jejunongdi/screens/idle_farmland_list_screen.dart';
import 'package:jejunongdi/screens/idle_farmland_create_screen.dart';
import 'package:jejunongdi/screens/idle_farmland_detail_screen.dart';
import 'package:jejunongdi/core/models/idle_farmland_models.dart';
import 'package:jejunongdi/core/services/idle_farmland_service.dart';
import 'package:jejunongdi/redux/chat/chat_actions.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
  List<JobPostingResponse> _allJobPostings = [];
  List<IdleFarmlandResponse> _idleFarmlands = [];
  final JobPostingService _jobPostingService = JobPostingService.instance;
  final IdleFarmlandService _idleFarmlandService = IdleFarmlandService.instance;
  Timer? _debounceTimer;
  bool _isLoading = false;
  
  // 탭 상태
  int _selectedTabIndex = 0; // 0: 일자리, 1: 유휴농지

  // DraggableScrollableSheet 관련 상태
  double _sheetPosition = 0.3;
  final DraggableScrollableController _sheetController = DraggableScrollableController();
  
  // 말풍선 텍스트 순환을 위한 상태
  Timer? _textSwitchTimer;
  int _currentTextIndex = 0;
  final List<String> _speechBubbleTexts = [
    '🔥 1일부터 5일간 연속 폭염 예상!',
  ];


  // 웹용 설정
  static const double _initialLat = 33.375;
  static const double _initialLng = 126.49;

  static const NLatLng _initialPosition = NLatLng(_initialLat, _initialLng);

  @override
  void initState() {
    super.initState();
    _loadJobPostingsForCurrentView();
    _loadAllJobPostings();
    _loadIdleFarmlandsForCurrentView();

    // DraggableScrollableController 리스너 추가
    _sheetController.addListener(() {
      if (_sheetController.isAttached) {
        setState(() {
          _sheetPosition = _sheetController.size;
        });
      }
    });

    // 텍스트 순환 타이머 시작
    _startTextSwitchTimer();
  }

  void _startTextSwitchTimer() {
    _textSwitchTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          _currentTextIndex = (_currentTextIndex + 1) % _speechBubbleTexts.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _textSwitchTimer?.cancel();
    _sheetController.dispose();
    super.dispose();
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
      _loadAllJobPostings();
      _loadIdleFarmlandsForCurrentView();
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
        // 웹: 기본 범위 사용 (제주도 전체)
        const latRange = 0.3;
        const lngRange = 0.4;
        minLat = _initialLat - latRange;
        maxLat = _initialLat + latRange;
        minLng = _initialLng - lngRange;
        maxLng = _initialLng + lngRange;
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

        if (!kIsWeb) {
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

  Future<void> _loadAllJobPostings() async {
    if (!mounted) return;

    try {
      final result = await _jobPostingService.getJobPostingsPaged(
        page: 0,
        size: 1000, // 큰 수로 설정하여 모든 일자리 가져오기
      );

      if (result.isSuccess && mounted) {
        setState(() {
          _allJobPostings = result.data!.content;
        });
      } else if (result.isFailure && mounted) {
        final errorMsg = result.error?.message ?? "알 수 없는 오류";
        Logger.error('전체 일자리 데이터 로드 실패: $errorMsg');
      }
    } catch (e) {
      Logger.error('전체 일자리 데이터 로드 실패', error: e);
    }
  }

  Future<void> _loadIdleFarmlandsForCurrentView() async {
    if (!mounted) return;

    try {
      final result = await _idleFarmlandService.getIdleFarmlands(
        page: 0,
        size: 20,
      );

      if (result.isSuccess && mounted) {
        setState(() {
          _idleFarmlands = result.data!.content;
        });
      } else if (result.isFailure && mounted) {
        final errorMsg = result.error?.message ?? "알 수 없는 오류";
        Logger.error('유휴농지 데이터 로드 실패: $errorMsg');
      }
    } catch (e) {
      Logger.error('유휴농지 데이터 로드 실패', error: e);
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
      // 웹에서는 데이터 새로고침만 수행
      _loadJobPostingsForCurrentView();
      _loadAllJobPostings();
      _loadIdleFarmlandsForCurrentView();
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

  // 가장 가까운 중단점으로 스냅하는 메서드
  /// 드래그가 끝났을 때의 속도를 기반으로 가장 적절한 중단점으로 스냅합니다.
  void _snapToClosestBreakpoint(DragEndDetails details) {
    if (!_sheetController.isAttached) return;

    final double dyVelocity = details.velocity.pixelsPerSecond.dy;
    const double velocityThreshold = 500.0; // '플릭(flick)'으로 인식할 최소 수직 스크롤 속도

    final currentSize = _sheetController.size;
    const double minSize = 0.2;
    const double maxSize = 0.7;

    double targetBreakpoint;

    // 위/아래로 빠르게 밀어내는(플릭) 제스처를 확인합니다.
    if (dyVelocity < -velocityThreshold) {
      // 위로 플릭: 상단 중단점(0.7)으로 이동
      targetBreakpoint = maxSize;
    } else if (dyVelocity > velocityThreshold) {
      // 아래로 플릭: 하단 중단점(0.2)으로 이동
      targetBreakpoint = minSize;
    } else {
      // 플릭이 아닌 경우: 드래그를 멈춘 위치에서 가장 가까운 중단점으로 이동
      if ((currentSize - minSize).abs() < (currentSize - maxSize).abs()) {
        targetBreakpoint = minSize;
      } else {
        targetBreakpoint = maxSize;
      }
    }

    // 결정된 목표 중단점으로 애니메이션을 실행합니다.
    _sheetController.animateTo(
      targetBreakpoint,
      duration: const Duration(milliseconds: 350), // 반응성을 위해 애니메이션 시간을 약간 줄임
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final sheetHeight = screenHeight * _sheetPosition;
    // 시트 위치에 따라 동적으로 간격 조정 (overflow 방지)
    double dynamicSpacing;
    if (_sheetPosition <= 0.08) {
      // 최하단일 때는 충분한 간격 확보 (overflow 방지)
      dynamicSpacing = 80.0; // 더 큰 간격으로 overflow 방지
    } else if (_sheetPosition <= 0.15) {
      // 하단 근처에서도 여유 간격 확보
      dynamicSpacing = 70.0;
    } else if (_sheetPosition >= 0.8) {
      // 최상단일 때는 더 가깝게
      dynamicSpacing = -50.0;
    } else if (_sheetPosition >= 0.6) {
      // 상단 근처일 때
      dynamicSpacing = -30.0;
    } else {
      // 중간 위치에서는 기본 간격
      dynamicSpacing = 10.0;
    }
    final jobAlertBottom = sheetHeight + dynamicSpacing;

    return Scaffold(
      body: Stack(
        children: [
          // 지도
          Positioned.fill(
            child: IgnorePointer(
              ignoring: _sheetPosition > 0.8,
              child: kIsWeb ? _buildWebMap() : _buildNativeMap(),
            ),
          ),
          // 상단 UI
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _navigateToAiAssistant,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFF2711C),
                            Color(0xFFFF8C42),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(26),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFF2711C).withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                            spreadRadius: 1,
                          ),
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(23),
                          ),
                          child: Image.asset(
                            'lib/assets/images/ai_assistant_image.png',
                            height: 32,
                            width: 32,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 800),
                      tween: Tween<double>(begin: 0.0, end: 1.0),
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: 0.8 + (0.2 * value),
                          alignment: Alignment.centerLeft,
                          child: Opacity(
                            opacity: value,
                            child: CustomPaint(
                              painter: ModernSpeechBubblePainter(),
                              child: Container(
                                margin: const EdgeInsets.only(left: 12),
                                padding: const EdgeInsets.fromLTRB(24, 14, 18, 14),
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  transitionBuilder: (Widget child, Animation<double> animation) {
                                    return FadeTransition(
                                      opacity: animation,
                                      child: SlideTransition(
                                        position: Tween<Offset>(
                                          begin: const Offset(0.0, 0.5),
                                          end: Offset.zero,
                                        ).animate(animation),
                                        child: child,
                                      ),
                                    );
                                  },
                                  switchInCurve: Curves.easeOut,
                                  switchOutCurve: Curves.easeIn,
                                  child: Text(
                                    _speechBubbleTexts[_currentTextIndex],
                                    key: ValueKey<int>(_currentTextIndex),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF2D2D2D),
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 컨테이너들을 가로로 배치 - 왼쪽에 위치 추적 + 새로고침 버튼, 중앙에 일자리 알림, 오른쪽에 로딩
          Positioned(
            bottom: jobAlertBottom,
            left: 16,
            right: 16,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // 왼쪽: 위치 추적 및 새로고침 버튼 컨테이너
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.95),
                        Colors.grey[50]!.withValues(alpha: 0.95),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFFF2711C).withValues(alpha: 0.2),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 위치 추적 버튼
                      InkWell(
                        onTap: _moveToJejuCenter,
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFF2711C),
                                Color(0xFFFF8C42),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.my_location,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      // 구분선
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        width: 1,
                        height: 20,
                        color: const Color(0xFFF2711C).withOpacity(0.3),
                      ),
                      // 새로고침 버튼
                      InkWell(
                        onTap: _loadJobPostingsForCurrentView,
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFF2711C),
                                Color(0xFFFF8C42),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.refresh,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // 중앙: 일자리 알림 컨테이너 (내용에 맞게 크기 조정)
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.95),
                          Colors.grey[50]!.withValues(alpha: 0.95),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: const Color(0xFFF2711C).withValues(alpha: 0.2),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFF2711C),
                                Color(0xFFFF8C42),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.work_outline,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _selectedTabIndex == 0 
                              ? '현재 ${_jobPostings.length}개 일자리'
                              : '현재 ${_idleFarmlands.length}개 유휴농지',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2D2D2D),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // DraggableScrollableSheet
          DraggableScrollableSheet(
            controller: _sheetController,
            initialChildSize: 0.25,
            minChildSize: 0.25, // 중단점 아래로 내려가지 않도록 제한
            maxChildSize: 0.7, // 상단 중단점까지만 확장
            snap: true, // 스냅 효과 활성화
            snapSizes: [0.25, 0.7], // 중단, 상단 2개 중단점만 설정
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
                    // 드래그 핸들 영역 (드래그 가능)
                    GestureDetector(
                      onPanUpdate: (details) {
                        // 수직 드래그만 허용
                        if (details.delta.dy.abs() > details.delta.dx.abs()) {
                          final currentSize = _sheetController.size;
                          final screenHeight = MediaQuery.of(context).size.height;
                          final deltaSize = -details.delta.dy / screenHeight * 1.5; // 민감도 증가
                          final newSize = (currentSize + deltaSize).clamp(0.25, 0.7); // 중단점 범위로 제한
                          
                          // 즉시 반영 (애니메이션 없이)
                          if (_sheetController.isAttached) {
                            _sheetController.jumpTo(newSize);
                          }
                        }
                      },
                      onPanEnd: (details) {
                        // 드래그 종료 시 가장 가까운 중단점으로 스냅
                        _snapToClosestBreakpoint(details);
                      },
                      child: Container(
                        width: double.infinity,
                        height: 32,
                        color: Colors.transparent,
                        child: Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey[400],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // 탭 버튼 영역 (드래그 가능, 탭은 GestureDetector로 처리)
                    GestureDetector(
                      onPanUpdate: (details) {
                        // 수직 드래그만 허용
                        if (details.delta.dy.abs() > details.delta.dx.abs()) {
                          final currentSize = _sheetController.size;
                          final screenHeight = MediaQuery.of(context).size.height;
                          final deltaSize = -details.delta.dy / screenHeight * 1.0; // 민감도 증가
                          final newSize = (currentSize + deltaSize).clamp(0.2, 0.7);

                          // 즉시 반영 (애니메이션 없이)
                          if (_sheetController.isAttached) {
                            _sheetController.jumpTo(newSize);
                          }
                        }
                      },
                      onPanEnd: (details) {
                        // 드래그 종료 시 가장 가까운 중단점으로 스냅
                        _snapToClosestBreakpoint(details);
                      },
                      onTap: () {
                        // 탭 처리는 별도 GestureDetector로
                      },
                      child: GestureDetector(
                        onTapDown: (details) {
                          // 탭 위치에 따라 탭 인덱스 결정
                          final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
                          if (renderBox != null) {
                            final localPosition = renderBox.globalToLocal(details.globalPosition);
                            final containerWidth = renderBox.size.width - 32; // padding 제외
                            final isLeftTab = localPosition.dx < (containerWidth / 2 + 16);
                            
                            setState(() {
                              _selectedTabIndex = isLeftTab ? 0 : 1;
                            });
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: _selectedTabIndex == 0 
                                          ? const Color(0xFFF2711C)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.work_outline,
                                          size: 16,
                                          color: _selectedTabIndex == 0 
                                              ? Colors.white
                                              : Colors.grey[600],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '일자리',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: _selectedTabIndex == 0 
                                                ? Colors.white
                                                : Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: _selectedTabIndex == 1 
                                          ? const Color(0xFFF2711C)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.agriculture,
                                          size: 16,
                                          color: _selectedTabIndex == 1 
                                              ? Colors.white
                                              : Colors.grey[600],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '유휴농지',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: _selectedTabIndex == 1 
                                                ? Colors.white
                                                : Colors.grey[600],
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
                    ),
                    // 리스트 영역 (드래그 차단, 스크롤 가능)
                    Expanded(
                      child: NotificationListener<ScrollNotification>(
                        onNotification: (notification) {
                          // 스크롤 알림을 차단하여 DraggableScrollableSheet가 반응하지 않도록 함
                          return true;
                        },
                        child: Stack(
                          children: [
                            _selectedTabIndex == 0 
                                ? _buildJobListWithController(scrollController)
                                : _buildIdleFarmlandListWithController(scrollController),
                            // 플로팅 액션 버튼
                            Positioned(
                              bottom: 16,
                              right: 16,
                              child: FloatingActionButton.extended(
                                onPressed: _selectedTabIndex == 0 ? _showWorkerRecruit : _navigateToIdleFarmlandCreate,
                                backgroundColor: const Color(0xFFF2711C),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(64),
                                ),
                                icon: Icon(
                                  _selectedTabIndex == 0 ? Icons.add : Icons.add_location,
                                  size: 24,
                                ),
                                label: Text(
                                  _selectedTabIndex == 0 ? '일자리 추가하기' : '농지 등록하기',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
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
    if (kIsWeb) {
      return _buildSimpleWebMap();
    } else {
      return Container(); // 웹이 아닐 때는 빈 컨테이너
    }
  }

  Widget _buildSimpleWebMap() {
    // iframe 스타일의 간단한 웹 지도
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!, width: 1),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            // Static Map 이미지
            Image.network(
              'https://maps.apigw.ntruss.com/map-static/v2/raster-cors?w=800&h=600&center=126.49,33.375&level=11&X-NCP-APIGW-API-KEY-ID=be8jif7owm',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, size: 48, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('지도를 불러올 수 없습니다'),
                      ],
                    ),
                  ),
                );
              },
            ),
            // 좌상단 로고
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'NAVER',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
            ),
            // 우하단 정보
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _selectedTabIndex == 0 
                      ? '일자리: ${_jobPostings.length}개'
                      : '유휴농지: ${_idleFarmlands.length}개',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFF2711C),
                  ),
                ),
              ),
            ),
            // 클릭 가능한 영역
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    // 지도 클릭 시 새로고침
                    _loadJobPostingsForCurrentView();
                  },
                  child: Container(),
                ),
              ),
            ),
          ],
        ),
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

  void _navigateToAiAssistant() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AiAssistantScreen(),
      ),
    );
  }

  void _navigateToIdleFarmlandList() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const IdleFarmlandListScreen(),
      ),
    );
  }
  
  void _navigateToIdleFarmlandCreate() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const IdleFarmlandCreateScreen()),
    ).then((result) {
      if (result == true) {
        // 지도 및 데이터 새로고침
        _loadJobPostingsForCurrentView();
        _loadIdleFarmlandsForCurrentView();
      }
    });
  }

  Widget _buildJobListWithController(ScrollController scrollController) {
    if (_isLoading && _allJobPostings.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFF2711C),
        ),
      );
    }

    if (_allJobPostings.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.work_off,
              size: 48,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              '등록된 일자리가 없습니다',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: scrollController,
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _allJobPostings.length + 1,
      itemBuilder: (context, index) {
        if (index >= _allJobPostings.length) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                '리스트를 전부 확인 하셨습니다.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ),
          );
        }
        final job = _allJobPostings[index];
        return _buildJobCard(job);
      },
    );
  }

  Widget _buildIdleFarmlandListWithController(ScrollController scrollController) {
    if (_idleFarmlands.isEmpty) {
      return _buildEmptyIdleFarmlandView(scrollController);
    }
    return _buildIdleFarmlandContent(scrollController);
  }

  Widget _buildEmptyIdleFarmlandView(ScrollController scrollController) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          controller: scrollController,
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: Column(
              children: [
                _buildIdleFarmlandActionButtons(),
                SizedBox(height: constraints.maxHeight > 200 ? 20 : 10),
                SizedBox(
                  height: constraints.maxHeight > 200 ? constraints.maxHeight - 120 : constraints.maxHeight * 0.6,
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.agriculture,
                          size: 48,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          '등록된 유휴농지가 없습니다',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildIdleFarmlandContent(ScrollController scrollController) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          controller: scrollController,
          physics: const ClampingScrollPhysics(),
          child: Column(
            children: [
              _buildIdleFarmlandActionButtons(),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: _idleFarmlands.length + 1,
                itemBuilder: (context, index) {
                  if (index >= _idleFarmlands.length) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          '리스트를 전부 확인 하셨습니다.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ),
                    );
                  }
                  final farmland = _idleFarmlands[index];
                  return _buildFarmlandCard(farmland);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildJobList() {
    if (_isLoading && _allJobPostings.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFF2711C),
        ),
      );
    }

    if (_allJobPostings.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.work_off,
              size: 48,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              '등록된 일자리가 없습니다',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _allJobPostings.length + 1,
      itemBuilder: (context, index) {
        if (index >= _allJobPostings.length) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                '리스트 끝',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ),
          );
        }
        final job = _allJobPostings[index];
        return _buildJobCard(job);
      },
    );
  }

  Widget _buildIdleFarmlandList() {
    if (_idleFarmlands.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.agriculture,
              size: 48,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              '등록된 유휴농지가 없습니다',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _idleFarmlands.length + 1,
      itemBuilder: (context, index) {
        if (index >= _idleFarmlands.length) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                '리스트 끝',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ),
          );
        }
        final farmland = _idleFarmlands[index];
        return _buildFarmlandCard(farmland);
      },
    );
  }

  Widget _buildJobCard(JobPostingResponse job) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 6),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 1),
            spreadRadius: -1,
          ),
        ],
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.08),
          width: 0.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showJobPostingDetails(job),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 상단: 상태 뱃지와 하트 아이콘
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '모집중',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.favorite_border,
                        size: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // 제목
                Text(
                  job.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // 위치
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        job.address,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // 구분선
                Container(
                  height: 1,
                  color: Colors.grey.withValues(alpha: 0.1),
                ),
                const SizedBox(height: 16),
                // 하단: 급여와 모집인원
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '급여',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[500],
                          ),
                        ),
                        const SizedBox(height: 4),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '${NumberFormat('#,###').format(job.wages)}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFFF2711C),
                                ),
                              ),
                              TextSpan(
                                text: '원',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          job.wageTypeName,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2711C).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '모집인원',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 2),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '${job.recruitmentCount}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFFF2711C),
                                  ),
                                ),
                                TextSpan(
                                  text: '명',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
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
      ),
    );
  }

  Widget _buildFarmlandCard(IdleFarmlandResponse farmland) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 6),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 1),
            spreadRadius: -1,
          ),
        ],
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.08),
          width: 0.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // 유휴농지 상세 페이지로 이동
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => IdleFarmlandDetailScreen(farmlandId: farmland.id),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 상단: 상태 뱃지와 하트 아이콘
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2196F3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '임대가능',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.bookmark_border,
                        size: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // 제목
                Text(
                  farmland.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // 위치
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        farmland.address,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // 구분선
                Container(
                  height: 1,
                  color: Colors.grey.withValues(alpha: 0.1),
                ),
                const SizedBox(height: 16),
                // 하단: 면적과 임대료
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '면적',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[500],
                          ),
                        ),
                        const SizedBox(height: 4),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '${farmland.areaSize}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF4CAF50),
                                ),
                              ),
                              TextSpan(
                                text: '평',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '월 임대료',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${NumberFormat('#,###').format(farmland.monthlyRent ?? 0)}원',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF4CAF50),
                            ),
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
      ),
    );
  }

  Widget _buildJobListWithoutController() {
    if (_isLoading && _allJobPostings.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFF2711C),
        ),
      );
    }

    if (_allJobPostings.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.work_off,
              size: 48,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              '등록된 일자리가 없습니다',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          ...List.generate(_allJobPostings.length, (index) {
            final job = _allJobPostings[index];
            return _buildJobCard(job);
          }),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                '리스트를 전부 확인 하셨습니다.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdleFarmlandListWithoutController() {
    if (_idleFarmlands.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.agriculture,
              size: 48,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              '등록된 유휴농지가 없습니다',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          ...List.generate(_idleFarmlands.length, (index) {
            final farmland = _idleFarmlands[index];
            return _buildFarmlandCard(farmland);
          }),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                '리스트 끝',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdleFarmlandActionButtons() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          // 농지 관리 버튼
          Expanded(
            child: _buildActionButton(
              icon: FontAwesomeIcons.seedling,
              label: '농지 관리',
              color: const Color(0xFF4CAF50),
              onTap: () {
                // 농지 관리 기능 - 농지 리스트 화면으로 이동
                _navigateToIdleFarmlandList();
              },
            ),
          ),
          const SizedBox(width: 12),
          // 필터 버튼
          Expanded(
            child: _buildActionButton(
              icon: FontAwesomeIcons.filter,
              label: '필터',
              color: const Color(0xFF2196F3),
              onTap: () {
                _showFilterBottomSheet();
              },
            ),
          ),
          const SizedBox(width: 12),
          // 정렬 버튼
          Expanded(
            child: _buildActionButton(
              icon: FontAwesomeIcons.sort,
              label: '정렬',
              color: const Color(0xFFFF9800),
              onTap: () {
                _showSortBottomSheet();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withOpacity(0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // 핸들
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // 헤더
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(
                    FontAwesomeIcons.filter,
                    color: const Color(0xFF2196F3),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    '필터 설정',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('완료'),
                  ),
                ],
              ),
            ),
            // 필터 내용
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFilterSection('면적', [
                      '100평 미만',
                      '100-300평',
                      '300-500평',
                      '500평 이상',
                    ]),
                    _buildFilterSection('임대료', [
                      '10만원 미만',
                      '10-30만원',
                      '30-50만원',
                      '50만원 이상',
                    ]),
                    _buildFilterSection('편의시설', [
                      '수도 공급',
                      '전기 공급',
                      '농기구 포함',
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSortBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 핸들
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // 헤더
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(
                    FontAwesomeIcons.sort,
                    color: const Color(0xFFFF9800),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    '정렬 기준',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            // 정렬 옵션들
            _buildSortOption('최신순', true),
            _buildSortOption('면적 큰 순', false),
            _buildSortOption('면적 작은 순', false),
            _buildSortOption('가격 높은 순', false),
            _buildSortOption('가격 낮은 순', false),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection(String title, List<String> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) => FilterChip(
            label: Text(option),
            selected: false,
            onSelected: (selected) {
              // 필터 선택 로직
            },
            backgroundColor: Colors.grey[100],
            selectedColor: const Color(0xFF2196F3).withOpacity(0.2),
            checkmarkColor: const Color(0xFF2196F3),
          )).toList(),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSortOption(String title, bool isSelected) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          color: isSelected ? const Color(0xFFFF9800) : Colors.black87,
        ),
      ),
      trailing: isSelected
        ? const Icon(
            Icons.check,
            color: Color(0xFFFF9800),
          )
        : null,
      onTap: () {
        Navigator.pop(context);
        // 정렬 로직 구현
      },
    );
  }

  void _startChatWithJobOwner(JobPostingResponse job) async {
    final store = StoreProvider.of<AppState>(context, listen: false);
    final user = store.state.userState.user;
    
    if (user == null) {
      _showLoginRequiredDialog();
      return;
    }
    
    if (job.author.email?.isEmpty ?? true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('일자리 작성자의 연락처 정보가 없습니다.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    store.dispatch(GetOrCreateOneToOneRoomAction(job.author.email!));
    
    // 채팅방 생성/조회 완료를 기다리기 위해 작은 지연 후 채팅 화면으로 이동
    Future.delayed(const Duration(milliseconds: 500), () {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ChatRoomScreen(
            roomId: job.author.email!, // 임시로 이메일을 roomId로 사용
            roomName: job.author.nickname,
          ),
        ),
      );
    });
  }
  
  void _startChatWithFarmlandOwner(IdleFarmlandResponse farmland) async {
    final store = StoreProvider.of<AppState>(context, listen: false);
    final user = store.state.userState.user;
    
    if (user == null) {
      _showLoginRequiredDialog();
      return;
    }
    
    if (farmland.contactEmail == null || farmland.contactEmail!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('농지 소유자의 연락처 정보가 없습니다.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    store.dispatch(GetOrCreateOneToOneRoomAction(farmland.contactEmail!));
    
    // 채팅방 생성/조회 완료를 기다리기 위해 작은 지연 후 채팅 화면으로 이동
    Future.delayed(const Duration(milliseconds: 500), () {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ChatRoomScreen(
            roomId: farmland.contactEmail!, // 임시로 이메일을 roomId로 사용
            roomName: farmland.farmlandName,
          ),
        ),
      );
    });
  }
}

class SpeechBubblePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFFF2711C),
          Color(0xFFFF8C42),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = const Color(0xFFF2711C).withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final path = Path();
    final radius = 12.0;
    final arrowSize = 8.0;

    // 말풍선 본체 (둥근 사각형)
    path.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(arrowSize, 0, size.width - arrowSize, size.height),
      Radius.circular(radius),
    ));

    // 왼쪽 화살표 (돌하르방을 가리키는)
    path.moveTo(arrowSize, size.height * 0.5 - arrowSize * 0.5);
    path.lineTo(0, size.height * 0.5);
    path.lineTo(arrowSize, size.height * 0.5 + arrowSize * 0.5);
    path.close();

    // 그림자 그리기
    canvas.drawPath(path, shadowPaint);

    // 말풍선 그리기
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class WhiteSpeechBubblePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = const Color(0xFFF2711C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final radius = 20.0;
    final arrowSize = 8.0;

    // 전체 말풍선을 하나의 경로로 그리기 (화살표와 본체 연결)
    final path = Path();
    
    // 말풍선 본체의 둥근 사각형 부분
    final bodyRect = Rect.fromLTWH(arrowSize, 0, size.width - arrowSize, size.height);
    final bodyRRect = RRect.fromRectAndRadius(bodyRect, Radius.circular(radius));
    path.addRRect(bodyRRect);
    
    // 화살표 부분을 본체와 연결
    final arrowPath = Path();
    arrowPath.moveTo(arrowSize, size.height * 0.5 - arrowSize * 0.5);
    arrowPath.lineTo(0, size.height * 0.5);
    arrowPath.lineTo(arrowSize, size.height * 0.5 + arrowSize * 0.5);
    
    // 화살표를 메인 경로에 결합하되, 연결 부분의 선은 제거
    path.addPath(arrowPath, Offset.zero);

    // 그림자 그리기
    canvas.drawPath(path, shadowPaint);

    // 흰색 배경 그리기
    canvas.drawPath(path, fillPaint);

    // 주황색 테두리 그리기 (화살표 연결 부분 제외)
    // 본체 테두리
    canvas.drawRRect(bodyRRect, strokePaint);
    
    // 화살표 테두리 (연결 부분 제외하고 외곽선만)
    final arrowStrokePath = Path();
    arrowStrokePath.moveTo(arrowSize, size.height * 0.5 - arrowSize * 0.5);
    arrowStrokePath.lineTo(0, size.height * 0.5);
    arrowStrokePath.lineTo(arrowSize, size.height * 0.5 + arrowSize * 0.5);
    
    canvas.drawPath(arrowStrokePath, strokePaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class LeftArrowSpeechBubblePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = const Color(0xFFF2711C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final radius = 20.0;
    final arrowSize = 8.0;

    // 전체 말풍선을 하나의 경로로 그리기 (화살표와 본체 연결)
    final path = Path();
    
    // 말풍선 본체의 둥근 사각형 부분
    final bodyRect = Rect.fromLTWH(arrowSize, 0, size.width - arrowSize, size.height);
    final bodyRRect = RRect.fromRectAndRadius(bodyRect, Radius.circular(radius));
    path.addRRect(bodyRRect);
    
    // 왼쪽 중간에 화살표 부분을 본체와 연결
    final arrowPath = Path();
    arrowPath.moveTo(arrowSize, size.height * 0.5 - arrowSize * 0.5);
    arrowPath.lineTo(0, size.height * 0.5);
    arrowPath.lineTo(arrowSize, size.height * 0.5 + arrowSize * 0.5);
    
    // 화살표를 메인 경로에 결합
    path.addPath(arrowPath, Offset.zero);

    // 그림자 그리기
    canvas.drawPath(path, shadowPaint);

    // 흰색 배경 그리기
    canvas.drawPath(path, fillPaint);

    // 주황색 테두리 그리기 (화살표 연결 부분 제외)
    // 본체 테두리
    canvas.drawRRect(bodyRRect, strokePaint);
    
    // 화살표 테두리 (연결 부분 제외하고 외곽선만)
    final arrowStrokePath = Path();
    arrowStrokePath.moveTo(arrowSize, size.height * 0.5 - arrowSize * 0.5);
    arrowStrokePath.lineTo(0, size.height * 0.5);
    arrowStrokePath.lineTo(arrowSize, size.height * 0.5 + arrowSize * 0.5);
    
    canvas.drawPath(arrowStrokePath, strokePaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class ModernSpeechBubblePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 그라데이션 배경
    final gradientPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.white,
          const Color(0xFFFAFAFA),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    // 테두리
    final strokePaint = Paint()
      ..color = const Color(0xFFF2711C).withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // 그림자 (더 부드럽고 자연스러운)
    final shadowPaint = Paint()
      ..color = const Color(0xFFF2711C).withOpacity(0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    final shadowPaint2 = Paint()
      ..color = Colors.black.withOpacity(0.06)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    final radius = 18.0;
    final arrowSize = 10.0;

    // 말풍선 경로 생성
    final path = Path();
    
    // 말풍선 본체 (더 둥글고 현대적인 형태)
    final bodyRect = Rect.fromLTWH(arrowSize, 0, size.width - arrowSize, size.height);
    final bodyRRect = RRect.fromRectAndRadius(bodyRect, Radius.circular(radius));
    path.addRRect(bodyRRect);
    
    // 더 부드러운 화살표 (곡선 사용)
    final arrowPath = Path();
    arrowPath.moveTo(arrowSize, size.height * 0.5 - arrowSize * 0.4);
    arrowPath.quadraticBezierTo(
      arrowSize * 0.3, size.height * 0.5 - arrowSize * 0.1,
      0, size.height * 0.5,
    );
    arrowPath.quadraticBezierTo(
      arrowSize * 0.3, size.height * 0.5 + arrowSize * 0.1,
      arrowSize, size.height * 0.5 + arrowSize * 0.4,
    );
    
    path.addPath(arrowPath, Offset.zero);

    // 그림자 그리기 (다중 그림자로 더 입체적)
    canvas.drawPath(path, shadowPaint2);
    canvas.drawPath(path, shadowPaint);

    // 배경 그리기
    canvas.drawPath(path, gradientPaint);

    // 테두리 그리기
    canvas.drawRRect(bodyRRect, strokePaint);
    
    // 화살표 테두리 (더 부드럽게)
    final arrowStrokePath = Path();
    arrowStrokePath.moveTo(arrowSize, size.height * 0.5 - arrowSize * 0.4);
    arrowStrokePath.quadraticBezierTo(
      arrowSize * 0.3, size.height * 0.5 - arrowSize * 0.1,
      0, size.height * 0.5,
    );
    arrowStrokePath.quadraticBezierTo(
      arrowSize * 0.3, size.height * 0.5 + arrowSize * 0.1,
      arrowSize, size.height * 0.5 + arrowSize * 0.4,
    );
    
    canvas.drawPath(arrowStrokePath, strokePaint);

    // 내부 하이라이트 (더 현대적인 느낌)
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    
    final highlightPath = Path();
    final highlightRect = Rect.fromLTWH(
      arrowSize + 2, 
      2, 
      size.width - arrowSize - 4, 
      size.height - 4
    );
    final highlightRRect = RRect.fromRectAndRadius(
      highlightRect, 
      Radius.circular(radius - 2)
    );
    highlightPath.addRRect(highlightRRect);
    canvas.drawPath(highlightPath, highlightPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}