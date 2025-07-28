import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jejunongdi/core/services/price_service.dart';

class PriceMonitoringScreen extends StatefulWidget {
  const PriceMonitoringScreen({super.key});

  @override
  State<PriceMonitoringScreen> createState() => _PriceMonitoringScreenState();
}

class _PriceMonitoringScreenState extends State<PriceMonitoringScreen>
    with SingleTickerProviderStateMixin {
  
  late TabController _tabController;
  final PriceService _priceService = PriceService.instance;
  
  List<JejuSpecialty> _jejuSpecialties = [];
  final Map<String, CropPrice> _watchedCrops = {};
  final Map<String, PriceTrend> _priceTrends = {};
  
  bool _isLoading = false;
  String? _errorMessage;
  
  final TextEditingController _searchController = TextEditingController();
  final List<String> _popularCrops = [
    '감귤',
    '무',
    '배추',
    '당근',
    '브로콜리',
    '양파',
    '감자',
    '토마토',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadInitialData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 제주 특산품 목록 로드
      final specialtiesResult = await _priceService.getJejuSpecialties();
      if (specialtiesResult.isSuccess) {
        setState(() {
          _jejuSpecialties = specialtiesResult.data!;
        });
      }

      // 인기 작물들의 가격 정보 로드
      for (final crop in _popularCrops.take(3)) {
        final priceResult = await _priceService.getCropPrice(crop);
        if (priceResult.isSuccess) {
          setState(() {
            _watchedCrops[crop] = priceResult.data!;
          });
        }
      }

    } catch (e) {
      setState(() {
        _errorMessage = '가격 정보를 불러오는 중 오류가 발생했습니다: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _searchCropPrice(String cropName) async {
    if (cropName.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final priceResult = await _priceService.getCropPrice(cropName);
      final trendResult = await _priceService.getPriceTrend(cropName);

      if (priceResult.isSuccess) {
        setState(() {
          _watchedCrops[cropName] = priceResult.data!;
        });
        
        if (trendResult.isSuccess) {
          setState(() {
            _priceTrends[cropName] = trendResult.data!;
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$cropName 가격 정보를 불러왔습니다.'),
            backgroundColor: const Color(0xFFF2711C),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(priceResult.error?.message ?? '$cropName 가격 정보를 찾을 수 없습니다.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('가격 검색 중 오류가 발생했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
      _searchController.clear();
    }
  }

  Future<void> _getCropGuide(String cropName) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final guideResult = await _priceService.getCropGuide(cropName);
      
      if (guideResult.isSuccess) {
        _showCropGuideDialog(cropName, guideResult.data!);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(guideResult.error?.message ?? '$cropName 가이드를 불러올 수 없습니다.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('가이드 조회 중 오류가 발생했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showCropGuideDialog(String cropName, String guide) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(FontAwesomeIcons.seedling, color: Color(0xFFF2711C)),
            const SizedBox(width: 8),
            Text('$cropName 재배 가이드'),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(guide),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          '가격 모니터링',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(FontAwesomeIcons.chartLine),
              text: '관심 작물',
            ),
            Tab(
              icon: Icon(FontAwesomeIcons.star),
              text: '제주 특산품',
            ),
            Tab(
              icon: Icon(FontAwesomeIcons.magnifyingGlass),
              text: '가격 검색',
            ),
          ],
          labelColor: const Color(0xFFF2711C),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFFF2711C),
        ),
      ),
      body: _isLoading && _watchedCrops.isEmpty
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFF2711C),
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildWatchedCropsTab(),
                _buildSpecialtiesTab(),
                _buildSearchTab(),
              ],
            ),
    );
  }

  Widget _buildWatchedCropsTab() {
    return RefreshIndicator(
      onRefresh: _loadInitialData,
      color: const Color(0xFFF2711C),
      child: _watchedCrops.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    FontAwesomeIcons.chartLine,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    '관심 작물을 추가해보세요!\n검색 탭에서 작물을 검색할 수 있습니다.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _watchedCrops.length,
              itemBuilder: (context, index) {
                final entry = _watchedCrops.entries.elementAt(index);
                final cropName = entry.key;
                final cropPrice = entry.value;
                final trend = _priceTrends[cropName];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF2711C).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                FontAwesomeIcons.seedling,
                                color: Color(0xFFF2711C),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    cropPrice.cropName,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF333333),
                                    ),
                                  ),
                                  Text(
                                    _formatDateTime(cropPrice.lastUpdated),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => _getCropGuide(cropName),
                              icon: const Icon(
                                FontAwesomeIcons.infoCircle,
                                size: 20,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '현재가격',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  '${cropPrice.currentPrice.toStringAsFixed(0)}원/${cropPrice.unit}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFF2711C),
                                  ),
                                ),
                              ],
                            ),
                            
                            if (cropPrice.changeRate != null) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: cropPrice.changeRate! > 0
                                      ? Colors.red.withOpacity(0.1)
                                      : cropPrice.changeRate! < 0
                                          ? Colors.blue.withOpacity(0.1)
                                          : Colors.grey.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      cropPrice.changeRate! > 0
                                          ? FontAwesomeIcons.arrowUp
                                          : cropPrice.changeRate! < 0
                                              ? FontAwesomeIcons.arrowDown
                                              : FontAwesomeIcons.minus,
                                      size: 12,
                                      color: cropPrice.changeRate! > 0
                                          ? Colors.red
                                          : cropPrice.changeRate! < 0
                                              ? Colors.blue
                                              : Colors.grey,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${cropPrice.changeRate!.abs().toStringAsFixed(1)}%',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: cropPrice.changeRate! > 0
                                            ? Colors.red
                                            : cropPrice.changeRate! < 0
                                                ? Colors.blue
                                                : Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                        
                        if (trend != null) ...[
                          const SizedBox(height: 12),
                          const Divider(),
                          const SizedBox(height: 8),
                          Text(
                            '분석',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            trend.analysis,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                              height: 1.3,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildSpecialtiesTab() {
    return RefreshIndicator(
      onRefresh: _loadInitialData,
      color: const Color(0xFFF2711C),
      child: _jejuSpecialties.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    FontAwesomeIcons.star,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    '제주 특산품 정보를 불러오는 중입니다...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.8,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _jejuSpecialties.length,
              itemBuilder: (context, index) {
                final specialty = _jejuSpecialties[index];
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                FontAwesomeIcons.star,
                                color: Colors.orange,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                specialty.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF333333),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        
                        Text(
                          specialty.description,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            height: 1.3,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        
                        const Spacer(),
                        
                        Row(
                          children: [
                            Icon(
                              FontAwesomeIcons.mapLocationDot,
                              size: 12,
                              color: Colors.grey[500],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              specialty.region,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[500],
                              ),
                            ),
                            const Spacer(),
                            Text(
                              specialty.season,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFFF2711C),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 8),
                        Text(
                          '${specialty.currentPrice.toStringAsFixed(0)}원',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFF2711C),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildSearchTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 검색창
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: '작물명을 입력하세요 (예: 감귤, 무, 배추)',
                    prefixIcon: const Icon(FontAwesomeIcons.magnifyingGlass),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFF2711C)),
                    ),
                  ),
                  onSubmitted: _searchCropPrice,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () => _searchCropPrice(_searchController.text),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF2711C),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('검색'),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // 인기 작물
          const Text(
            '인기 작물',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 12),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _popularCrops.map((crop) {
              final isWatched = _watchedCrops.containsKey(crop);
              return GestureDetector(
                onTap: () => _searchCropPrice(crop),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isWatched
                        ? const Color(0xFFF2711C).withOpacity(0.1)
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isWatched
                          ? const Color(0xFFF2711C)
                          : Colors.grey[300]!,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isWatched) ...[
                        const Icon(
                          FontAwesomeIcons.check,
                          size: 12,
                          color: Color(0xFFF2711C),
                        ),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        crop,
                        style: TextStyle(
                          fontSize: 14,
                          color: isWatched
                              ? const Color(0xFFF2711C)
                              : Colors.grey[700],
                          fontWeight: isWatched
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          
          if (_errorMessage != null) ...[
            const SizedBox(height: 24),
            Card(
              color: Colors.red[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(
                      FontAwesomeIcons.circleExclamation,
                      color: Colors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}분 전 업데이트';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}시간 전 업데이트';
    } else {
      return '${dateTime.month}/${dateTime.day} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }
}