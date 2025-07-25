import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jejunongdi/core/models/idle_farmland_models.dart';
import 'package:jejunongdi/redux/app_state.dart';
import 'package:jejunongdi/redux/idle_farmland/idle_farmland_actions.dart';
import 'package:jejunongdi/screens/idle_farmland_edit_screen.dart';
import 'package:redux/redux.dart';

class IdleFarmlandDetailScreen extends StatefulWidget {
  final int farmlandId;

  const IdleFarmlandDetailScreen({super.key, required this.farmlandId});

  @override
  State<IdleFarmlandDetailScreen> createState() => _IdleFarmlandDetailScreenState();
}

class _IdleFarmlandDetailScreenState extends State<IdleFarmlandDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
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

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      StoreProvider.of<AppState>(context, listen: false)
          .dispatch(LoadIdleFarmlandDetailAction(widget.farmlandId));
      
      _fadeController.forward();
      Future.delayed(const Duration(milliseconds: 200), () {
        _slideController.forward();
      });
      Future.delayed(const Duration(milliseconds: 400), () {
        _scaleController.forward();
      });
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ViewModel>(
      converter: (store) => _ViewModel.fromStore(store),
      onWillChange: (previousViewModel, newViewModel) {
        if (previousViewModel?.isDeleting == true && !newViewModel.isDeleting && newViewModel.error == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('농지 정보가 삭제되었습니다. 🗑️'),
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
            child: _buildBody(context, vm),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, _ViewModel vm) {
    if (vm.isLoading && vm.farmland == null) {
      return Center(
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  color: Color(0xFFF2711C),
                ),
                const SizedBox(height: 16),
                Text(
                  '농지 정보를 불러오는 중...',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (vm.error != null && vm.farmland == null) {
      return Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            margin: const EdgeInsets.all(32),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  FontAwesomeIcons.exclamationTriangle,
                  color: Colors.red,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  '오류가 발생했습니다',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${vm.error}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    vm.loadFarmland(widget.farmlandId);
                  },
                  icon: const Icon(FontAwesomeIcons.arrowRotateRight),
                  label: const Text('다시 시도'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF2711C),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (vm.farmland == null) {
      return const Center(
        child: Text(
          '농지 정보를 찾을 수 없습니다.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      );
    }

    return _buildContent(context, vm);
  }

  Widget _buildContent(BuildContext context, _ViewModel vm) {
    final farmland = vm.farmland!;
    return CustomScrollView(
      slivers: [
        _buildSliverAppBar(farmland, vm),
        SliverToBoxAdapter(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: _buildMainContent(farmland),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSliverAppBar(IdleFarmlandResponse farmland, _ViewModel vm) {
    return SliverAppBar(
      expandedHeight: 300.0,
      pinned: true,
      stretch: true,
      backgroundColor: Colors.transparent,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
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
      actions: [
        if (vm.isAuthor) ...[
          Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12),
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
                FontAwesomeIcons.pen,
                color: Color(0xFFF2711C),
                size: 18,
              ),
              onPressed: () {
                Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                    builder: (context) => IdleFarmlandEditScreen(initialFarmland: farmland),
                  ),
                ).then((isUpdated) {
                  if (isUpdated == true) {
                    vm.loadFarmland(farmland.id);
                  }
                });
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 8, top: 4, bottom: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: vm.isDeleting 
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: Colors.red,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(
                      FontAwesomeIcons.trash,
                      color: Colors.red,
                      size: 16,
                    ),
              onPressed: vm.isDeleting ? null : () => _showDeleteConfirmDialog(context, vm),
            ),
          ),
        ],
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            farmland.imageUrls.isNotEmpty
                ? Image.network(
                    farmland.imageUrls.first,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildDefaultImage();
                    },
                  )
                : _buildDefaultImage(),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.3),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        farmland.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFF2711C),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            FontAwesomeIcons.locationDot,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              farmland.address,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultImage() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF2711C),
            Color(0xFFFF8C42),
          ],
        ),
      ),
      child: const Center(
        child: Icon(
          FontAwesomeIcons.seedling,
          size: 80,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildMainContent(IdleFarmlandResponse farmland) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          _buildInfoSection(farmland),
          const SizedBox(height: 20),
          _buildAmenitiesSection(farmland),
          const SizedBox(height: 20),
          _buildDescriptionSection(farmland),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildInfoSection(IdleFarmlandResponse farmland) {
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
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2711C).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    FontAwesomeIcons.circleInfo,
                    color: Color(0xFFF2711C),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  '상세 정보',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildInfoRow(FontAwesomeIcons.seedling, "농지명", farmland.farmlandName),
            const SizedBox(height: 16),
            _buildInfoRow(FontAwesomeIcons.maximize, "면적", "${farmland.areaSize} 평"),
            const SizedBox(height: 16),
            _buildInfoRow(FontAwesomeIcons.won, "월 임대료", "${farmland.monthlyRent ?? 0} 원"),
            const SizedBox(height: 16),
            _buildInfoRow(FontAwesomeIcons.calendar, "임대 기간", "${farmland.availableStartDate} ~ ${farmland.availableEndDate}"),
            const SizedBox(height: 16),
            _buildInfoRow(FontAwesomeIcons.phone, "연락처", farmland.contactPhone ?? '없음'),
            const SizedBox(height: 16),
            _buildInfoRow(FontAwesomeIcons.envelope, "이메일", farmland.contactEmail ?? '없음'),
            const SizedBox(height: 16),
            _buildInfoRow(FontAwesomeIcons.mountain, "토양 종류", farmland.soilType ?? '없음'),
            const SizedBox(height: 16),
            _buildInfoRow(FontAwesomeIcons.bullseye, "사용 목적", farmland.usageType ?? '없음'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: const Color(0xFFF2711C),
            size: 16,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAmenitiesSection(IdleFarmlandResponse farmland) {
    List<Map<String, dynamic>> amenities = [];
    
    if (farmland.waterSupply == true) {
      amenities.add({'icon': FontAwesomeIcons.droplet, 'label': '수도 공급', 'color': Colors.blue});
    }
    if (farmland.electricitySupply == true) {
      amenities.add({'icon': FontAwesomeIcons.bolt, 'label': '전기 공급', 'color': Colors.amber});
    }
    if (farmland.farmingToolsIncluded == true) {
      amenities.add({'icon': FontAwesomeIcons.hammer, 'label': '농기구 포함', 'color': Colors.green});
    }

    if (amenities.isEmpty) return const SizedBox.shrink();

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
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2711C).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    FontAwesomeIcons.tools,
                    color: Color(0xFFF2711C),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  '편의시설',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: amenities.map((amenity) => _buildAmenityChip(
                amenity['icon'],
                amenity['label'],
                amenity['color'],
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmenityChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(IdleFarmlandResponse farmland) {
    if (farmland.description.isEmpty) return const SizedBox.shrink();

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
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2711C).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    FontAwesomeIcons.fileText,
                    color: Color(0xFFF2711C),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  '상세 설명',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                farmland.description,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: Colors.black87,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, _ViewModel vm) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  FontAwesomeIcons.exclamationTriangle,
                  color: Colors.red,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                '농지 삭제',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          content: const Text(
            '정말로 이 농지 정보를 삭제하시겠습니까?\n삭제된 정보는 복구할 수 없습니다.',
            style: TextStyle(
              fontSize: 16,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                '취소',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                vm.deleteFarmland(widget.farmlandId);
                Navigator.of(dialogContext).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text(
                '삭제',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
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