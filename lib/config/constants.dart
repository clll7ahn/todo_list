import 'package:flutter/material.dart';

/// 앱 전역 상수
class AppConstants {
  AppConstants._();

  /// 앱 정보
  static const String appName = 'TodoMaster';
  static const String appVersion = '1.0.0';

  /// 저장소 키
  static const String todosKey = 'todos';
  static const String categoriesKey = 'categories';
  static const String isDarkModeKey = 'is_dark_mode';
  static const String sortTypeKey = 'sort_type';
}

/// 기본 카테고리 데이터
class DefaultCategories {
  DefaultCategories._();

  static final List<Map<String, dynamic>> data = [
    {
      'id': 'cat_work',
      'name': '업무',
      'color': const Color(0xFF1976D2).toARGB32(),
      'icon': Icons.work.codePoint,
    },
    {
      'id': 'cat_personal',
      'name': '개인',
      'color': const Color(0xFF7B1FA2).toARGB32(),
      'icon': Icons.person.codePoint,
    },
    {
      'id': 'cat_shopping',
      'name': '쇼핑',
      'color': const Color(0xFFE64A19).toARGB32(),
      'icon': Icons.shopping_cart.codePoint,
    },
    {
      'id': 'cat_health',
      'name': '건강',
      'color': const Color(0xFF388E3C).toARGB32(),
      'icon': Icons.favorite.codePoint,
    },
    {
      'id': 'cat_study',
      'name': '학습',
      'color': const Color(0xFFF57C00).toARGB32(),
      'icon': Icons.school.codePoint,
    },
  ];

  /// 카테고리용 색상 팔레트
  static const List<Color> colorPalette = [
    Color(0xFF1976D2), // 파랑
    Color(0xFF7B1FA2), // 보라
    Color(0xFFE64A19), // 주황
    Color(0xFF388E3C), // 초록
    Color(0xFFF57C00), // 노랑
    Color(0xFFD32F2F), // 빨강
    Color(0xFF00796B), // 청록
    Color(0xFF5D4037), // 갈색
    Color(0xFF455A64), // 회색
    Color(0xFFC2185B), // 분홍
  ];

  /// 카테고리용 아이콘 목록
  static const List<IconData> iconOptions = [
    Icons.work,
    Icons.person,
    Icons.shopping_cart,
    Icons.favorite,
    Icons.school,
    Icons.home,
    Icons.sports_esports,
    Icons.restaurant,
    Icons.flight,
    Icons.music_note,
    Icons.code,
    Icons.pets,
  ];
}
