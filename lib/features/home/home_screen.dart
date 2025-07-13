import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:jejunongdi/core/models/job_posting_model.dart';
import 'package:jejunongdi/core/services/job_posting_service.dart';
import 'package:jejunongdi/core/utils/logger.dart';
import 'package:jejunongdi/screens/widgets/job_posting_detail_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  NaverMapController? _controller;
  final Set<NMarker> _markers = {};
  List<JobPostingResponse> _jobPostings = [];
  final JobPostingService _jobPostingService = JobPostingService.instance;
  Timer? _debounceTimer;
  bool _isLoading = false;
  double _sheetExtent = 0.3;

  // 제주도 중심 좌표
  static const NLatLng _initialPosition = NLatLng(33.375, 126.49);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onMapReady(NaverMapController controller) {
    _controller = controller;
    Logger.info('네이버 지도 초기화 완료');
    
    // 초기 데이터 로드
    _loadJobPostingsForCurrentView();
  }

  void _onCameraChange(NCameraUpdateReason reason, bool animated) {
    // 지도 이동 중에는 API 호출하지 않음
    Logger.debug('카메라 이동 중: $reason');
  }

  void _onCameraIdle() {
    // 지도 이동이 완료된 후 디바운스를 적용하여 API 호출
    Logger.debug('카메라 이동 완료');
    
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 800), () {
      _loadJobPostingsForCurrentView();
    });
  }

  Future<void> _loadJobPostingsForCurrentView() async {
    if (!mounted || _controller == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // 현재 화면의 경계(bounds) 계산
      final bounds = await _controller!.getContentBounds();
      
      Logger.info('현재 지도 범위: ${bounds.southWest} ~ ${bounds.northEast}');

      // API 호출
      final result = await _jobPostingService.getJobPostingsByBounds(
        minLat: bounds.southWest.latitude,
        maxLat: bounds.northEast.latitude,
        minLng: bounds.southWest.longitude,
        maxLng: bounds.northEast.longitude,
      );

      if (result.isSuccess && mounted) {
        await _updateMarkers(result.data!);
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
    if (_controller == null) return;
    
    try {
      // 기존 마커 제거
      await _controller!.clearOverlays();
      _markers.clear();

      // 새로운 마커 추가
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

          // 마커 클릭 이벤트
          marker.setOnTapListener((NMarker marker) {
            _showJobPostingDetails(jobPosting);
          });

          _markers.add(marker);
          await _controller!.addOverlay(marker);
        } catch (e) {
          Logger.error('마커 생성 실패: ${jobPosting.id}', error: e);
        }
      }

      setState(() {
        _jobPostings = jobPostings;
      });

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
                child: NaverMap(
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
                ),
              ),
            ),

            // 2. Top floating UI
            SafeArea(
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

                    // 오른쪽 아이콘 버튼들
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

            // 3. 정보 카드
            Positioned(
              top: 90,
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

            // 4. Draggable bottom sheet
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
                                        color: const Color(0xFFF2711C).withValues(alpha: 0.3),
                                        blurRadius: 20,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: _loadJobPostingsForCurrentView,
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
}
