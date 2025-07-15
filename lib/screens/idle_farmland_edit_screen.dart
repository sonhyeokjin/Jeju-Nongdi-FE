import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:jejunongdi/core/models/idle_farmland_models.dart';
import 'package:jejunongdi/redux/app_state.dart';
import 'package:jejunongdi/redux/idle_farmland/idle_farmland_actions.dart';
import 'package:redux/redux.dart';

class IdleFarmlandEditScreen extends StatefulWidget {
  // 수정할 기존 농지 정보를 전달받습니다.
  final IdleFarmlandResponse initialFarmland;

  const IdleFarmlandEditScreen({super.key, required this.initialFarmland});

  @override
  State<IdleFarmlandEditScreen> createState() => _IdleFarmlandEditScreenState();
}

class _IdleFarmlandEditScreenState extends State<IdleFarmlandEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _addressController;
  late TextEditingController _areaController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    // 전달받은 정보로 텍스트 필드를 초기화합니다.
    _addressController = TextEditingController(text: widget.initialFarmland.address);
    _areaController = TextEditingController(text: widget.initialFarmland.area.toString());
    _descriptionController = TextEditingController(text: widget.initialFarmland.description);
  }

  @override
  void dispose() {
    _addressController.dispose();
    _areaController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitForm(Store<AppState> store) {
    if (_formKey.currentState?.validate() ?? false) {
      final request = IdleFarmlandRequest(
        address: _addressController.text,
        area: double.tryParse(_areaController.text) ?? 0.0,
        description: _descriptionController.text,
        imageUrls: widget.initialFarmland.imageUrls, // 이미지는 그대로 유지
      );

      store.dispatch(UpdateIdleFarmlandAction(widget.initialFarmland.id, request));
    }
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ViewModel>(
      converter: (store) => _ViewModel.fromStore(store),
      onWillChange: (previousViewModel, newViewModel) {
        // 수정이 성공적으로 완료되면 이전 화면으로 돌아갑니다.
        if (previousViewModel?.isLoading == true && !newViewModel.isLoading && newViewModel.error == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('농지 정보가 수정되었습니다.')),
          );
          Navigator.of(context).pop(true); // 수정 성공을 알림
        }
      },
      builder: (context, vm) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('농지 정보 수정'),
            actions: [
              // 로딩 중일 때는 버튼 비활성화
              if (vm.isLoading)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextFormField(
                    controller: _addressController,
                    label: '주소',
                    validator: (value) => (value?.isEmpty ?? true) ? '주소를 입력해주세요.' : null,
                  ),
                  const SizedBox(height: 20),
                  _buildTextFormField(
                    controller: _areaController,
                    label: '면적 (평)',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value?.isEmpty ?? true) return '면적을 입력해주세요.';
                      if (double.tryParse(value!) == null) return '숫자만 입력해주세요.';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildTextFormField(
                    controller: _descriptionController,
                    label: '상세 설명',
                    maxLines: 5,
                    validator: (value) => (value?.isEmpty ?? true) ? '상세 설명을 입력해주세요.' : null,
                  ),
                  if (vm.error != null) ...[
                    const SizedBox(height: 20),
                    Text('오류: ${vm.error}', style: const TextStyle(color: Colors.red)),
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
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: validator,
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