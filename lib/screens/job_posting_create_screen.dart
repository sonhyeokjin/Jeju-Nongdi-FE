import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:jejunongdi/core/models/job_posting_model.dart';
import 'package:jejunongdi/core/services/job_posting_service.dart';
import 'package:jejunongdi/core/utils/logger.dart';

class JobPostingCreateScreen extends StatefulWidget {
  const JobPostingCreateScreen({super.key});

  @override
  State<JobPostingCreateScreen> createState() => _JobPostingCreateScreenState();
}

class _JobPostingCreateScreenState extends State<JobPostingCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final JobPostingService _jobPostingService = JobPostingService.instance;
  
  // Form controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _farmNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _wagesController = TextEditingController();
  final _recruitmentCountController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  final _contactEmailController = TextEditingController();
  
  // Selected values
  CropType? _selectedCropType;
  WorkType? _selectedWorkType;
  WageType _selectedWageType = WageType.daily;
  DateTime? _workStartDate;
  DateTime? _workEndDate;
  
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _farmNameController.dispose();
    _addressController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _wagesController.dispose();
    _recruitmentCountController.dispose();
    _contactPhoneController.dispose();
    _contactEmailController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('ko', 'KR'),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _workStartDate = picked;
          // 시작일이 종료일보다 뒤면 종료일을 시작일로 설정
          if (_workEndDate != null && _workEndDate!.isBefore(picked)) {
            _workEndDate = picked;
          }
        } else {
          _workEndDate = picked;
        }
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '날짜 선택';
    return DateFormat('yyyy년 MM월 dd일').format(date);
  }

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName은(는) 필수입니다';
    }
    return null;
  }

  String? _validateLatitude(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '위도는 필수입니다';
    }
    final double? latitude = double.tryParse(value);
    if (latitude == null) {
      return '올바른 숫자를 입력해주세요';
    }
    if (latitude < 33.0 || latitude > 34.0) {
      return '제주도 범위의 위도를 입력해주세요 (33.0~34.0)';
    }
    return null;
  }

  String? _validateLongitude(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '경도는 필수입니다';
    }
    final double? longitude = double.tryParse(value);
    if (longitude == null) {
      return '올바른 숫자를 입력해주세요';
    }
    if (longitude < 126.0 || longitude > 127.0) {
      return '제주도 범위의 경도를 입력해주세요 (126.0~127.0)';
    }
    return null;
  }

  String? _validateWages(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '급여는 필수입니다';
    }
    final int? wages = int.tryParse(value.replaceAll(',', ''));
    if (wages == null) {
      return '올바른 숫자를 입력해주세요';
    }
    if (wages < 1000 || wages > 1000000) {
      return '급여는 1,000원 이상 1,000,000원 이하여야 합니다';
    }
    return null;
  }

  String? _validateRecruitmentCount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '모집 인원은 필수입니다';
    }
    final int? count = int.tryParse(value);
    if (count == null) {
      return '올바른 숫자를 입력해주세요';
    }
    if (count < 1 || count > 100) {
      return '모집 인원은 1명 이상 100명 이하여야 합니다';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value != null && value.trim().isNotEmpty) {
      final phoneRegex = RegExp(r'^\d{2,3}-\d{3,4}-\d{4}$');
      if (!phoneRegex.hasMatch(value)) {
        return '올바른 전화번호 형식이 아닙니다 (예: 010-1234-5678)';
      }
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value != null && value.trim().isNotEmpty) {
      final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
      if (!emailRegex.hasMatch(value)) {
        return '올바른 이메일 형식이 아닙니다';
      }
    }
    return null;
  }

  bool _validateContactInfo() {
    final phone = _contactPhoneController.text.trim();
    final email = _contactEmailController.text.trim();
    return phone.isNotEmpty || email.isNotEmpty;
  }

  bool _validateDates() {
    if (_workStartDate == null || _workEndDate == null) return false;
    return _workEndDate!.isAfter(_workStartDate!) || _workEndDate!.isAtSameMomentAs(_workStartDate!);
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedCropType == null) {
      _showErrorSnackBar('작물 종류를 선택해주세요');
      return;
    }
    
    if (_selectedWorkType == null) {
      _showErrorSnackBar('작업 종류를 선택해주세요');
      return;
    }
    
    if (_workStartDate == null) {
      _showErrorSnackBar('작업 시작일을 선택해주세요');
      return;
    }
    
    if (_workEndDate == null) {
      _showErrorSnackBar('작업 종료일을 선택해주세요');
      return;
    }
    
    if (!_validateDates()) {
      _showErrorSnackBar('작업 종료일은 시작일과 같거나 뒤여야 합니다');
      return;
    }
    
    if (!_validateContactInfo()) {
      _showErrorSnackBar('전화번호 또는 이메일 중 하나는 필수입니다');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final request = JobPostingRequest(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        farmName: _farmNameController.text.trim(),
        address: _addressController.text.trim(),
        latitude: double.parse(_latitudeController.text),
        longitude: double.parse(_longitudeController.text),
        cropType: _selectedCropType!,
        workType: _selectedWorkType!,
        wages: int.parse(_wagesController.text.replaceAll(',', '')),
        wageType: _selectedWageType,
        workStartDate: DateFormat('yyyy-MM-dd').format(_workStartDate!),
        workEndDate: DateFormat('yyyy-MM-dd').format(_workEndDate!),
        recruitmentCount: int.parse(_recruitmentCountController.text),
        contactPhone: _contactPhoneController.text.trim().isEmpty 
            ? null 
            : _contactPhoneController.text.trim(),
        contactEmail: _contactEmailController.text.trim().isEmpty 
            ? null 
            : _contactEmailController.text.trim(),
      );

      final result = await _jobPostingService.createJobPosting(request);
      
      if (result.isSuccess && mounted) {
        _showSuccessDialog();
      } else if (result.isFailure && mounted) {
        _showErrorSnackBar(result.error?.message ?? '공고 등록에 실패했습니다');
      }
    } catch (e) {
      Logger.error('공고 등록 오류', error: e);
      if (mounted) {
        _showErrorSnackBar('공고 등록 중 오류가 발생했습니다: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 28),
              SizedBox(width: 8),
              Text('등록 완료'),
            ],
          ),
          content: const Text('일손 모집 공고가 성공적으로 등록되었습니다!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
                Navigator.of(context).pop(); // 등록 화면 닫기
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          '일손 모집 공고 등록',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFFF2711C),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionCard(
                title: '기본 정보',
                icon: Icons.info_outline,
                children: [
                  _buildTextField(
                    controller: _titleController,
                    label: '제목',
                    hint: '예: 감귤 수확 일손 구합니다',
                    validator: (value) => _validateRequired(value, '제목'),
                    maxLength: 100,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _descriptionController,
                    label: '상세 설명 (선택)',
                    hint: '작업 내용, 주의사항 등을 자세히 적어주세요',
                    maxLines: 4,
                    maxLength: 2000,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _farmNameController,
                    label: '농장명',
                    hint: '예: 제주감귤농장',
                    validator: (value) => _validateRequired(value, '농장명'),
                    maxLength: 50,
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              _buildSectionCard(
                title: '위치 정보',
                icon: Icons.location_on,
                children: [
                  _buildTextField(
                    controller: _addressController,
                    label: '주소',
                    hint: '예: 제주시 애월읍 고성리 123',
                    validator: (value) => _validateRequired(value, '주소'),
                    maxLength: 200,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _latitudeController,
                          label: '위도',
                          hint: '33.0~34.0',
                          validator: _validateLatitude,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          controller: _longitudeController,
                          label: '경도',
                          hint: '126.0~127.0',
                          validator: _validateLongitude,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue, size: 16),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '정확한 위치 정보를 입력하면 구직자가 쉽게 찾을 수 있습니다',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              _buildSectionCard(
                title: '작업 정보',
                icon: Icons.agriculture,
                children: [
                  _buildDropdownField<CropType>(
                    label: '작물 종류',
                    value: _selectedCropType,
                    items: CropType.values,
                    itemBuilder: (cropType) => cropType.displayName,
                    onChanged: (value) => setState(() => _selectedCropType = value),
                  ),
                  const SizedBox(height: 16),
                  _buildDropdownField<WorkType>(
                    label: '작업 종류',
                    value: _selectedWorkType,
                    items: WorkType.values,
                    itemBuilder: (workType) => workType.displayName,
                    onChanged: (value) => setState(() => _selectedWorkType = value),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              _buildSectionCard(
                title: '급여 정보',
                icon: Icons.paid,
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: _buildTextField(
                          controller: _wagesController,
                          label: '급여',
                          hint: '예: 100000',
                          validator: _validateWages,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            TextInputFormatter.withFunction((oldValue, newValue) {
                              final number = int.tryParse(newValue.text.replaceAll(',', ''));
                              if (number == null) return newValue;
                              final formatter = NumberFormat('#,###');
                              return TextEditingValue(
                                text: formatter.format(number),
                                selection: TextSelection.collapsed(offset: formatter.format(number).length),
                              );
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDropdownField<WageType>(
                          label: '급여 형태',
                          value: _selectedWageType,
                          items: WageType.values,
                          itemBuilder: (wageType) => wageType.displayName,
                          onChanged: (value) => setState(() => _selectedWageType = value!),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              _buildSectionCard(
                title: '근무 기간',
                icon: Icons.calendar_today,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildDateField(
                          label: '시작일',
                          date: _workStartDate,
                          onTap: () => _selectDate(context, true),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDateField(
                          label: '종료일',
                          date: _workEndDate,
                          onTap: () => _selectDate(context, false),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              _buildSectionCard(
                title: '모집 정보',
                icon: Icons.people,
                children: [
                  _buildTextField(
                    controller: _recruitmentCountController,
                    label: '모집 인원',
                    hint: '예: 5',
                    validator: _validateRecruitmentCount,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    suffix: const Text('명'),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              _buildSectionCard(
                title: '연락처 정보',
                icon: Icons.contact_phone,
                children: [
                  _buildTextField(
                    controller: _contactPhoneController,
                    label: '전화번호 (선택)',
                    hint: '예: 010-1234-5678',
                    validator: _validatePhone,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _contactEmailController,
                    label: '이메일 (선택)',
                    hint: '예: example@email.com',
                    validator: _validateEmail,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.warning, color: Colors.orange, size: 16),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '전화번호 또는 이메일 중 최소 하나는 입력해주세요',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF2711C),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          '공고 등록하기',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFFF2711C)),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF2711C),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
    int? maxLength,
    Widget? suffix,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      maxLength: maxLength,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffix: suffix,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFF2711C)),
        ),
        counterText: maxLength != null ? null : '',
      ),
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required T? value,
    required List<T> items,
    required String Function(T) itemBuilder,
    required void Function(T?) onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFF2711C)),
        ),
      ),
      items: items.map((item) {
        return DropdownMenuItem<T>(
          value: item,
          child: Text(itemBuilder(item)),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) {
        if (value == null) {
          return '$label을(를) 선택해주세요';
        }
        return null;
      },
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDate(date),
                  style: TextStyle(
                    fontSize: 16,
                    color: date != null ? Colors.black : Colors.grey,
                  ),
                ),
                const Icon(Icons.calendar_today, size: 20, color: Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
