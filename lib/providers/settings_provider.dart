import 'package:flutter/material.dart';
import '../services/storage_service.dart';

/// 앱 설정 상태 관리 Provider
class SettingsProvider extends ChangeNotifier {
  final StorageService _storageService;

  bool _isDarkMode = false;

  SettingsProvider({StorageService? storageService})
      : _storageService = storageService ?? StorageService();

  /// 다크모드 여부
  bool get isDarkMode => _isDarkMode;

  /// 초기 설정 로드
  Future<void> initialize() async {
    _isDarkMode = await _storageService.loadDarkMode();
    notifyListeners();
  }

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
}
