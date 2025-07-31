import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jejunongdi/redux/app_state.dart';
import 'package:jejunongdi/redux/user/user_actions.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  SignupScreenState createState() => SignupScreenState();
}

class SignupScreenState extends State<SignupScreen> 
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _phoneController = TextEditingController();
  
  String _email = '';
  String _password = '';
  String _nickname = '';
  String _name = '';
  String _phone = '';
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isNicknameChecking = false;
  bool _isNicknameAvailable = false;
  String? _nicknameCheckMessage;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _staggerController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    // 애니메이션 시작
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _slideController.forward();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _staggerController.forward();
    });
  }

  void _checkNickname() async {
    if (_nicknameController.text.isEmpty) {
      setState(() {
        _nicknameCheckMessage = '닉네임을 입력해주세요';
        _isNicknameAvailable = false;
      });
      return;
    }

    if (_nicknameController.text.length < 2 || _nicknameController.text.length > 12) {
      setState(() {
        _nicknameCheckMessage = '닉네임은 2-12자 사이여야 합니다';
        _isNicknameAvailable = false;
      });
      return;
    }

    setState(() {
      _isNicknameChecking = true;
      _nicknameCheckMessage = null;
    });

    StoreProvider.of<AppState>(context, listen: false).dispatch(
      CheckNicknameRequestAction(_nicknameController.text)
    );
  }

  void _signup() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (!_isNicknameAvailable) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('닉네임 중복 확인을 먼저 해주세요'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      _formKey.currentState?.save();
      StoreProvider.of<AppState>(context, listen: false).dispatch(SignUpRequestAction(
        email: _email,
        password: _password,
        nickname: _nickname,
        name: _name,
        phone: _phone,
      ));
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _staggerController.dispose();
    _scrollController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nicknameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final size = MediaQuery.of(context).size; // 사용하지 않으므로 주석 처리

    return StoreConnector<AppState, AppState>(
      converter: (store) => store.state,
      onWillChange: (previousState, newState) {
        // 회원가입 성공 시 네비게이션 - 로그인 화면으로 돌아가기
        if (previousState?.userState.user == null && 
            newState.userState.user != null) {
          // 회원가입 성공 시 자동 로그인 해제하고 로그인 화면으로 이동
          StoreProvider.of<AppState>(context, listen: false).dispatch(LogoutAction());
          
          // 회원가입 성공 메시지 표시
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('회원가입이 완료되었습니다. 로그인해주세요.'),
              backgroundColor: Colors.green,
              duration: Duration(milliseconds: 2000),
            ),
          );
          
          // 잠시 후 로그인 화면으로 이동
          Future.delayed(const Duration(milliseconds: 1500), () {
            if (context.mounted) {
              Navigator.of(context).pushReplacementNamed('/login');
            }
          });
        }
        
        // 닉네임 중복 확인 결과 처리
        if (previousState?.userState.isLoading == true && 
            newState.userState.isLoading == false &&
            mounted) {
          setState(() {
            _isNicknameChecking = false;
            // Redux 상태에서 닉네임 확인 결과 가져오기
            if (newState.userState.isNicknameAvailable != null) {
              _isNicknameAvailable = newState.userState.isNicknameAvailable!;
              _nicknameCheckMessage = newState.userState.nicknameCheckMessage;
            }
          });
        }
        
        // 에러 메시지 표시
        if (newState.userState.errorMessage != null && 
            newState.userState.errorMessage!.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(newState.userState.errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state.userState.isLoading;
        
        return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Color(0xFFF8F9FA),
              Color(0xFFFFE8D6),
              Color(0xFFFFF0E6),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 커스텀 앱바
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(
                          FontAwesomeIcons.arrowLeft,
                          color: Color(0xFFF2711C),
                          size: 20,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    Expanded(
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: const Text(
                          '회원가입',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48), // AppBar leading과 균형 맞추기
                  ],
                ),
              ),
              
              // 메인 컨텐츠
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                        // 웰컴 섹션
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: SlideTransition(
                            position: _slideAnimation,
                            child: Hero(
                              tag: 'signup_welcome',
                              child: Container(
                                padding: const EdgeInsets.all(28),
                                margin: const EdgeInsets.only(bottom: 24),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFF2711C).withOpacity(0.08),
                                      blurRadius: 25,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    const Text(
                                      '환영합니다!',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFFF2711C),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      '농부와 일손을 연결하는 스마트한 여정을 시작해보세요',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                        height: 1.4,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        // 회원가입 폼
                        SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.6),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: _slideController,
                            curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
                          )),
                          child: FadeTransition(
                            opacity: CurvedAnimation(
                              parent: _fadeController,
                              curve: const Interval(0.2, 1.0),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(28),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
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
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    const Text(
                                      '계정 만들기',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black87,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 28),

                                    // 스태거드 애니메이션으로 필드들 표시
                                    _buildStaggeredTextField(
                                      index: 0,
                                      controller: _nameController,
                                      labelText: '이름',
                                      hintText: '실명을 입력하세요',
                                      icon: FontAwesomeIcons.user,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return '이름을 입력해주세요';
                                        }
                                        if (value.length < 2) {
                                          return '이름은 2자 이상이어야 합니다';
                                        }
                                        return null;
                                      },
                                      onSaved: (value) => _name = value ?? '',
                                    ),

                                    const SizedBox(height: 18),

                                    _buildStaggeredTextField(
                                      index: 1,
                                      controller: _emailController,
                                      labelText: '이메일',
                                      hintText: 'example@email.com',
                                      icon: FontAwesomeIcons.envelope,
                                      keyboardType: TextInputType.emailAddress,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return '이메일을 입력해주세요';
                                        }
                                        if (!RegExp(r'^[\w-.]+@([\w-]+.)+[\w-]{2,4}$').hasMatch(value)) {
                                          return '올바른 이메일 형식을 입력해주세요';
                                        }
                                        return null;
                                      },
                                      onSaved: (value) => _email = value ?? '',
                                    ),

                                    const SizedBox(height: 18),

                                    _buildStaggeredTextField(
                                      index: 2,
                                      controller: _passwordController,
                                      labelText: '비밀번호',
                                      hintText: '6자 이상 입력하세요',
                                      icon: FontAwesomeIcons.lock,
                                      obscureText: !_isPasswordVisible,
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _isPasswordVisible 
                                            ? FontAwesomeIcons.eyeSlash
                                            : FontAwesomeIcons.eye,
                                          size: 18,
                                          color: Colors.grey[600],
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _isPasswordVisible = !_isPasswordVisible;
                                          });
                                        },
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return '비밀번호를 입력해주세요';
                                        }
                                        if (value.length < 6) {
                                          return '비밀번호는 6자 이상이어야 합니다';
                                        }
                                        return null;
                                      },
                                      onSaved: (value) => _password = value ?? '',
                                    ),

                                    const SizedBox(height: 18),

                                    _buildStaggeredTextField(
                                      index: 3,
                                      controller: _confirmPasswordController,
                                      labelText: '비밀번호 확인',
                                      hintText: '비밀번호를 다시 입력하세요',
                                      icon: FontAwesomeIcons.lock,
                                      obscureText: !_isConfirmPasswordVisible,
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _isConfirmPasswordVisible 
                                            ? FontAwesomeIcons.eyeSlash
                                            : FontAwesomeIcons.eye,
                                          size: 18,
                                          color: Colors.grey[600],
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                                          });
                                        },
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return '비밀번호를 다시 입력해주세요';
                                        }
                                        if (value != _passwordController.text) {
                                          return '비밀번호가 일치하지 않습니다';
                                        }
                                        return null;
                                      },
                                    ),

                                    const SizedBox(height: 18),

                                    _buildNicknameFieldWithCheck(4),

                                    const SizedBox(height: 18),

                                    _buildStaggeredTextField(
                                      index: 5,
                                      controller: _phoneController,
                                      labelText: '전화번호',
                                      hintText: '010-1234-5678',
                                      icon: FontAwesomeIcons.phone,
                                      keyboardType: TextInputType.phone,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        _PhoneNumberFormatter(),
                                      ],
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return '전화번호를 입력해주세요';
                                        }
                                        if (!RegExp(r'^010-\d{4}-\d{4}$').hasMatch(value)) {
                                          return '올바른 전화번호 형식을 입력해주세요 (010-0000-0000)';
                                        }
                                        return null;
                                      },
                                      onSaved: (value) => _phone = value ?? '',
                                    ),

                                    const SizedBox(height: 36),

                                    // 회원가입 버튼
                                    _buildSignupButton(isLoading),

                                    const SizedBox(height: 24),

                                    // 로그인 링크
                                    _buildLoginLink(),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
      },
    );
  }

  Widget _buildStaggeredTextField({
    required int index,
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    void Function(String?)? onSaved,
  }) {
    return AnimatedBuilder(
      animation: _staggerController,
      builder: (context, child) {
        final begin = (index * 0.1).clamp(0.0, 1.0);
        final end = ((index * 0.1) + 0.7).clamp(0.0, 1.0);
        final interval = Interval(
          begin,
          end > begin ? end : begin + 0.01,
          curve: Curves.easeOutCubic,
        );
        
        final slideAnimation = Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _staggerController,
          curve: interval,
        ));

        final fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: _staggerController,
          curve: interval,
        ));

        return SlideTransition(
          position: slideAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextFormField(
                controller: controller,
                keyboardType: keyboardType,
                obscureText: obscureText,
                inputFormatters: inputFormatters,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  labelText: labelText,
                  hintText: hintText,
                  prefixIcon: Container(
                    margin: const EdgeInsets.all(12),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2711C).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
                      size: 18,
                      color: const Color(0xFFF2711C),
                    ),
                  ),
                  suffixIcon: suffixIcon,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey[200]!, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFF2711C), width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Colors.red, width: 1.5),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  labelStyle: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                  ),
                ),
                validator: validator,
                onSaved: onSaved,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSignupButton(bool isLoading) {
    return AnimatedBuilder(
      animation: _staggerController,
      builder: (context, child) {
        return Container(
          height: 56,
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
                color: const Color(0xFFF2711C).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: isLoading ? null : _signup,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : const Text(
                    '회원가입하기',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildLoginLink() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '이미 계정이 있으신가요? ',
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[600],
              fontWeight: FontWeight.w400,
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                '로그인',
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFFF2711C),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNicknameFieldWithCheck(int index) {
    return AnimatedBuilder(
      animation: _staggerController,
      builder: (context, child) {
        final begin = (index * 0.1).clamp(0.0, 1.0);
        final end = ((index * 0.1) + 0.7).clamp(0.0, 1.0);
        final interval = Interval(
          begin,
          end > begin ? end : begin + 0.01,
          curve: Curves.easeOutCubic,
        );
        
        final slideAnimation = Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _staggerController,
          curve: interval,
        ));

        final fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: _staggerController,
          curve: interval,
        ));

        return SlideTransition(
          position: slideAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _nicknameController,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          onChanged: (value) {
                            // 닉네임이 변경되면 중복 확인 상태 초기화
                            setState(() {
                              _isNicknameAvailable = false;
                              _nicknameCheckMessage = null;
                            });
                          },
                          decoration: InputDecoration(
                            labelText: '닉네임',
                            hintText: '다른 사용자에게 보여질 이름',
                            prefixIcon: Container(
                              margin: const EdgeInsets.all(12),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF2711C).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                FontAwesomeIcons.at,
                                size: 18,
                                color: Color(0xFFF2711C),
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: Colors.grey[200]!, width: 1.5),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: Color(0xFFF2711C), width: 2),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: Colors.red, width: 1.5),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: Colors.red, width: 2),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                            labelStyle: TextStyle(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                            hintStyle: TextStyle(
                              color: Colors.grey[400],
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '닉네임을 입력해주세요';
                            }
                            if (value.length < 2 || value.length > 12) {
                              return '닉네임은 2-12자 사이여야 합니다';
                            }
                            return null;
                          },
                          onSaved: (value) => _nickname = value ?? '',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            colors: [
                              _isNicknameAvailable ? Colors.green : const Color(0xFFF2711C),
                              _isNicknameAvailable ? Colors.green[400]! : const Color(0xFFFF8C42),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (_isNicknameAvailable ? Colors.green : const Color(0xFFF2711C)).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _isNicknameChecking ? null : _checkNickname,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                          child: _isNicknameChecking
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Icon(
                                  _isNicknameAvailable 
                                      ? FontAwesomeIcons.check 
                                      : FontAwesomeIcons.magnifyingGlass,
                                  color: Colors.white,
                                  size: 16,
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_nicknameCheckMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 16, top: 8),
                    child: Text(
                      _nicknameCheckMessage!,
                      style: TextStyle(
                        fontSize: 12,
                        color: _isNicknameAvailable ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w500,
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
}

class _PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll('-', '');
    
    if (text.length <= 3) {
      return TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    } else if (text.length <= 7) {
      final formatted = '${text.substring(0, 3)}-${text.substring(3)}';
      return TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    } else if (text.length <= 11) {
      final formatted = '${text.substring(0, 3)}-${text.substring(3, 7)}-${text.substring(7)}';
      return TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
    
    return oldValue;
  }
}
