import 'package:flutter/material.dart';
import 'package:jejunongdi/core/services/mentoring_service.dart';
import 'package:jejunongdi/core/models/mentoring_models.dart';
import 'package:jejunongdi/core/network/api_exceptions.dart';

class MyActivitiesScreen extends StatefulWidget {
  const MyActivitiesScreen({super.key});

  @override
  State<MyActivitiesScreen> createState() => _MyActivitiesScreenState();
}

class _MyActivitiesScreenState extends State<MyActivitiesScreen> {
  final ScrollController _scrollController = ScrollController();
  final MentoringService _mentoringService = MentoringService.instance;
  
  List<MentoringResponse> _mentorings = [];
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  int _currentPage = 0;
  bool _hasMoreData = true;

  @override
  void initState() {
    super.initState();
    _loadMentorings();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      if (!_isLoading && _hasMoreData) {
        _loadMoreMentorings();
      }
    }
  }

  Future<void> _loadMentorings() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _currentPage = 0;
      _mentorings.clear();
    });

    final result = await _mentoringService.getMentorings(page: 0);
    
    if (mounted) {
      result
        .onSuccess((pageResponse) {
          setState(() {
            _mentorings = pageResponse.content;
            _hasMoreData = !pageResponse.last;
            _isLoading = false;
          });
        })
        .onFailure((error) {
          setState(() {
            _hasError = true;
            _errorMessage = _getErrorMessage(error);
            _isLoading = false;
          });
        });
    }
  }

  Future<void> _loadMoreMentorings() async {
    setState(() {
      _isLoading = true;
    });

    final result = await _mentoringService.getMentorings(page: _currentPage + 1);
    
    if (mounted) {
      result
        .onSuccess((pageResponse) {
          setState(() {
            _mentorings.addAll(pageResponse.content);
            _currentPage++;
            _hasMoreData = !pageResponse.last;
            _isLoading = false;
          });
        })
        .onFailure((error) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_getErrorMessage(error)),
              backgroundColor: Colors.red.shade400,
            ),
          );
        });
    }
  }

  String _getErrorMessage(ApiException error) {
    if (error is NetworkException) {
      return '인터넷 연결을 확인해주세요.';
    } else if (error is UnauthorizedException) {
      return '로그인이 필요합니다.';
    } else if (error is ServerException) {
      return '서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요.';
    } else if (error is TimeoutException) {
      return '요청 시간이 초과되었습니다.';
    } else {
      return error.message;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '멘토링 목록',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: _loadMentorings,
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF8F9FA),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: 멘토링 생성 페이지로 이동
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('멘토링 생성 기능은 준비 중입니다.'),
              backgroundColor: Color(0xFFF2711C),
            ),
          );
        },
        backgroundColor: const Color(0xFFF2711C),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _mentorings.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF2711C)),
            ),
            SizedBox(height: 16),
            Text(
              '멘토링 목록을 불러오는 중...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    if (_hasError && _mentorings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              '데이터를 불러오는데 실패했습니다',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadMentorings,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF2711C),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    if (_mentorings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.school_outlined,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              '등록된 멘토링이 없습니다',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: 멘토링 생성 페이지로 이동
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('멘토링 생성 기능은 준비 중입니다.'),
                    backgroundColor: Color(0xFFF2711C),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('첫 멘토링 만들기'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF2711C),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMentorings,
      color: const Color(0xFFF2711C),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: _mentorings.length + (_hasMoreData ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _mentorings.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF2711C)),
                ),
              ),
            );
          }

          final mentoring = _mentorings[index];
          return _buildMentoringCard(mentoring);
        },
      ),
    );
  }

  Widget _buildMentoringCard(MentoringResponse mentoring) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.white,
      child: InkWell(
        onTap: () {
          _showMentoringDetail(mentoring);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더 (제목과 상태)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      mentoring.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildStatusChip(mentoring.statusName),
                ],
              ),
              const SizedBox(height: 8),

              // 멘토링 타입과 카테고리
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  _buildChip(mentoring.mentoringTypeName, const Color(0xFFE3F2FD), const Color(0xFF1976D2)),
                  _buildChip(mentoring.categoryName, const Color(0xFFE8F5E8), const Color(0xFF388E3C)),
                  _buildChip(mentoring.experienceLevelName, const Color(0xFFFFF3E0), const Color(0xFFF57C00)),
                ],
              ),
              const SizedBox(height: 12),

              // 설명
              Text(
                mentoring.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // 위치와 일정 (있는 경우만)
              if (mentoring.preferredLocation != null || mentoring.preferredSchedule != null) ...[
                Row(
                  children: [
                    if (mentoring.preferredLocation != null) ...[
                      Icon(Icons.location_on, size: 16, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          mentoring.preferredLocation!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                    if (mentoring.preferredLocation != null && mentoring.preferredSchedule != null)
                      const SizedBox(width: 16),
                    if (mentoring.preferredSchedule != null) ...[
                      Icon(Icons.schedule, size: 16, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          mentoring.preferredSchedule!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
              ],

              // 하단 정보 (작성자와 날짜)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: const Color(0xFFF2711C).withOpacity(0.2),
                        child: Text(
                          mentoring.author.name.isNotEmpty ? mentoring.author.name[0] : '?',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFFF2711C),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        mentoring.author.name,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    _formatDate(mentoring.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
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

  void _showMentoringDetail(MentoringResponse mentoring) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(24),
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 드래그 핸들
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              
              // 제목과 상태
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      mentoring.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildStatusChip(mentoring.statusName),
                ],
              ),
              const SizedBox(height: 16),
              
              // 태그들
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildChip(mentoring.mentoringTypeName, const Color(0xFFE3F2FD), const Color(0xFF1976D2)),
                  _buildChip(mentoring.categoryName, const Color(0xFFE8F5E8), const Color(0xFF388E3C)),
                  _buildChip(mentoring.experienceLevelName, const Color(0xFFFFF3E0), const Color(0xFFF57C00)),
                ],
              ),
              const SizedBox(height: 20),
              
              // 설명
              Text(
                '멘토링 소개',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                mentoring.description,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              
              // 상세 정보
              if (mentoring.preferredLocation != null) ...[
                _buildDetailRow(Icons.location_on, '선호 장소', mentoring.preferredLocation!),
                const SizedBox(height: 12),
              ],
              if (mentoring.preferredSchedule != null) ...[
                _buildDetailRow(Icons.schedule, '선호 일정', mentoring.preferredSchedule!),
                const SizedBox(height: 12),
              ],
              if (mentoring.contactEmail != null) ...[
                _buildDetailRow(Icons.email, '이메일', mentoring.contactEmail!),
                const SizedBox(height: 12),
              ],
              if (mentoring.contactPhone != null) ...[
                _buildDetailRow(Icons.phone, '연락처', mentoring.contactPhone!),
                const SizedBox(height: 12),
              ],
              
              const Spacer(),
              
              // 연락하기 버튼
              if (mentoring.statusName == '모집중')
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: 연락하기 기능 구현
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('연락하기 기능은 준비 중입니다.'),
                          backgroundColor: Color(0xFFF2711C),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF2711C),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      '멘토에게 연락하기',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;
    
    switch (status) {
      case '모집중':
        backgroundColor = const Color(0xFFE8F5E8);
        textColor = const Color(0xFF388E3C);
        break;
      case '모집완료':
        backgroundColor = Colors.grey.shade200;
        textColor = Colors.grey.shade600;
        break;
      case '진행중':
        backgroundColor = const Color(0xFFE3F2FD);
        textColor = const Color(0xFF1976D2);
        break;
      case '완료':
        backgroundColor = const Color(0xFFF3E5F5);
        textColor = const Color(0xFF7B1FA2);
        break;
      default:
        backgroundColor = Colors.grey.shade200;
        textColor = Colors.grey.shade600;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildChip(String label, Color backgroundColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return '${date.month}/${date.day}';
    } else if (difference.inDays > 0) {
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
