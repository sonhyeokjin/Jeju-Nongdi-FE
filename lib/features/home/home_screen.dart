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
import 'package:jejunongdi/screens/ai_assistant_screen.dart';
import 'package:jejunongdi/screens/idle_farmland_list_screen.dart';
import 'package:jejunongdi/core/models/idle_farmland_models.dart';
import 'package:jejunongdi/core/services/idle_farmland_service.dart';
import 'package:intl/intl.dart';

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
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: _navigateToAiAssistant,
                        child: Container(
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
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Image.asset(
                              'lib/assets/images/dol_hareubang_emti.png',
                              height: 32,
                              width: 32,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      CustomPaint(
                        painter: SpeechBubblePainter(),
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(12, 8, 10, 8),
                          child: const Text(
                            ' 클릭하면 AI 팁!',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox.shrink(), // 빈 공간으로 대체
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
                        Colors.white.withOpacity(0.95),
                        Colors.grey[50]!.withOpacity(0.95),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFFF2711C).withOpacity(0.2),
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
                          Colors.white.withOpacity(0.95),
                          Colors.grey[50]!.withOpacity(0.95),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: const Color(0xFFF2711C).withOpacity(0.2),
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
                              borderRadius: BorderRadius.circular(8),
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
                                      borderRadius: BorderRadius.circular(6),
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
                                      borderRadius: BorderRadius.circular(6),
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
                              child: FloatingActionButton(
                                onPressed: _selectedTabIndex == 0 ? _showWorkerRecruit : _navigateToIdleFarmlandCreate,
                                backgroundColor: const Color(0xFFF2711C),
                                foregroundColor: Colors.white,
                                child: Icon(
                                  _selectedTabIndex == 0 ? Icons.add : Icons.add_location,
                                  size: 24,
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
    // 유휴농지 등록 화면으로 이동 (필요시 구현)
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
      controller: scrollController,
      physics: const ClampingScrollPhysics(),
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
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () => _showJobPostingDetails(job),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                job.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 14,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      job.address,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${NumberFormat('#,###').format(job.wages)}원/${job.wageTypeName}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF2711C),
                    ),
                  ),
                  Text(
                    '모집 ${job.recruitmentCount}명',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFarmlandCard(IdleFarmlandResponse farmland) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () {
          // 유휴농지 상세 보기 (필요시 구현)
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                farmland.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 14,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      farmland.address,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${farmland.areaSize}평',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF2711C),
                    ),
                  ),
                  Text(
                    '월 ${NumberFormat('#,###').format(farmland.monthlyRent ?? 0)}원',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
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