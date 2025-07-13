import 'package:flutter/material.dart';
import 'package:jejunongdi/core/models/job_posting_model.dart';

class JobPostingDetailSheet extends StatelessWidget {
  final JobPostingResponse jobPosting;

  const JobPostingDetailSheet({super.key, required this.jobPosting});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // 핸들바
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 헤더
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getCropTypeColor(jobPosting.cropType),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          jobPosting.cropTypeName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          jobPosting.statusName,
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // 제목
                  Text(
                    jobPosting.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoCard([
                            _buildDetailRow(Icons.business, '농장명', jobPosting.farmName),
                            _buildDetailRow(Icons.location_on, '주소', jobPosting.address),
                            _buildDetailRow(Icons.work, '작업 유형', jobPosting.workTypeName),
                          ]),
                          
                          const SizedBox(height: 16),
                          
                          _buildInfoCard([
                            _buildDetailRow(Icons.payments, '급여', '${jobPosting.wages}원 (${jobPosting.wageTypeName})'),
                            _buildDetailRow(Icons.calendar_today, '근무 기간', 
                              '${jobPosting.workStartDate} ~ ${jobPosting.workEndDate}'),
                            _buildDetailRow(Icons.people, '모집 인원', '${jobPosting.recruitmentCount}명'),
                          ]),
                          
                          const SizedBox(height: 16),
                          
                          _buildInfoCard([
                            _buildDetailRow(Icons.phone, '연락처', jobPosting.contactPhone ?? '정보 없음'),
                            _buildDetailRow(Icons.person, '작성자', jobPosting.author.nickname),
                          ]),
                          
                          const SizedBox(height: 20),
                          
                          const Text(
                            '상세 내용',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Text(
                              jobPosting.description ?? '상세 내용이 없습니다.',
                              style: const TextStyle(
                                fontSize: 16,
                                height: 1.5,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // 하단 버튼
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.close),
                      label: const Text('닫기'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.green),
          const SizedBox(width: 12),
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getCropTypeColor(String cropType) {
    switch (cropType) {
      case 'RICE':
        return Colors.green;
      case 'VEGETABLE':
        return Colors.blue;
      case 'FRUIT':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
