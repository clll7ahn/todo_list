// InstaPlanner 앱에서 사용하는 열거형 정의

import 'package:flutter/material.dart';

/// 콘텐츠 유형
enum ContentType {
  /// 단일 이미지
  image,

  /// 캐러셀 (다중 이미지)
  carousel,

  /// 릴스
  reel,

  /// 스토리
  story,
}

/// 콘텐츠 유형 확장 메서드
extension ContentTypeExtension on ContentType {
  /// 한국어 표시 이름
  String get label {
    switch (this) {
      case ContentType.image:
        return '이미지';
      case ContentType.carousel:
        return '캐러셀';
      case ContentType.reel:
        return '릴스';
      case ContentType.story:
        return '스토리';
    }
  }

  /// 아이콘
  IconData get icon {
    switch (this) {
      case ContentType.image:
        return Icons.image;
      case ContentType.carousel:
        return Icons.view_carousel;
      case ContentType.reel:
        return Icons.movie;
      case ContentType.story:
        return Icons.amp_stories;
    }
  }

  /// JSON 직렬화용 문자열
  String get value {
    switch (this) {
      case ContentType.image:
        return 'image';
      case ContentType.carousel:
        return 'carousel';
      case ContentType.reel:
        return 'reel';
      case ContentType.story:
        return 'story';
    }
  }

  /// 문자열에서 ContentType 변환
  static ContentType fromValue(String value) {
    switch (value) {
      case 'image':
        return ContentType.image;
      case 'carousel':
        return ContentType.carousel;
      case 'reel':
        return ContentType.reel;
      case 'story':
        return ContentType.story;
      default:
        return ContentType.image;
    }
  }
}

/// 콘텐츠 상태
enum ContentStatus {
  /// 초안
  draft,

  /// 준비 완료
  ready,

  /// 예약됨
  scheduled,

  /// 게시됨
  posted,

  /// 보관됨
  archived,
}

/// 콘텐츠 상태 확장 메서드
extension ContentStatusExtension on ContentStatus {
  /// 한국어 표시 이름
  String get label {
    switch (this) {
      case ContentStatus.draft:
        return '초안';
      case ContentStatus.ready:
        return '준비 완료';
      case ContentStatus.scheduled:
        return '예약됨';
      case ContentStatus.posted:
        return '게시됨';
      case ContentStatus.archived:
        return '보관됨';
    }
  }

  /// 아이콘
  IconData get icon {
    switch (this) {
      case ContentStatus.draft:
        return Icons.edit_note;
      case ContentStatus.ready:
        return Icons.check_circle_outline;
      case ContentStatus.scheduled:
        return Icons.schedule;
      case ContentStatus.posted:
        return Icons.publish;
      case ContentStatus.archived:
        return Icons.archive;
    }
  }

  /// JSON 직렬화용 문자열
  String get value {
    switch (this) {
      case ContentStatus.draft:
        return 'draft';
      case ContentStatus.ready:
        return 'ready';
      case ContentStatus.scheduled:
        return 'scheduled';
      case ContentStatus.posted:
        return 'posted';
      case ContentStatus.archived:
        return 'archived';
    }
  }

  /// 문자열에서 ContentStatus 변환
  static ContentStatus fromValue(String value) {
    switch (value) {
      case 'draft':
        return ContentStatus.draft;
      case 'ready':
        return ContentStatus.ready;
      case 'scheduled':
        return ContentStatus.scheduled;
      case 'posted':
        return ContentStatus.posted;
      case 'archived':
        return ContentStatus.archived;
      default:
        return ContentStatus.draft;
    }
  }
}

/// 게시 시간대
enum PostTimeSlot {
  /// 아침 (06:00~12:00)
  morning,

  /// 오후 (12:00~18:00)
  afternoon,

  /// 저녁 (18:00~22:00)
  evening,

  /// 밤 (22:00~06:00)
  night,
}

/// 게시 시간대 확장 메서드
extension PostTimeSlotExtension on PostTimeSlot {
  /// 한국어 표시 이름
  String get label {
    switch (this) {
      case PostTimeSlot.morning:
        return '아침';
      case PostTimeSlot.afternoon:
        return '오후';
      case PostTimeSlot.evening:
        return '저녁';
      case PostTimeSlot.night:
        return '밤';
    }
  }

  /// 아이콘
  IconData get icon {
    switch (this) {
      case PostTimeSlot.morning:
        return Icons.wb_sunny;
      case PostTimeSlot.afternoon:
        return Icons.wb_cloudy;
      case PostTimeSlot.evening:
        return Icons.wb_twilight;
      case PostTimeSlot.night:
        return Icons.nightlight_round;
    }
  }

  /// JSON 직렬화용 문자열
  String get value {
    switch (this) {
      case PostTimeSlot.morning:
        return 'morning';
      case PostTimeSlot.afternoon:
        return 'afternoon';
      case PostTimeSlot.evening:
        return 'evening';
      case PostTimeSlot.night:
        return 'night';
    }
  }

  /// 문자열에서 PostTimeSlot 변환
  static PostTimeSlot fromValue(String value) {
    switch (value) {
      case 'morning':
        return PostTimeSlot.morning;
      case 'afternoon':
        return PostTimeSlot.afternoon;
      case 'evening':
        return PostTimeSlot.evening;
      case 'night':
        return PostTimeSlot.night;
      default:
        return PostTimeSlot.morning;
    }
  }
}

/// 성과 등급
enum PerformanceGrade {
  /// 매우 우수
  excellent,

  /// 우수
  good,

  /// 보통
  average,

  /// 미흡
  poor,
}

/// 성과 등급 확장 메서드
extension PerformanceGradeExtension on PerformanceGrade {
  /// 한국어 표시 이름
  String get label {
    switch (this) {
      case PerformanceGrade.excellent:
        return '매우 우수';
      case PerformanceGrade.good:
        return '우수';
      case PerformanceGrade.average:
        return '보통';
      case PerformanceGrade.poor:
        return '미흡';
    }
  }

  /// 아이콘
  IconData get icon {
    switch (this) {
      case PerformanceGrade.excellent:
        return Icons.star;
      case PerformanceGrade.good:
        return Icons.thumb_up;
      case PerformanceGrade.average:
        return Icons.trending_flat;
      case PerformanceGrade.poor:
        return Icons.thumb_down;
    }
  }

  /// JSON 직렬화용 문자열
  String get value {
    switch (this) {
      case PerformanceGrade.excellent:
        return 'excellent';
      case PerformanceGrade.good:
        return 'good';
      case PerformanceGrade.average:
        return 'average';
      case PerformanceGrade.poor:
        return 'poor';
    }
  }

  /// 문자열에서 PerformanceGrade 변환
  static PerformanceGrade fromValue(String value) {
    switch (value) {
      case 'excellent':
        return PerformanceGrade.excellent;
      case 'good':
        return PerformanceGrade.good;
      case 'average':
        return PerformanceGrade.average;
      case 'poor':
        return PerformanceGrade.poor;
      default:
        return PerformanceGrade.average;
    }
  }
}

/// 스케줄 반복 유형
enum ScheduleRepeatType {
  /// 반복 없음
  none,

  /// 매일 반복
  daily,

  /// 매주 반복
  weekly,

  /// 격주 반복
  biweekly,

  /// 매월 반복
  monthly,
}

/// 스케줄 반복 유형 확장 메서드
extension ScheduleRepeatTypeExtension on ScheduleRepeatType {
  /// 한국어 표시 이름
  String get label {
    switch (this) {
      case ScheduleRepeatType.none:
        return '반복 없음';
      case ScheduleRepeatType.daily:
        return '매일';
      case ScheduleRepeatType.weekly:
        return '매주';
      case ScheduleRepeatType.biweekly:
        return '격주';
      case ScheduleRepeatType.monthly:
        return '매월';
    }
  }

  /// 아이콘
  IconData get icon {
    switch (this) {
      case ScheduleRepeatType.none:
        return Icons.block;
      case ScheduleRepeatType.daily:
        return Icons.today;
      case ScheduleRepeatType.weekly:
        return Icons.date_range;
      case ScheduleRepeatType.biweekly:
        return Icons.calendar_view_week;
      case ScheduleRepeatType.monthly:
        return Icons.calendar_month;
    }
  }

  /// JSON 직렬화용 문자열
  String get value {
    switch (this) {
      case ScheduleRepeatType.none:
        return 'none';
      case ScheduleRepeatType.daily:
        return 'daily';
      case ScheduleRepeatType.weekly:
        return 'weekly';
      case ScheduleRepeatType.biweekly:
        return 'biweekly';
      case ScheduleRepeatType.monthly:
        return 'monthly';
    }
  }

  /// 문자열에서 ScheduleRepeatType 변환
  static ScheduleRepeatType fromValue(String value) {
    switch (value) {
      case 'daily':
        return ScheduleRepeatType.daily;
      case 'weekly':
        return ScheduleRepeatType.weekly;
      case 'biweekly':
        return ScheduleRepeatType.biweekly;
      case 'monthly':
        return ScheduleRepeatType.monthly;
      case 'none':
      default:
        return ScheduleRepeatType.none;
    }
  }
}

/// 분석 기간
enum AnalyticsPeriod {
  /// 1주일
  week,

  /// 1개월
  month,

  /// 분기 (3개월)
  quarter,

  /// 1년
  year,
}

/// 분석 기간 확장 메서드
extension AnalyticsPeriodExtension on AnalyticsPeriod {
  /// 한국어 표시 이름
  String get label {
    switch (this) {
      case AnalyticsPeriod.week:
        return '1주일';
      case AnalyticsPeriod.month:
        return '1개월';
      case AnalyticsPeriod.quarter:
        return '분기';
      case AnalyticsPeriod.year:
        return '1년';
    }
  }

  /// 아이콘
  IconData get icon {
    switch (this) {
      case AnalyticsPeriod.week:
        return Icons.view_week;
      case AnalyticsPeriod.month:
        return Icons.calendar_today;
      case AnalyticsPeriod.quarter:
        return Icons.date_range;
      case AnalyticsPeriod.year:
        return Icons.calendar_month;
    }
  }

  /// JSON 직렬화용 문자열
  String get value {
    switch (this) {
      case AnalyticsPeriod.week:
        return 'week';
      case AnalyticsPeriod.month:
        return 'month';
      case AnalyticsPeriod.quarter:
        return 'quarter';
      case AnalyticsPeriod.year:
        return 'year';
    }
  }

  /// 문자열에서 AnalyticsPeriod 변환
  static AnalyticsPeriod fromValue(String value) {
    switch (value) {
      case 'week':
        return AnalyticsPeriod.week;
      case 'month':
        return AnalyticsPeriod.month;
      case 'quarter':
        return AnalyticsPeriod.quarter;
      case 'year':
        return AnalyticsPeriod.year;
      default:
        return AnalyticsPeriod.week;
    }
  }
}

/// 해시태그 카테고리
enum HashtagCategory {
  /// 브랜드 해시태그
  brand,

  /// 니치(틈새) 해시태그
  niche,

  /// 트렌딩 해시태그
  trending,

  /// 위치 해시태그
  location,

  /// 일반 해시태그
  general,
}

/// 해시태그 카테고리 확장 메서드
extension HashtagCategoryExtension on HashtagCategory {
  /// 한국어 표시 이름
  String get label {
    switch (this) {
      case HashtagCategory.brand:
        return '브랜드';
      case HashtagCategory.niche:
        return '니치';
      case HashtagCategory.trending:
        return '트렌딩';
      case HashtagCategory.location:
        return '위치';
      case HashtagCategory.general:
        return '일반';
    }
  }

  /// 아이콘
  IconData get icon {
    switch (this) {
      case HashtagCategory.brand:
        return Icons.branding_watermark;
      case HashtagCategory.niche:
        return Icons.filter_alt;
      case HashtagCategory.trending:
        return Icons.trending_up;
      case HashtagCategory.location:
        return Icons.location_on;
      case HashtagCategory.general:
        return Icons.tag;
    }
  }

  /// JSON 직렬화용 문자열
  String get value {
    switch (this) {
      case HashtagCategory.brand:
        return 'brand';
      case HashtagCategory.niche:
        return 'niche';
      case HashtagCategory.trending:
        return 'trending';
      case HashtagCategory.location:
        return 'location';
      case HashtagCategory.general:
        return 'general';
    }
  }

  /// 문자열에서 HashtagCategory 변환
  static HashtagCategory fromValue(String value) {
    switch (value) {
      case 'brand':
        return HashtagCategory.brand;
      case 'niche':
        return HashtagCategory.niche;
      case 'trending':
        return HashtagCategory.trending;
      case 'location':
        return HashtagCategory.location;
      case 'general':
      default:
        return HashtagCategory.general;
    }
  }
}

/// 콘텐츠 정렬 유형
enum ContentSortType {
  /// 생성일 순
  createdAt,

  /// 예약일 순
  scheduledAt,

  /// 성과 순
  performance,

  /// 제목 순
  title,
}

/// 콘텐츠 정렬 유형 확장 메서드
extension ContentSortTypeExtension on ContentSortType {
  /// 한국어 표시 이름
  String get label {
    switch (this) {
      case ContentSortType.createdAt:
        return '생성일 순';
      case ContentSortType.scheduledAt:
        return '예약일 순';
      case ContentSortType.performance:
        return '성과 순';
      case ContentSortType.title:
        return '제목 순';
    }
  }

  /// 아이콘
  IconData get icon {
    switch (this) {
      case ContentSortType.createdAt:
        return Icons.access_time;
      case ContentSortType.scheduledAt:
        return Icons.schedule;
      case ContentSortType.performance:
        return Icons.bar_chart;
      case ContentSortType.title:
        return Icons.sort_by_alpha;
    }
  }

  /// JSON 직렬화용 문자열
  String get value {
    switch (this) {
      case ContentSortType.createdAt:
        return 'createdAt';
      case ContentSortType.scheduledAt:
        return 'scheduledAt';
      case ContentSortType.performance:
        return 'performance';
      case ContentSortType.title:
        return 'title';
    }
  }

  /// 문자열에서 ContentSortType 변환
  static ContentSortType fromValue(String value) {
    switch (value) {
      case 'createdAt':
        return ContentSortType.createdAt;
      case 'scheduledAt':
        return ContentSortType.scheduledAt;
      case 'performance':
        return ContentSortType.performance;
      case 'title':
        return ContentSortType.title;
      default:
        return ContentSortType.createdAt;
    }
  }
}

/// 리포스트 전략
enum RepostStrategy {
  /// 동일한 내용으로 재게시
  exact,

  /// 수정된 내용으로 재게시
  modified,

  /// 리믹스 (새로운 형태로 재구성)
  remixed,
}

/// 리포스트 전략 확장 메서드
extension RepostStrategyExtension on RepostStrategy {
  /// 한국어 표시 이름
  String get label {
    switch (this) {
      case RepostStrategy.exact:
        return '동일 재게시';
      case RepostStrategy.modified:
        return '수정 재게시';
      case RepostStrategy.remixed:
        return '리믹스';
    }
  }

  /// 아이콘
  IconData get icon {
    switch (this) {
      case RepostStrategy.exact:
        return Icons.repeat;
      case RepostStrategy.modified:
        return Icons.edit;
      case RepostStrategy.remixed:
        return Icons.shuffle;
    }
  }

  /// JSON 직렬화용 문자열
  String get value {
    switch (this) {
      case RepostStrategy.exact:
        return 'exact';
      case RepostStrategy.modified:
        return 'modified';
      case RepostStrategy.remixed:
        return 'remixed';
    }
  }

  /// 문자열에서 RepostStrategy 변환
  static RepostStrategy fromValue(String value) {
    switch (value) {
      case 'exact':
        return RepostStrategy.exact;
      case 'modified':
        return RepostStrategy.modified;
      case 'remixed':
        return RepostStrategy.remixed;
      default:
        return RepostStrategy.exact;
    }
  }
}
