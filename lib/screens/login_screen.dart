import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:jejunongdi/redux/app_state.dart';
import 'package:jejunongdi/redux/user/user_actions.dart';
import 'package:jejunongdi/redux/user/user_model.dart';
import 'package:jejunongdi/redux/user/user_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: StoreConnector<AppState, UserState>(
        converter: (store) => store.state.userState,
        builder: (context, userState) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 로고 및 제목
                    const SizedBox(height: 40),
                    Center(
                      child: Column(
                        children: [
                          const Text(
                            'my농디🍊',
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFF2711C),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '제주 농업의 디지털 혁신',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 60),
                    
                    // 로그인 타이틀
                    const Text(
                      '로그인',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // 이메일 입력
                    const Text(
                      '이메일',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: '이메일을 입력해주세요',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFF2711C), width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '이메일을 입력해주세요';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                          return '올바른 이메일 형식을 입력해주세요';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // 비밀번호 입력
                    const Text(
                      '비밀번호',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        hintText: '비밀번호를 입력해주세요',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFF2711C), width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '비밀번호를 입력해주세요';
                        }
                        if (value.length < 6) {
                          return '비밀번호는 6자 이상 입력해주세요';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // 로그인 버튼
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: userState.isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF2711C),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: userState.isLoading
                            ? const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              )
                            : const Text(
                                '로그인',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    
                    // 에러 메시지 표시
                    if (userState.hasError) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Text(
                          userState.errorMessage ?? '로그인에 실패했습니다.',
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                    
                    const Spacer(),
                    
                    // 회원가입 링크
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          '계정이 없으신가요? ',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            // TODO: 회원가입 화면 구현 후 활성화
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('회원가입 기능은 준비 중입니다.')),
                            );
                            // Navigator.of(context).pushNamed('/signup');
                          },
                          child: const Text(
                            '회원가입',
                            style: TextStyle(
                              color: Color(0xFFF2711C),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      final store = StoreProvider.of<AppState>(context);
      
      // 에러 상태 클리어
      store.dispatch(ClearUserErrorAction());
      
      // 로딩 시작
      store.dispatch(SetUserLoadingAction(true));
      
      // 실제 로그인 로직 (임시로 가짜 성공 처리)
      _performLogin();
    }
  }

  void _performLogin() async {
    final store = StoreProvider.of<AppState>(context);
    
    try {
      // 여기서 실제 API 호출을 수행합니다
      // 임시로 2초 대기 후 성공 처리
      await Future.delayed(const Duration(seconds: 2));
      
      // 가짜 사용자 데이터 생성
      final user = User(
        id: '1',
        email: _emailController.text,
        name: '홍길동',
        role: UserRole.worker,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // 로그인 성공 액션 디스패치
      store.dispatch(LoginSuccessAction(
        user: user,
        accessToken: 'fake_access_token',
        refreshToken: 'fake_refresh_token',
      ));
      
      // 로그인 성공 시 네비게이션
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/main');
      }
    } catch (e) {
      // 로그인 실패 처리
      store.dispatch(SetUserErrorAction('이메일 또는 비밀번호가 올바르지 않습니다.'));
    }
  }
}
