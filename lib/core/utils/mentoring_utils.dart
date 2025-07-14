import 'package:flutter/material.dart';
import 'package:jejunongdi/core/models/mentoring_models.dart';

class MentoringUtils {
  // 멘토링 타입에 따른 색상 반환
  static Color getMentoringTypeColor(String type) {
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

  // 멘토링 상태에 따른 색상 반환
  static Color getStatusColor(String status) {
    switch (status) {
      case 'ACTIVE':
        return Colors.green;
      case 'MATCHED':
        return Colors.blue;
      case 'CLOSED':
        return Colors.orange;
      case 'CANCELLED':
        return Colors.red;
      case 'COMPLETED':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  // 날짜 포맷팅 (상대 시간)
  static String formatRelativeDate(DateTime date) {
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

  // 날짜 포맷팅 (절대 시간)
  static String formatAbsoluteDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  // 멘토링 타입 아이콘 반환
  static IconData getMentoringTypeIcon(String type) {
    switch (type) {
      case 'MENTOR_WANTED':
        return Icons.search;
      case 'MENTEE_WANTED':
        return Icons.volunteer_activism;
      case 'MENTOR':
        return Icons.school;
      case 'MENTEE':
        return Icons.person_add;
      default:
        return Icons.help_outline;
    }
  }

  // 카테고리 아이콘 반환
  static IconData getCategoryIcon(String category) {
    switch (category) {
      case 'CROP_CULTIVATION':
        return Icons.grass;
      case 'LIVESTOCK':
        return Icons.pets;
      case 'GREENHOUSE':
        return Icons.home_work;
      case 'ORGANIC_FARMING':
        return Icons.eco;
      case 'FARM_MANAGEMENT':
        return Icons.business;
      case 'MARKETING':
        return Icons.trending_up;
      case 'TECHNOLOGY':
      case 'AGRICULTURAL_TECHNOLOGY':
        return Icons.computer;
      case 'CERTIFICATION':
        return Icons.verified;
      case 'FUNDING':
        return Icons.attach_money;
      case 'OTHER':
      default:
        return Icons.category;
    }
  }

  // 경험 수준 아이콘 반환
  static IconData getExperienceLevelIcon(String level) {
    switch (level) {
      case 'BEGINNER':
        return Icons.star_border;
      case 'INTERMEDIATE':
        return Icons.star_half;
      case 'ADVANCED':
        return Icons.star;
      case 'EXPERT':
        return Icons.stars;
      default:
        return Icons.help_outline;
    }
  }

  // 멘토링 타입에 따른 설명 텍스트 반환
  static String getMentoringTypeDescription(MentoringType type) {
    switch (type) {
      case MentoringType.mentorWanted:
        return '멘토를 찾고 있습니다. 경험이 풍부한 분의 도움이 필요해요.';
      case MentoringType.menteeWanted:
        return '멘티를 찾고 있습니다. 제 경험을 나누고 싶어요.';
      case MentoringType.mentor:
        return '멘토로 활동하고 있습니다.';
      case MentoringType.mentee:
        return '멘티로 활동하고 있습니다.';
    }
  }

  // 카테고리에 따른 설명 텍스트 반환
  static String getCategoryDescription(Category category) {
    switch (category) {
      case Category.cropCultivation:
        return '작물 재배에 관한 전문 지식과 실무 경험';
      case Category.livestock:
        return '축산업 운영과 가축 관리 전문 지식';
      case Category.greenhouse:
        return '온실 시설 관리와 스마트팜 기술';
      case Category.organicFarming:
        return '친환경 농업과 유기농 인증 관련';
      case Category.farmManagement:
        return '농장 경영 전략과 비즈니스 모델';
      case Category.marketing:
        return '농산물 판매와 마케팅 전략';
      case Category.technology:
      case Category.agriculturalTechnology:
        return '농업 기술과 디지털 솔루션';
      case Category.certification:
        return '각종 농업 관련 인증과 자격증';
      case Category.funding:
        return '농업 관련 자금 조달과 지원 사업';
      case Category.other:
        return '기타 농업 관련 주제';
    }
  }

  // 이메일 유효성 검증
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  // 전화번호 유효성 검증 (한국 전화번호 형식)
  static bool isValidPhoneNumber(String phoneNumber) {
    final phoneRegex = RegExp(r'^01[0-9]-?[0-9]{3,4}-?[0-9]{4}$');
    return phoneRegex.hasMatch(phoneNumber.replaceAll('-', ''));
  }

  // 연락처 정보 유효성 검증
  static bool isContactInfoValid(String? phone, String? email) {
    if (phone != null && phone.trim().isNotEmpty) {
      return true;
    }
    if (email != null && email.trim().isNotEmpty) {
      return true;
    }
    return false;
  }

  // 멘토링 상태에 따른 액션 가능 여부 확인
  static bool canEditMentoring(String status) {
    return status == 'ACTIVE';
  }

  // 멘토링 상태에 따른 삭제 가능 여부 확인
  static bool canDeleteMentoring(String status) {
    return status != 'MATCHED';
  }

  // 텍스트 길이 제한과 말줄임표 처리
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) {
      return text;
    }
    return '${text.substring(0, maxLength)}...';
  }

  // 키워드 하이라이트 (검색 결과에서 사용)
  static List<TextSpan> highlightKeywords(String text, String keyword) {
    if (keyword.isEmpty) {
      return [TextSpan(text: text)];
    }

    final List<TextSpan> spans = [];
    final RegExp regex = RegExp(keyword, caseSensitive: false);
    int start = 0;

    for (final Match match in regex.allMatches(text)) {
      if (match.start > start) {
        spans.add(TextSpan(text: text.substring(start, match.start)));
      }
      spans.add(TextSpan(
        text: text.substring(match.start, match.end),
        style: const TextStyle(
          backgroundColor: Colors.yellow,
          fontWeight: FontWeight.bold,
        ),
      ));
      start = match.end;
    }

    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start)));
    }

    return spans;
  }

  // 멘토링 정렬 옵션
  static List<String> getSortOptions() {
    return [
      '최신순',
      '제목순',
      '카테고리순',
      '경험순',
    ];
  }

  // 정렬 옵션을 API 파라미터로 변환
  static String getSortParameter(String sortOption) {
    switch (sortOption) {
      case '최신순':
        return 'createdAt,desc';
      case '제목순':
        return 'title,asc';
      case '카테고리순':
        return 'category,asc';
      case '경험순':
        return 'experienceLevel,desc';
      default:
        return 'createdAt,desc';
    }
  }
}

// 확장 메서드들
extension MentoringResponseExtension on MentoringResponse {
  bool get isActive => status == 'ACTIVE';
  bool get isMatched => status == 'MATCHED';
  bool get isClosed => status == 'CLOSED';
  bool get isCancelled => status == 'CANCELLED';
  bool get isCompleted => status == 'COMPLETED';
  
  bool get canEdit => MentoringUtils.canEditMentoring(status);
  bool get canDelete => MentoringUtils.canDeleteMentoring(status);
  
  Color get typeColor => MentoringUtils.getMentoringTypeColor(mentoringType);
  Color get statusColor => MentoringUtils.getStatusColor(status);
  
  IconData get typeIcon => MentoringUtils.getMentoringTypeIcon(mentoringType);
  IconData get categoryIcon => MentoringUtils.getCategoryIcon(category);
  
  String get relativeDate => MentoringUtils.formatRelativeDate(createdAt);
  String get absoluteDate => MentoringUtils.formatAbsoluteDate(createdAt);
}

extension MentoringRequestExtension on MentoringRequest {
  bool get hasValidContact => MentoringUtils.isContactInfoValid(contactPhone, contactEmail);
  
  bool get isEmailValid => contactEmail == null || 
      contactEmail!.isEmpty || 
      MentoringUtils.isValidEmail(contactEmail!);
      
  bool get isPhoneValid => contactPhone == null || 
      contactPhone!.isEmpty || 
      MentoringUtils.isValidPhoneNumber(contactPhone!);
}
