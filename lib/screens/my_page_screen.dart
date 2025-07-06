import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:jejunongdi/redux/app_state.dart';
import 'package:jejunongdi/redux/user/user_actions.dart';
import 'package:jejunongdi/redux/user/user_state.dart';

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, UserState>(
      converter: (store) => store.state.userState,
      builder: (context, userState) {
        final user = userState.user;
        
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'MY농디',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.grey),
                onPressed: () => _showLogoutDialog(context),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 프로필 카드
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2711C).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFF2711C).withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      // 프로필 아바타
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2711C),
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // 사용자 이름
                      Text(
                        user?.name ?? '사용자',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      
                      // 사용자 이메일
                      Text(
                        user?.email ?? '',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // 사용자 역할
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2711C),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          user?.role.name == 'worker' ? '구직자' : '농장주',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // 메뉴 섹션
                const Text(
                  '계정 관리',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                
                // 메뉴 아이템들
                _buildMenuItem(
                  icon: Icons.edit,
                  title: '프로필 수정',
                  onTap: () {
                    // 프로필 수정 화면으로 이동
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('프로필 수정 기능은 준비 중입니다.')),
                    );
                  },
                ),
                _buildMenuItem(
                  icon: Icons.lock,
                  title: '비밀번호 변경',
                  onTap: () {
                    // 비밀번호 변경 화면으로 이동
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('비밀번호 변경 기능은 준비 중입니다.')),
                    );
                  },
                ),
                _buildMenuItem(
                  icon: Icons.notifications,
                  title: '알림 설정',
                  onTap: () {
                    // 알림 설정 화면으로 이동
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('알림 설정 기능은 준비 중입니다.')),
                    );
                  },
                ),
                
                const SizedBox(height: 24),
                
                const Text(
                  '고객 지원',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                
                _buildMenuItem(
                  icon: Icons.help_outline,
                  title: '도움말',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('도움말 기능은 준비 중입니다.')),
                    );
                  },
                ),
                _buildMenuItem(
                  icon: Icons.info_outline,
                  title: '앱 정보',
                  onTap: () {
                    _showAppInfoDialog(context);
                  },
                ),
                
                const SizedBox(height: 32),
                
                // 로그아웃 버튼
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () => _showLogoutDialog(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      '로그아웃',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
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

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: const Color(0xFFF2711C),
                  size: 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: Colors.grey,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('로그아웃'),
          content: const Text('정말 로그아웃하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                final store = StoreProvider.of<AppState>(context);
                store.dispatch(LogoutAction());
                Navigator.of(context).pop();
                // 홈 화면으로 이동
                Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
              },
              child: const Text(
                '로그아웃',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAppInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('앱 정보'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('제주 농디 🍊'),
              SizedBox(height: 8),
              Text('버전: 1.0.0'),
              SizedBox(height: 8),
              Text('제주 농업의 디지털 혁신을 위한 플랫폼'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }
}
