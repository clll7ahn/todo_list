import 'package:flutter/material.dart';
import '../models/enums.dart';
import '../services/storage_service.dart';

/// 앱 설정 상태 관리 Provider
class SettingsProvider extends ChangeNotifier {
  final StorageService _storageService;

  bool _isDarkMode = false;
  String _instagramUsername = '';
  int _defaultPostsPerWeek = 3;
  PostTimeSlot _preferredTimeSlot = PostTimeSlot.afternoon;
  bool _showNotifications = true;
  double _engagementRateThreshold = 3.0;

  SettingsProvider({StorageService? storageService})
      : _storageService = storageService ?? StorageService();

  // ============ Getters ============

  /// 다크모드 여부
  bool get isDarkMode => _isDarkMode;

  /// 인스타그램 사용자명
  String get instagramUsername => _instagramUsername;

  /// 주간 기본 게시 횟수
  int get defaultPostsPerWeek => _defaultPostsPerWeek;

  /// 선호 게시 시간대
  PostTimeSlot get preferredTimeSlot => _preferredTimeSlot;

  /// 알림 표시 여부
  bool get showNotifications => _showNotifications;

  /// 참여율 임계값
  double get engagementRateThreshold => _engagementRateThreshold;

  // ============ 초기화 ============

  /// 초기 설정 로드
  Future<void> initialize() async {
    _isDarkMode = await _storageService.loadDarkMode();
    _instagramUsername =
        await _storageService.loadInstagramUsername() ?? '';
    _defaultPostsPerWeek =
        await _storageService.loadDefaultPostsPerWeek();
    final timeSlotValue = await _storageService.loadPreferredTimeSlot();
    _preferredTimeSlot = timeSlotValue != null
        ? PostTimeSlotExtension.fromValue(timeSlotValue)
        : PostTimeSlot.afternoon;
    _showNotifications =
        await _storageService.loadNotificationsEnabled();
    _engagementRateThreshold =
        await _storageService.loadEngagementRateThreshold();
    notifyListeners();
  }

  // ============ Setters ============

  /// 다크모드 토글
  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    await _storageService.saveDarkMode(_isDarkMode);
    notifyListeners();
  }

  /// 다크모드 설정
  Future<void> setDarkMode(bool value) async {
    if (_isDarkMode == value) return;
    _isDarkMode = value;
    await _storageService.saveDarkMode(_isDarkMode);
    notifyListeners();
  }

  /// 인스타그램 사용자명 설정
  Future<void> setInstagramUsername(String username) async {
    if (_instagramUsername == username) return;
    _instagramUsername = username;
    await _storageService.saveInstagramUsername(_instagramUsername);
    notifyListeners();
  }

  /// 주간 기본 게시 횟수 설정
  Future<void> setDefaultPostsPerWeek(int count) async {
    if (_defaultPostsPerWeek == count) return;
    _defaultPostsPerWeek = count;
    await _storageService.saveDefaultPostsPerWeek(_defaultPostsPerWeek);
    notifyListeners();
  }

  /// 선호 게시 시간대 설정
  Future<void> setPreferredTimeSlot(PostTimeSlot timeSlot) async {
    if (_preferredTimeSlot == timeSlot) return;
    _preferredTimeSlot = timeSlot;
    await _storageService.savePreferredTimeSlot(_preferredTimeSlot.value);
    notifyListeners();
  }

  /// 알림 표시 설정
  Future<void> setShowNotifications(bool value) async {
    if (_showNotifications == value) return;
    _showNotifications = value;
    await _storageService.saveNotificationsEnabled(_showNotifications);
    notifyListeners();
  }

  /// 참여율 임계값 설정
  Future<void> setEngagementRateThreshold(double threshold) async {
    if (_engagementRateThreshold == threshold) return;
    _engagementRateThreshold = threshold;
    await _storageService.saveEngagementRateThreshold(
        _engagementRateThreshold);
    notifyListeners();
  }
}
