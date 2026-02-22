// 앱에서 사용하는 열거형 정의

/// 할일 우선순위
enum Priority {
  /// 높은 우선순위
  high,

  /// 중간 우선순위
  medium,

  /// 낮은 우선순위
  low,
}

/// 우선순위 확장 메서드
extension PriorityExtension on Priority {
  /// 우선순위 한국어 이름
  String get label {
    switch (this) {
      case Priority.high:
        return '높음';
      case Priority.medium:
        return '중간';
      case Priority.low:
        return '낮음';
    }
  }

  /// 우선순위 정렬 값 (낮을수록 높은 우선순위)
  int get sortOrder {
    switch (this) {
      case Priority.high:
        return 0;
      case Priority.medium:
        return 1;
      case Priority.low:
        return 2;
    }
  }

  /// JSON 직렬화용 문자열
  String get value {
    switch (this) {
      case Priority.high:
        return 'high';
      case Priority.medium:
        return 'medium';
      case Priority.low:
        return 'low';
    }
  }

  /// 문자열에서 Priority 변환
  static Priority fromValue(String value) {
    switch (value) {
      case 'high':
        return Priority.high;
      case 'medium':
        return Priority.medium;
      case 'low':
      default:
        return Priority.low;
    }
  }
}

/// 반복 유형
enum RepeatType {
  /// 반복 없음
  none,

  /// 매일 반복
  daily,

  /// 매주 반복
  weekly,

  /// 매월 반복
  monthly,
}

/// 반복 유형 확장 메서드
extension RepeatTypeExtension on RepeatType {
  /// 반복 유형 한국어 이름
  String get label {
    switch (this) {
      case RepeatType.none:
        return '반복 없음';
      case RepeatType.daily:
        return '매일';
      case RepeatType.weekly:
        return '매주';
      case RepeatType.monthly:
        return '매월';
    }
  }

  /// JSON 직렬화용 문자열
  String get value {
    switch (this) {
      case RepeatType.none:
        return 'none';
      case RepeatType.daily:
        return 'daily';
      case RepeatType.weekly:
        return 'weekly';
      case RepeatType.monthly:
        return 'monthly';
    }
  }

  /// 문자열에서 RepeatType 변환
  static RepeatType fromValue(String value) {
    switch (value) {
      case 'daily':
        return RepeatType.daily;
      case 'weekly':
        return RepeatType.weekly;
      case 'monthly':
        return RepeatType.monthly;
      case 'none':
      default:
        return RepeatType.none;
    }
  }
}

/// 할일 필터 유형
enum FilterType {
  /// 전체
  all,

  /// 활성 (미완료)
  active,

  /// 완료됨
  completed,

  /// 중요 표시
  important,

  /// 오늘 마감
  today,
}

/// 정렬 유형
enum SortType {
  /// 생성일 순
  createdAt,

  /// 마감일 순
  dueDate,

  /// 우선순위 순
  priority,

  /// 제목 순
  title,
}
