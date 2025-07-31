import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:jejunongdi/core/models/job_posting_model.dart';
import 'package:jejunongdi/core/models/place_search_models.dart';
import 'package:jejunongdi/core/services/job_posting_service.dart';
import 'package:jejunongdi/core/services/place_search_service.dart';
import 'package:jejunongdi/core/utils/logger.dart';
import 'package:jejunongdi/screens/widgets/job_posting_detail_sheet.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  NaverMapController? _controller;
  final Set<NMarker> _jobMarkers = {};
  final Set<NMarker> _farmMarkers = {};
  List<JobPostingResponse> _jobPostings = [];
  List<NaverPlace> _farms = [];
  final JobPostingService _jobPostingService = JobPostingService.instance;
  final PlaceSearchService _placeSearchService = PlaceSearchService.instance;
  Timer? _debounceTimer;
  bool _isLoading = false;
  bool _showFarms = true;
  bool _showJobs = true;

  // 검색 관련
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  // 제주도 중심 좌표
  static const NLatLng _initialPosition = NLatLng(33.375, 126.49);

  // 생성자에서 로그 찍기
  _MapScreenState() {
    print('🏗️ _MapScreenState 생성자 호출됨');
  }

  @override
  void initState() {
    super.initState();
    print('🔍 MapScreen initState 호출됨');
    // 지도 초기화 후 _onMapReady에서 데이터 로드
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onMapReady(NaverMapController controller) {
    print('🎉 네이버 지도 초기화 완료! Controller: $controller');
    _controller = controller;
    
    // API 연결 테스트
    print('🔧 API 연결 테스트 시작...');
    _testApiConnection();
    
    // 초기 데이터 로드 (지도 영역 기반)
    print('📡 초기 데이터 로드 시작...');
    _loadJobPostingsForCurrentView();
    _loadFarmsForCurrentView();
  }

  Future<void> _testApiConnection() async {
    print('🔧 _testApiConnection 메서드 시작');
    try {
      final isConnected = await _placeSearchService.testNaverApiConnection();
      print('🔧 API 연결 테스트 결과: $isConnected');
      
      if (mounted) {
        if (isConnected) {
          print('✅ API 연결 성공 - 성공 메시지 표시');
          _showInfoSnackBar('네이버 API 연결 성공! 실제 농장 데이터를 사용합니다 🎉');
        } else {
          print('❌ API 연결 실패 - 실패 메시지 표시');
          _showInfoSnackBar('네이버 API 연결 실패. 샘플 데이터를 사용합니다 📝');
        }
      } else {
        print('⚠️ Widget이 mounted되지 않음');
      }
    } catch (e) {
      print('💥 _testApiConnection 에러: $e');
    }
  }

  void _onCameraChange(NCameraUpdateReason reason, bool animated) {
    // 지도 이동 중에는 API 호출하지 않음
    print('카메라 이동 중: $reason');
  }

  void _onCameraIdle() {
    // 지도 이동이 완료된 후 디바운스를 적용하여 API 호출
    print('카메라 이동 완료');
    
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 800), () {
      _loadJobPostingsForCurrentView();
      _loadFarmsForCurrentView(); // 농장도 현재 영역 기준으로 로드
    });
  }

  Future<void> _loadJobPostingsForCurrentView() async {
    if (!mounted || _controller == null || !_showJobs) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // 현재 화면의 경계(bounds) 계산
      final bounds = await _controller!.getContentBounds();
      
      print('현재 지도 범위: ${bounds.southWest} ~ ${bounds.northEast}');

      // API 호출
      final result = await _jobPostingService.getJobPostingsByBounds(
        minLat: bounds.southWest.latitude,
        maxLat: bounds.northEast.latitude,
        minLng: bounds.southWest.longitude,
        maxLng: bounds.northEast.longitude,
      );

      if (result.isSuccess && mounted) {
        await _updateJobMarkers(result.data!);
      } else if (result.isFailure && mounted) {
        final errorMsg = result.error?.message ?? "알 수 없는 오류";
        _showErrorSnackBar('일자리 데이터를 불러오는데 실패했습니다: $errorMsg');
      }
    } catch (e) {
      Logger.error('일자리 데이터 로드 실패', error: e);
      if (mounted) {
        _showErrorSnackBar('일자리 데이터를 불러오는데 실패했습니다: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadFarmsForCurrentView() async {
    if (!mounted || _controller == null || !_showFarms) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // 현재 화면의 경계(bounds) 계산
      final bounds = await _controller!.getContentBounds();
      
      print('농장 검색 지도 범위: ${bounds.southWest} ~ ${bounds.northEast}');

      List<NaverPlace> farms;
      
      if (!_placeSearchService.isApiKeyConfigured) {
        // API 키가 설정되지 않았으면 샘플 데이터에서 영역 필터링
        farms = await _placeSearchService.getSampleFarmsInBounds(
          minLat: bounds.southWest.latitude,
          maxLat: bounds.northEast.latitude,
          minLng: bounds.southWest.longitude,
          maxLng: bounds.northEast.longitude,
        );
      } else {
        // API 키가 설정되어 있으면 실제 영역 검색 수행
        farms = await _placeSearchService.searchFarmsInBounds(
          minLat: bounds.southWest.latitude,
          maxLat: bounds.northEast.latitude,
          minLng: bounds.southWest.longitude,
          maxLng: bounds.northEast.longitude,
        );
      }
      
      if (mounted) {
        await _updateFarmMarkers(farms);
      }
    } catch (e) {
      print('현재 영역 농장 데이터 로드 실패: $e');
      if (mounted) {
        _showErrorSnackBar('농장 데이터를 불러오는데 실패했습니다: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadJejuFarms() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      List<NaverPlace> farms;
      
      // API 키가 설정되어 있는지 확인
      if (!_placeSearchService.isApiKeyConfigured) {
        // API 키가 설정되지 않았으면 샘플 데이터 사용
        print('네이버 API 키가 설정되지 않았습니다. 샘플 농장 데이터를 사용합니다.');
        farms = await _placeSearchService.getSampleFarms();
        if (mounted) {
          _showInfoSnackBar('샘플 농장 데이터를 표시합니다. 실제 데이터를 보려면 네이버 API 키를 설정하세요.');
        }
      } else {
        print('네이버 API 키가 설정되어 있습니다. 실제 제주 농장 데이터를 검색합니다.');
        // API 키가 설정되어 있으면 실제 검색 수행
        farms = await _placeSearchService.searchJejuFarms();
      }
      
      if (mounted) {
        await _updateFarmMarkers(farms);
      }
    } catch (e) {
      print('제주 농장 데이터 로드 실패: $e');
      if (mounted) {
        _showErrorSnackBar('농장 데이터를 불러오는데 실패했습니다: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _searchFarms(String query) async {
    if (query.trim().isEmpty || !mounted) return;

    setState(() {
      _isSearching = true;
    });

    try {
      List<NaverPlace> farms;
      
      if (!_placeSearchService.isApiKeyConfigured) {
        // API 키가 설정되지 않았으면 샘플 데이터에서 필터링
        final allSampleFarms = await _placeSearchService.getSampleFarms();
        farms = allSampleFarms.where((farm) {
          final lowerQuery = query.trim().toLowerCase();
          final lowerTitle = farm.cleanTitle.toLowerCase();
          final lowerDescription = farm.cleanDescription.toLowerCase();
          
          return lowerTitle.contains(lowerQuery) || 
                 lowerDescription.contains(lowerQuery);
        }).toList();
        
        if (mounted) {
          _showInfoSnackBar('샘플 데이터에서 검색했습니다. ${farms.length}개의 농장을 찾았습니다.');
        }
      } else {
        // API 키가 설정되어 있으면 실제 검색 수행
        farms = await _placeSearchService.searchFarms(query: query.trim());
        if (mounted) {
          _showInfoSnackBar('${farms.length}개의 농장을 찾았습니다');
        }
      }
      
      if (mounted) {
        await _updateFarmMarkers(farms);
        
        // 검색 결과가 있으면 첫 번째 농장으로 이동
        if (farms.isNotEmpty && _controller != null) {
          final firstFarm = farms.first;
          _controller!.updateCamera(
            NCameraUpdate.fromCameraPosition(
              NCameraPosition(
                target: NLatLng(firstFarm.latitude, firstFarm.longitude),
                zoom: 13.0,
              ),
            ),
          );
        }
      }
    } catch (e) {
      print('농장 검색 실패: $e');
      if (mounted) {
        _showErrorSnackBar('농장 검색에 실패했습니다: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  Future<void> _updateJobMarkers(List<JobPostingResponse> jobPostings) async {
    if (_controller == null || !_showJobs) return;
    
    try {
      // 기존 일자리 마커 제거
      for (final marker in _jobMarkers) {
        await _controller!.deleteOverlay(marker.info);
      }
      _jobMarkers.clear();

      // 새로운 일자리 마커 추가
      for (final jobPosting in jobPostings) {
        try {
          final marker = NMarker(
            id: 'job_${jobPosting.id}',
            position: NLatLng(jobPosting.latitude, jobPosting.longitude),
            caption: NOverlayCaption(
              text: jobPosting.title.length > 10 
                  ? '${jobPosting.title.substring(0, 10)}...'
                  : jobPosting.title,
              textSize: 11,
              color: Colors.white,
              haloColor: Colors.blue[800]!,
            ),
            // 기본 마커 사용 (사용자 정의 아이콘 파일이 있으면 위 라인 주석해제)
            size: const Size(40, 40),
          );

          // 마커 클릭 이벤트
          marker.setOnTapListener((NMarker marker) {
            _showJobPostingDetails(jobPosting);
          });

          _jobMarkers.add(marker);
          await _controller!.addOverlay(marker);
        } catch (e) {
          print('일자리 마커 생성 실패: ${jobPosting.id}, 에러: $e');
        }
      }

      setState(() {
        _jobPostings = jobPostings;
      });

      print('일자리 마커 업데이트 완료: ${jobPostings.length}개');
    } catch (e) {
      print('일자리 마커 업데이트 실패: $e');
    }
  }

  Future<void> _updateFarmMarkers(List<NaverPlace> farms) async {
    if (_controller == null || !_showFarms) return;
    
    try {
      // 기존 농장 마커 제거
      for (final marker in _farmMarkers) {
        await _controller!.deleteOverlay(marker.info);
      }
      _farmMarkers.clear();

      // 새로운 농장 마커 추가
      for (final farm in farms) {
        try {
          final marker = NMarker(
            id: 'farm_${farm.title.hashCode}',
            position: NLatLng(farm.latitude, farm.longitude),
            caption: NOverlayCaption(
              text: farm.cleanTitle.length > 15 
                  ? '${farm.cleanTitle.substring(0, 15)}...'
                  : farm.cleanTitle,
              textSize: 11,
              color: Colors.white,
              haloColor: Colors.green[700]!,
            ),
            size: const Size(35, 35),
          );

          // 마커 클릭 이벤트
          marker.setOnTapListener((NMarker marker) {
            _showFarmDetails(farm);
          });

          _farmMarkers.add(marker);
          await _controller!.addOverlay(marker);
        } catch (e) {
          print('농장 마커 생성 실패: ${farm.title}, 에러: $e');
        }
      }

      setState(() {
        _farms = farms;
      });

      print('농장 마커 업데이트 완료: ${farms.length}개');
    } catch (e) {
      print('농장 마커 업데이트 실패: $e');
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

  void _showFarmDetails(NaverPlace farm) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _FarmDetailSheet(farm: farm),
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

  void _showInfoSnackBar(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green[700],
        duration: const Duration(seconds: 2),
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

  void _toggleFarmVisibility() {
    setState(() {
      _showFarms = !_showFarms;
    });
    
    if (_showFarms) {
      _loadFarmsForCurrentView();
    } else {
      // 농장 마커 숨기기
      for (final marker in _farmMarkers) {
        _controller?.deleteOverlay(marker.info);
      }
    }
  }

  void _toggleJobVisibility() {
    setState(() {
      _showJobs = !_showJobs;
    });
    
    if (_showJobs) {
      _loadJobPostingsForCurrentView();
    } else {
      // 일자리 마커 숨기기
      for (final marker in _jobMarkers) {
        _controller?.deleteOverlay(marker.info);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print('🔍 MapScreen build 호출됨');
    return Scaffold(
      appBar: AppBar(
        title: const Text('농사 일자리 & 농장 지도'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        actions: [
          if (_isLoading || _isSearching)
            Container(
              margin: const EdgeInsets.only(right: 16),
              child: const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.layers),
            onSelected: (value) {
              switch (value) {
                case 'toggle_farms':
                  _toggleFarmVisibility();
                  break;
                case 'toggle_jobs':
                  _toggleJobVisibility();
                  break;
                case 'refresh':
                  _loadJobPostingsForCurrentView();
                  _loadFarmsForCurrentView();
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'toggle_farms',
                child: Row(
                  children: [
                    Icon(
                      _showFarms ? Icons.visibility : Icons.visibility_off,
                      color: Colors.green[700],
                    ),
                    const SizedBox(width: 8),
                    Text('농장 ${_showFarms ? '숨기기' : '보이기'}'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'toggle_jobs',
                child: Row(
                  children: [
                    Icon(
                      _showJobs ? Icons.visibility : Icons.visibility_off,
                      color: Colors.blue[700],
                    ),
                    const SizedBox(width: 8),
                    Text('일자리 ${_showJobs ? '숨기기' : '보이기'}'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Icons.refresh),
                    SizedBox(width: 8),
                    Text('새로고침'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          NaverMap(
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
            onMapReady: (NaverMapController controller) {
              print('🗺️ NaverMap onMapReady 콜백 호출됨');
              _onMapReady(controller);
            },
            onCameraChange: (NCameraUpdateReason reason, bool animated) {
              print('📷 NaverMap onCameraChange: $reason');
              _onCameraChange(reason, animated);
            },
            onCameraIdle: () {
              print('📷 NaverMap onCameraIdle 호출됨');
              _onCameraIdle();
            },
            onMapTapped: (NPoint point, NLatLng latLng) {
              print('👆 지도 탭됨: $latLng');
            },
          ),
          
          // 검색바
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: '농장 이름을 검색하세요 (예: 감귤농장)',
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.search),
                        ),
                        onSubmitted: _searchFarms,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () => _searchFarms(_searchController.text),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // 정보 카드
          Positioned(
            top: 80,
            left: 16,
            right: 16,
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.agriculture, color: Colors.green[700]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '농장 ${_farms.length}개',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                        ),
                        Icon(Icons.work, color: Colors.blue[700]),
                        const SizedBox(width: 8),
                        Text(
                          '일자리 ${_jobPostings.length}개',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.green[700],
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text('농장', style: TextStyle(fontSize: 12)),
                        const SizedBox(width: 16),
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.blue[700],
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text('일자리', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // 🧪 임시 테스트 버튼
          Positioned(
            bottom: 200,
            right: 16,
            child: FloatingActionButton(
              onPressed: () {
                print('🧪 테스트 버튼 클릭됨!');
                print('🧪 _controller: $_controller');
                print('🧪 isApiKeyConfigured: ${_placeSearchService.isApiKeyConfigured}');
                _showInfoSnackBar('테스트 버튼 클릭됨! 콘솔을 확인하세요.');
              },
              heroTag: "test",
              backgroundColor: Colors.red,
              child: const Icon(Icons.bug_report),
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _moveToJejuCenter,
            heroTag: "center",
            backgroundColor: Colors.green[700],
            foregroundColor: Colors.white,
            tooltip: '제주도 중심으로 이동',
            child: const Icon(Icons.center_focus_strong),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () {
              _loadJobPostingsForCurrentView();
              _loadFarmsForCurrentView();
            },
            heroTag: "refresh",
            backgroundColor: Colors.blue[700],
            foregroundColor: Colors.white,
            tooltip: '새로고침',
            child: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }
}

// 농장 상세 정보를 보여주는 바텀시트
class _FarmDetailSheet extends StatelessWidget {
  final NaverPlace farm;

  const _FarmDetailSheet({required this.farm});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 핸들바
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
          
          // 농장 이름
          Text(
            farm.cleanTitle,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // 카테고리
          if (farm.cleanCategory.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                farm.cleanCategory,
                style: TextStyle(
                  color: Colors.green[800],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          const SizedBox(height: 16),
          
          // 주소
          if (farm.address.isNotEmpty)
            _DetailRow(
              icon: Icons.location_on,
              label: '주소',
              value: farm.address,
            ),
          
          // 도로명 주소
          if (farm.roadAddress.isNotEmpty && farm.roadAddress != farm.address)
            _DetailRow(
              icon: Icons.navigation,
              label: '도로명주소',
              value: farm.roadAddress,
            ),
          
          // 전화번호
          if (farm.telephone.isNotEmpty)
            _DetailRow(
              icon: Icons.phone,
              label: '전화번호',
              value: farm.telephone,
            ),
          
          // 설명
          if (farm.cleanDescription.isNotEmpty)
            _DetailRow(
              icon: Icons.info,
              label: '설명',
              value: farm.cleanDescription,
            ),
          
          // 좌표
          _DetailRow(
            icon: Icons.my_location,
            label: '좌표',
            value: '위도: ${farm.latitude.toStringAsFixed(6)}, 경도: ${farm.longitude.toStringAsFixed(6)}',
          ),
          
          const SizedBox(height: 20),
          
          // 닫기 버튼
          Center(
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                foregroundColor: Colors.white,
                minimumSize: const Size(200, 45),
              ),
              child: const Text('닫기'),
            ),
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
