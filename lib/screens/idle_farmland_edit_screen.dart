import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jejunongdi/core/models/idle_farmland_models.dart';
import 'package:jejunongdi/redux/app_state.dart';
import 'package:jejunongdi/redux/idle_farmland/idle_farmland_actions.dart';
import 'package:redux/redux.dart';

class IdleFarmlandEditScreen extends StatefulWidget {
  final IdleFarmlandResponse initialFarmland;

  const IdleFarmlandEditScreen({super.key, required this.initialFarmland});

  @override
  State<IdleFarmlandEditScreen> createState() => _IdleFarmlandEditScreenState();
}

class _IdleFarmlandEditScreenState extends State<IdleFarmlandEditScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _farmlandNameController;
  late TextEditingController _addressController;
  late TextEditingController _latitudeController;
  late TextEditingController _longitudeController;
  late TextEditingController _areaSizeController;
  late TextEditingController _monthlyRentController;
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;
  late TextEditingController _contactPhoneController;
  late TextEditingController _contactEmailController;
  late TextEditingController _soilTypeController;
  late TextEditingController _usageTypeController;

  late bool _waterSupply;
  late bool _electricitySupply;
  late bool _farmingToolsIncluded;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
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
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _titleController = TextEditingController(text: widget.initialFarmland.title);
    _descriptionController = TextEditingController(text: widget.initialFarmland.description);
    _farmlandNameController = TextEditingController(text: widget.initialFarmland.farmlandName);
    _addressController = TextEditingController(text: widget.initialFarmland.address);
    _latitudeController = TextEditingController(text: widget.initialFarmland.latitude.toString());
    _longitudeController = TextEditingController(text: widget.initialFarmland.longitude.toString());
    _areaSizeController = TextEditingController(text: widget.initialFarmland.areaSize.toString());
    _monthlyRentController = TextEditingController(text: widget.initialFarmland.monthlyRent?.toString() ?? '');
    _startDateController = TextEditingController(text: widget.initialFarmland.availableStartDate);
    _endDateController = TextEditingController(text: widget.initialFarmland.availableEndDate);
    _contactPhoneController = TextEditingController(text: widget.initialFarmland.contactPhone);
    _contactEmailController = TextEditingController(text: widget.initialFarmland.contactEmail);
    _soilTypeController = TextEditingController(text: widget.initialFarmland.soilType);
    _usageTypeController = TextEditingController(text: widget.initialFarmland.usageType);

    _waterSupply = widget.initialFarmland.waterSupply ?? false;
    _electricitySupply = widget.initialFarmland.electricitySupply ?? false;
    _farmingToolsIncluded = widget.initialFarmland.farmingToolsIncluded ?? false;

    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _farmlandNameController.dispose();
    _addressController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _areaSizeController.dispose();
    _monthlyRentController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _contactPhoneController.dispose();
    _contactEmailController.dispose();
    _soilTypeController.dispose();
    _usageTypeController.dispose();
    super.dispose();
  }

  void _submitForm(Store<AppState> store) {
    if (_formKey.currentState?.validate() ?? false) {
      final request = IdleFarmlandRequest(
        title: _titleController.text,
        description: _descriptionController.text,
        farmlandName: _farmlandNameController.text,
        address: _addressController.text,
        latitude: double.tryParse(_latitudeController.text) ?? 0.0,
        longitude: double.tryParse(_longitudeController.text) ?? 0.0,
        areaSize: double.tryParse(_areaSizeController.text) ?? 0.0,
        monthlyRent: int.tryParse(_monthlyRentController.text) ?? 0,
        availableStartDate: _startDateController.text,
        availableEndDate: _endDateController.text,
        contactPhone: _contactPhoneController.text,
        contactEmail: _contactEmailController.text,
        soilType: _soilTypeController.text,
        usageType: _usageTypeController.text,
        waterSupply: _waterSupply,
        electricitySupply: _electricitySupply,
        farmingToolsIncluded: _farmingToolsIncluded,
      );
      store.dispatch(UpdateIdleFarmlandAction(widget.initialFarmland.id, request));
    }
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ViewModel>(
      converter: (store) => _ViewModel.fromStore(store),
      onWillChange: (previousViewModel, newViewModel) {
        if (previousViewModel?.isLoading == true && !newViewModel.isLoading && newViewModel.error == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('농지 정보가 수정되었습니다. ✨'),
              backgroundColor: const Color(0xFFF2711C),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
          Navigator.of(context).pop(true);
        }
      },
      builder: (context, vm) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
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
              child: Column(
                children: [
                  _buildCustomAppBar(vm),
                  Expanded(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: _buildForm(vm),
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

  Widget _buildCustomAppBar(_ViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(16),
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
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '농지 정보 수정 📝',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFF2711C),
                  ),
                ),
                Text(
                  '정보를 업데이트하세요',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          _buildSubmitButton(vm),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(_ViewModel vm) {
    return Container(
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
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: vm.isLoading ? null : () => _submitForm(StoreProvider.of<AppState>(context)),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: vm.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        FontAwesomeIcons.floppyDisk,
                        color: Colors.white,
                        size: 16,
                      ),
                      SizedBox(width: 8),
                      Text(
                        '저장',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(_ViewModel vm) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSection(
              title: '기본 정보',
              icon: FontAwesomeIcons.circleInfo,
              children: [
                _buildAnimatedTextField(
                  controller: _titleController,
                  label: '제목',
                  icon: FontAwesomeIcons.tag,
                  hint: '농지 제목을 입력하세요',
                ),
                const SizedBox(height: 16),
                _buildAnimatedTextField(
                  controller: _farmlandNameController,
                  label: '농지 이름',
                  icon: FontAwesomeIcons.seedling,
                  hint: '농지의 이름을 입력하세요',
                ),
                const SizedBox(height: 16),
                _buildAnimatedTextField(
                  controller: _addressController,
                  label: '주소',
                  icon: FontAwesomeIcons.locationDot,
                  hint: '농지 주소를 입력하세요',
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: '규모 및 임대 정보',
              icon: FontAwesomeIcons.chartLine,
              children: [
                _buildAnimatedTextField(
                  controller: _areaSizeController,
                  label: '면적 (평)',
                  icon: FontAwesomeIcons.maximize,
                  hint: '예: 100',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                _buildAnimatedTextField(
                  controller: _monthlyRentController,
                  label: '월 임대료 (원)',
                  icon: FontAwesomeIcons.won,
                  hint: '예: 50000',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildAnimatedTextField(
                        controller: _startDateController,
                        label: '임대 시작일',
                        icon: FontAwesomeIcons.calendarDay,
                        hint: 'YYYY-MM-DD',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildAnimatedTextField(
                        controller: _endDateController,
                        label: '임대 종료일',
                        icon: FontAwesomeIcons.calendarXmark,
                        hint: 'YYYY-MM-DD',
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: '연락처 정보',
              icon: FontAwesomeIcons.addressBook,
              children: [
                _buildAnimatedTextField(
                  controller: _contactPhoneController,
                  label: '연락처',
                  icon: FontAwesomeIcons.phone,
                  hint: '010-1234-5678',
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                _buildAnimatedTextField(
                  controller: _contactEmailController,
                  label: '이메일',
                  icon: FontAwesomeIcons.envelope,
                  hint: 'example@email.com',
                  keyboardType: TextInputType.emailAddress,
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: '편의시설',
              icon: FontAwesomeIcons.tools,
              children: [
                _buildAnimatedSwitchTile(
                  title: '수도 공급',
                  subtitle: '농지에 수도 시설이 제공됩니다',
                  icon: FontAwesomeIcons.droplet,
                  value: _waterSupply,
                  onChanged: (value) => setState(() => _waterSupply = value),
                ),
                _buildAnimatedSwitchTile(
                  title: '전기 공급',
                  subtitle: '농지에 전기 시설이 제공됩니다',
                  icon: FontAwesomeIcons.bolt,
                  value: _electricitySupply,
                  onChanged: (value) => setState(() => _electricitySupply = value),
                ),
                _buildAnimatedSwitchTile(
                  title: '농기구 포함',
                  subtitle: '기본 농기구가 제공됩니다',
                  icon: FontAwesomeIcons.hammer,
                  value: _farmingToolsIncluded,
                  onChanged: (value) => setState(() => _farmingToolsIncluded = value),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: '추가 정보',
              icon: FontAwesomeIcons.clipboardList,
              children: [
                _buildAnimatedTextField(
                  controller: _soilTypeController,
                  label: '토양 종류',
                  icon: FontAwesomeIcons.mountain,
                  hint: '예: VOLCANIC',
                ),
                const SizedBox(height: 16),
                _buildAnimatedTextField(
                  controller: _usageTypeController,
                  label: '사용 목적',
                  icon: FontAwesomeIcons.bullseye,
                  hint: '예: SHORT_TERM_RENTAL',
                ),
                const SizedBox(height: 16),
                _buildAnimatedTextField(
                  controller: _descriptionController,
                  label: '상세 설명',
                  icon: FontAwesomeIcons.fileText,
                  hint: '농지에 대한 자세한 설명을 입력하세요',
                  maxLines: 4,
                ),
              ],
            ),
            if (vm.error != null) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      FontAwesomeIcons.exclamationTriangle,
                      color: Colors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '오류: ${vm.error}',
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2711C).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xFFF2711C),
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return AnimatedBuilder(
      animation: _slideController,
      builder: (context, child) {
        return Container(
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
            maxLines: maxLines,
            keyboardType: keyboardType,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              labelText: label,
              hintText: hint,
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
            validator: (value) => (value?.isEmpty ?? true) ? '필수 항목입니다.' : null,
          ),
        );
      },
    );
  }

  Widget _buildAnimatedSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: value ? const Color(0xFFF2711C).withOpacity(0.1) : Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: value ? const Color(0xFFF2711C) : Colors.grey[600],
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: value ? Colors.black87 : Colors.grey[700],
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFFF2711C),
          activeTrackColor: const Color(0xFFF2711C).withOpacity(0.3),
        ),
      ),
    );
  }
}

class _ViewModel {
  final bool isLoading;
  final String? error;
  _ViewModel({required this.isLoading, this.error});
  static _ViewModel fromStore(Store<AppState> store) {
    return _ViewModel(
      isLoading: store.state.idleFarmlandState.isLoading,
      error: store.state.idleFarmlandState.error,
    );
  }
}