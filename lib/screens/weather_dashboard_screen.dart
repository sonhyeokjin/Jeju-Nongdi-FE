import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jejunongdi/redux/app_state.dart';
import 'package:jejunongdi/core/services/weather_service.dart';

class WeatherDashboardScreen extends StatefulWidget {
  const WeatherDashboardScreen({super.key});

  @override
  State<WeatherDashboardScreen> createState() => _WeatherDashboardScreenState();
}

class _WeatherDashboardScreenState extends State<WeatherDashboardScreen>
    with SingleTickerProviderStateMixin {
  
  late TabController _tabController;
  final WeatherService _weatherService = WeatherService.instance;
  
  WeatherInfo? _jejuWeather;
  String? _farmworkRecommendations;
  String? _weatherSummary;
  String? _weatherAdvice;
  
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadWeatherData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadWeatherData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 병렬로 여러 API 호출
      // 개별적으로 API 호출
      final jejuWeatherResult = await _weatherService.getJejuWeather();
      final farmWorkResult = await _weatherService.getFarmWorkWeather(); 
      final summaryResult = await _weatherService.getWeatherSummary();

      setState(() {
        if (jejuWeatherResult.isSuccess) {
          _jejuWeather = jejuWeatherResult.data;
        }
        if (farmWorkResult.isSuccess) {
          _farmworkRecommendations = farmWorkResult.data!;
        }
        if (summaryResult.isSuccess) {
          _weatherSummary = summaryResult.data;
        }
      });

      // 사용자별 날씨 조언 로드
      await _loadWeatherAdvice();

    } catch (e) {
      setState(() {
        _errorMessage = '날씨 정보를 불러오는 중 오류가 발생했습니다: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadWeatherAdvice() async {
    final store = StoreProvider.of<AppState>(context, listen: false);
    final userIdString = store.state.userState.user?.id;

    if (userIdString != null) {
      final userId = int.tryParse(userIdString) ?? 0;
      if (userId > 0) {
        final adviceResult = await _weatherService.getWeatherAdvice(userId);
        if (adviceResult.isSuccess) {
          setState(() {
            _weatherAdvice = adviceResult.data;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          '날씨 대시보드',
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
              icon: Icon(FontAwesomeIcons.cloudSun),
              text: '현재 날씨',
            ),
            Tab(
              icon: Icon(FontAwesomeIcons.tractor),
              text: '농작업 권장',
            ),
            Tab(
              icon: Icon(FontAwesomeIcons.robot),
              text: 'AI 조언',
            ),
          ],
          labelColor: const Color(0xFFF2711C),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFFF2711C),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFF2711C),
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildCurrentWeatherTab(),
                _buildFarmWorkTab(),
                _buildAdviceTab(),
              ],
            ),
    );
  }

  Widget _buildCurrentWeatherTab() {
    return RefreshIndicator(
      onRefresh: _loadWeatherData,
      color: const Color(0xFFF2711C),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 날씨 요약 카드
            if (_weatherSummary != null) ...[
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4FC3F7), Color(0xFF29B6F6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            FontAwesomeIcons.cloudSun,
                            color: Colors.white,
                            size: 24,
                          ),
                          SizedBox(width: 12),
                          Text(
                            '날씨 요약',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _weatherSummary!,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // 제주 날씨 상세 정보
            if (_jejuWeather != null) ...[
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            FontAwesomeIcons.locationDot,
                            color: Color(0xFFF2711C),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _jejuWeather!.location,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF333333),
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
                                '${_jejuWeather!.temperature.toStringAsFixed(1)}°C',
                                style: const TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFF2711C),
                                ),
                              ),
                              Text(
                                _jejuWeather!.description,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          Icon(
                            _getWeatherIcon(_jejuWeather!.description),
                            size: 64,
                            color: const Color(0xFFF2711C),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 16),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              const Icon(
                                FontAwesomeIcons.droplet,
                                color: Colors.blue,
                                size: 20,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '습도',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                '${_jejuWeather!.humidity.toStringAsFixed(0)}%',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              const Icon(
                                FontAwesomeIcons.wind,
                                color: Colors.grey,
                                size: 20,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '풍속',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                '${_jejuWeather!.windSpeed.toStringAsFixed(1)}m/s',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              const Icon(
                                FontAwesomeIcons.clock,
                                color: Colors.orange,
                                size: 20,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '업데이트',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                _formatTime(_jejuWeather!.lastUpdated),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ] else if (_errorMessage != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Icon(
                        FontAwesomeIcons.circleExclamation,
                        size: 48,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _loadWeatherData,
                        icon: const Icon(FontAwesomeIcons.arrowRotateRight),
                        label: const Text('다시 시도'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF2711C),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFarmWorkTab() {
    return RefreshIndicator(
      onRefresh: _loadWeatherData,
      color: const Color(0xFFF2711C),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      FontAwesomeIcons.tractor,
                      color: Color(0xFFF2711C),
                      size: 24,
                    ),
                    SizedBox(width: 12),
                    Text(
                      '농작업 권장사항',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (_farmworkRecommendations != null) ...[
                  Text(
                    _farmworkRecommendations!,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF333333),
                      height: 1.5,
                    ),
                  ),
                ] else ...[
                  const Center(
                    child: Column(
                      children: [
                        CircularProgressIndicator(
                          color: Color(0xFFF2711C),
                        ),
                        SizedBox(height: 16),
                        Text(
                          '농작업 권장사항을 불러오는 중입니다...',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdviceTab() {
    return RefreshIndicator(
      onRefresh: _loadWeatherData,
      color: const Color(0xFFF2711C),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      FontAwesomeIcons.robot,
                      color: Color(0xFFF2711C),
                      size: 24,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'AI 날씨 기반 조언',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (_weatherAdvice != null) ...[
                  Text(
                    _weatherAdvice!,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF333333),
                      height: 1.5,
                    ),
                  ),
                ] else ...[
                  const Center(
                    child: Column(
                      children: [
                        CircularProgressIndicator(
                          color: Color(0xFFF2711C),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'AI가 날씨 기반 맞춤 조언을 생성하고 있습니다...',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getWeatherIcon(String description) {
    final lowerDescription = description.toLowerCase();
    if (lowerDescription.contains('맑')) {
      return FontAwesomeIcons.sun;
    } else if (lowerDescription.contains('구름')) {
      return FontAwesomeIcons.cloud;
    } else if (lowerDescription.contains('비')) {
      return FontAwesomeIcons.cloudRain;
    } else if (lowerDescription.contains('눈')) {
      return FontAwesomeIcons.snowflake;
    } else {
      return FontAwesomeIcons.cloudSun;
    }
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);
    
    final difference = targetDate.difference(today).inDays;
    
    if (difference == 0) {
      return '오늘';
    } else if (difference == 1) {
      return '내일';
    } else if (difference == -1) {
      return '어제';
    } else {
      return '${date.month}/${date.day}';
    }
  }
}