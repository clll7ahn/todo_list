/// 텍스트 처리 유틸리티 함수 모음
class TextUtils {
  TextUtils._();

  /// 텍스트를 지정된 최대 길이로 잘라냄
  /// 잘린 경우 말줄임표(...)를 추가
  static String truncateText(String text, int maxLength) {
    if (maxLength <= 0) return '';
    if (text.length <= maxLength) return text;
    if (maxLength <= 3) return text.substring(0, maxLength);
    return '${text.substring(0, maxLength - 3)}...';
  }

  /// 텍스트의 단어 수를 세기
  /// 공백 기준으로 분리 (한글/영어 모두 지원)
  static int countWords(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return 0;
    return trimmed.split(RegExp(r'\s+')).length;
  }

  /// 텍스트에서 @멘션을 추출
  /// 예: "@user1 안녕 @user2" -> ["@user1", "@user2"]
  static List<String> extractMentions(String text) {
    final regex = RegExp(r'@[a-zA-Z0-9._]+');
    return regex.allMatches(text).map((match) => match.group(0)!).toList();
  }

  /// 텍스트에서 #해시태그를 추출
  /// 한글 해시태그도 지원
  /// 예: "#여행 좋아요 #travel" -> ["#여행", "#travel"]
  static List<String> extractHashtags(String text) {
    final regex = RegExp(r'#[a-zA-Z0-9가-힣ㄱ-ㅎㅏ-ㅣ_]+');
    return regex.allMatches(text).map((match) => match.group(0)!).toList();
  }

  /// 해시태그를 표시용으로 강조 표시
  /// 해시태그 앞뒤에 마커를 추가하여 UI에서 색상 구분 가능
  /// 반환값에서 [h]...[/h]로 감싸진 부분이 해시태그
  static String highlightHashtags(String text) {
    final regex = RegExp(r'(#[a-zA-Z0-9가-힣ㄱ-ㅎㅏ-ㅣ_]+)');
    return text.replaceAllMapped(regex, (match) => '[h]${match.group(0)}[/h]');
  }

  /// 금지된 콘텐츠가 포함되어 있는지 기본 검사
  /// 스팸/부적절한 키워드 기반 간단한 체크
  static bool containsProhibitedContent(String text) {
    final lowerText = text.toLowerCase();

    const prohibitedPatterns = [
      // 스팸 관련
      'follow4follow',
      'f4f',
      'like4like',
      'l4l',
      'follow back',
      'followback',
      // 부적절한 마케팅
      'free followers',
      'buy followers',
      'get followers fast',
      '팔로워 구매',
      '좋아요 구매',
      '팔로워 늘리기 무료',
    ];

    for (final pattern in prohibitedPatterns) {
      if (lowerText.contains(pattern)) return true;
    }

    return false;
  }
}
