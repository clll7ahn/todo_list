import 'package:flutter/material.dart';

/// 앱 전역 상수
class AppConstants {
  AppConstants._();

  /// 앱 정보
  static const String appName = 'InstaPlanner';
  static const String appVersion = '1.0.0';

  /// Instagram 제한
  static const int maxCaptionLength = 2200;
  static const int maxHashtags = 30;
  static const int maxMentions = 20;
  static const int maxCarouselImages = 10;

  /// 기본 설정
  static const int defaultPostsPerWeek = 3;
  static const double defaultEngagementThreshold = 3.0; // 3% 참여율

  /// 저장소 키
  static const String postsKey = 'posts';
  static const String schedulesKey = 'schedules';
  static const String hashtagGroupsKey = 'hashtag_groups';
  static const String isDarkModeKey = 'is_dark_mode';
  static const String sortTypeKey = 'sort_type';

  /// 시간대 레이블 (한국어)
  static const Map<String, String> timeSlotLabels = {
    'morning': '아침 (6:00-12:00)',
    'afternoon': '오후 (12:00-18:00)',
    'evening': '저녁 (18:00-22:00)',
    'night': '밤 (22:00-6:00)',
  };

  /// Instagram API 설정 플레이스홀더
  static const String instagramAppId = ''; // 사용자가 설정에서 입력
  static const String instagramRedirectUri = 'https://localhost/callback';
}

/// 기본 해시태그 그룹 데이터
class DefaultHashtagGroups {
  DefaultHashtagGroups._();

  static final List<Map<String, dynamic>> data = [
    {
      'id': 'htg_daily',
      'name': '일상',
      'color': const Color(0xFF833AB4).toARGB32(),
      'icon': Icons.sunny.codePoint,
      'hashtags': [
        '#일상', '#데일리', '#소통', '#좋아요', '#팔로우',
        '#daily', '#instadaily', '#instagood',
      ],
    },
    {
      'id': 'htg_food',
      'name': '맛집/음식',
      'color': const Color(0xFFF77737).toARGB32(),
      'icon': Icons.restaurant.codePoint,
      'hashtags': [
        '#맛집', '#먹스타그램', '#맛스타그램', '#푸드스타그램',
        '#foodie', '#foodstagram', '#instafood', '#yummy',
      ],
    },
    {
      'id': 'htg_travel',
      'name': '여행',
      'color': const Color(0xFF1976D2).toARGB32(),
      'icon': Icons.flight.codePoint,
      'hashtags': [
        '#여행', '#여행스타그램', '#여행에미치다', '#국내여행',
        '#travel', '#travelgram', '#instatravel', '#wanderlust',
      ],
    },
    {
      'id': 'htg_fashion',
      'name': '패션/뷰티',
      'color': const Color(0xFFC2185B).toARGB32(),
      'icon': Icons.checkroom.codePoint,
      'hashtags': [
        '#패션', '#오오티디', '#데일리룩', '#뷰티',
        '#fashion', '#ootd', '#style', '#beauty',
      ],
    },
    {
      'id': 'htg_fitness',
      'name': '운동/건강',
      'color': const Color(0xFF388E3C).toARGB32(),
      'icon': Icons.fitness_center.codePoint,
      'hashtags': [
        '#운동', '#헬스타그램', '#운동스타그램', '#건강',
        '#fitness', '#workout', '#gym', '#healthy',
      ],
    },
  ];

  /// 해시태그 그룹용 색상 팔레트
  static const List<Color> colorPalette = [
    Color(0xFF833AB4), // 인스타 퍼플
    Color(0xFFF77737), // 인스타 오렌지
    Color(0xFFC2185B), // 핑크
    Color(0xFF1976D2), // 블루
    Color(0xFF388E3C), // 그린
    Color(0xFFE64A19), // 딥 오렌지
    Color(0xFF00796B), // 틸
    Color(0xFFF57C00), // 앰버
    Color(0xFF455A64), // 블루 그레이
    Color(0xFF5D4037), // 브라운
  ];

  /// 해시태그 그룹용 아이콘 목록
  static const List<IconData> iconOptions = [
    Icons.sunny,
    Icons.restaurant,
    Icons.flight,
    Icons.checkroom,
    Icons.fitness_center,
    Icons.camera_alt,
    Icons.pets,
    Icons.music_note,
    Icons.palette,
    Icons.shopping_bag,
    Icons.coffee,
    Icons.landscape,
  ];
}

/// 기본 콘텐츠 템플릿
class DefaultContentTemplates {
  DefaultContentTemplates._();

  static const List<Map<String, String>> data = [
    {
      'id': 'tpl_product_review',
      'name': '제품 리뷰',
      'template': '오늘의 리뷰\n\n'
          '제품: [제품명]\n'
          '평점: [별점]\n\n'
          '[리뷰 내용]\n\n'
          '추천도: [추천/비추천]',
    },
    {
      'id': 'tpl_daily_log',
      'name': '일상 기록',
      'template': '오늘 하루\n\n'
          '[오늘의 이야기]\n\n'
          '#일상 #데일리 #소통',
    },
    {
      'id': 'tpl_food_review',
      'name': '맛집 리뷰',
      'template': '맛집 탐방\n\n'
          '장소: [맛집 이름]\n'
          '위치: [위치]\n'
          '메뉴: [메뉴명]\n\n'
          '[후기]\n\n'
          '#맛집 #먹스타그램 #맛스타그램',
    },
    {
      'id': 'tpl_travel_post',
      'name': '여행 포스트',
      'template': '여행 기록\n\n'
          '[여행지]: [장소명]\n'
          '[여행 이야기]\n\n'
          '#여행 #여행스타그램 #instatravel',
    },
  ];
}
