/// 해시태그 유틸리티 서비스
/// 해시태그 파싱, 포맷팅, 유효성 검사, 문자 수 계산 등을 처리합니다.
class HashtagService {
  /// 인스타그램 캡션 최대 문자 수
  static const int maxCaptionLength = 2200;

  /// 인스타그램 최대 해시태그 수
  static const int maxHashtagCount = 30;

  /// 해시태그 최대 길이 (# 포함)
  static const int maxHashtagLength = 100;

  // ==========================================
  // 해시태그 파싱 (Parsing)
  // ==========================================

  /// 텍스트에서 해시태그 목록 추출
  /// '#' 으로 시작하는 단어를 모두 추출합니다.
  List<String> parseHashtags(String text) {
    if (text.isEmpty) return [];
    try {
      // # 뒤에 한글, 영문, 숫자, 밑줄이 올 수 있는 패턴
      final regex = RegExp(r'#[\w\u3131-\u3163\uac00-\ud7a3]+');
      final matches = regex.allMatches(text);
      return matches.map((m) => m.group(0)!).toSet().toList();
    } catch (e) {
      return [];
    }
  }

  // ==========================================
  // 해시태그 포맷팅 (Formatting)
  // ==========================================

  /// 해시태그 목록을 공백으로 연결한 문자열로 변환
  /// 각 태그에 '#' 접두사가 없으면 자동으로 추가합니다.
  String formatHashtags(List<String> tags) {
    if (tags.isEmpty) return '';
    final formatted = tags.map((tag) {
      final trimmed = tag.trim();
      if (trimmed.isEmpty) return '';
      return trimmed.startsWith('#') ? trimmed : '#$trimmed';
    }).where((tag) => tag.isNotEmpty).toList();
    return formatted.join(' ');
  }

  // ==========================================
  // 해시태그 유효성 검사 (Validation)
  // ==========================================

  /// 단일 해시태그 유효성 검사
  /// 유효한 해시태그: '#'으로 시작, 공백 없음, 특수문자 제한, 길이 제한
  bool validateHashtag(String tag) {
    if (tag.isEmpty) return false;

    // '#' 접두사 제거 후 검사
    final cleanTag = tag.startsWith('#') ? tag.substring(1) : tag;

    // 빈 태그 검사
    if (cleanTag.isEmpty) return false;

    // 길이 제한 검사 (# 포함)
    if ('#$cleanTag'.length > maxHashtagLength) return false;

    // 숫자로만 이루어진 태그는 유효하지 않음
    if (RegExp(r'^\d+$').hasMatch(cleanTag)) return false;

    // 한글, 영문, 숫자, 밑줄만 허용
    final validPattern = RegExp(r'^[\w\u3131-\u3163\uac00-\ud7a3]+$');
    return validPattern.hasMatch(cleanTag);
  }

  // ==========================================
  // 문자 수 계산 (Character Count)
  // ==========================================

  /// 캡션과 해시태그를 합한 총 문자 수 계산
  /// 인스타그램 2200자 제한에 대한 확인용
  int countCharacters(String caption, List<String> hashtags) {
    final formattedHashtags = formatHashtags(hashtags);
    if (caption.isEmpty && formattedHashtags.isEmpty) return 0;
    if (caption.isEmpty) return formattedHashtags.length;
    if (formattedHashtags.isEmpty) return caption.length;

    // 캡션과 해시태그 사이에 줄바꿈 2개 추가 (일반적인 인스타그램 포맷)
    return caption.length + 2 + formattedHashtags.length;
  }

  /// 캡션 문자 수가 제한 내인지 확인
  bool isWithinLimit(String caption, List<String> hashtags) {
    return countCharacters(caption, hashtags) <= maxCaptionLength;
  }

  /// 해시태그 개수가 제한 내인지 확인
  bool isWithinHashtagLimit(List<String> hashtags) {
    return hashtags.length <= maxHashtagCount;
  }

  // ==========================================
  // 해시태그 추천 (Suggestion)
  // ==========================================

  /// 사용 이력에서 검색어에 맞는 해시태그 추천
  /// query와 부분 일치하는 해시태그를 필터링하여 반환합니다.
  List<String> suggestFromHistory(String query, List<String> usedHashtags) {
    if (query.isEmpty || usedHashtags.isEmpty) return [];
    try {
      // 검색어에서 '#' 제거
      final cleanQuery =
          query.startsWith('#') ? query.substring(1).toLowerCase() : query.toLowerCase();

      if (cleanQuery.isEmpty) return usedHashtags;

      // 사용 이력에서 검색어와 부분 일치하는 해시태그 필터링
      final suggestions = usedHashtags.where((tag) {
        final cleanTag =
            tag.startsWith('#') ? tag.substring(1).toLowerCase() : tag.toLowerCase();
        return cleanTag.contains(cleanQuery);
      }).toList();

      // 검색어로 시작하는 해시태그를 먼저 정렬
      suggestions.sort((a, b) {
        final cleanA =
            a.startsWith('#') ? a.substring(1).toLowerCase() : a.toLowerCase();
        final cleanB =
            b.startsWith('#') ? b.substring(1).toLowerCase() : b.toLowerCase();
        final aStartsWith = cleanA.startsWith(cleanQuery);
        final bStartsWith = cleanB.startsWith(cleanQuery);
        if (aStartsWith && !bStartsWith) return -1;
        if (!aStartsWith && bStartsWith) return 1;
        return cleanA.compareTo(cleanB);
      });

      return suggestions;
    } catch (e) {
      return [];
    }
  }
}
