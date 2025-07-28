import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jejunongdi/core/models/ai_tip_models.dart';
import 'package:jejunongdi/core/services/ai_tip_service.dart';

class AiTipDetailScreen extends StatefulWidget {
  final AiTipResponseDto tip;

  const AiTipDetailScreen({
    super.key,
    required this.tip,
  });

  @override
  State<AiTipDetailScreen> createState() => _AiTipDetailScreenState();
}

class _AiTipDetailScreenState extends State<AiTipDetailScreen> {
  bool _isMarkingAsRead = false;
  late bool _isRead;

  final AiTipService _aiTipService = AiTipService.instance;

  @override
  void initState() {
    super.initState();
    _isRead = widget.tip.isRead;
    
    // 화면에 진입하면 자동으로 읽음 처리
    if (!_isRead) {
      _markAsRead();
    }
  }

  Future<void> _markAsRead() async {
    if (_isMarkingAsRead || _isRead) return;

    setState(() {
      _isMarkingAsRead = true;
    });

    try {
      final result = await _aiTipService.markTipAsRead(widget.tip.id);
      
      if (result.isSuccess) {
        setState(() {
          _isRead = true;
        });
      }
    } catch (e) {
      // 에러가 발생해도 사용자에게는 표시하지 않음 (백그라운드 작업)
      debugPrint('팁 읽음 처리 실패: $e');
    } finally {
      setState(() {
        _isMarkingAsRead = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'AI 농업 팁',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            FontAwesomeIcons.arrowLeft,
            color: Color(0xFF333333),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (!_isRead)
            Container(
              margin: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2711C),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '새로운 팁',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더 카드
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 태그들
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getTipTypeColor(widget.tip.tipType),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getTipTypeIcon(widget.tip.tipType),
                              size: 16,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _getTipTypeDisplayName(widget.tip.tipType),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (widget.tip.cropType != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getCropTypeIcon(widget.tip.cropType!),
                                size: 16,
                                color: const Color(0xFF333333),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _getCropTypeDisplayName(widget.tip.cropType!),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF333333),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // 제목
                  Text(
                    widget.tip.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // 생성 날짜
                  Row(
                    children: [
                      Icon(
                        FontAwesomeIcons.clock,
                        size: 14,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _formatDateTime(widget.tip.createdAt),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                      const Spacer(),
                      if (_isMarkingAsRead)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFFF2711C),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // 내용 카드
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        FontAwesomeIcons.alignLeft,
                        size: 18,
                        color: Color(0xFFF2711C),
                      ),
                      SizedBox(width: 10),
                      Text(
                        '상세 내용',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.tip.content,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF333333),
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),

            // 액션 버튼들
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              child: Column(
                children: [
                  // 공유 버튼
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _shareTip,
                      icon: const Icon(FontAwesomeIcons.share),
                      label: const Text('팁 공유하기'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFF2711C),
                        side: const BorderSide(color: Color(0xFFF2711C)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // 북마크 버튼 (향후 구현 예정)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _bookmarkTip,
                      icon: const Icon(FontAwesomeIcons.bookmark),
                      label: const Text('북마크 추가'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey[600],
                        side: BorderSide(color: Colors.grey[300]!),
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
          ],
        ),
      ),
    );
  }

  void _shareTip() {
    // 실제 구현에서는 share_plus 패키지 등을 사용
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('공유 기능은 곧 추가될 예정입니다.'),
        backgroundColor: Color(0xFFF2711C),
      ),
    );
  }

  void _bookmarkTip() {
    // 북마크 기능 (향후 구현)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('북마크 기능은 곧 추가될 예정입니다.'),
        backgroundColor: Color(0xFFF2711C),
      ),
    );
  }

  Color _getTipTypeColor(String tipType) {
    switch (tipType) {
      case 'WEATHER':
        return Colors.blue;
      case 'PEST_CONTROL':
        return Colors.red;
      case 'HARVEST':
        return Colors.green;
      case 'FERTILIZER':
        return Colors.orange;
      case 'IRRIGATION':
        return Colors.cyan;
      default:
        return const Color(0xFFF2711C);
    }
  }

  IconData _getTipTypeIcon(String tipType) {
    switch (tipType) {
      case 'WEATHER':
        return FontAwesomeIcons.cloudSun;
      case 'PEST_CONTROL':
        return FontAwesomeIcons.bug;
      case 'HARVEST':
        return FontAwesomeIcons.scissors;
      case 'FERTILIZER':
        return FontAwesomeIcons.seedling;
      case 'IRRIGATION':
        return FontAwesomeIcons.droplet;
      default:
        return FontAwesomeIcons.lightbulb;
    }
  }

  String _getTipTypeDisplayName(String tipType) {
    switch (tipType) {
      case 'WEATHER':
        return '날씨 정보';
      case 'PEST_CONTROL':
        return '병해충 방제';
      case 'HARVEST':
        return '수확 시기';
      case 'FERTILIZER':
        return '비료 관리';
      case 'IRRIGATION':
        return '관개 관리';
      default:
        return '일반 팁';
    }
  }

  IconData _getCropTypeIcon(String cropType) {
    switch (cropType) {
      case 'CITRUS':
        return FontAwesomeIcons.lemon;
      case 'VEGETABLE':
        return FontAwesomeIcons.carrot;
      case 'GRAIN':
        return FontAwesomeIcons.wheatAwn;
      case 'FRUIT':
        return FontAwesomeIcons.apple;
      case 'HERB':
        return FontAwesomeIcons.leaf;
      case 'ROOT':
        return FontAwesomeIcons.carrot;
      default:
        return FontAwesomeIcons.seedling;
    }
  }

  String _getCropTypeDisplayName(String cropType) {
    switch (cropType) {
      case 'CITRUS':
        return '감귤류';
      case 'VEGETABLE':
        return '채소류';
      case 'GRAIN':
        return '곡류';
      case 'FRUIT':
        return '과일류';
      case 'HERB':
        return '허브류';
      case 'ROOT':
        return '근채류';
      default:
        return cropType;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}년 ${dateTime.month}월 ${dateTime.day}일 '
           '${dateTime.hour.toString().padLeft(2, '0')}:'
           '${dateTime.minute.toString().padLeft(2, '0')}';
  }
}