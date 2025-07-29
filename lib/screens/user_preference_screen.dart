import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jejunongdi/redux/app_state.dart';
import 'package:jejunongdi/redux/user_preference/user_preference_actions.dart';
import 'package:jejunongdi/redux/user_preference/user_preference_state.dart';
import 'package:jejunongdi/screens/user_preference_advanced_screen.dart';
import 'package:jejunongdi/core/models/user_preference_models.dart';

/// 농업 개인화 설정을 관리하는 메인 화면입니다.
class UserPreferenceScreen extends StatefulWidget {
  const UserPreferenceScreen({super.key});

  @override
  State<UserPreferenceScreen> createState() => _UserPreferenceScreenState();
}

class _UserPreferenceScreenState extends State<UserPreferenceScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final _farmLocationController = TextEditingController();
  final _farmSizeController = TextEditingController();
  final _farmingExperienceController = TextEditingController();
  final _primaryCropsController = TextEditingController();
  
  // Selected values
  String? _selectedFarmingType;
  String? _selectedPreferredTipTime;
  
  // Notification settings
  bool _notificationWeather = true;
  bool _notificationPest = true;
  bool _notificationMarket = false;
  bool _notificationLabor = false;

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late List<Animation<double>> _fadeAnimations;
  late List<Animation<Offset>> _slideAnimations;

  @override
  void initState() {
    super.initState();
    
    // Initialize animations
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Create staggered animations for 6 sections
    final itemCount = 6;
    _fadeAnimations = List.generate(itemCount, (index) {
      final begin = (0.1 * index).clamp(0.0, 1.0);
      final end = (0.6 + 0.1 * index).clamp(0.0, 1.0);
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _fadeController,
          curve: Interval(begin, end > begin ? end : begin + 0.01, curve: Curves.easeOutCubic),
        ),
      );
    });

    _slideAnimations = List.generate(itemCount, (index) {
      final begin = (0.1 * index).clamp(0.0, 1.0);
      final end = (0.6 + 0.1 * index).clamp(0.0, 1.0);
      return Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
        CurvedAnimation(
          parent: _slideController,
          curve: Interval(begin, end > begin ? end : begin + 0.01, curve: Curves.easeOutCubic),
        ),
      );
    });

    // Start animations
    _fadeController.forward();
    _slideController.forward();
    
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final store = StoreProvider.of<AppState>(context);
      store.dispatch(LoadMyPreferenceAction());
      store.dispatch(LoadFarmingTypesAction());
    });
  }

  @override
  void dispose() {
    _farmLocationController.dispose();
    _farmSizeController.dispose();
    _farmingExperienceController.dispose();
    _primaryCropsController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
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
        child: SafeArea(
          child: StoreConnector<AppState, UserPreferenceState>(
            converter: (store) => store.state.userPreferenceState,
            onInit: (store) {
              _loadPreferenceData(store.state.userPreferenceState.myPreference);
            },
            onDidChange: (prevState, state) {
              if (prevState?.myPreference != state.myPreference && state.myPreference != null) {
                _loadPreferenceData(state.myPreference);
              }
            },
            builder: (context, state) {
              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // Custom App Bar
                  _buildCustomAppBar(),
                  
                  // Main Content
                  SliverPadding(
                    padding: const EdgeInsets.all(24.0),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              // Welcome Card
                              _buildAnimatedItem(0, _buildWelcomeCard()),
                              const SizedBox(height: 24),
                              
                              // Basic Info Section
                              _buildAnimatedItem(1, _buildBasicInfoSection(state)),
                              const SizedBox(height: 24),
                              
                              // Farm Details Section
                              _buildAnimatedItem(2, _buildFarmDetailsSection(state)),
                              const SizedBox(height: 24),
                              
                              // Crop Preferences Section
                              _buildAnimatedItem(3, _buildCropPreferencesSection()),
                              const SizedBox(height: 24),
                              
                              // Notification Settings Section
                              _buildAnimatedItem(4, _buildNotificationSection()),
                              const SizedBox(height: 24),
                              
                              // Action Buttons Section
                              _buildAnimatedItem(5, _buildActionButtons(state)),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ]),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCustomAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: Colors.white.withValues(alpha: 0.9),
      elevation: 0,
      flexibleSpace: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8),
              border: Border(
                bottom: BorderSide(color: Colors.black.withValues(alpha: 0.05), width: 1),
              ),
            ),
          ),
        ),
      ),
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF2711C).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(8),
          child: const FaIcon(
            FontAwesomeIcons.arrowLeft,
            color: Color(0xFFF2711C),
            size: 18,
          ),
        ),
      ),
      title: const Text(
        '농업 설정',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const UserPreferenceAdvancedScreen(),
              ),
            );
          },
          icon: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF2711C).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(8),
            child: const FaIcon(
              FontAwesomeIcons.gears,
              color: Color(0xFFF2711C),
              size: 18,
            ),
          ),
          tooltip: '고급 설정',
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildAnimatedItem(int index, Widget child) {
    return FadeTransition(
      opacity: _fadeAnimations[index],
      child: SlideTransition(
        position: _slideAnimations[index],
        child: child,
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF2711C),
            Color(0xFFE67E22),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF2711C).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const FaIcon(
                  FontAwesomeIcons.seedling,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '농업 맞춤 설정',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '나만의 농업 환경을 설정해보세요',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection(UserPreferenceState state) {
    return _buildSection(
      title: '기본 정보',
      icon: FontAwesomeIcons.user,
      children: [
        _buildTextField(
          controller: _farmLocationController,
          label: '농장 위치',
          hintText: '예: 제주시 애월읍',
          prefixIcon: FontAwesomeIcons.locationDot,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '농장 위치를 입력해주세요';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildDropdownField(
          value: _selectedFarmingType,
          label: '농업 유형',
          hintText: '농업 유형을 선택하세요',
          prefixIcon: FontAwesomeIcons.tractor,
          items: state.farmingTypes.map((type) => 
            DropdownMenuItem(
              value: type.code,
              child: Text(
                type.name,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ).toList(),
          onChanged: (value) {
            setState(() {
              _selectedFarmingType = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildFarmDetailsSection(UserPreferenceState state) {
    return _buildSection(
      title: '농장 세부 정보',
      icon: FontAwesomeIcons.warehouse,
      children: [
        _buildTextField(
          controller: _farmSizeController,
          label: '농장 크기 (㎡)',
          hintText: '예: 1000',
          prefixIcon: FontAwesomeIcons.ruler,
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              final size = double.tryParse(value);
              if (size == null || size <= 0) {
                return '올바른 농장 크기를 입력해주세요';
              }
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _farmingExperienceController,
          label: '농업 경험 (년)',
          hintText: '예: 5',
          prefixIcon: FontAwesomeIcons.calendar,
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              final experience = int.tryParse(value);
              if (experience == null || experience < 0) {
                return '올바른 경험 연수를 입력해주세요';
              }
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildCropPreferencesSection() {
    return _buildSection(
      title: '작물 선호도',
      icon: FontAwesomeIcons.appleWhole,
      children: [
        _buildTextField(
          controller: _primaryCropsController,
          label: '주요 작물',
          hintText: '예: 감귤, 당근, 무 (쉼표로 구분)',
          prefixIcon: FontAwesomeIcons.leaf,
          maxLines: 2,
        ),
        const SizedBox(height: 16),
        _buildDropdownField(
          value: _selectedPreferredTipTime,
          label: '선호 팁 수신 시간',
          hintText: '팁을 받고 싶은 시간을 선택하세요',
          prefixIcon: FontAwesomeIcons.clock,
          items: const [
            DropdownMenuItem(value: 'MORNING', child: Text('오전 (9시)')),
            DropdownMenuItem(value: 'AFTERNOON', child: Text('오후 (3시)')),
            DropdownMenuItem(value: 'EVENING', child: Text('저녁 (6시)')),
          ],
          onChanged: (value) {
            setState(() {
              _selectedPreferredTipTime = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildNotificationSection() {
    return _buildSection(
      title: '알림 설정',
      icon: FontAwesomeIcons.bell,
      children: [
        _buildSwitchTile(
          title: '날씨 알림',
          subtitle: '기상 정보 및 농업 날씨 알림',
          icon: FontAwesomeIcons.cloudSun,
          value: _notificationWeather,
          onChanged: (value) {
            setState(() {
              _notificationWeather = value;
            });
          },
        ),
        _buildSwitchTile(
          title: '병해충 알림',
          subtitle: '병해충 발생 및 방제 정보',
          icon: FontAwesomeIcons.bug,
          value: _notificationPest,
          onChanged: (value) {
            setState(() {
              _notificationPest = value;
            });
          },
        ),
        _buildSwitchTile(
          title: '시장 알림',
          subtitle: '농산물 가격 및 시장 동향',
          icon: FontAwesomeIcons.store,
          value: _notificationMarket,
          onChanged: (value) {
            setState(() {
              _notificationMarket = value;
            });
          },
        ),
        _buildSwitchTile(
          title: '일자리 알림',
          subtitle: '농업 관련 일자리 정보',
          icon: FontAwesomeIcons.briefcase,
          value: _notificationLabor,
          onChanged: (value) {
            setState(() {
              _notificationLabor = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildActionButtons(UserPreferenceState state) {
    return Column(
      children: [
        // Validation Buttons Row
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                label: '로컬 검증',
                icon: FontAwesomeIcons.circleCheck,
                color: Colors.blue,
                isLoading: false,
                onPressed: () => _validateLocally(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                label: '서버 검증',
                icon: FontAwesomeIcons.server,
                color: Colors.purple,
                isLoading: state.isLoading,
                onPressed: () => _validateOnServer(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Save Button
        SizedBox(
          width: double.infinity,
          child: _buildActionButton(
            label: '설정 저장',
            icon: FontAwesomeIcons.floppyDisk,
            color: const Color(0xFFF2711C),
            isLoading: state.isLoading,
            onPressed: () => _savePreference(),
            isPrimary: true,
          ),
        ),
        
        // Validation Status
        if ((state.isValidationPassed ?? false) || (state.isServerValidationPassed ?? false))
          Container(
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const FaIcon(FontAwesomeIcons.circleCheck, color: Colors.green, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    (state.isServerValidationPassed ?? false) 
                        ? '서버 검증이 완료되었습니다' 
                        : '로컬 검증이 완료되었습니다',
                    style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        
        // Error Message
        if (state.error != null)
          Container(
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const FaIcon(FontAwesomeIcons.triangleExclamation, color: Colors.red, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    state.error!,
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: const Color(0xFFF2711C).withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2711C).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: FaIcon(
                  icon,
                  color: const Color(0xFFF2711C),
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData prefixIcon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Container(
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF2711C).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: FaIcon(
            prefixIcon,
            color: const Color(0xFFF2711C),
            size: 16,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFF2711C), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildDropdownField({
    required String? value,
    required String label,
    required String hintText,
    required IconData prefixIcon,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Container(
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF2711C).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: FaIcon(
            prefixIcon,
            color: const Color(0xFFF2711C),
            size: 16,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFF2711C), width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      isExpanded: true, // Fix overflow issue
      icon: const FaIcon(FontAwesomeIcons.chevronDown, size: 16),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required void Function(bool) onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: value 
                  ? const Color(0xFFF2711C).withValues(alpha: 0.1)
                  : Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: FaIcon(
              icon,
              color: value ? const Color(0xFFF2711C) : Colors.grey,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: value ? Colors.black87 : Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFFF2711C),
            activeTrackColor: const Color(0xFFF2711C).withValues(alpha: 0.3),
            inactiveThumbColor: Colors.grey.shade400,
            inactiveTrackColor: Colors.grey.shade300,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required bool isLoading,
    required VoidCallback onPressed,
    bool isPrimary = false,
  }) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? color : color.withValues(alpha: 0.1),
        foregroundColor: isPrimary ? Colors.white : color,
        elevation: isPrimary ? 8 : 0,
        shadowColor: isPrimary ? color.withValues(alpha: 0.3) : null,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: isPrimary ? BorderSide.none : BorderSide(color: color.withValues(alpha: 0.3)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isLoading)
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: isPrimary ? Colors.white : color,
              ),
            )
          else
            FaIcon(
              icon,
              size: 16,
              color: isPrimary ? Colors.white : color,
            ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isPrimary ? Colors.white : color,
            ),
          ),
        ],
      ),
    );
  }

  void _loadPreferenceData(UserPreferenceDto? preference) {
    if (preference != null) {
      setState(() {
        _farmLocationController.text = preference.farmLocation ?? '';
        _farmSizeController.text = preference.farmSize?.toString() ?? '';
        _farmingExperienceController.text = preference.farmingExperience?.toString() ?? '';
        _primaryCropsController.text = preference.primaryCrops?.join(', ') ?? '';
        _selectedFarmingType = preference.farmingType;
        _selectedPreferredTipTime = preference.preferredTipTime;
        _notificationWeather = preference.notificationWeather ?? true;
        _notificationPest = preference.notificationPest ?? true;
        _notificationMarket = preference.notificationMarket ?? false;
        _notificationLabor = preference.notificationLabor ?? false;
      });
    }
  }

  void _validateLocally() {
    if (_formKey.currentState!.validate()) {
      final preference = _buildPreferenceFromForm();
      StoreProvider.of<AppState>(context).dispatch(ValidatePreferenceAction(preference));
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              FaIcon(FontAwesomeIcons.circleCheck, color: Colors.white, size: 16),
              SizedBox(width: 8),
              Text('로컬 검증이 완료되었습니다'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _validateOnServer() {
    if (_formKey.currentState!.validate()) {
      final preference = _buildPreferenceFromForm();
      StoreProvider.of<AppState>(context).dispatch(ValidatePreferenceOnServerAction(preference));
    }
  }

  void _savePreference() {
    if (_formKey.currentState!.validate()) {
      final preference = _buildPreferenceFromForm();
      StoreProvider.of<AppState>(context).dispatch(UpdateMyPreferenceAction(preference));
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              FaIcon(FontAwesomeIcons.floppyDisk, color: Colors.white, size: 16),
              SizedBox(width: 8),
              Text('설정이 저장되었습니다'),
            ],
          ),
          backgroundColor: const Color(0xFFF2711C),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  UserPreferenceDto _buildPreferenceFromForm() {
    final crops = _primaryCropsController.text
        .split(',')
        .map((crop) => crop.trim())
        .where((crop) => crop.isNotEmpty)
        .toList();

    return UserPreferenceDto(
      farmLocation: _farmLocationController.text.trim().isEmpty ? null : _farmLocationController.text.trim(),
      farmingType: _selectedFarmingType,
      farmSize: _farmSizeController.text.trim().isEmpty ? null : double.tryParse(_farmSizeController.text.trim()),
      farmingExperience: _farmingExperienceController.text.trim().isEmpty ? null : int.tryParse(_farmingExperienceController.text.trim()),
      primaryCrops: crops.isEmpty ? null : crops,
      preferredTipTime: _selectedPreferredTipTime,
      notificationWeather: _notificationWeather,
      notificationPest: _notificationPest,
      notificationMarket: _notificationMarket,
      notificationLabor: _notificationLabor,
    );
  }
}