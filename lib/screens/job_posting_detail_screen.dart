import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:jejunongdi/core/models/job_posting_model.dart';
import 'package:jejunongdi/core/services/job_posting_service.dart';
import 'package:jejunongdi/core/models/chat_models.dart';
import 'package:jejunongdi/redux/chat/chat_actions.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:jejunongdi/redux/app_state.dart';

class JobPostingDetailScreen extends StatefulWidget {
  final int jobPostingId;

  const JobPostingDetailScreen({
    super.key,
    required this.jobPostingId,
  });

  @override
  State<JobPostingDetailScreen> createState() => _JobPostingDetailScreenState();
}

class _JobPostingDetailScreenState extends State<JobPostingDetailScreen> {
  final JobPostingService _jobPostingService = JobPostingService.instance;
  JobPostingResponse? _jobPosting;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchJobPostingDetails();
  }

  Future<void> _fetchJobPostingDetails() async {
    final result = await _jobPostingService.getJobPostingById(widget.jobPostingId);
    if (mounted) {
      setState(() {
        result.onSuccess((data) {
          _jobPosting = data;
        });
        result.onFailure((error) {
          _errorMessage = error.message;
        });
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: _isLoading
          ? _buildLoading()
          : _errorMessage != null
          ? _buildError()
          : _buildContent(),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(color: Color(0xFFF2711C)),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 50),
          const SizedBox(height: 16),
          Text(_errorMessage ?? '데이터를 불러오는 데 실패했습니다.'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _fetchJobPostingDetails,
            child: const Text('다시 시도'),
          )
        ],
      ),
    );
  }

  Widget _buildContent() {
    final posting = _jobPosting!;
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 250.0,
          pinned: true,
          backgroundColor: const Color(0xFFF2711C),
          iconTheme: const IconThemeData(color: Colors.white),
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              posting.farmName,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                shadows: [Shadow(blurRadius: 2, color: Colors.black45)],
              ),
            ),
            background: NaverMap(
              options: NaverMapViewOptions(
                initialCameraPosition: NCameraPosition(
                  target: NLatLng(posting.latitude, posting.longitude),
                  zoom: 15,
                ),
                mapType: NMapType.basic,
              ),
              onMapReady: (controller) {
                controller.addOverlay(NMarker(
                  id: posting.id.toString(),
                  position: NLatLng(posting.latitude, posting.longitude),
                ));
              },
            ),
          ),
          actions: [
            StoreConnector<AppState, VoidCallback>(
              converter: (store) => () {
                // 새로운 API 사용: 1:1 채팅방 생성 (작성자 이메일로)
                final email = posting.author.email;
                if (email != null && email.isNotEmpty) {
                  store.dispatch(GetOrCreateOneToOneRoomAction(email));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('채팅방을 생성하고 있습니다...')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('작성자 이메일 정보가 없어 채팅을 시작할 수 없습니다.')),
                  );
                }
              },
              builder: (context, startChat) => IconButton(
                icon: const Icon(Icons.chat, color: Colors.white),
                onPressed: startChat,
                tooltip: '채팅하기',
              ),
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 제목
                Text(
                  posting.title,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                // 상태 및 작성일
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        posting.statusName,
                        style: TextStyle(color: Colors.green[800], fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '작성일: ${DateFormat('yyyy.MM.dd').format(posting.createdAt)}',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
                const Divider(height: 40),

                // 상세 정보 섹션
                _buildDetailSection('근무 정보', [
                  _buildDetailRow(FontAwesomeIcons.calendarDays, '근무 기간', '${DateFormat('MM.dd').format(DateTime.parse(posting.workStartDate))} ~ ${DateFormat('MM.dd').format(DateTime.parse(posting.workEndDate))}'),
                  _buildDetailRow(FontAwesomeIcons.person, '모집 인원', '${posting.recruitmentCount}명'),
                  _buildDetailRow(FontAwesomeIcons.tractor, '주요 작물', posting.cropTypeName),
                  _buildDetailRow(FontAwesomeIcons.hand, '주요 작업', posting.workTypeName),
                ]),
                const Divider(height: 40),

                _buildDetailSection('급여 정보', [
                  _buildDetailRow(FontAwesomeIcons.coins, '급여', '${NumberFormat('#,###').format(posting.wages)}원 / ${posting.wageTypeName}'),
                ]),
                const Divider(height: 40),

                _buildDetailSection('농장 정보', [
                  _buildDetailRow(FontAwesomeIcons.locationDot, '농장 주소', posting.address),
                  _buildDetailRow(FontAwesomeIcons.userTie, '작성자', posting.author.nickname),
                ]),
                const Divider(height: 40),

                // 상세 설명
                const Text(
                  '상세 설명',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  posting.description ?? '상세 설명이 없습니다.',
                  style: const TextStyle(fontSize: 15, height: 1.6),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FaIcon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 16),
          SizedBox(
            width: 80,
            child: Text(
              title,
              style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[800]),
            ),
          ),
          Expanded(
            child: Text(
              content,
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}
