import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:jejunongdi/core/models/idle_farmland_models.dart';
import 'package:jejunongdi/redux/app_state.dart';
import 'package:jejunongdi/redux/idle_farmland/idle_farmland_actions.dart';
import 'package:jejunongdi/screens/idle_farmland_edit_screen.dart'; // [추가]
import 'package:redux/redux.dart';

class IdleFarmlandDetailScreen extends StatefulWidget {
  final int farmlandId;

  const IdleFarmlandDetailScreen({super.key, required this.farmlandId});

  @override
  State<IdleFarmlandDetailScreen> createState() => _IdleFarmlandDetailScreenState();
}

class _IdleFarmlandDetailScreenState extends State<IdleFarmlandDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      StoreProvider.of<AppState>(context, listen: false)
          .dispatch(LoadIdleFarmlandDetailAction(widget.farmlandId));
    });
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ViewModel>(
      converter: (store) => _ViewModel.fromStore(store),
      onWillChange: (previousViewModel, newViewModel) {
        if (previousViewModel?.isDeleting == true && !newViewModel.isDeleting && newViewModel.error == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('농지 정보가 삭제되었습니다.')),
          );
          Navigator.of(context).pop(true);
        }
      },
      builder: (context, vm) {
        return Scaffold(
          body: _buildBody(context, vm),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, _ViewModel vm) {
    if (vm.isLoading && vm.farmland == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (vm.error != null && vm.farmland == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text('오류가 발생했습니다: ${vm.error}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                vm.loadFarmland(widget.farmlandId);
              },
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    if (vm.farmland == null) {
      return const Center(child: Text('농지 정보를 찾을 수 없습니다.'));
    }

    return _buildContent(context, vm);
  }

  Widget _buildContent(BuildContext context, _ViewModel vm) {
    final farmland = vm.farmland!;
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 250.0,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(farmland.title, style: const TextStyle(shadows: [Shadow(blurRadius: 2)])), // [수정] address -> title
            background: farmland.imageUrls.isNotEmpty
                ? Image.network(farmland.imageUrls.first, fit: BoxFit.cover)
                : Container(color: Colors.grey, child: const Icon(Icons.image_not_supported, size: 50)),
          ),
          actions: [
            if (vm.isAuthor)
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  // [수정] 수정 화면으로 이동하는 로직
                  Navigator.of(context).push<bool>(
                    MaterialPageRoute(
                      builder: (context) => IdleFarmlandEditScreen(initialFarmland: farmland),
                    ),
                  ).then((isUpdated) {
                    // 수정이 성공적으로 완료되고 돌아왔을 때, 상세 정보를 새로고침
                    if (isUpdated == true) {
                      vm.loadFarmland(farmland.id);
                    }
                  });
                },
              ),
            if (vm.isAuthor)
              IconButton(
                icon: vm.isDeleting ? const SizedBox(width:20, height:20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2,)) : const Icon(Icons.delete),
                onPressed: vm.isDeleting ? null : () => _showDeleteConfirmDialog(context, vm),
              ),
          ],
        ),
        SliverList(
          delegate: SliverChildListDelegate([
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // [수정] 모든 필드를 보여주도록 항목 추가
                  _buildInfoRow(Icons.label_outline, "농지 이름", farmland.farmlandName),
                  const SizedBox(height: 16),
                  _buildInfoRow(Icons.map_outlined, "주소", farmland.address),
                  const SizedBox(height: 16),
                  _buildInfoRow(Icons.aspect_ratio, "면적", "${farmland.areaSize} 평"),
                  const SizedBox(height: 16),
                  _buildInfoRow(Icons.paid_outlined, "월 임대료", "${farmland.monthlyRent ?? 0} 원"),
                  const SizedBox(height: 16),
                  _buildInfoRow(Icons.calendar_today_outlined, "임대 기간", "${farmland.availableStartDate} ~ ${farmland.availableEndDate}"),
                  const SizedBox(height: 16),
                  _buildInfoRow(Icons.phone_outlined, "연락처", farmland.contactPhone ?? '없음'),
                  const SizedBox(height: 16),
                  _buildInfoRow(Icons.email_outlined, "이메일", farmland.contactEmail ?? '없음'),

                  const Divider(height: 40),

                  const Text("편의 시설", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: [
                      if(farmland.waterSupply) _buildAmenityChip("수도 공급"),
                      if(farmland.electricitySupply) _buildAmenityChip("전기 공급"),
                      if(farmland.farmingToolsIncluded) _buildAmenityChip("농기구 포함"),
                    ],
                  ),

                  const Divider(height: 40),

                  const Text("상세 설명", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Text(farmland.description, style: const TextStyle(fontSize: 16, height: 1.5)),
                ],
              ),
            ),
          ]),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.grey[600], size: 20),
        const SizedBox(width: 16),
        SizedBox(
          width: 60,
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
        Expanded(child: Text(value)),
      ],
    );
  }

  Widget _buildAmenityChip(String label) {
    return Chip(
      avatar: const Icon(Icons.check_circle_outline, color: Colors.green),
      label: Text(label),
      backgroundColor: Colors.green.withOpacity(0.1),
      shape: StadiumBorder(side: BorderSide(color: Colors.green.withOpacity(0.3))),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, _ViewModel vm) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('농지 삭제'),
          content: const Text('정말로 이 농지 정보를 삭제하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () {
                vm.deleteFarmland(widget.farmlandId);
                Navigator.of(dialogContext).pop();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('삭제', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}

class _ViewModel {
  final bool isLoading;
  final bool isDeleting;
  final String? error;
  final IdleFarmlandResponse? farmland;
  final bool isAuthor;
  final Function(int) loadFarmland;
  final Function(int) deleteFarmland;

  _ViewModel({
    required this.isLoading,
    required this.isDeleting,
    this.error,
    this.farmland,
    required this.isAuthor,
    required this.loadFarmland,
    required this.deleteFarmland,
  });

  static _ViewModel fromStore(Store<AppState> store) {
    final state = store.state;
    return _ViewModel(
      isLoading: state.idleFarmlandState.isLoading,
      isDeleting: state.idleFarmlandState.isDeleting,
      error: state.idleFarmlandState.error,
      farmland: state.idleFarmlandState.selectedFarmland,
      isAuthor: state.userState.user?.id != null && 
                state.idleFarmlandState.selectedFarmland?.author?.id != null &&
                state.userState.user!.id == state.idleFarmlandState.selectedFarmland!.author!.id,
      loadFarmland: (int id) => store.dispatch(LoadIdleFarmlandDetailAction(id)),
      deleteFarmland: (int id) => store.dispatch(DeleteIdleFarmlandAction(id)),
    );
  }
}