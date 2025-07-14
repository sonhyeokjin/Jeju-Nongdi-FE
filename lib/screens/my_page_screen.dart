import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jejunongdi/redux/app_state.dart';
import 'package:jejunongdi/redux/user/user_actions.dart';
import 'package:jejunongdi/redux/user/user_state.dart';
import 'package:jejunongdi/redux/user/user_model.dart';
import 'package:jejunongdi/screens/my_mentoring_list_screen.dart';

/// 동적인 AppBar와 확장된 레이아웃이 적용된 새로운 마이페이지 화면입니다.
class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> with TickerProviderStateMixin {
  // Staggered Animation을 위한 애니메이션 컨트롤러
  late AnimationController _staggerController;
  late List<Animation<double>> _fadeAnimations;
  late List<Animation<Offset>> _slideAnimations;

  // 스크롤 감지를 위한 컨트롤러와 AppBar 표시 여부를 위한 상태 변수
  final ScrollController _scrollController = ScrollController();
  bool _isAppBarVisible = false;

  @override
  void initState() {
    super.initState();

    // 스크롤 리스너 추가
    _scrollController.addListener(_scrollListener);

    // 기존 Staggered Animation 컨트롤러 초기화
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    final itemCount = 3;
    _fadeAnimations = List.generate(itemCount, (index) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _staggerController,
          curve: Interval(0.1 * index, 0.5 + 0.1 * index, curve: Curves.easeOutCubic),
        ),
      );
    });

    _slideAnimations = List.generate(itemCount, (index) {
      return Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
        CurvedAnimation(
          parent: _staggerController,
          curve: Interval(0.1 * index, 0.5 + 0.1 * index, curve: Curves.easeOutCubic),
        ),
      );
    });

    _staggerController.forward();
  }

  /// 스크롤 위치를 감지하여 AppBar의 표시 여부를 결정하는 리스너
  void _scrollListener() {
    // 스크롤이 120px 이상 내려가면 AppBar를 표시
    if (_scrollController.offset >= 120 && !_isAppBarVisible) {
      setState(() {
        _isAppBarVisible = true;
      });
    }
    // 스크롤이 120px 미만으로 올라오면 AppBar를 숨김
    else if (_scrollController.offset < 120 && _isAppBarVisible) {
      setState(() {
        _isAppBarVisible = false;
      });
    }
  }

  @override
  void dispose() {
    // 위젯이 제거될 때 컨트롤러와 리스너를 해제하여 메모리 누수 방지
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _staggerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, UserState>(
      converter: (store) => store.state.userState,
      builder: (context, userState) {
        final user = userState.user;

        return Scaffold(
          backgroundColor: Colors.transparent,
          // Stack을 사용하여 스크롤되는 컨텐츠 위에 AppBar를 띄움
          body: Stack(
            children: [
              // 1. 메인 컨텐츠 영역
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFF8F9FA),
                      Color(0xFFFFEEE6),
                      Color(0xFFFFF4F0),
                    ],
                  ),
                ),
                // CustomScrollView를 사용하여 스크롤 효과 제어
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // 상단 여백
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 60),
                    ),
                    // 메인 제목
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Text(
                          'MY농디',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 24),
                    ),
                    // 프로필 카드
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: _buildAnimatedItem(index: 0, child: _buildProfileCard(user)),
                      ),
                    ),
                    // 그룹 간 간격을 더 넓게 조정
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 40),
                    ),
                    // '나의 활동' 메뉴 그룹
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: _buildAnimatedItem(index: 1, child: _buildMenuGroup(
                          title: '나의 활동',
                          children: [
                            _buildMenuTile(context, icon: FontAwesomeIcons.chalkboardTeacher, title: '내 멘토링', onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const MyMentoringListScreen(),
                                ),
                              );
                            }),
                            _buildMenuTile(context, icon: FontAwesomeIcons.clipboardList, title: '지원 현황', onTap: () {}),
                            _buildMenuTile(context, icon: FontAwesomeIcons.solidHeart, title: '찜한 일자리', onTap: () {}),
                            _buildMenuTile(context, icon: FontAwesomeIcons.solidStar, title: '내가 받은 후기', onTap: () {}),
                          ],
                        )),
                      ),
                    ),
                    // 그룹 간 간격을 더 넓게 조정
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 40),
                    ),
                    // '기타' 메뉴 그룹
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: _buildAnimatedItem(index: 2, child: _buildMenuGroup(
                          title: '기타',
                          children: [
                            _buildMenuTile(context, icon: FontAwesomeIcons.bell, title: '알림 설정', onTap: () {}),
                            _buildMenuTile(context, icon: FontAwesomeIcons.circleInfo, title: '앱 정보', onTap: () => _showAppInfoDialog(context)),
                            _buildMenuTile(context, icon: FontAwesomeIcons.rightFromBracket, title: '로그아웃', onTap: () => _showLogoutDialog(context), color: Colors.redAccent),
                          ],
                        )),
                      ),
                    ),
                    // 전체 페이지 길이를 늘리기 위한 하단 여백
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 100),
                    ),
                  ],
                ),
              ),
              // 2. 동적 AppBar 영역
              _buildAnimatedAppBar(),
            ],
          ),
        );
      },
    );
  }

  /// 스크롤에 따라 로그인 화면처럼 부드럽게 나타나는 AppBar
  Widget _buildAnimatedAppBar() {
    // AnimatedSlide를 사용하여 위에서 아래로 내려오는 애니메이션을 추가합니다.
    return AnimatedSlide(
      offset: _isAppBarVisible ? Offset.zero : const Offset(0, -1.5),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        opacity: _isAppBarVisible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
        // AppBar가 보이지 않을 때 터치 이벤트를 무시합니다.
        child: IgnorePointer(
          ignoring: !_isAppBarVisible,
          child: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
              child: Container(
                height: kToolbarHeight + MediaQuery.of(context).padding.top,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.75),
                  // AppBar 하단에 미세한 경계선을 추가하여 구분감을 줍니다.
                  border: Border(
                    bottom: BorderSide(color: Colors.black.withOpacity(0.05), width: 1.5),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                  child: Center(
                    child: const Text(
                      'MY농디',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 애니메이션을 적용하기 위한 래퍼 위젯
  Widget _buildAnimatedItem({required int index, required Widget child}) {
    return FadeTransition(
      opacity: _fadeAnimations[index],
      child: SlideTransition(
        position: _slideAnimations[index],
        child: child,
      ),
    );
  }

  /// 프로필 카드 UI
  Widget _buildProfileCard(User? user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 25,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: const Color(0xFFF2711C).withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: const Color(0xFFF2711C).withOpacity(0.1),
            child: const FaIcon(FontAwesomeIcons.solidUser, color: Color(0xFFF2711C), size: 28),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.nickname ?? '로그인이 필요합니다',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  user?.email ?? '농촌의 기회를 연결해보세요!',
                  style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              onPressed: () {
                // TODO: 프로필 수정 화면으로 이동하는 로직 구현
              },
              icon: Icon(Icons.edit, size: 20, color: Colors.grey[700]),
              tooltip: '프로필 수정',
            ),
          ),
        ],
      ),
    );
  }

  /// 메뉴 그룹 UI
  Widget _buildMenuGroup({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12.0, bottom: 12.0),
          child: Text(
            title,
            style: TextStyle(fontSize: 16, color: Colors.grey[700], fontWeight: FontWeight.w600),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Column(
            children: List.generate(children.length, (index) {
              return Column(
                children: [
                  children[index],
                  if (index != children.length - 1)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Divider(height: 1, color: Colors.grey[200]),
                    ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  /// 메뉴 타일 UI
  Widget _buildMenuTile(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap, Color? color}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      leading: FaIcon(icon, size: 20, color: color ?? Colors.grey[800]),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: color ?? Colors.black87, fontSize: 16)),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      hoverColor: const Color(0xFFF2711C).withOpacity(0.05),
    );
  }

  /// 로그아웃 확인 다이얼로그
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('로그아웃', style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text('정말로 로그아웃 하시겠습니까?'),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('취소', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                StoreProvider.of<AppState>(context, listen: false).dispatch(LogoutRequestAction());
                Navigator.of(dialogContext).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('로그아웃', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  /// 앱 정보 다이얼로그
  void _showAppInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              FaIcon(FontAwesomeIcons.infoCircle, color: Color(0xFFF2711C)),
              SizedBox(width: 12),
              Text('앱 정보', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('jejunongdi 🍊', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('버전: 1.0.0'),
              SizedBox(height: 8),
              Text('제주 농촌의 기회를 잇다'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text('확인', style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}
