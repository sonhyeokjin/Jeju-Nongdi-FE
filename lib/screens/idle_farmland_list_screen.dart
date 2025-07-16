import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:jejunongdi/core/models/idle_farmland_models.dart';
import 'package:jejunongdi/redux/app_state.dart';
import 'package:jejunongdi/redux/idle_farmland/idle_farmland_actions.dart';
import 'package:jejunongdi/screens/idle_farmland_create_screen.dart';
import 'package:jejunongdi/screens/idle_farmland_detail_screen.dart';
import 'package:redux/redux.dart';

class IdleFarmlandListScreen extends StatefulWidget {
  const IdleFarmlandListScreen({super.key});

  @override
  State<IdleFarmlandListScreen> createState() => _IdleFarmlandListScreenState();
}

class _IdleFarmlandListScreenState extends State<IdleFarmlandListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      StoreProvider.of<AppState>(context, listen: false).dispatch(LoadIdleFarmlandsAction(refresh: true));
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      StoreProvider.of<AppState>(context, listen: false).dispatch(LoadIdleFarmlandsAction());
    }
  }

  Future<void> _onRefresh() async {
    StoreProvider.of<AppState>(context, listen: false).dispatch(LoadIdleFarmlandsAction(refresh: true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('유휴 농지 목록')),
      body: StoreConnector<AppState, _ViewModel>(
        converter: (store) => _ViewModel.fromStore(store),
        builder: (context, vm) {
          if (vm.isLoading && vm.farmlands.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (vm.error != null && vm.farmlands.isEmpty) {
            return Center(child: Text('오류: ${vm.error}'));
          }
          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView.builder(
              controller: _scrollController,
              itemCount: vm.farmlands.length + (vm.hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == vm.farmlands.length) {
                  return const Center(child: CircularProgressIndicator());
                }
                final farmland = vm.farmlands[index];
                return _FarmlandCard(farmland: farmland);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const IdleFarmlandCreateScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _FarmlandCard extends StatelessWidget {
  final IdleFarmlandResponse farmland;
  const _FarmlandCard({required this.farmland});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => IdleFarmlandDetailScreen(farmlandId: farmland.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                farmland.title, // [수정] 주소 대신 제목 표시
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                farmland.address, // [추가] 주소를 부가 정보로 표시
                style: TextStyle(color: Colors.grey[600]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Chip(
                    label: Text('${farmland.areaSize}평'),
                    backgroundColor: Colors.grey[200],
                  ),
                  Text(
                    '월 ${farmland.monthlyRent ?? 0}원', // [추가] 월 임대료 표시
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFFF2711C)),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _ViewModel {
  final bool isLoading;
  final String? error;
  final List<IdleFarmlandResponse> farmlands;
  final bool hasMore;

  _ViewModel({
    required this.isLoading,
    this.error,
    required this.farmlands,
    required this.hasMore,
  });

  static _ViewModel fromStore(Store<AppState> store) {
    final state = store.state.idleFarmlandState;
    return _ViewModel(
      isLoading: state.isLoading,
      error: state.error,
      farmlands: state.farmlands,
      hasMore: state.hasMore,
    );
  }
}