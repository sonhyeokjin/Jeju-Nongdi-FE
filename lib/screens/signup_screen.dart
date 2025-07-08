import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:jejunongdi/redux/app_state.dart';
import 'package:redux/redux.dart';
import 'package:jejunongdi/redux/user/user_actions.dart';
import 'package:jejunongdi/core/utils/validators.dart';
import 'package:jejunongdi/screens/main_navigation.dart';

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

  void _signup(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      StoreProvider.of<AppState>(context).dispatch(SignUpRequestAction(
        email: _emailController.text,
        password: _passwordController.text,
        name: _nameController.text,
        nickname: _nicknameController.text,
        phone: _phoneController.text,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('회원가입'),
      ),
      body: StoreConnector<AppState, _ViewModel>(
        converter: (store) => _ViewModel.fromStore(store),
        builder: (context, vm) {
          if (vm.isAuthenticated) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const MainNavigation()),
                (route) => false,
              );
            });
          }

          if (vm.error != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(vm.error!)),
              );
              vm.clearError();
            });
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: '이메일'),
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.email,
                  ),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: '비밀번호 (8자 이상)'),
                    obscureText: true,
                    validator: Validators.password,
                  ),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: '이름'),
                    validator: Validators.name,
                  ),
                  TextFormField(
                    controller: _nicknameController,
                    decoration: const InputDecoration(labelText: '닉네임'),
                    validator: (value) => Validators.required(value, fieldName: '닉네임'),
                  ),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(labelText: '전화번호'),
                    keyboardType: TextInputType.phone,
                    validator: Validators.phoneNumber,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: vm.isLoading ? null : () => _signup(context),
                    child: vm.isLoading
                        ? const CircularProgressIndicator()
                        : const Text('회원가입'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ViewModel {
  final bool isLoading;
  final bool isAuthenticated;
  final String? error;
  final Function() clearError;

  _ViewModel({
    required this.isLoading,
    required this.isAuthenticated,
    required this.error,
    required this.clearError,
  });

  static _ViewModel fromStore(Store<AppState> store) {
    return _ViewModel(
      isLoading: store.state.userState.isLoading,
      isAuthenticated: store.state.userState.isAuthenticated,
      error: store.state.userState.errorMessage,
      clearError: () => store.dispatch(ClearUserErrorAction()),
    );
  }
}
