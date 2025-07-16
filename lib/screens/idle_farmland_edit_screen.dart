import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
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

class _IdleFarmlandEditScreenState extends State<IdleFarmlandEditScreen> {
  final _formKey = GlobalKey<FormState>();

  // [수정] 모든 필드에 대한 컨트롤러 및 상태 변수 추가
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

  @override
  void initState() {
    super.initState();
    // [수정] 전달받은 정보로 모든 텍스트 필드와 상태 변수를 초기화합니다.
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
  }

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
      // [수정] 모든 필드를 포함하여 요청 객체 생성
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
            const SnackBar(content: Text('농지 정보가 수정되었습니다.')),
          );
          Navigator.of(context).pop(true);
        }
      },
      builder: (context, vm) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('농지 정보 수정'),
            actions: [
              if (vm.isLoading)
                const Padding(
                  padding: EdgeInsets.only(right: 16.0),
                  child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
                )
              else
                TextButton(
                  onPressed: () => _submitForm(StoreProvider.of<AppState>(context)),
                  child: const Text('저장', style: TextStyle(fontSize: 16)),
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
                    Text('오류: ${vm.error}', style: const TextStyle(color: Colors.red, fontSize: 14)),
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