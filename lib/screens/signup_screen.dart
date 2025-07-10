import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jejunongdi/redux/app_state.dart';
import 'package:jejunongdi/redux/user/user_actions.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
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

  void _signup() {
    if (_formKey.currentState?.validate() ?? false) {
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
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            FontAwesomeIcons.arrowLeft,
            color: Color(0xFFF2711C),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '회원가입',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // 회원가입 폼
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 헤더 텍스트
                        const Text(
                          '제주 농디에 오신걸 환영합니다🍊',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFF2711C),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '농부와 일손을 연결하는 첫 걸음을 시작하세요',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),

                        // 이름 입력 필드
                        _buildTextField(
                          controller: _nameController,
                          labelText: '이름',
                          hintText: '실명을 입력하세요',
                          prefixIcon: FontAwesomeIcons.user,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '이름을 입력해주세요.';
                            }
                            if (value.length < 2) {
                              return '이름은 2자 이상이어야 합니다.';
                            }
                            return null;
                          },
                          onSaved: (value) => _name = value ?? '',
                        ),

                        const SizedBox(height: 16),

                        // 이메일 입력 필드
                        _buildTextField(
                          controller: _emailController,
                          labelText: '이메일',
                          hintText: 'example@email.com',
                          prefixIcon: FontAwesomeIcons.envelope,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '이메일을 입력해주세요.';
                            }
                            if (!RegExp(r'^[\w-.]+@([\w-]+.)+[\w-]{2,4}$').hasMatch(value)) {
                              return '올바른 이메일 형식을 입력해주세요.';
                            }
                            return null;
                          },
                          onSaved: (value) => _email = value ?? '',
                        ),

                        const SizedBox(height: 16),

                        // 비밀번호 입력 필드
                        _buildTextField(
                          controller: _passwordController,
                          labelText: '비밀번호',
                          hintText: '6자 이상 입력하세요',
                          prefixIcon: FontAwesomeIcons.lock,
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
                              return '비밀번호를 입력해주세요.';
                            }
                            if (value.length < 6) {
                              return '비밀번호는 6자 이상이어야 합니다.';
                            }
                            return null;
                          },
                          onSaved: (value) => _password = value ?? '',
                        ),

                        const SizedBox(height: 16),

                        // 비밀번호 확인 입력 필드
                        _buildTextField(
                          controller: _confirmPasswordController,
                          labelText: '비밀번호 확인',
                          hintText: '비밀번호를 다시 입력하세요',
                          prefixIcon: FontAwesomeIcons.lock,
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
                              return '비밀번호를 다시 입력해주세요.';
                            }
                            if (value != _passwordController.text) {
                              return '비밀번호가 일치하지 않습니다.';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // 닉네임 입력 필드
                        _buildTextField(
                          controller: _nicknameController,
                          labelText: '닉네임',
                          hintText: '다른 사용자에게 보여질 이름',
                          prefixIcon: FontAwesomeIcons.at,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '닉네임을 입력해주세요.';
                            }
                            if (value.length < 2 || value.length > 12) {
                              return '닉네임은 2-12자 사이여야 합니다.';
                            }
                            return null;
                          },
                          onSaved: (value) => _nickname = value ?? '',
                        ),

                        const SizedBox(height: 16),

                        // 전화번호 입력 필드
                        _buildTextField(
                          controller: _phoneController,
                          labelText: '전화번호',
                          hintText: '010-1234-5678',
                          prefixIcon: FontAwesomeIcons.phone,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            _PhoneNumberFormatter(),
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '전화번호를 입력해주세요.';
                            }
                            if (!RegExp(r'^010-\d{4}-\d{4}$').hasMatch(value)) {
                              return '올바른 전화번호 형식을 입력해주세요. (010-0000-0000)';
                            }
                            return null;
                          },
                          onSaved: (value) => _phone = value ?? '',
                        ),

                        const SizedBox(height: 32),

                        // 회원가입 버튼
                        ElevatedButton(
                          onPressed: _signup,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF2711C),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: const Text(
                            '회원가입하기',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // 로그인 링크
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '이미 계정이 있으신가요? ',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: const Text(
                                '로그인',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFFF2711C),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required IconData prefixIcon,
    Widget? suffixIcon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    void Function(String?)? onSaved,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: Icon(
          prefixIcon,
          size: 20,
          color: const Color(0xFFF2711C),
        ),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFF2711C), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      validator: validator,
      onSaved: onSaved,
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
