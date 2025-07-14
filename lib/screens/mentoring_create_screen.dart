import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:jejunongdi/redux/app_state.dart';
import 'package:jejunongdi/redux/mentoring/mentoring_actions.dart';
import 'package:jejunongdi/redux/mentoring/mentoring_state.dart';
import 'package:jejunongdi/core/models/mentoring_models.dart';

class MentoringCreateScreen extends StatefulWidget {
  const MentoringCreateScreen({Key? key}) : super(key: key);

  @override
  State<MentoringCreateScreen> createState() => _MentoringCreateScreenState();
}

class _MentoringCreateScreenState extends State<MentoringCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  
  // 폼 필드 컨트롤러들
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _scheduleController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  
  // 선택된 값들
  MentoringType? _selectedMentoringType;
  Category? _selectedCategory;
  ExperienceLevel? _selectedExperienceLevel;

  @override
  void dispose() {
    _scrollController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _scheduleController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  bool _validateContactInfo() {
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    return phone.isNotEmpty || email.isNotEmpty;
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_validateContactInfo()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('전화번호 또는 이메일 중 하나는 반드시 입력해주세요.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final request = MentoringRequest(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      mentoringType: _selectedMentoringType!.value,
      category: _selectedCategory!.value,
      experienceLevel: _selectedExperienceLevel!.value,
      preferredLocation: _locationController.text.trim().isEmpty 
          ? null 
          : _locationController.text.trim(),
      preferredSchedule: _scheduleController.text.trim().isEmpty 
          ? null 
          : _scheduleController.text.trim(),
      contactPhone: _phoneController.text.trim().isEmpty 
          ? null 
          : _phoneController.text.trim(),
      contactEmail: _emailController.text.trim().isEmpty 
          ? null 
          : _emailController.text.trim(),
    );

    StoreProvider.of<AppState>(context).dispatch(CreateMentoringAction(request));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('멘토링 글 작성'),
        elevation: 0,
        actions: [
          StoreConnector<AppState, bool>(
            converter: (store) => store.state.mentoringState.isCreateLoading,
            builder: (context, isLoading) {
              return isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : TextButton(
                      onPressed: _submitForm,
                      child: const Text(
                        '작성완료',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
            },
          ),
        ],
      ),
      body: StoreConnector<AppState, MentoringState>(
        converter: (store) => store.state.mentoringState,
        onWillChange: (prev, current) {
          // 생성 성공시 이전 화면으로 이동
          if (prev?.isCreateLoading == true && 
              current.isCreateLoading == false && 
              current.error == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('멘토링 글이 성공적으로 작성되었습니다!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop(true);
          }
          
          // 에러 발생시 스낵바 표시
          if (prev?.error != current.error && current.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(current.error!),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, mentoringState) {
          return SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 제목 입력
                  _buildSectionTitle('제목', required: true),
                  const SizedBox(height: 8),
                  _buildTextFormField(
                    controller: _titleController,
                    hintText: '멘토링 글의 제목을 입력해주세요',
                    maxLength: 100,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return '제목은 필수입니다';
                      }
                      if (value.length > 100) {
                        return '제목은 100자를 초과할 수 없습니다';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // 멘토링 타입 선택
                  _buildSectionTitle('멘토링 타입', required: true),
                  const SizedBox(height: 8),
                  _buildMentoringTypeSelector(),
                  const SizedBox(height: 24),

                  // 카테고리 선택
                  _buildSectionTitle('카테고리', required: true),
                  const SizedBox(height: 8),
                  _buildDropdown<Category>(
                    value: _selectedCategory,
                    items: Category.values,
                    hint: '카테고리를 선택해주세요',
                    onChanged: (value) => setState(() => _selectedCategory = value),
                    itemBuilder: (category) => category.koreanName,
                    validator: (value) => value == null ? '카테고리는 필수입니다' : null,
                  ),
                  const SizedBox(height: 24),

                  // 경험 수준 선택
                  _buildSectionTitle('경험 수준', required: true),
                  const SizedBox(height: 8),
                  _buildDropdown<ExperienceLevel>(
                    value: _selectedExperienceLevel,
                    items: ExperienceLevel.values,
                    hint: '경험 수준을 선택해주세요',
                    onChanged: (value) => setState(() => _selectedExperienceLevel = value),
                    itemBuilder: (level) => level.koreanName,
                    validator: (value) => value == null ? '경험 수준은 필수입니다' : null,
                  ),
                  const SizedBox(height: 24),

                  // 설명 입력
                  _buildSectionTitle('설명', required: true),
                  const SizedBox(height: 8),
                  _buildTextFormField(
                    controller: _descriptionController,
                    hintText: '멘토링에 대한 자세한 설명을 작성해주세요',
                    maxLength: 1000,
                    maxLines: 5,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return '설명은 필수입니다';
                      }
                      if (value.length > 1000) {
                        return '설명은 1000자를 초과할 수 없습니다';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // 희망 지역
                  _buildSectionTitle('희망 지역'),
                  const SizedBox(height: 8),
                  _buildTextFormField(
                    controller: _locationController,
                    hintText: '희망하는 지역을 입력해주세요 (선택사항)',
                    maxLength: 100,
                  ),
                  const SizedBox(height: 24),

                  // 희망 일정
                  _buildSectionTitle('희망 일정'),
                  const SizedBox(height: 8),
                  _buildTextFormField(
                    controller: _scheduleController,
                    hintText: '희망하는 일정을 입력해주세요 (선택사항)',
                    maxLength: 200,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 24),

                  // 연락처 정보
                  _buildSectionTitle('연락처 정보', required: true),
                  const SizedBox(height: 4),
                  Text(
                    '전화번호 또는 이메일 중 하나는 반드시 입력해주세요',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // 전화번호
                  _buildTextFormField(
                    controller: _phoneController,
                    hintText: '전화번호',
                    maxLength: 20,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  
                  // 이메일
                  _buildTextFormField(
                    controller: _emailController,
                    hintText: '이메일 주소',
                    maxLength: 100,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        // 이메일 형식 검증
                        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                        if (!emailRegex.hasMatch(value)) {
                          return '올바른 이메일 형식이 아닙니다';
                        }
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title, {bool required = false}) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (required) ...[
          const SizedBox(width: 4),
          const Text(
            '*',
            style: TextStyle(
              color: Colors.red,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String hintText,
    int? maxLength,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLength: maxLength,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T? value,
    required List<T> items,
    required String hint,
    required ValueChanged<T?> onChanged,
    required String Function(T) itemBuilder,
    String? Function(T?)? validator,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
      items: items.map((item) {
        return DropdownMenuItem<T>(
          value: item,
          child: Text(itemBuilder(item)),
        );
      }).toList(),
    );
  }

  Widget _buildMentoringTypeSelector() {
    return Column(
      children: MentoringType.values.map((type) {
        return RadioListTile<MentoringType>(
          title: Text(type.koreanName),
          value: type,
          groupValue: _selectedMentoringType,
          onChanged: (value) => setState(() => _selectedMentoringType = value),
          contentPadding: EdgeInsets.zero,
        );
      }).toList(),
    );
  }
}
