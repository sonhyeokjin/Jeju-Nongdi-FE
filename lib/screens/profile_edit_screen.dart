import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:jejunongdi/redux/app_state.dart';
import 'package:jejunongdi/redux/user/user_actions.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ProfileEditScreenState createState() => ProfileEditScreenState();
}

class ProfileEditScreenState extends State<ProfileEditScreen> 
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nicknameController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  String _originalNickname = '';
  bool _isCurrentPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isNicknameChecking = false;
  bool _isNicknameAvailable = false;
  String? _nicknameCheckMessage;
  bool _isNicknameChanged = false;
  
  // 프로필 이미지 관련 상태
  File? _selectedImage;
  bool _isImageUploading = false;
  final ImagePicker _imagePicker = ImagePicker();

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

  void _initializeUserInfo() {
    final store = StoreProvider.of<AppState>(context, listen: false);
    final user = store.state.userState.user;
    if (user != null && _nicknameController.text.isEmpty) {
      _nicknameController.text = user.nickname;
      _originalNickname = user.nickname;
    }
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

    // 기존 닉네임과 같다면 사용 가능
    if (_nicknameController.text == _originalNickname) {
      setState(() {
        _nicknameCheckMessage = '현재 사용 중인 닉네임입니다';
        _isNicknameAvailable = true;
        _isNicknameChanged = false;
      });
      return;
    }

    setState(() {
      _isNicknameChecking = true;
      _nicknameCheckMessage = null;
      _isNicknameChanged = true;
    });

    StoreProvider.of<AppState>(context, listen: false).dispatch(
      CheckNicknameRequestAction(_nicknameController.text)
    );
  }

  void _updateNickname() async {
    if (!_isNicknameAvailable || !_isNicknameChanged) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('닉네임 중복 확인을 먼저 해주세요'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    StoreProvider.of<AppState>(context, listen: false).dispatch(
      UpdateNicknameRequestAction(_nicknameController.text)
    );
  }

  void _changePassword() async {
    if (_formKey.currentState?.validate() ?? false) {
      StoreProvider.of<AppState>(context, listen: false).dispatch(
        ChangePasswordRequestAction(
          currentPassword: _currentPasswordController.text,
          newPassword: _newPasswordController.text,
        )
      );
    }
  }
  
  // 이미지 선택 함수
  Future<void> _selectImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
        _uploadImage();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('이미지 선택 중 오류가 발생했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  // 카메라로 촬영
  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
        _uploadImage();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('사진 촬영 중 오류가 발생했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  // 이미지 업로드 함수 (임시 URL 생성)
  Future<void> _uploadImage() async {
    if (_selectedImage == null) return;
    
    setState(() {
      _isImageUploading = true;
    });
    
    try {
      // 실제 구현에서는 서버에 이미지를 업로드하고 URL을 받아와야 합니다.
      // 현재는 임시로 placeholder URL을 사용합니다.
      // TODO: 실제 이미지 업로드 서비스 구현 필요
      final imageUrl = "https://example.com/profile-images/user-${DateTime.now().millisecondsSinceEpoch}.jpg";
      
      // 프로필 이미지 업데이트 액션 디스패치
      StoreProvider.of<AppState>(context, listen: false).dispatch(
        UpdateProfileImageRequestAction(imageUrl)
      );
      
      // 임시로 딜레이 추가 (서버 업로드 시뮬레이션)
      await Future.delayed(const Duration(seconds: 1));
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('이미지 업로드 중 오류가 발생했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isImageUploading = false;
      });
    }
  }
  
  // 이미지 선택 옵션 다이얼로그
  void _showImagePickerDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  '프로필 사진 선택',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2711C).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    FontAwesomeIcons.camera,
                    color: Color(0xFFF2711C),
                    size: 20,
                  ),
                ),
                title: const Text('카메라로 촬영'),
                onTap: () {
                  Navigator.pop(context);
                  _takePhoto();
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2711C).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    FontAwesomeIcons.image,
                    color: Color(0xFFF2711C),
                    size: 20,
                  ),
                ),
                title: const Text('갤러리에서 선택'),
                onTap: () {
                  Navigator.pop(context);
                  _selectImage();
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _staggerController.dispose();
    _nicknameController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AppState>(
      converter: (store) => store.state,
      onWillChange: (previousState, newState) {
        // 사용자 정보 초기화
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _initializeUserInfo();
        });

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

        // 닉네임 변경 성공 처리
        if (previousState?.userState.user?.nickname != newState.userState.user?.nickname &&
            newState.userState.user?.nickname == _nicknameController.text &&
            mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('닉네임이 성공적으로 변경되었습니다'),
              backgroundColor: Colors.green,
            ),
          );
          _originalNickname = _nicknameController.text;
          setState(() {
            _isNicknameChanged = false;
          });
        }

        // 비밀번호 변경 성공 처리 (에러가 없으면 성공으로 간주)
        if (previousState?.userState.isLoading == true && 
            newState.userState.isLoading == false &&
            newState.userState.errorMessage == null &&
            _currentPasswordController.text.isNotEmpty &&
            mounted) {
          // 비밀번호 필드가 입력되어 있고 에러가 없으면 성공으로 간주
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('비밀번호가 성공적으로 변경되었습니다'),
              backgroundColor: Colors.green,
            ),
          );
          // 비밀번호 필드 초기화
          _currentPasswordController.clear();
          _newPasswordController.clear();
          _confirmPasswordController.clear();
        }
        
        // 프로필 이미지 변경 성공 처리
        if (previousState?.userState.isLoading == true && 
            newState.userState.isLoading == false &&
            newState.userState.errorMessage == null &&
            _isImageUploading &&
            mounted) {
          // 이미지 업로드가 진행 중이고 에러가 없으면 성공으로 간주
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('프로필 이미지가 성공적으로 변경되었습니다'),
              backgroundColor: Colors.green,
            ),
          );
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
        final user = state.userState.user;
        
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
                              '프로필 편집',
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
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          children: [
                            // 프로필 정보 섹션
                            FadeTransition(
                              opacity: _fadeAnimation,
                              child: SlideTransition(
                                position: _slideAnimation,
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
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        '기본 정보',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      
                                      // 이메일 (읽기 전용)
                                      _buildReadOnlyField(
                                        label: '이메일',
                                        value: user?.email ?? '',
                                        icon: FontAwesomeIcons.envelope,
                                      ),
                                      
                                      const SizedBox(height: 20),
                                      
                                      // 이름 (읽기 전용)
                                      _buildReadOnlyField(
                                        label: '이름',
                                        value: user?.name ?? '',
                                        icon: FontAwesomeIcons.user,
                                      ),
                                      
                                      const SizedBox(height: 20),
                                      
                                      // 프로필 이미지 섹션
                                      _buildProfileImageSection(user),
                                      
                                      const SizedBox(height: 20),
                                      
                                      // 닉네임 변경
                                      _buildNicknameSection(),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // 비밀번호 변경 섹션
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
                                    ],
                                  ),
                                  child: Form(
                                    key: _formKey,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          '비밀번호 변경',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 24),

                                        // 현재 비밀번호
                                        _buildPasswordField(
                                          controller: _currentPasswordController,
                                          labelText: '현재 비밀번호',
                                          hintText: '현재 비밀번호를 입력하세요',
                                          isVisible: _isCurrentPasswordVisible,
                                          onVisibilityToggle: () {
                                            setState(() {
                                              _isCurrentPasswordVisible = !_isCurrentPasswordVisible;
                                            });
                                          },
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return '현재 비밀번호를 입력해주세요';
                                            }
                                            return null;
                                          },
                                        ),

                                        const SizedBox(height: 18),

                                        // 새 비밀번호
                                        _buildPasswordField(
                                          controller: _newPasswordController,
                                          labelText: '새 비밀번호',
                                          hintText: '6자 이상 입력하세요',
                                          isVisible: _isNewPasswordVisible,
                                          onVisibilityToggle: () {
                                            setState(() {
                                              _isNewPasswordVisible = !_isNewPasswordVisible;
                                            });
                                          },
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return '새 비밀번호를 입력해주세요';
                                            }
                                            if (value.length < 6) {
                                              return '비밀번호는 6자 이상이어야 합니다';
                                            }
                                            return null;
                                          },
                                        ),

                                        const SizedBox(height: 18),

                                        // 새 비밀번호 확인
                                        _buildPasswordField(
                                          controller: _confirmPasswordController,
                                          labelText: '새 비밀번호 확인',
                                          hintText: '새 비밀번호를 다시 입력하세요',
                                          isVisible: _isConfirmPasswordVisible,
                                          onVisibilityToggle: () {
                                            setState(() {
                                              _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                                            });
                                          },
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return '새 비밀번호를 다시 입력해주세요';
                                            }
                                            if (value != _newPasswordController.text) {
                                              return '비밀번호가 일치하지 않습니다';
                                            }
                                            return null;
                                          },
                                        ),

                                        const SizedBox(height: 32),

                                        // 비밀번호 변경 버튼
                                        _buildPasswordChangeButton(isLoading),
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

  Widget _buildReadOnlyField({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[300]!, width: 1),
          ),
          child: Row(
            children: [
              Container(
                margin: const EdgeInsets.only(right: 12),
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
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNicknameSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '닉네임',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _nicknameController,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                onChanged: (value) {
                  setState(() {
                    _isNicknameAvailable = false;
                    _nicknameCheckMessage = null;
                    _isNicknameChanged = value != _originalNickname;
                  });
                },
                decoration: InputDecoration(
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
                  filled: true,
                  fillColor: Colors.grey[50],
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [
                    _isNicknameAvailable && _isNicknameChanged ? Colors.green : const Color(0xFFF2711C),
                    _isNicknameAvailable && _isNicknameChanged ? Colors.green[400]! : const Color(0xFFFF8C42),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: (_isNicknameAvailable && _isNicknameChanged ? Colors.green : const Color(0xFFF2711C)).withOpacity(0.3),
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
                        _isNicknameAvailable && _isNicknameChanged
                            ? FontAwesomeIcons.check 
                            : FontAwesomeIcons.magnifyingGlass,
                        color: Colors.white,
                        size: 16,
                      ),
              ),
            ),
          ],
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
        if (_isNicknameChanged && _isNicknameAvailable)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _updateNickname,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF2711C),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '닉네임 변경',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required bool isVisible,
    required VoidCallback onVisibilityToggle,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: !isVisible,
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
          child: const Icon(
            FontAwesomeIcons.lock,
            size: 18,
            color: Color(0xFFF2711C),
          ),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            isVisible 
                ? FontAwesomeIcons.eyeSlash
                : FontAwesomeIcons.eye,
            size: 18,
            color: Colors.grey[600],
          ),
          onPressed: onVisibilityToggle,
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
      validator: validator,
    );
  }

  Widget _buildPasswordChangeButton(bool isLoading) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: Container(
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
          onPressed: isLoading ? null : _changePassword,
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
                  '비밀번호 변경',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildProfileImageSection(dynamic user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '프로필 이미지',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // 프로필 이미지 표시
            GestureDetector(
              onTap: _showImagePickerDialog,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey[300]!, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: _selectedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.file(
                          _selectedImage!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            FontAwesomeIcons.solidUser,
                            size: 28,
                            color: const Color(0xFFF2711C).withOpacity(0.7),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '기본',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(width: 16),
            // 이미지 변경 버튼 및 설명
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFF2711C).withOpacity(0.1),
                          const Color(0xFFFF8C42).withOpacity(0.1),
                        ],
                      ),
                    ),
                    child: ElevatedButton.icon(
                      onPressed: _isImageUploading ? null : _showImagePickerDialog,
                      icon: _isImageUploading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFFF2711C),
                              ),
                            )
                          : const Icon(
                              FontAwesomeIcons.camera,
                              size: 16,
                              color: Color(0xFFF2711C),
                            ),
                      label: Text(
                        _isImageUploading ? '업로드 중...' : '이미지 변경',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFF2711C),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: const Color(0xFFF2711C).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '권장 크기: 1024x1024px\n지원 형식: JPG, PNG',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}