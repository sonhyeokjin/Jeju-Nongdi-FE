import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:jejunongdi/core/models/ai_tip_model.dart';
import 'package:jejunongdi/core/services/ai_tips_service.dart';
import 'package:jejunongdi/core/utils/logger.dart';
import 'package:jejunongdi/redux/app_state.dart';

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen>
    with TickerProviderStateMixin {
  final AiTipsService _aiTipsService = AiTipsService.instance;
  
  TodayFarmLifeModel? _todayFarmLife;
  List<AiTipModel> _notifications = [];
  List<AiTipModel> _dailyTips = [];
  List<TipTypeModel> _tipTypes = [];
  List<PestAlertModel> _pestAlerts = [];
  WeatherBasedTipModel? _weatherTip;
  CropGuideModel? _cropGuide;
  
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _loadInitialData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    
    try {
      // 병렬로 데이터 로드 (사용자 정보는 각 메소드에서 자동으로 가져옴)
      await Future.wait([
        _loadTodayFarmLife(),
        _loadNotifications(),
        _loadDailyTips(),
        _loadTipTypes(),
        _loadPestAlerts(),
        _loadWeatherTip(),
        _loadCropGuide(),
      ]);
    } catch (e) {
      Logger.error('AI 도우미 초기 데이터 로드 실패', error: e);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadTodayFarmLife() async {
    final result = await _aiTipsService.getTodayFarmLife();
    if (result.isSuccess && mounted) {
      setState(() => _todayFarmLife = result.data);
    }
  }

  Future<void> _loadNotifications() async {
    final result = await _aiTipsService.getNotifications();
    if (result.isSuccess && mounted) {
      setState(() => _notifications = result.data!);
    }
  }

  Future<void> _loadDailyTips() async {
    final result = await _aiTipsService.getDailyTips();
    if (result.isSuccess && mounted) {
      setState(() => _dailyTips = result.data!);
    }
  }

  Future<void> _loadTipTypes() async {
    final result = await _aiTipsService.getTipTypes();
    if (result.isSuccess && mounted) {
      setState(() => _tipTypes = result.data!);
    }
  }

  Future<void> _loadPestAlerts() async {
    final result = await _aiTipsService.getPestAlert(region: '제주도');
    if (result.isSuccess && mounted) {
      setState(() => _pestAlerts = result.data!);
    }
  }

  Future<void> _loadWeatherTip() async {
    final result = await _aiTipsService.getWeatherBasedTips();
    if (result.isSuccess && mounted) {
      setState(() => _weatherTip = result.data);
    }
  }

  Future<void> _loadCropGuide() async {
    final result = await _aiTipsService.getCropGuide('감귤');
    if (result.isSuccess && mounted) {
      setState(() => _cropGuide = result.data);
    }
  }

  Future<void> _generateNewTip() async {
    final result = await _aiTipsService.generateDailyTip();
    if (result.isSuccess) {
      _showSuccessSnackBar('새로운 맞춤 팁이 생성되었습니다!');
      _loadDailyTips();
    } else {
      _showErrorSnackBar('팁 생성에 실패했습니다.');
    }
  }

  Future<void> _markAsRead(AiTipModel tip) async {
    final result = await _aiTipsService.markTipAsRead(tip.id);
    if (result.isSuccess) {
      setState(() {
        final index = _notifications.indexWhere((t) => t.id == tip.id);
        if (index != -1) {
          _notifications[index] = tip.copyWith(isRead: true);
        }
      });
    }
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Text('🤖 AI 농업 도우미'),
          ],
        ),
        backgroundColor: const Color(0xFFF2711C),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: '오늘의 농업'),
            Tab(text: '알림'),
            Tab(text: '맞춤 팁'),
            Tab(text: '날씨 알림'),
            Tab(text: '병해충 경보'),
            Tab(text: '작물 가이드'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _generateNewTip,
            icon: const Icon(Icons.auto_awesome),
            tooltip: '새 팁 생성',
          ),
          IconButton(
            onPressed: _loadInitialData,
            icon: const Icon(Icons.refresh),
            tooltip: '새로고침',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFF2711C)))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildTodayFarmLifeTab(),
                _buildNotificationsTab(),
                _buildDailyTipsTab(),
                _buildWeatherTipTab(),
                _buildPestAlertsTab(),
                _buildCropGuideTab(),
              ],
            ),
    );
  }

  Widget _buildTodayFarmLifeTab() {
    if (_todayFarmLife == null) {
      return const Center(child: Text('오늘의 농업 정보를 불러올 수 없습니다.'));
    }

    return RefreshIndicator(
      onRefresh: _loadTodayFarmLife,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCard(),
            const SizedBox(height: 16),
            _buildWeatherAlertCard(),
            const SizedBox(height: 16),
            _buildCropTipCard(),
            const SizedBox(height: 16),
            _buildUrgentTasksCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.summarize, color: Color(0xFFF2711C)),
                SizedBox(width: 8),
                Text('오늘의 요약', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _todayFarmLife!.summary,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
            if (_todayFarmLife!.unreadNotifications > 0) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '읽지 않은 알림 ${_todayFarmLife!.unreadNotifications}개',
                  style: TextStyle(color: Colors.red[700], fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherAlertCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.wb_sunny, color: Colors.orange),
                SizedBox(width: 8),
                Text('날씨 알림', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _todayFarmLife!.weatherAlert,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCropTipCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.eco, color: Colors.green),
                SizedBox(width: 8),
                Text('작물 관리 팁', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _todayFarmLife!.cropTip,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUrgentTasksCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.priority_high, color: Colors.red),
                SizedBox(width: 8),
                Text('긴급 작업', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            if (_todayFarmLife!.urgentTasks.isEmpty)
              const Text('오늘은 긴급한 작업이 없습니다.', style: TextStyle(fontSize: 16))
            else
              ...(_todayFarmLife!.urgentTasks.map((task) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.task_alt, size: 20, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(child: Text(task, style: const TextStyle(fontSize: 16))),
                      ],
                    ),
                  ))),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsTab() {
    return RefreshIndicator(
      onRefresh: _loadNotifications,
      child: _notifications.isEmpty
          ? const Center(child: Text('알림이 없습니다.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notification = _notifications[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: notification.isRead ? Colors.grey : const Color(0xFFF2711C),
                      child: Icon(
                        _getIconForTipType(notification.tipType),
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      notification.title,
                      style: TextStyle(
                        fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notification.content,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDateTime(notification.createdAt),
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    trailing: notification.isRead
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : const Icon(Icons.circle, color: Colors.grey),
                    onTap: () => _showTipDetail(notification),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildDailyTipsTab() {
    return RefreshIndicator(
      onRefresh: _loadDailyTips,
      child: _dailyTips.isEmpty
          ? const Center(child: Text('오늘의 맞춤 팁이 없습니다.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _dailyTips.length,
              itemBuilder: (context, index) {
                final tip = _dailyTips[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(_getIconForTipType(tip.tipType), color: const Color(0xFFF2711C)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                tip.title,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                            if (tip.cropType != null)
                              Chip(
                                label: Text(tip.cropType!),
                                backgroundColor: Colors.green[100],
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          tip.content,
                          style: const TextStyle(fontSize: 14, height: 1.5),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _formatDateTime(tip.createdAt),
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildWeatherTipTab() {
    if (_weatherTip == null) {
      return const Center(child: Text('날씨 기반 알림을 불러올 수 없습니다.'));
    }

    return RefreshIndicator(
      onRefresh: _loadWeatherTip,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.wb_cloudy, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(
                      _weatherTip!.farmName,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildWeatherInfoRow('날씨 상태', _weatherTip!.weatherCondition),
                _buildWeatherInfoRow('온도', '${_weatherTip!.temperature.toStringAsFixed(1)}°C'),
                _buildWeatherInfoRow('습도', '${_weatherTip!.humidity}%'),
                const SizedBox(height: 16),
                const Text('권장사항', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(_weatherTip!.recommendation, style: const TextStyle(fontSize: 14, height: 1.5)),
                if (_weatherTip!.warning.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.warning, color: Colors.orange),
                            SizedBox(width: 8),
                            Text('주의사항', style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(_weatherTip!.warning),
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

  Widget _buildWeatherInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildPestAlertsTab() {
    return RefreshIndicator(
      onRefresh: _loadPestAlerts,
      child: _pestAlerts.isEmpty
          ? const Center(child: Text('현재 병해충 경보가 없습니다.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _pestAlerts.length,
              itemBuilder: (context, index) {
                final alert = _pestAlerts[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.bug_report,
                              color: _getSeverityColor(alert.severity),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                alert.pestName,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getSeverityColor(alert.severity).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                alert.severity,
                                style: TextStyle(
                                  color: _getSeverityColor(alert.severity),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '지역: ${alert.region}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        Text(alert.description),
                        if (alert.preventionMethods.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          const Text('예방법:', style: TextStyle(fontWeight: FontWeight.bold)),
                          ...alert.preventionMethods.map((method) => Padding(
                                padding: const EdgeInsets.only(left: 16, top: 4),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('• '),
                                    Expanded(child: Text(method)),
                                  ],
                                ),
                              )),
                        ],
                        const SizedBox(height: 8),
                        Text(
                          '발령일: ${_formatDateTime(alert.alertDate)}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildCropGuideTab() {
    if (_cropGuide == null) {
      return const Center(child: Text('작물 가이드를 불러올 수 없습니다.'));
    }

    return RefreshIndicator(
      onRefresh: _loadCropGuide,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.agriculture, color: Colors.green),
                        const SizedBox(width: 8),
                        Text(
                          _cropGuide!.cropType,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildGuideRow('현재 단계', _cropGuide!.currentStage),
                    const SizedBox(height: 12),
                    const Text('단계 설명', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(_cropGuide!.stageDescription, style: const TextStyle(height: 1.5)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.task_alt, color: Color(0xFFF2711C)),
                        SizedBox(width: 8),
                        Text('해야 할 일', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ..._cropGuide!.tasks.map((task) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('• ', style: TextStyle(color: Color(0xFFF2711C), fontSize: 16)),
                              Expanded(child: Text(task)),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.warning, color: Colors.orange),
                        SizedBox(width: 8),
                        Text('주의사항', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ..._cropGuide!.cautions.map((caution) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('⚠️ ', style: TextStyle(fontSize: 16)),
                              Expanded(child: Text(caution)),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.schedule, color: Colors.blue),
                        SizedBox(width: 8),
                        Text('다음 단계', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildGuideRow('다음 단계', _cropGuide!.nextStage),
                    _buildGuideRow(
                      '예상 시기',
                      _formatDateTime(_cropGuide!.estimatedNextStageDate),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuideRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  void _showTipDetail(AiTipModel tip) {
    if (!tip.isRead) {
      _markAsRead(tip);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
              Row(
                children: [
                  Icon(_getIconForTipType(tip.tipType), color: const Color(0xFFF2711C)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      tip.title,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (tip.cropType != null)
                    Chip(
                      label: Text(tip.cropType!),
                      backgroundColor: Colors.green[100],
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Text(
                    tip.content,
                    style: const TextStyle(fontSize: 16, height: 1.6),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDateTime(tip.createdAt),
                    style: const TextStyle(color: Colors.grey),
                  ),
                  if (tip.isRead)
                    const Row(
                      children: [
                        Icon(Icons.check, size: 16, color: Colors.green),
                        SizedBox(width: 4),
                        Text('읽음', style: TextStyle(color: Colors.green)),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForTipType(String tipType) {
    switch (tipType.toLowerCase()) {
      case 'weather':
        return Icons.wb_sunny;
      case 'pest':
        return Icons.bug_report;
      case 'crop':
        return Icons.eco;
      case 'general':
        return Icons.lightbulb;
      case 'urgent':
        return Icons.priority_high;
      default:
        return Icons.info;
    }
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'high':
      case '높음':
        return Colors.red;
      case 'medium':
      case '보통':
        return Colors.orange;
      case 'low':
      case '낮음':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}