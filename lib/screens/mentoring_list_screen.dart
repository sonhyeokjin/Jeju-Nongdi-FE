import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:jejunongdi/redux/app_state.dart';
import 'package:jejunongdi/redux/mentoring/mentoring_actions.dart';
import 'package:jejunongdi/redux/mentoring/mentoring_state.dart';
import 'package:jejunongdi/core/models/mentoring_models.dart';
import 'package:jejunongdi/screens/mentoring_create_screen.dart';
import 'package:jejunongdi/screens/mentoring_detail_screen.dart';

class MentoringListScreen extends StatefulWidget {
  const MentoringListScreen({Key? key}) : super(key: key);

  @override
  State<MentoringListScreen> createState() => _MentoringListScreenState();
}

class _MentoringListScreenState extends State<MentoringListScreen>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  
  // 필터 상태
  Category? _selectedCategory;
  MentoringType? _selectedMentoringType;
  ExperienceLevel? _selectedExperienceLevel;
  
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    
    // 초기 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMentorings(refresh: true);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // 페이지 끝에 도달하면 다음 페이지 로드
      _loadMoreMentorings();
    }
  }

  void _loadMentorings({bool refresh = false}) {
    final store = StoreProvider.of<AppState>(context);
    
    if (_hasFilters()) {
      store.dispatch(SearchMentoringsAction(
        page: refresh ? 0 : store.state.mentoringState.currentPage + 1,
        category: _selectedCategory?.value,
        mentoringType: _selectedMentoringType?.value,
        experienceLevel: _selectedExperienceLevel?.value,
        keyword: _searchController.text.trim().isEmpty 
            ? null 
            : _searchController.text.trim(),
        refresh: refresh,
      ));
    } else {
      store.dispatch(LoadMentoringsAction(
        page: refresh ? 0 : store.state.mentoringState.currentPage + 1,
        refresh: refresh,
      ));
    }
  }

  void _loadMoreMentorings() {
    final store = StoreProvider.of<AppState>(context);
    final mentoringState = store.state.mentoringState;
    
    if (!mentoringState.isLoading && mentoringState.hasMore) {
      _loadMentorings();
    }
  }

  bool _hasFilters() {
    return _selectedCategory != null ||
           _selectedMentoringType != null ||
           _selectedExperienceLevel != null ||
           _searchController.text.trim().isNotEmpty;
  }

  void _resetFilters() {
    setState(() {
      _selectedCategory = null;
      _selectedMentoringType = null;
      _selectedExperienceLevel = null;
      _searchController.clear();
    });
    _loadMentorings(refresh: true);
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => _FilterDialog(
        selectedCategory: _selectedCategory,
        selectedMentoringType: _selectedMentoringType,
        selectedExperienceLevel: _selectedExperienceLevel,
        onApply: (category, mentoringType, experienceLevel) {
          setState(() {
            _selectedCategory = category;
            _selectedMentoringType = mentoringType;
            _selectedExperienceLevel = experienceLevel;
          });
          _loadMentorings(refresh: true);
        },
        onReset: _resetFilters,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('멘토링'),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              Icons.filter_list,
              color: _hasFilters() ? Theme.of(context).primaryColor : null,
            ),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [

          // 필터 상태 표시
          if (_hasFilters()) _buildActiveFilters(),
          
          // 멘토링 목록
          Expanded(
            child: StoreConnector<AppState, MentoringState>(
              converter: (store) => store.state.mentoringState,
              builder: (context, mentoringState) {
                if (mentoringState.isLoading && mentoringState.mentorings.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (mentoringState.error != null && mentoringState.mentorings.isEmpty) {
                  return _buildErrorWidget(mentoringState.error!);
                }

                if (mentoringState.mentorings.isEmpty) {
                  return _buildEmptyWidget();
                }

                return RefreshIndicator(
                  onRefresh: () async => _loadMentorings(refresh: true),
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: mentoringState.mentorings.length + 
                               (mentoringState.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == mentoringState.mentorings.length) {
                        // 로딩 인디케이터
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      
                      return _buildMentoringCard(mentoringState.mentorings[index]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (context) => const MentoringCreateScreen(),
            ),
          );
          
          if (result == true) {
            _loadMentorings(refresh: true);
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('멘토링 글 작성'),
      ),
    );
  }

  Widget _buildActiveFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        children: [
          if (_selectedCategory != null)
            Chip(
              label: Text(_selectedCategory!.koreanName),
              onDeleted: () {
                setState(() => _selectedCategory = null);
                _loadMentorings(refresh: true);
              },
            ),
          if (_selectedMentoringType != null)
            Chip(
              label: Text(_selectedMentoringType!.koreanName),
              onDeleted: () {
                setState(() => _selectedMentoringType = null);
                _loadMentorings(refresh: true);
              },
            ),
          if (_selectedExperienceLevel != null)
            Chip(
              label: Text(_selectedExperienceLevel!.koreanName),
              onDeleted: () {
                setState(() => _selectedExperienceLevel = null);
                _loadMentorings(refresh: true);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildMentoringCard(MentoringResponse mentoring) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => MentoringDetailScreen(mentoringId: mentoring.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getMentoringTypeColor(mentoring.mentoringType),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      mentoring.mentoringTypeName,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      mentoring.categoryName,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                mentoring.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                mentoring.description,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.star_outline,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    mentoring.experienceLevelName,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (mentoring.preferredLocation != null) ...[
                    const SizedBox(width: 16),
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      mentoring.preferredLocation!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                  const Spacer(),
                  Text(
                    mentoring.authorName,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getMentoringTypeColor(String type) {
    switch (type) {
      case 'MENTOR_WANTED':
      case 'MENTOR':
        return Colors.blue;
      case 'MENTEE_WANTED':
      case 'MENTEE':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            error,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _loadMentorings(refresh: true),
            child: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            '아직 등록된 멘토링이 없습니다.\n첫 번째 멘토링 글을 작성해보세요!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterDialog extends StatefulWidget {
  final Category? selectedCategory;
  final MentoringType? selectedMentoringType;
  final ExperienceLevel? selectedExperienceLevel;
  final Function(Category?, MentoringType?, ExperienceLevel?) onApply;
  final VoidCallback onReset;

  const _FilterDialog({
    this.selectedCategory,
    this.selectedMentoringType,
    this.selectedExperienceLevel,
    required this.onApply,
    required this.onReset,
  });

  @override
  State<_FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<_FilterDialog> {
  Category? _category;
  MentoringType? _mentoringType;
  ExperienceLevel? _experienceLevel;

  @override
  void initState() {
    super.initState();
    _category = widget.selectedCategory;
    _mentoringType = widget.selectedMentoringType;
    _experienceLevel = widget.selectedExperienceLevel;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('필터'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('멘토링 타입', style: TextStyle(fontWeight: FontWeight.w600)),
            ...MentoringType.values.map((type) => RadioListTile<MentoringType>(
              title: Text(type.koreanName),
              value: type,
              groupValue: _mentoringType,
              onChanged: (value) => setState(() => _mentoringType = value),
              contentPadding: EdgeInsets.zero,
            )),
            
            const SizedBox(height: 16),
            const Text('카테고리', style: TextStyle(fontWeight: FontWeight.w600)),
            DropdownButton<Category>(
              value: _category,
              hint: const Text('카테고리 선택'),
              isExpanded: true,
              onChanged: (value) => setState(() => _category = value),
              items: [
                const DropdownMenuItem<Category>(
                  value: null,
                  child: Text('전체'),
                ),
                ...Category.values.map((category) => DropdownMenuItem<Category>(
                  value: category,
                  child: Text(category.koreanName),
                )),
              ],
            ),
            
            const SizedBox(height: 16),
            const Text('경험 수준', style: TextStyle(fontWeight: FontWeight.w600)),
            DropdownButton<ExperienceLevel>(
              value: _experienceLevel,
              hint: const Text('경험 수준 선택'),
              isExpanded: true,
              onChanged: (value) => setState(() => _experienceLevel = value),
              items: [
                const DropdownMenuItem<ExperienceLevel>(
                  value: null,
                  child: Text('전체'),
                ),
                ...ExperienceLevel.values.map((level) => DropdownMenuItem<ExperienceLevel>(
                  value: level,
                  child: Text(level.koreanName),
                )),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            widget.onReset();
            Navigator.of(context).pop();
          },
          child: const Text('초기화'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onApply(_category, _mentoringType, _experienceLevel);
            Navigator.of(context).pop();
          },
          child: const Text('적용'),
        ),
      ],
    );
  }
}
