import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:jejunongdi/redux/app_state.dart';
import 'package:jejunongdi/redux/mentoring/mentoring_actions.dart';
import 'package:jejunongdi/redux/mentoring/mentoring_state.dart';
import 'package:jejunongdi/core/models/mentoring_models.dart';
import 'package:jejunongdi/screens/mentoring_create_screen.dart';
import 'package:jejunongdi/screens/mentoring_detail_screen.dart';

class MyMentoringListScreen extends StatefulWidget {
  const MyMentoringListScreen({Key? key}) : super(key: key);

  @override
  State<MyMentoringListScreen> createState() => _MyMentoringListScreenState();
}

class _MyMentoringListScreenState extends State<MyMentoringListScreen>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    
    // 초기 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMyMentorings(refresh: true);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // 페이지 끝에 도달하면 다음 페이지 로드
      _loadMoreMentorings();
    }
  }

  void _loadMyMentorings({bool refresh = false}) {
    final store = StoreProvider.of<AppState>(context);
    store.dispatch(LoadMyMentoringsAction(
      page: refresh ? 0 : store.state.mentoringState.currentPage + 1,
      refresh: refresh,
    ));
  }

  void _loadMoreMentorings() {
    final store = StoreProvider.of<AppState>(context);
    final mentoringState = store.state.mentoringState;
    
    if (!mentoringState.isLoading && mentoringState.hasMore) {
      _loadMyMentorings();
    }
  }

  void _showDeleteConfirmDialog(MentoringResponse mentoring) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('멘토링 삭제'),
        content: Text('${mentoring.title} 글을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              StoreProvider.of<AppState>(context)
                  .dispatch(DeleteMentoringAction(mentoring.id));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('내 멘토링'),
        elevation: 0,
      ),
      body: StoreConnector<AppState, MentoringState>(
        converter: (store) => store.state.mentoringState,
        onWillChange: (prev, current) {
          // 삭제 성공시 메시지 표시
          if (prev?.isLoading == true && 
              current.isLoading == false && 
              current.error == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('멘토링 글이 삭제되었습니다.'),
                backgroundColor: Colors.green,
              ),
            );
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
          if (mentoringState.isLoading && mentoringState.myMentorings.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (mentoringState.error != null && mentoringState.myMentorings.isEmpty) {
            return _buildErrorWidget(mentoringState.error!);
          }

          if (mentoringState.myMentorings.isEmpty) {
            return _buildEmptyWidget();
          }

          return RefreshIndicator(
            onRefresh: () async => _loadMyMentorings(refresh: true),
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: mentoringState.myMentorings.length + 
                         (mentoringState.hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == mentoringState.myMentorings.length) {
                  // 로딩 인디케이터
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                
                return _buildMentoringCard(mentoringState.myMentorings[index]);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (context) => const MentoringCreateScreen(),
            ),
          );
          
          if (result == true) {
            _loadMyMentorings(refresh: true);
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('멘토링 글 작성'),
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
                      color: _getStatusColor(mentoring.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      mentoring.statusName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: _getStatusColor(mentoring.status),
                      ),
                    ),
                  ),
                  const Spacer(),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        // TODO: 편집 화면으로 이동
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('편집 기능은 준비 중입니다.')),
                        );
                      } else if (value == 'delete') {
                        _showDeleteConfirmDialog(mentoring);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit),
                            SizedBox(width: 8),
                            Text('수정'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('삭제'),
                          ],
                        ),
                      ),
                    ],
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
                    _formatDate(mentoring.createdAt),
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'ACTIVE':
        return Colors.green;
      case 'MATCHED':
        return Colors.blue;
      case 'CLOSED':
        return Colors.orange;
      case 'CANCELLED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
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
            onPressed: () => _loadMyMentorings(refresh: true),
            child: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.article_outlined,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            '아직 작성한 멘토링 글이 없습니다.\n첫 번째 멘토링 글을 작성해보세요!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () async {
              final result = await Navigator.of(context).push<bool>(
                MaterialPageRoute(
                  builder: (context) => const MentoringCreateScreen(),
                ),
              );
              
              if (result == true) {
                _loadMyMentorings(refresh: true);
              }
            },
            icon: const Icon(Icons.add),
            label: const Text('멘토링 글 작성'),
          ),
        ],
      ),
    );
  }
}
