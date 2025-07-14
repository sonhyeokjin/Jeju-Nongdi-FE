import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jejunongdi/core/config/environment.dart';
import 'package:jejunongdi/core/models/job_posting_model.dart';
import 'package:jejunongdi/core/services/job_posting_service.dart';
import 'package:jejunongdi/core/utils/validators.dart';
import 'package:intl/intl.dart';
import 'package:kpostal/kpostal.dart';

class EnvironmentConfig {
  static const String kakaoMapApiKey = String.fromEnvironment(
    '752d47c1d500b05f00d22e33448215a9',
    defaultValue: 'development_key_here',
  );
}

class JobPostingCreateScreen extends StatefulWidget {
  const JobPostingCreateScreen({super.key});

  @override
  State<JobPostingCreateScreen> createState() => _JobPostingCreateScreenState();
}

class _JobPostingCreateScreenState extends State<JobPostingCreateScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Animation Controllers
  late AnimationController _staggerController;

  // Form Field Controllers
  final _titleController = TextEditingController();
  final _farmNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _wagesController = TextEditingController();
  final _recruitmentCountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _contactPhoneController = TextEditingController();

  // Dropdown & Date & LatLng Values
  String? _cropType;
  String? _workType;
  String? _wageType;
  DateTime? _workStartDate;
  DateTime? _workEndDate;
  double? _latitude;
  double? _longitude;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    // 화면이 빌드된 후 애니메이션 시작
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _staggerController.forward();
    });
  }

  @override
  void dispose() {
    _staggerController.dispose();
    _titleController.dispose();
    _farmNameController.dispose();
    _addressController.dispose();
    _wagesController.dispose();
    _recruitmentCountController.dispose();
    _descriptionController.dispose();
    _contactPhoneController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if ((_formKey.currentState?.validate() ?? false) && _latitude != null && _longitude != null) {
      setState(() => _isLoading = true);

      final request = JobPostingRequest(
        title: _titleController.text,
        farmName: _farmNameController.text,
        address: _addressController.text,
        wages: int.parse(_wagesController.text),
        recruitmentCount: int.parse(_recruitmentCountController.text),
        description: _descriptionController.text,
        cropType: _cropType!,
        workType: _workType!,
        wageType: _wageType!,
        workStartDate: DateFormat('yyyy-MM-dd').format(_workStartDate!),
        workEndDate: DateFormat('yyyy-MM-dd').format(_workEndDate!),
        latitude: _latitude!,
        longitude: _longitude!,
        contactPhone: _contactPhoneController.text.isNotEmpty
            ? _contactPhoneController.text
            : null,
      );

      final result = await JobPostingService.instance.createJobPosting(request);

      if (mounted) {
        setState(() => _isLoading = false);
        result.onSuccess((data) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('공고가 성공적으로 등록되었습니다!'), backgroundColor: Colors.green),
          );
          Navigator.of(context).pop(true);
        });
        result.onFailure((error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('공고 등록 실패: ${error.message}'), backgroundColor: Colors.red),
          );
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('주소를 포함한 모든 필수 항목을 입력해주세요.'), backgroundColor: Colors.orange),
      );
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _workStartDate ?? DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2101));
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _workStartDate = picked;
          if (_workEndDate != null && _workEndDate!.isBefore(_workStartDate!)) {
            _workEndDate = null;
          }
        } else {
          _workEndDate = picked;
        }
      });
    }
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
            colors: [Color(0xFFF8F9FA), Color(0xFFFFEEE6), Color(0xFFFFF4F0)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                    children: [
                      _buildSectionCard(
                        index: 0,
                        title: '기본 정보',
                        icon: FontAwesomeIcons.circleInfo,
                        children: [
                          _buildStyledTextField(controller: _titleController, labelText: '공고 제목', hintText: '예: 당근 수확 단기 알바 구해요', icon: FontAwesomeIcons.penToSquare, validator: Validators.required),
                          const SizedBox(height: 18),
                          _buildStyledTextField(controller: _farmNameController, labelText: '농장 이름', hintText: '예: 제주농디 농장', icon: FontAwesomeIcons.tractor, validator: Validators.required),
                          const SizedBox(height: 18),
                          _buildAddressField(),
                        ],
                      ),
                      _buildSectionCard(
                        index: 1,
                        title: '근무 조건',
                        icon: FontAwesomeIcons.calendarCheck,
                        children: [
                          _buildStyledSelectionField(
                            labelText: '작물 종류',
                            value: _cropType,
                            icon: FontAwesomeIcons.carrot,
                            onTap: () => _showStyledSelectionSheet(
                              title: '어떤 작물인가요?',
                              items: [
                                {'label': '감자', 'value': 'POTATO', 'icon': FontAwesomeIcons.leaf},
                                {'label': '감귤', 'value': 'TANGERINE', 'icon': FontAwesomeIcons.lemon},
                                {'label': '양배추', 'value': 'CABBAGE', 'icon': FontAwesomeIcons.seedling},
                                {'label': '기타', 'value': 'OTHER', 'icon': FontAwesomeIcons.spa},
                              ],
                              onSelected: (val) => setState(() => _cropType = val),
                            ),
                          ),
                          const SizedBox(height: 18),
                          _buildStyledSelectionField(
                            labelText: '작업 종류',
                            value: _workType,
                            icon: FontAwesomeIcons.hand,
                            onTap: () => _showStyledSelectionSheet(
                              title: '어떤 작업인가요?',
                              items: [
                                {'label': '수확', 'value': 'HARVESTING', 'icon': FontAwesomeIcons.basketShopping},
                                {'label': '포장', 'value': 'PACKING', 'icon': FontAwesomeIcons.boxOpen},
                                {'label': '파종', 'value': 'PLANTING', 'icon': FontAwesomeIcons.handDots},
                                {'label': '기타', 'value': 'OTHER', 'icon': FontAwesomeIcons.ellipsis},
                              ],
                              onSelected: (val) => setState(() => _workType = val),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: _buildStyledDateField('시작일', _workStartDate, () => _selectDate(context, true))),
                              const SizedBox(width: 12),
                              Expanded(child: _buildStyledDateField('종료일', _workEndDate, () => _selectDate(context, false))),
                            ],
                          ),
                        ],
                      ),
                      _buildSectionCard(
                        index: 2,
                        title: '급여 및 인원',
                        icon: FontAwesomeIcons.coins,
                        children: [
                          _buildStyledTextField(controller: _wagesController, labelText: '급여', keyboardType: TextInputType.number, icon: FontAwesomeIcons.wonSign, validator: (v) => Validators.combine(v, [Validators.required, (val) => Validators.minLength(val, 4, fieldName: '급여')])),
                          const SizedBox(height: 18),
                          _buildStyledSelectionField(
                            labelText: '급여 종류',
                            value: _wageType,
                            icon: FontAwesomeIcons.clock,
                            onTap: () => _showStyledSelectionSheet(
                              title: '급여 지급 방식은 무엇인가요?',
                              items: [
                                {'label': '시급', 'value': 'HOURLY', 'icon': FontAwesomeIcons.hourglassHalf},
                                {'label': '일급', 'value': 'DAILY', 'icon': FontAwesomeIcons.sun},
                                {'label': '월급', 'value': 'MONTHLY', 'icon': FontAwesomeIcons.calendar},
                              ],
                              onSelected: (val) => setState(() => _wageType = val),
                            ),
                          ),
                          const SizedBox(height: 18),
                          _buildStyledTextField(controller: _recruitmentCountController, labelText: '모집 인원', keyboardType: TextInputType.number, icon: FontAwesomeIcons.users, validator: (v) => Validators.combine(v, [Validators.required, Validators.numbersOnly])),
                        ],
                      ),
                      _buildSectionCard(
                        index: 3,
                        title: '추가 정보',
                        icon: FontAwesomeIcons.phone,
                        children: [
                          _buildStyledTextField(controller: _contactPhoneController, labelText: '연락처 (선택)', hintText: '010-1234-5678', keyboardType: TextInputType.phone, icon: FontAwesomeIcons.phone),
                          const SizedBox(height: 18),
                          _buildStyledMultilineTextField(controller: _descriptionController, labelText: '상세 설명 (선택)', hintText: '작업에 대한 구체적인 내용을 적어주세요.', icon: FontAwesomeIcons.commentDots),
                        ],
                      ),
                      const SizedBox(height: 30),
                      _buildSubmitButton(),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 2))],
            ),
            child: IconButton(
              icon: const Icon(FontAwesomeIcons.arrowLeft, color: Color(0xFFF2711C), size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const Expanded(
            child: Text(
              '일손 모집 공고 등록',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required int index, required String title, required IconData icon, required List<Widget> children}) {
    return AnimatedBuilder(
      animation: _staggerController,
      builder: (context, child) {
        final interval = Interval((0.15 * index).clamp(0.0, 1.0), ((0.15 * index) + 0.7).clamp(0.0, 1.0), curve: Curves.easeOutCubic);
        final slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(CurvedAnimation(parent: _staggerController, curve: interval));
        final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _staggerController, curve: interval));

        return SlideTransition(
          position: slideAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: Container(
              margin: const EdgeInsets.only(bottom: 24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, 5)),
                  BoxShadow(color: const Color(0xFFF2711C).withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 3)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      FaIcon(icon, size: 18, color: const Color(0xFFF2711C)),
                      const SizedBox(width: 10),
                      Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black87)),
                    ],
                  ),
                  const Divider(height: 32),
                  ...children,
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAddressField() {
    return TextFormField(
      controller: _addressController,
      readOnly: true,
      decoration: _getStyledInputDecoration('주소', '탭하여 주소 검색', FontAwesomeIcons.mapLocationDot).copyWith(
        suffixIcon: const Icon(FontAwesomeIcons.magnifyingGlass, size: 14, color: Colors.grey),
      ),
      validator: Validators.required,
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => KpostalView(
              kakaoKey: EnvironmentConfig.kakaoMapApiKey,
              callback: (Kpostal result) {
                setState(() {
                  _addressController.text = result.address;
                  _latitude = result.latitude;
                  _longitude = result.longitude;
                });
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildStyledTextField({required TextEditingController controller, required String labelText, String? hintText, required IconData icon, TextInputType? keyboardType, bool obscureText = false, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      decoration: _getStyledInputDecoration(labelText, hintText, icon),
      validator: validator,
    );
  }

  Widget _buildStyledMultilineTextField({required TextEditingController controller, required String labelText, String? hintText, required IconData icon, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      maxLines: 5,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      decoration: _getStyledInputDecoration(labelText, hintText, icon).copyWith(
        prefixIcon: Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Container(
            margin: const EdgeInsets.fromLTRB(12, 0, 10, 12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: const Color(0xFFF2711C).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 18, color: const Color(0xFFF2711C)),
          ),
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildStyledSelectionField({required String labelText, required String? value, required IconData icon, required VoidCallback onTap}) {
    return TextFormField(
      readOnly: true,
      onTap: onTap,
      key: ValueKey('${labelText}_$value'),
      initialValue: value,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      decoration: _getStyledInputDecoration(labelText, value == null ? '선택해주세요' : null, icon).copyWith(
        suffixIcon: const Icon(FontAwesomeIcons.chevronDown, size: 14, color: Colors.grey),
      ),
      validator: (val) => value == null ? '$labelText을(를) 선택해주세요.' : null,
    );
  }

  Widget _buildStyledDateField(String labelText, DateTime? date, VoidCallback onTap) {
    return TextFormField(
      readOnly: true,
      onTap: onTap,
      key: ValueKey('${labelText}_$date'),
      initialValue: date == null ? null : DateFormat('yyyy년 MM월 dd일').format(date),
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      decoration: _getStyledInputDecoration(labelText, '날짜 선택', FontAwesomeIcons.calendar),
      validator: (value) {
        if (date == null) return '$labelText을(를) 선택해주세요.';
        if (labelText.contains('종료일') && _workStartDate != null && !date.isAfter(_workStartDate!)) {
          return '종료일은 시작일보다 이후 날짜여야 합니다.';
        }
        return null;
      },
    );
  }

  InputDecoration _getStyledInputDecoration(String labelText, String? hintText, IconData icon) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      prefixIcon: Container(
        margin: const EdgeInsets.fromLTRB(12, 12, 10, 12),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: const Color(0xFFF2711C).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, size: 18, color: const Color(0xFFF2711C)),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey[200]!, width: 1.5)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFF2711C), width: 2)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.red, width: 1.5)),
      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.red, width: 2)),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      labelStyle: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w600),
      hintStyle: TextStyle(color: Colors.grey[400]),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(colors: [Color(0xFFF2711C), Color(0xFFFF8C42)]),
        boxShadow: [BoxShadow(color: const Color(0xFFF2711C).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: _isLoading
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
            : const Text('공고 등록하기', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 0.5)),
      ),
    );
  }

  void _showStyledSelectionSheet({required String title, required List<Map<String, dynamic>> items, required Function(String) onSelected}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.only(top: 16, bottom: 32),
          decoration: const BoxDecoration(
            color: Color(0xFFF8F9FA),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: items.map((item) {
                    return InkWell(
                      onTap: () {
                        onSelected(item['value']);
                        Navigator.pop(context);
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FaIcon(item['icon'], size: 18, color: const Color(0xFFF2711C)),
                            const SizedBox(width: 10),
                            Text(item['label'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
