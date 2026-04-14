import 'package:flutter/material.dart';

/// 앱 테마 설정 - Instagram 스타일 Material Design 3
class AppTheme {
  AppTheme._();

  /// Instagram 브랜드 컬러
  static const Color instagramPurple = Color(0xFF833AB4);
  static const Color instagramPink = Color(0xFFE1306C);
  static const Color instagramOrange = Color(0xFFF77737);
  static const Color instagramYellow = Color(0xFFFCAF45);

  /// 시드 색상 (Instagram 퍼플 기반)
  static const Color _seedColor = Color(0xFF833AB4);

  /// Instagram 그라데이션
  static const LinearGradient instagramGradient = LinearGradient(
    colors: [instagramPurple, instagramPink, instagramOrange, instagramYellow],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// 라이트 테마
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.light,
      primary: instagramPurple,
      secondary: instagramPink,
      tertiary: instagramOrange,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 4,
        backgroundColor: instagramPurple,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: instagramPurple, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        hintStyle: TextStyle(color: Colors.grey.shade400),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.grey.shade100,
        selectedColor: instagramPurple.withValues(alpha: 0.15),
        labelStyle: const TextStyle(fontSize: 13),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        side: BorderSide.none,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: instagramPurple,
        unselectedItemColor: Colors.grey.shade500,
        backgroundColor: Colors.white,
        elevation: 8,
        selectedLabelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
      ),
      dividerTheme: DividerThemeData(
        space: 1,
        thickness: 0.5,
        color: Colors.grey.shade200,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colorScheme.inverseSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      textTheme: _buildTextTheme(Brightness.light),
    );
  }

  /// 다크 테마
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.dark,
      primary: const Color(0xFFBB86FC),
      secondary: instagramPink,
      tertiary: instagramOrange,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFF121212),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFF121212),
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF2C2C2C), width: 1),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 4,
        backgroundColor: const Color(0xFFBB86FC),
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2C2C2C),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF3C3C3C)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF3C3C3C)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFBB86FC), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        hintStyle: const TextStyle(color: Color(0xFF757575)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFF2C2C2C),
        selectedColor: const Color(0xFFBB86FC).withValues(alpha: 0.25),
        labelStyle: const TextStyle(fontSize: 13),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        side: BorderSide.none,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Color(0xFFBB86FC),
        unselectedItemColor: Color(0xFF757575),
        backgroundColor: Color(0xFF121212),
        elevation: 8,
        selectedLabelStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(fontSize: 11),
      ),
      dividerTheme: const DividerThemeData(
        space: 1,
        thickness: 0.5,
        color: Color(0xFF2C2C2C),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colorScheme.inverseSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      textTheme: _buildTextTheme(Brightness.dark),
    );
  }

  /// 텍스트 테마 구성
  static TextTheme _buildTextTheme(Brightness brightness) {
    final bool isLight = brightness == Brightness.light;
    final Color primaryText = isLight ? const Color(0xFF262626) : const Color(0xFFFAFAFA);
    final Color secondaryText = isLight ? const Color(0xFF8E8E8E) : const Color(0xFFA8A8A8);
    final Color hashtagColor = isLight ? const Color(0xFF00376B) : const Color(0xFF90CAF9);

    return TextTheme(
      // 큰 제목 (대시보드 헤더)
      headlineLarge: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: primaryText,
        letterSpacing: -0.5,
      ),
      // 중간 제목 (섹션 헤더)
      headlineMedium: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: primaryText,
        letterSpacing: -0.3,
      ),
      // 작은 제목
      headlineSmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: primaryText,
      ),
      // 캡션 텍스트 (게시글 캡션)
      bodyLarge: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: primaryText,
        height: 1.5,
      ),
      // 일반 본문 텍스트
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: primaryText,
        height: 1.4,
      ),
      // 보조 텍스트
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: secondaryText,
      ),
      // 해시태그/멘션 스타일 (labelLarge 활용)
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: hashtagColor,
      ),
      // 통계 수치 (팔로워 수 등)
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: primaryText,
        letterSpacing: -0.2,
      ),
      // 통계 레이블
      titleMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: primaryText,
      ),
      // 작은 레이블 (타임스탬프 등)
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: secondaryText,
        letterSpacing: 0.2,
      ),
    );
  }
}
