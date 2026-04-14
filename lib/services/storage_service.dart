import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/content.dart';
import '../models/content_template.dart';
import '../models/hashtag_group.dart';
import '../models/schedule.dart';
import '../models/analytics_record.dart';
import '../models/repost_plan.dart';

/// 로컬 저장소 서비스 (SharedPreferences + JSON 기반)
/// InstaPlanner 앱의 모든 데이터를 로컬에 저장/로드/삭제합니다.
class StorageService {
  // === 저장소 키 상수 ===
  static const String _contentsKey = 'contents';
  static const String _contentTemplatesKey = 'content_templates';
  static const String _hashtagGroupsKey = 'hashtag_groups';
  static const String _schedulesKey = 'schedules';
  static const String _analyticsRecordsKey = 'analytics_records';
  static const String _repostPlansKey = 'repost_plans';
  static const String _darkModeKey = 'is_dark_mode';
  static const String _instagramUsernameKey = 'instagram_username';
  static const String _accessTokenKey = 'access_token';
  static const String _tokenExpiryKey = 'token_expiry';
  static const String _userIdKey = 'user_id';
  static const String _defaultHashtagsKey = 'default_hashtags';
  static const String _autoScheduleEnabledKey = 'auto_schedule_enabled';
  static const String _notificationsEnabledKey = 'notifications_enabled';

  // ==========================================
  // Contents (콘텐츠 목록) CRUD
  // ==========================================

  /// 콘텐츠 목록 저장
  Future<void> saveContents(List<Content> contents) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = contents.map((c) => c.toJson()).toList();
      await prefs.setString(_contentsKey, jsonEncode(jsonList));
    } catch (e) {
      debugPrint('콘텐츠 저장 오류: $e');
    }
  }

  /// 콘텐츠 목록 로드
  Future<List<Content>> loadContents() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_contentsKey);
    if (jsonString == null) return [];
    try {
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map((e) => Content.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('콘텐츠 로드 오류: $e');
      return [];
    }
  }

  /// 콘텐츠 목록 삭제
  Future<void> deleteContents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_contentsKey);
    } catch (e) {
      debugPrint('콘텐츠 삭제 오류: $e');
    }
  }

  // ==========================================
  // ContentTemplates (콘텐츠 템플릿) CRUD
  // ==========================================

  /// 콘텐츠 템플릿 목록 저장
  Future<void> saveContentTemplates(List<ContentTemplate> templates) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = templates.map((t) => t.toJson()).toList();
      await prefs.setString(_contentTemplatesKey, jsonEncode(jsonList));
    } catch (e) {
      debugPrint('콘텐츠 템플릿 저장 오류: $e');
    }
  }

  /// 콘텐츠 템플릿 목록 로드
  Future<List<ContentTemplate>> loadContentTemplates() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_contentTemplatesKey);
    if (jsonString == null) return [];
    try {
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map((e) => ContentTemplate.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('콘텐츠 템플릿 로드 오류: $e');
      return [];
    }
  }

  /// 콘텐츠 템플릿 목록 삭제
  Future<void> deleteContentTemplates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_contentTemplatesKey);
    } catch (e) {
      debugPrint('콘텐츠 템플릿 삭제 오류: $e');
    }
  }

  // ==========================================
  // HashtagGroups (해시태그 그룹) CRUD
  // ==========================================

  /// 해시태그 그룹 목록 저장
  Future<void> saveHashtagGroups(List<HashtagGroup> groups) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = groups.map((g) => g.toJson()).toList();
      await prefs.setString(_hashtagGroupsKey, jsonEncode(jsonList));
    } catch (e) {
      debugPrint('해시태그 그룹 저장 오류: $e');
    }
  }

  /// 해시태그 그룹 목록 로드
  Future<List<HashtagGroup>> loadHashtagGroups() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_hashtagGroupsKey);
    if (jsonString == null) return [];
    try {
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map((e) => HashtagGroup.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('해시태그 그룹 로드 오류: $e');
      return [];
    }
  }

  /// 해시태그 그룹 목록 삭제
  Future<void> deleteHashtagGroups() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_hashtagGroupsKey);
    } catch (e) {
      debugPrint('해시태그 그룹 삭제 오류: $e');
    }
  }

  // ==========================================
  // Schedules (스케줄) CRUD
  // ==========================================

  /// 스케줄 목록 저장
  Future<void> saveSchedules(List<Schedule> schedules) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = schedules.map((s) => s.toJson()).toList();
      await prefs.setString(_schedulesKey, jsonEncode(jsonList));
    } catch (e) {
      debugPrint('스케줄 저장 오류: $e');
    }
  }

  /// 스케줄 목록 로드
  Future<List<Schedule>> loadSchedules() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_schedulesKey);
    if (jsonString == null) return [];
    try {
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map((e) => Schedule.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('스케줄 로드 오류: $e');
      return [];
    }
  }

  /// 스케줄 목록 삭제
  Future<void> deleteSchedules() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_schedulesKey);
    } catch (e) {
      debugPrint('스케줄 삭제 오류: $e');
    }
  }

  // ==========================================
  // AnalyticsRecords (분석 기록) CRUD
  // ==========================================

  /// 분석 기록 목록 저장
  Future<void> saveAnalyticsRecords(List<AnalyticsRecord> records) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = records.map((r) => r.toJson()).toList();
      await prefs.setString(_analyticsRecordsKey, jsonEncode(jsonList));
    } catch (e) {
      debugPrint('분석 기록 저장 오류: $e');
    }
  }

  /// 분석 기록 목록 로드
  Future<List<AnalyticsRecord>> loadAnalyticsRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_analyticsRecordsKey);
    if (jsonString == null) return [];
    try {
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map((e) => AnalyticsRecord.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('분석 기록 로드 오류: $e');
      return [];
    }
  }

  /// 분석 기록 목록 삭제
  Future<void> deleteAnalyticsRecords() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_analyticsRecordsKey);
    } catch (e) {
      debugPrint('분석 기록 삭제 오류: $e');
    }
  }

  // ==========================================
  // RepostPlans (리포스트 계획) CRUD
  // ==========================================

  /// 리포스트 계획 목록 저장
  Future<void> saveRepostPlans(List<RepostPlan> plans) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = plans.map((p) => p.toJson()).toList();
      await prefs.setString(_repostPlansKey, jsonEncode(jsonList));
    } catch (e) {
      debugPrint('리포스트 계획 저장 오류: $e');
    }
  }

  /// 리포스트 계획 목록 로드
  Future<List<RepostPlan>> loadRepostPlans() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_repostPlansKey);
    if (jsonString == null) return [];
    try {
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map((e) => RepostPlan.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('리포스트 계획 로드 오류: $e');
      return [];
    }
  }

  /// 리포스트 계획 목록 삭제
  Future<void> deleteRepostPlans() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_repostPlansKey);
    } catch (e) {
      debugPrint('리포스트 계획 삭제 오류: $e');
    }
  }

  // ==========================================
  // Settings (앱 설정)
  // ==========================================

  /// 다크모드 설정 저장
  Future<void> saveDarkMode(bool isDarkMode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_darkModeKey, isDarkMode);
    } catch (e) {
      debugPrint('다크모드 설정 저장 오류: $e');
    }
  }

  /// 다크모드 설정 로드
  Future<bool> loadDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_darkModeKey) ?? false;
  }

  /// 인스타그램 사용자명 저장
  Future<void> saveInstagramUsername(String username) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_instagramUsernameKey, username);
    } catch (e) {
      debugPrint('인스타그램 사용자명 저장 오류: $e');
    }
  }

  /// 인스타그램 사용자명 로드
  Future<String?> loadInstagramUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_instagramUsernameKey);
  }

  /// 기본 해시태그 저장
  Future<void> saveDefaultHashtags(String hashtags) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_defaultHashtagsKey, hashtags);
    } catch (e) {
      debugPrint('기본 해시태그 저장 오류: $e');
    }
  }

  /// 기본 해시태그 로드
  Future<String?> loadDefaultHashtags() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_defaultHashtagsKey);
  }

  /// 자동 스케줄 활성화 저장
  Future<void> saveAutoScheduleEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_autoScheduleEnabledKey, enabled);
    } catch (e) {
      debugPrint('자동 스케줄 설정 저장 오류: $e');
    }
  }

  /// 자동 스케줄 활성화 로드
  Future<bool> loadAutoScheduleEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_autoScheduleEnabledKey) ?? false;
  }

  /// 알림 활성화 저장
  Future<void> saveNotificationsEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_notificationsEnabledKey, enabled);
    } catch (e) {
      debugPrint('알림 설정 저장 오류: $e');
    }
  }

  /// 알림 활성화 로드
  Future<bool> loadNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationsEnabledKey) ?? true;
  }

  // ==========================================
  // Auth Tokens (인증 토큰)
  // ==========================================

  /// 액세스 토큰 저장
  Future<void> saveAccessToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_accessTokenKey, token);
    } catch (e) {
      debugPrint('액세스 토큰 저장 오류: $e');
    }
  }

  /// 액세스 토큰 로드
  Future<String?> loadAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  /// 액세스 토큰 삭제
  Future<void> deleteAccessToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_accessTokenKey);
    } catch (e) {
      debugPrint('액세스 토큰 삭제 오류: $e');
    }
  }

  /// 토큰 만료 시간 저장
  Future<void> saveTokenExpiry(DateTime expiry) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenExpiryKey, expiry.toIso8601String());
    } catch (e) {
      debugPrint('토큰 만료 시간 저장 오류: $e');
    }
  }

  /// 토큰 만료 시간 로드
  Future<DateTime?> loadTokenExpiry() async {
    final prefs = await SharedPreferences.getInstance();
    final expiryString = prefs.getString(_tokenExpiryKey);
    if (expiryString == null) return null;
    try {
      return DateTime.parse(expiryString);
    } catch (e) {
      debugPrint('토큰 만료 시간 로드 오류: $e');
      return null;
    }
  }

  /// 토큰 만료 시간 삭제
  Future<void> deleteTokenExpiry() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenExpiryKey);
    } catch (e) {
      debugPrint('토큰 만료 시간 삭제 오류: $e');
    }
  }

  /// 사용자 ID 저장
  Future<void> saveUserId(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userIdKey, userId);
    } catch (e) {
      debugPrint('사용자 ID 저장 오류: $e');
    }
  }

  /// 사용자 ID 로드
  Future<String?> loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  /// 사용자 ID 삭제
  Future<void> deleteUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userIdKey);
    } catch (e) {
      debugPrint('사용자 ID 삭제 오류: $e');
    }
  }

  // ==========================================
  // 전체 데이터 초기화
  // ==========================================

  /// 모든 저장된 데이터 초기화
  Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_contentsKey);
      await prefs.remove(_contentTemplatesKey);
      await prefs.remove(_hashtagGroupsKey);
      await prefs.remove(_schedulesKey);
      await prefs.remove(_analyticsRecordsKey);
      await prefs.remove(_repostPlansKey);
      await prefs.remove(_darkModeKey);
      await prefs.remove(_instagramUsernameKey);
      await prefs.remove(_accessTokenKey);
      await prefs.remove(_tokenExpiryKey);
      await prefs.remove(_userIdKey);
      await prefs.remove(_defaultHashtagsKey);
      await prefs.remove(_autoScheduleEnabledKey);
      await prefs.remove(_notificationsEnabledKey);
    } catch (e) {
      debugPrint('전체 데이터 초기화 오류: $e');
    }
  }
}
