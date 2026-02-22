/// 날짜 관련 유틸리티 함수 모음
class AppDateUtils {
  AppDateUtils._();

  /// 두 날짜가 같은 날인지 확인
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// 오늘 날짜인지 확인
  static bool isToday(DateTime date) {
    return isSameDay(date, DateTime.now());
  }

  /// 내일 날짜인지 확인
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return isSameDay(date, tomorrow);
  }

  /// 마감일이 지났는지 확인 (오늘 포함하지 않음)
  static bool isOverdue(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    return dateOnly.isBefore(today);
  }

  /// 날짜를 한국어 형식으로 포맷 (예: 2024년 1월 15일)
  static String formatDate(DateTime date) {
    return '${date.year}년 ${date.month}월 ${date.day}일';
  }

  /// 날짜를 짧은 한국어 형식으로 포맷 (예: 1월 15일)
  static String formatShortDate(DateTime date) {
    return '${date.month}월 ${date.day}일';
  }

  /// 날짜를 숫자 형식으로 포맷 (예: 2024.01.15)
  static String formatNumeric(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}.$month.$day';
  }

  /// 마감일을 상대적 표현으로 반환
  /// 예: "오늘", "내일", "3일 후", "어제", "5일 전"
  static String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    final diff = dateOnly.difference(today).inDays;

    if (diff == 0) return '오늘';
    if (diff == 1) return '내일';
    if (diff == -1) return '어제';
    if (diff > 1) return '$diff일 후';
    return '${diff.abs()}일 전';
  }

  /// 마감일 상태 레이블 반환
  /// 예: "오늘 마감", "내일 마감", "3일 후 마감", "기한 초과"
  static String formatDueDateLabel(DateTime? dueDate) {
    if (dueDate == null) return '';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final diff = dateOnly.difference(today).inDays;

    if (diff < 0) return '기한 초과';
    if (diff == 0) return '오늘 마감';
    if (diff == 1) return '내일 마감';
    if (diff <= 7) return '$diff일 후 마감';
    return '${formatShortDate(dueDate)} 마감';
  }

  /// 마감일 긴급도 수준 반환 (0: 정상, 1: 임박, 2: 오늘, 3: 초과)
  static int getDueDateUrgency(DateTime? dueDate) {
    if (dueDate == null) return 0;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final diff = dateOnly.difference(today).inDays;

    if (diff < 0) return 3; // 기한 초과
    if (diff == 0) return 2; // 오늘 마감
    if (diff <= 3) return 1; // 3일 이내 임박
    return 0; // 정상
  }

  /// 요일 한국어 이름 반환
  static String weekdayName(DateTime date) {
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    return weekdays[date.weekday - 1];
  }

  /// 날짜와 요일 포함 형식 (예: 1월 15일 (화))
  static String formatDateWithWeekday(DateTime date) {
    return '${date.month}월 ${date.day}일 (${weekdayName(date)})';
  }

  /// 월 한국어 이름 반환 (예: 2024년 1월)
  static String formatYearMonth(DateTime date) {
    return '${date.year}년 ${date.month}월';
  }

  /// 날짜의 자정(00:00:00) 반환
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// 날짜의 마지막 시간(23:59:59) 반환
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59);
  }

  /// 이번 주 시작일 (월요일)
  static DateTime startOfWeek(DateTime date) {
    final weekday = date.weekday;
    return startOfDay(date.subtract(Duration(days: weekday - 1)));
  }

  /// 이번 주 종료일 (일요일)
  static DateTime endOfWeek(DateTime date) {
    final weekday = date.weekday;
    return endOfDay(date.add(Duration(days: 7 - weekday)));
  }
}
