import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jejunongdi/redux/app_state.dart';
import 'package:jejunongdi/redux/mentoring/mentoring_actions.dart';
import 'package:jejunongdi/redux/mentoring/mentoring_state.dart';
import 'package:jejunongdi/core/models/mentoring_models.dart';
import 'package:jejunongdi/screens/mentoring_create_screen.dart';
import 'package:jejunongdi/screens/mentoring_detail_screen.dart';
import 'dart:async';

class MentoringListScreen extends StatefulWidget {
  const MentoringListScreen({Key? key}) : super(key: key);

  @override
  State<MentoringListScreen> createState() => _MentoringListScreenState();
}

class _MentoringListScreenState extends State<MentoringListScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  // --- 상태 변수들 ---
  final ScrollController _scrollController = ScrollController();

  // --- 애니메이션 컨트롤러 ---
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _listStaggerController;
  late AnimationController _refreshController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    // --- 애니메이션 컨트롤러 초기화 ---
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _listStaggerController = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    );
    _refreshController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // --- 리스너 및 초기 데이터 로드 ---
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMentorings(refresh: true);
      _startInitialAnimation();
    });
  }

  void _startInitialAnimation() {
    _fadeController.forward();
    _slideController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _listStaggerController.forward();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _listStaggerController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  // --- 데이터 로딩 로직 ---
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      _loadMoreMentorings();
    }
  }

  void _loadMentorings({bool refresh = false}) {
    if (refresh) {
      _listStaggerController.reset();
      _refreshController.reset();
      _refreshController.forward();
    }
    final store = StoreProvider.of<AppState>(context, listen: false);

    store.dispatch(LoadMentoringsAction(
      page: refresh ? 0 : store.state.mentoringState.currentPage + 1,
      refresh: refresh,
    ));

    // 데이터 로드 요청 후 애니메이션 시작
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _listStaggerController.forward();
    });
  }

  void _loadMoreMentorings() {
    final mentoringState = StoreProvider.of<AppState>(context, listen: false).state.mentoringState;
    if (!mentoringState.isLoading && mentoringState.hasMore) {
      _loadMentorings();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        // 제주 농장 느낌의 그라데이션 배경
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF0F8F0), // 연한 민트 그린
              Color(0xFFE8F5E8), // 연한 초록
              Color(0xFFFFF8E1), // 연한 노란
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // --- 제주 농장 컨셉 헤더 ---
              _buildAnimatedHeader(),
              // --- 귀여운 농장 장식 ---
              _buildFarmDecoration(),
              Expanded(
                child: StoreConnector<AppState, MentoringState>(
                  converter: (store) => store.state.mentoringState,
                  builder: (context, mentoringState) {
                    if (mentoringState.isLoading && mentoringState.mentorings.isEmpty) {
                      return _buildLoadingWidget();
                    }
                    if (mentoringState.error != null && mentoringState.mentorings.isEmpty) {
                      return _buildErrorWidget(mentoringState.error!);
                    }
                    if (mentoringState.mentorings.isEmpty) {
                      return _buildEmptyWidget();
                    }
                    return RefreshIndicator(
                      onRefresh: () async => _loadMentorings(refresh: true),
                      color: const Color(0xFFF2711C),
                      backgroundColor: Colors.white,
                      strokeWidth: 3,
                      child: ListView.builder(
                        controller: _scrollController,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                        itemCount: mentoringState.mentorings.length + (mentoringState.hasMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == mentoringState.mentorings.length) {
                            return _buildLoadingMoreWidget();
                          }
                          // --- 애니메이션이 적용된 새로운 멘토링 카드 ---
                          return _buildAnimatedMentoringCard(mentoringState.mentorings[index], index);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      // --- 제주 농장 컨셉 FAB ---
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: _buildFloatingActionButton(),
      ),
    );
  }

  // --- UI 빌더 함수들 ---

  Widget _buildAnimatedHeader() {
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, -0.7), end: Offset.zero)
          .animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack)),
      child: FadeTransition(
        opacity: _fadeController,
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '제주 농디 말벗방',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '함께 성장하는 농업 커뮤니티 🌱',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.green[600],
                      fontWeight: FontWeight.w500,
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

  Widget _buildFarmDecoration() {
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero)
          .animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack)),

    );
  }

  Widget _buildDecorationItem(String emoji, String text) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 11,
            color: Colors.green[700],
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedMentoringCard(MentoringResponse mentoring, int index) {
    // Staggered Animation 설정
    final begin = (index * 0.08).clamp(0.0, 1.0);
    final end = ((index * 0.08) + 0.5).clamp(0.0, 1.0);
    final interval = Interval(
      begin,
      end > begin ? end : begin + 0.01,
      curve: Curves.easeOutBack,
    );

    return AnimatedBuilder(
      animation: _listStaggerController,
      builder: (context, child) {
        final animationValue = interval.transform(_listStaggerController.value);
        return Transform.translate(
          offset: Offset(0, 80 * (1 - animationValue)),
          child: Transform.scale(
            scale: 0.8 + (0.2 * animationValue),
            child: FadeTransition(
              opacity: CurvedAnimation(parent: _listStaggerController, curve: interval),
              child: _buildMentoringCard(mentoring),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMentoringCard(MentoringResponse mentoring) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.orange.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.green.withOpacity(0.1),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            final result = await Navigator.of(context).push<bool>(
              MaterialPageRoute(
                builder: (context) => MentoringDetailScreen(mentoringId: mentoring.id),
              ),
            );
            if (result == true) {
              _loadMentorings(refresh: true);
            }
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2711C).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: const Color(0xFFF2711C).withOpacity(0.3)),
                      ),
                      child: const Icon(
                        FontAwesomeIcons.userFriends,
                        size: 20,
                        color: Color(0xFFF2711C),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mentoring.authorName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '경력: ${mentoring.experienceLevelName}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF388E3C),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildTag(
                      mentoring.mentoringTypeName,
                      _getMentoringTypeColor(mentoring.mentoringType),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  mentoring.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1B5E20),
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.green.withOpacity(0.3),
                        Colors.orange.withOpacity(0.3),
                        Colors.green.withOpacity(0.3),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    _buildInfoChip(FontAwesomeIcons.seedling, mentoring.categoryName, const Color(0xFF4CAF50)),
                    if (mentoring.preferredLocation != null)
                      _buildInfoChip(FontAwesomeIcons.mapMarkerAlt, mentoring.preferredLocation!, const Color(0xFF2196F3)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.8), color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getMentoringTypeColor(String type) {
    switch (type) {
      case 'MENTOR_WANTED':
      case 'MENTOR':
        return const Color(0xFF1976D2);
      case 'MENTEE_WANTED':
      case 'MENTEE':
        return const Color(0xFF388E3C);
      default:
        return const Color(0xFF757575);
    }
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                const CircularProgressIndicator(
                  color: Color(0xFFF2711C),
                  strokeWidth: 3,
                ),
                const SizedBox(height: 16),
                Text(
                  '농장 멘토링 정보를 불러오고 있어요 🌱',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.green[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingMoreWidget() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: Color(0xFFF2711C),
                strokeWidth: 2,
              ),
              SizedBox(width: 16),
              Text(
                '더 많은 멘토링을 불러오는 중...',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF2E7D32),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        margin: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🌱', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 24),
            const Text(
              '아직 등록된 멘토링이 없어요',
              style: TextStyle(
                fontSize: 18,
                color: Color(0xFF2E7D32),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '제주 농장 커뮤니티의 첫 멘토링을\n시작해보세요!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.green[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        margin: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              FontAwesomeIcons.exclamationTriangle,
              size: 48,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 16),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.redAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _loadMentorings(refresh: true),
              icon: const Icon(Icons.refresh),
              label: const Text('다시 시도'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF2711C).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        heroTag: "mentoring_list_fab",
        onPressed: () async {
          final result = await Navigator.of(context).push<bool>(
            MaterialPageRoute(builder: (context) => const MentoringCreateScreen()),
          );
          if (result == true) {
            _loadMentorings(refresh: true);
          }
        },
        icon: const Icon(FontAwesomeIcons.plus, color: Colors.white, size: 18),
        label: const Text(
          '멘토링 등록',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        backgroundColor: const Color(0xFFF2711C),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        extendedPadding: const EdgeInsets.symmetric(horizontal: 24),
      ),
    );
  }
}