import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jejunongdi/redux/app_state.dart';
import 'package:jejunongdi/core/models/ai_tip_models.dart';
import 'package:jejunongdi/core/services/ai_tip_service.dart';
import 'package:jejunongdi/core/services/external_api_service.dart';
import 'package:jejunongdi/screens/ai_tip_detail_screen.dart';
import 'package:jejunongdi/screens/ai_advice_screen.dart';

class AiTipsScreen extends StatefulWidget {
  const AiTipsScreen({super.key});

  @override
  State<AiTipsScreen> createState() => _AiTipsScreenState();
}

class _AiTipsScreenState extends State<AiTipsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<AiTipResponseDto> _allTips = [];
  List<AiTipResponseDto> _unreadTips = [];
  bool _isLoading = false;
  String? _errorMessage;

  final AiTipService _aiTipService = AiTipService.instance;
  final ExternalApiService _externalApiService = ExternalApiService.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadTips();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadTips() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final store = StoreProvider.of<AppState>(context, listen: false);
      final userIdString = store.state.userState.user?.id;

      if (userIdString != null) {
        final userId = int.tryParse(userIdString) ?? 0;
        
        // 새로운 API들을 사용해서 팁 로드
        final todayTipsResult = await _aiTipService.getTodayTips(userId);
        final dailyTipsResult = await _aiTipService.getDailyTips(userId);
        final unreadTipsResult = await _aiTipService.getUnreadTips(userId);

        if (todayTipsResult.isSuccess) {
          final todayTips = todayTipsResult.data!;
          final dailyTips = dailyTipsResult.isSuccess ? dailyTipsResult.data! : <AiTipResponseDto>[];
          
          // 오늘의 팁과 일일 팁을 합쳐서 전체 팁으로 사용
          final combinedTips = <AiTipResponseDto>[...todayTips, ...dailyTips];
          
          setState(() {
            _allTips = combinedTips;
            _unreadTips = unreadTipsResult.isSuccess ? unreadTipsResult.data! : [];
          });
        } else {
          setState(() {
            _errorMessage = todayTipsResult.error?.message ?? '팁을 불러오는데 실패했습니다.';
          });
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = '팁을 불러오는 중 오류가 발생했습니다: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _generateDailyTips() async {
    final store = StoreProvider.of<AppState>(context, listen: false);
    final userIdString = store.state.userState.user?.id;

    if (userIdString == null) return;

    final userId = int.tryParse(userIdString) ?? 0;
    if (userId == 0) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _aiTipService.generateDailyTips(userId);
      
      if (result.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('일일 맞춤 팁이 생성되었습니다!'),
            backgroundColor: Color(0xFFF2711C),
          ),
        );
        await _loadTips(); // 새로운 팁을 로드
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.error?.message ?? '팁 생성에 실패했습니다.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('팁 생성 중 오류가 발생했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _getProfitAnalysis() async {
    final store = StoreProvider.of<AppState>(context, listen: false);
    final userIdString = store.state.userState.user?.id;

    if (userIdString == null) return;

    final userId = int.tryParse(userIdString) ?? 0;
    if (userId == 0) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _externalApiService.getProfitAnalysis(userId);
      
      if (result.isSuccess) {
        _showProfitAnalysisDialog(result.data!);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.error?.message ?? '수익성 분석에 실패했습니다.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('수익성 분석 중 오류가 발생했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showProfitAnalysisDialog(String analysis) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(FontAwesomeIcons.chartLine, color: Color(0xFFF2711C)),
            SizedBox(width: 8),
            Text('수익성 분석 결과'),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(analysis),
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
          'AI 농업 도우미',
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
              icon: Icon(FontAwesomeIcons.lightbulb),
              text: '일일 팁',
            ),
            Tab(
              icon: Icon(FontAwesomeIcons.commentDots),
              text: 'AI 조언',
            ),
            Tab(
              icon: Icon(FontAwesomeIcons.chartLine),
              text: '수익 분석',
            ),
          ],
          labelColor: const Color(0xFFF2711C),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFFF2711C),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTipsTab(),
          _buildAdviceTab(),
          _buildAnalysisTab(),
        ],
      ),
    );
  }

  Widget _buildTipsTab() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFF2711C),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              FontAwesomeIcons.exclamationCircle,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadTips,
              icon: const Icon(FontAwesomeIcons.arrowRotateRight),
              label: const Text('다시 시도'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF2711C),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTips,
      color: const Color(0xFFF2711C),
      child: CustomScrollView(
        slivers: [
          // 헤더 섹션
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF2711C), Color(0xFFE8785A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF2711C).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        FontAwesomeIcons.robot,
                        color: Colors.white,
                        size: 24,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'AI 맞춤 농업 팁',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '개인화된 농업 조언과 유용한 팁을 받아보세요',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _generateDailyTips,
                    icon: const Icon(FontAwesomeIcons.wandMagicSparkles),
                    label: const Text('일일 팁 생성'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFFF2711C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 읽지 않은 팁 섹션
          if (_unreadTips.isNotEmpty) ...[
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Text(
                  '📩 읽지 않은 팁',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildTipCard(_unreadTips[index], isUnread: true),
                childCount: _unreadTips.length,
              ),
            ),
          ],

          // 모든 팁 섹션
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                '📚 모든 팁',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
            ),
          ),

          _allTips.isEmpty
              ? const SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          FontAwesomeIcons.seedling,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          '아직 생성된 팁이 없습니다.\n일일 팁 생성 버튼을 눌러보세요!',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildTipCard(_allTips[index]),
                    childCount: _allTips.length,
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildAdviceTab() {
    return const AiAdviceScreen();
  }

  Widget _buildAnalysisTab() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      FontAwesomeIcons.chartLine,
                      color: Color(0xFFF2711C),
                      size: 24,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'AI 수익성 분석',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  '현재 재배 중인 작물들의 수익성을 AI가 분석해드립니다.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _getProfitAnalysis,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(FontAwesomeIcons.chartBar),
                    label: Text(_isLoading ? '분석 중...' : '수익성 분석 시작'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF2711C),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipCard(AiTipResponseDto tip, {bool isUnread = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isUnread
              ? const BorderSide(color: Color(0xFFF2711C), width: 1)
              : BorderSide.none,
        ),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AiTipDetailScreen(tip: tip),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getTipTypeColor(tip.tipType),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _getTipTypeDisplayName(tip.tipType),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    if (tip.cropType != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _getCropTypeDisplayName(tip.cropType!),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF333333),
                          ),
                        ),
                      ),
                    ],
                    const Spacer(),
                    if (isUnread)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF2711C),
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  tip.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  tip.content.length > 100
                      ? '${tip.content.substring(0, 100)}...'
                      : tip.content,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      FontAwesomeIcons.clock,
                      size: 12,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(tip.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      FontAwesomeIcons.chevronRight,
                      size: 12,
                      color: Colors.grey[400],
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

  Color _getTipTypeColor(String tipType) {
    switch (tipType) {
      case 'WEATHER':
        return Colors.blue;
      case 'PEST_CONTROL':
        return Colors.red;
      case 'HARVEST':
        return Colors.green;
      case 'FERTILIZER':
        return Colors.orange;
      case 'IRRIGATION':
        return Colors.cyan;
      default:
        return const Color(0xFFF2711C);
    }
  }

  String _getTipTypeDisplayName(String tipType) {
    switch (tipType) {
      case 'WEATHER':
        return '날씨 정보';
      case 'PEST_CONTROL':
        return '병해충 방제';
      case 'HARVEST':
        return '수확 시기';
      case 'FERTILIZER':
        return '비료 관리';
      case 'IRRIGATION':
        return '관개 관리';
      default:
        return '일반 팁';
    }
  }

  String _getCropTypeDisplayName(String cropType) {
    switch (cropType) {
      case 'CITRUS':
        return '감귤류';
      case 'VEGETABLE':
        return '채소류';
      case 'GRAIN':
        return '곡류';
      case 'FRUIT':
        return '과일류';
      case 'HERB':
        return '허브류';
      case 'ROOT':
        return '근채류';
      default:
        return cropType;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }
}