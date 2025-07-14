import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:jejunongdi/redux/app_state.dart';
import 'package:jejunongdi/redux/mentoring/mentoring_actions.dart';
import 'package:jejunongdi/redux/mentoring/mentoring_state.dart';
import 'package:jejunongdi/core/models/mentoring_models.dart';
import 'package:url_launcher/url_launcher.dart';

class MentoringDetailScreen extends StatefulWidget {
  final int mentoringId;

  const MentoringDetailScreen({
    Key? key,
    required this.mentoringId,
  }) : super(key: key);

  @override
  State<MentoringDetailScreen> createState() => _MentoringDetailScreenState();
}

class _MentoringDetailScreenState extends State<MentoringDetailScreen> {
  @override
  void initState() {
    super.initState();
    // 상세 정보 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      StoreProvider.of<AppState>(context)
          .dispatch(LoadMentoringDetailAction(widget.mentoringId));
    });
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('전화 앱을 열 수 없습니다.')),
        );
      }
    }
  }

  Future<void> _sendEmail(String emailAddress) async {
    final Uri launchUri = Uri(scheme: 'mailto', path: emailAddress);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('이메일 앱을 열 수 없습니다.')),
        );
      }
    }
  }

  void _showDeleteConfirmDialog(MentoringResponse mentoring) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('멘토링 삭제'),
        content: const Text('정말로 이 멘토링 글을 삭제하시겠습니까?'),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('멘토링 상세'),
        elevation: 0,
      ),
      body: StoreConnector<AppState, MentoringState>(
        converter: (store) => store.state.mentoringState,
        onWillChange: (prev, current) {
          // 삭제 성공시 이전 화면으로 이동
          if (prev?.isLoading == true && 
              current.isLoading == false && 
              current.selectedMentoring == null &&
              current.error == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('멘토링 글이 삭제되었습니다.'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop();
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
          if (mentoringState.isLoading && mentoringState.selectedMentoring == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (mentoringState.error != null && mentoringState.selectedMentoring == null) {
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
                    mentoringState.error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      StoreProvider.of<AppState>(context)
                          .dispatch(LoadMentoringDetailAction(widget.mentoringId));
                    },
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            );
          }

          final mentoring = mentoringState.selectedMentoring;
          if (mentoring == null) {
            return const Center(
              child: Text('멘토링 정보를 찾을 수 없습니다.'),
            );
          }

          return _buildMentoringDetail(mentoring);
        },
      ),
    );
  }

  Widget _buildMentoringDetail(MentoringResponse mentoring) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더 정보
          _buildHeader(mentoring),
          const SizedBox(height: 24),

          // 제목
          Text(
            mentoring.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // 메타 정보
          _buildMetaInfo(mentoring),
          const SizedBox(height: 24),

          // 설명
          _buildSection(
            title: '설명',
            child: Text(
              mentoring.description,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ),

          // 희망 지역
          if (mentoring.preferredLocation != null) ...[
            const SizedBox(height: 24),
            _buildSection(
              title: '희망 지역',
              child: Text(
                mentoring.preferredLocation!,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],

          // 희망 일정
          if (mentoring.preferredSchedule != null) ...[
            const SizedBox(height: 24),
            _buildSection(
              title: '희망 일정',
              child: Text(
                mentoring.preferredSchedule!,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],

          // 연락처 정보
          const SizedBox(height: 24),
          _buildContactInfo(mentoring),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildHeader(MentoringResponse mentoring) {
    // 현재 사용자가 작성자인지 확인 (실제로는 Redux 상태에서 확인해야 함)
    final isAuthor = false; // TODO: 실제 사용자 ID와 비교

    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getMentoringTypeColor(mentoring.mentoringType),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  mentoring.mentoringTypeName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  mentoring.categoryName,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (isAuthor) ...[
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                // TODO: 편집 화면으로 이동
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
      ],
    );
  }

  Widget _buildMetaInfo(MentoringResponse mentoring) {
    return Column(
      children: [
        _buildInfoRow(
          icon: Icons.person_outline,
          label: '작성자',
          value: mentoring.authorName,
        ),
        const SizedBox(height: 8),
        _buildInfoRow(
          icon: Icons.star_outline,
          label: '경험 수준',
          value: mentoring.experienceLevelName,
        ),
        const SizedBox(height: 8),
        _buildInfoRow(
          icon: Icons.access_time,
          label: '작성일',
          value: _formatDate(mentoring.createdAt),
        ),
        const SizedBox(height: 8),
        _buildInfoRow(
          icon: Icons.fiber_manual_record,
          label: '상태',
          value: mentoring.statusName,
          valueColor: _getStatusColor(mentoring.status),
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildContactInfo(MentoringResponse mentoring) {
    final hasContact = mentoring.contactPhone != null || mentoring.contactEmail != null;
    
    if (!hasContact) {
      return const SizedBox.shrink();
    }

    return _buildSection(
      title: '연락처 정보',
      child: Column(
        children: [
          if (mentoring.contactPhone != null) ...[
            _buildContactButton(
              icon: Icons.phone,
              label: '전화하기',
              value: mentoring.contactPhone!,
              onTap: () => _makePhoneCall(mentoring.contactPhone!),
            ),
            const SizedBox(height: 8),
          ],
          if (mentoring.contactEmail != null) ...[
            _buildContactButton(
              icon: Icons.email,
              label: '이메일 보내기',
              value: mentoring.contactEmail!,
              onTap: () => _sendEmail(mentoring.contactEmail!),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContactButton({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).primaryColor),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
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
}
