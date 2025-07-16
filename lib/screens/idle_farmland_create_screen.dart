// lib/screens/idle_farmland_create_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:jejunongdi/core/models/idle_farmland_models.dart';
import 'package:jejunongdi/redux/app_state.dart';
import 'package:jejunongdi/redux/idle_farmland/idle_farmland_actions.dart';
import 'package:redux/redux.dart';

class IdleFarmlandCreateScreen extends StatefulWidget {
  const IdleFarmlandCreateScreen({super.key});
  @override
  State<IdleFarmlandCreateScreen> createState() => _IdleFarmlandCreateScreenState();
}

class _IdleFarmlandCreateScreenState extends State<IdleFarmlandCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _farmlandNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _latitudeController = TextEditingController(text: '33.4996');
  final _longitudeController = TextEditingController(text: '126.5312');
  final _areaSizeController = TextEditingController();
  final _monthlyRentController = TextEditingController();
  final _startDateController = TextEditingController(text: '2025-07-17');
  final _endDateController = TextEditingController(text: '2026-07-16');
  final _contactPhoneController = TextEditingController();
  final _contactEmailController = TextEditingController();
  final _soilTypeController = TextEditingController(text: 'VOLCANIC');
  final _usageTypeController = TextEditingController(text: 'SHORT_TERM_RENTAL');

  bool _waterSupply = true;
  bool _electricitySupply = true;
  bool _farmingToolsIncluded = true;


  @override
  void dispose() {
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
      store.dispatch(CreateIdleFarmlandAction(request));
    }
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ViewModel>(
      converter: (store) => _ViewModel.fromStore(store),
      onWillChange: (previousViewModel, newViewModel) {
        if (previousViewModel?.isLoading == true && !newViewModel.isLoading && newViewModel.error == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('새로운 농지가 등록되었습니다.')),
          );
          Navigator.of(context).pop();
        }
      },
      builder: (context, vm) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('새 농지 등록'),
            actions: [
              if (vm.isLoading)
                const Padding(
                  padding: EdgeInsets.only(right: 16.0),
                  child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
                )
              else
                TextButton(
                  onPressed: () => _submitForm(StoreProvider.of<AppState>(context)),
                  child: const Text('등록', style: TextStyle(fontSize: 16)),
                )
            ],
          ),
          body: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // [수정] 모든 필드에 대한 입력 UI 추가
                  _buildTextFormField(controller: _titleController, label: '제목'),
                  const SizedBox(height: 20),
                  _buildTextFormField(controller: _farmlandNameController, label: '농지 이름'),
                  const SizedBox(height: 20),
                  _buildTextFormField(controller: _addressController, label: '주소'),
                  const SizedBox(height: 20),
                  _buildTextFormField(controller: _areaSizeController, label: '면적 (평)', keyboardType: TextInputType.number),
                  const SizedBox(height: 20),
                  _buildTextFormField(controller: _monthlyRentController, label: '월 임대료 (원)', keyboardType: TextInputType.number),
                  const SizedBox(height: 20),
                  _buildTextFormField(controller: _startDateController, label: '임대 시작 가능일 (YYYY-MM-DD)'),
                  const SizedBox(height: 20),
                  _buildTextFormField(controller: _endDateController, label: '임대 종료일 (YYYY-MM-DD)'),
                  const SizedBox(height: 20),
                  _buildTextFormField(controller: _contactPhoneController, label: '연락처'),
                  const SizedBox(height: 20),
                  _buildTextFormField(controller: _contactEmailController, label: '이메일'),
                  const SizedBox(height: 20),
                  _buildTextFormField(controller: _soilTypeController, label: '토양 종류 (예: VOLCANIC)'),
                  const SizedBox(height: 20),
                  _buildTextFormField(controller: _usageTypeController, label: '사용 목적 (예: SHORT_TERM_RENTAL)'),
                  const SizedBox(height: 20),

                  // [추가] bool 타입 입력을 위한 스위치
                  SwitchListTile(
                    title: const Text('수도 공급'),
                    value: _waterSupply,
                    onChanged: (bool value) => setState(() => _waterSupply = value),
                  ),
                  SwitchListTile(
                    title: const Text('전기 공급'),
                    value: _electricitySupply,
                    onChanged: (bool value) => setState(() => _electricitySupply = value),
                  ),
                  SwitchListTile(
                    title: const Text('농기구 포함'),
                    value: _farmingToolsIncluded,
                    onChanged: (bool value) => setState(() => _farmingToolsIncluded = value),
                  ),

                  const SizedBox(height: 20),
                  _buildTextFormField(controller: _descriptionController, label: '상세 설명', maxLines: 5),

                  if (vm.error != null) ...[
                    const SizedBox(height: 20),
                    Text(
                      '오류: ${vm.error}',
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                    ),
                  ]
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (value) => (value?.isEmpty ?? true) ? '필수 항목입니다.' : null,
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