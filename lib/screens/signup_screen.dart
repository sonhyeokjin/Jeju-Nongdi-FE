import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:jejunongdi/core/models/auth_models.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _nicknameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // Future<void> _signup() async {
  //   if (_formKey.currentState!.validate()) {
  //     try {
  //       final signupRequest = SignupRequest(
  //         email: _emailController.text,
  //         password: _passwordController.text,
  //         name: _nameController.text,
  //         nickname: _nicknameController.text,
  //         phone: _phoneController.text,
  //       );
  //       final response = await _authApi.signup(signupRequest);
  //       // 회원가입 성공
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('회원가입 성공: ${response.accessToken}')),
  //       );
  //       Navigator.of(context).pop(); // 로그인 화면으로 돌아가기
  //     } on DioException catch (e) {
  //       // 회원가입 실패
  //       String errorMessage = '회원가입 실패';
  //       if (e.response != null && e.response!.data != null) {
  //         errorMessage = '회원가입 실패: ${e.response!.data['message'] ?? e.response!.statusCode}';
  //       } else {
  //         errorMessage = '회원가입 실패: ${e.message}';
  //       }
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text(errorMessage)),
  //       );
  //     } catch (e) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('예상치 못한 오류 발생: $e')),
  //       );
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('회원가입'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: '이메일'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '이메일을 입력해주세요.';
                  }
                  if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value)) {
                    return '유효한 이메일 주소를 입력해주세요.';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: '비밀번호 (8자 이상)'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '비밀번호를 입력해주세요.';
                  }
                  if (value.length < 8) {
                    return '비밀번호는 8자 이상이어야 합니다.';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: '이름'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '이름을 입력해주세요.';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _nicknameController,
                decoration: const InputDecoration(labelText: '닉네임'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '닉네임을 입력해주세요.';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: '전화번호'),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '전화번호를 입력해주세요.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              // ElevatedButton(
              //   onPressed: _signup,
              //   child: const Text('회원가입'),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
