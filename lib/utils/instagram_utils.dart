/// Instagram 관련 유틸리티 함수 모음
class InstagramUtils {
  InstagramUtils._();

  /// 팔로워 수를 축약 형식으로 포맷
  /// 예: 1200 -> "1.2K", 3400000 -> "3.4M"
  static String formatFollowerCount(int count) {
    if (count < 0) return '0';
    if (count < 1000) return count.toString();
    if (count < 10000) {
      final double value = count / 1000;
      return '${value.toStringAsFixed(1)}K';
    }
    if (count < 1000000) {
      final double value = count / 1000;
      return '${value.toStringAsFixed(value < 100 ? 1 : 0)}K';
    }
    if (count < 1000000000) {
      final double value = count / 1000000;
      return '${value.toStringAsFixed(1)}M';
    }
    final double value = count / 1000000000;
    return '${value.toStringAsFixed(1)}B';
  }

  /// 참여율을 퍼센트 형식으로 포맷
  /// 예: 3.456 -> "3.5%"
  static String formatEngagementRate(double rate) {
    if (rate < 0) return '0.0%';
    return '${rate.toStringAsFixed(1)}%';
  }

  /// 게시 이후 경과 시간을 한국어로 반환
  /// 예: "방금 전", "2시간 전", "3일 전", "2주 전"
  static String getTimeSincePosted(DateTime postedAt) {
    final now = DateTime.now();
    final difference = now.difference(postedAt);

    if (difference.isNegative) return '예정됨';
    if (difference.inSeconds < 60) return '방금 전';
    if (difference.inMinutes < 60) return '${difference.inMinutes}분 전';
    if (difference.inHours < 24) return '${difference.inHours}시간 전';
    if (difference.inDays < 7) return '${difference.inDays}일 전';
    if (difference.inDays < 30) return '${(difference.inDays / 7).floor()}주 전';
    if (difference.inDays < 365) return '${(difference.inDays / 30).floor()}개월 전';
    return '${(difference.inDays / 365).floor()}년 전';
  }

  /// 게시 데이터를 분석하여 최적 게시 시간을 추천
  /// [data]는 각 항목이 {'hour': int, 'engagement': double} 형태인 리스트
  /// 반환값 예: "오후 6시 ~ 8시"
  static String getBestPostingTime(List<Map<String, dynamic>> data) {
    if (data.isEmpty) return '데이터 부족';

    // 시간대별 평균 참여율 계산
    final Map<int, List<double>> hourlyEngagement = {};
    for (final item in data) {
      final hour = item['hour'] as int?;
      final engagement = item['engagement'] as double?;
      if (hour != null && engagement != null) {
        hourlyEngagement.putIfAbsent(hour, () => []).add(engagement);
      }
    }

    if (hourlyEngagement.isEmpty) return '데이터 부족';

    // 평균 참여율이 가장 높은 시간대 찾기
    int bestHour = 0;
    double bestAvg = 0;
    hourlyEngagement.forEach((hour, engagements) {
      final avg = engagements.reduce((a, b) => a + b) / engagements.length;
      if (avg > bestAvg) {
        bestAvg = avg;
        bestHour = hour;
      }
    });

    final endHour = (bestHour + 2) % 24;
    return '${_formatHourKorean(bestHour)} ~ ${_formatHourKorean(endHour)}';
  }

  /// 시간을 한국어 형식으로 포맷
  static String _formatHourKorean(int hour) {
    if (hour == 0) return '오전 12시';
    if (hour < 12) return '오전 ${hour}시';
    if (hour == 12) return '오후 12시';
    return '오후 ${hour - 12}시';
  }

  /// Instagram 사용자 이름 유효성 검사
  /// 규칙: 영문, 숫자, 밑줄, 마침표만 허용, 1~30자
  static bool isValidInstagramUsername(String username) {
    if (username.isEmpty || username.length > 30) return false;
    final regex = RegExp(r'^[a-zA-Z0-9._]+$');
    if (!regex.hasMatch(username)) return false;
    // 마침표로 시작하거나 끝나면 안 됨
    if (username.startsWith('.') || username.endsWith('.')) return false;
    // 연속된 마침표 불가
    if (username.contains('..')) return false;
    return true;
  }

  /// 캡션과 해시태그를 결합하여 최종 게시 텍스트를 생성
  /// 캡션과 해시태그 사이에 줄바꿈 2개를 추가
  static String formatCaption(String caption, List<String> hashtags) {
    final trimmedCaption = caption.trim();
    if (hashtags.isEmpty) return trimmedCaption;

    final normalizedHashtags = hashtags.map((tag) {
      final trimmed = tag.trim();
      return trimmed.startsWith('#') ? trimmed : '#$trimmed';
    }).toList();

    final hashtagString = normalizedHashtags.join(' ');

    if (trimmedCaption.isEmpty) return hashtagString;
    return '$trimmedCaption\n\n$hashtagString';
  }
}
