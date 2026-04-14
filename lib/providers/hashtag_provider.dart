import 'package:flutter/material.dart';
import '../models/hashtag_group.dart';
import '../models/enums.dart';
import '../services/storage_service.dart';

/// 해시태그 그룹 상태 관리 Provider
class HashtagProvider extends ChangeNotifier {
  final StorageService _storageService;

  List<HashtagGroup> _groups = [];
  List<String> _recentlyUsed = [];

  HashtagProvider({StorageService? storageService})
      : _storageService = storageService ?? StorageService();

  // ============ Getters ============

  /// 전체 해시태그 그룹 목록
  List<HashtagGroup> get groups => List.unmodifiable(_groups);

  /// ID로 해시태그 그룹 찾기
  HashtagGroup? getGroupById(String id) {
    try {
      return _groups.firstWhere((g) => g.id == id);
    } catch (_) {
      return null;
    }
  }

  /// 카테고리별 해시태그 그룹 목록
  List<HashtagGroup> groupsByCategory(HashtagCategory category) {
    return _groups.where((g) => g.category == category).toList();
  }

  /// 모든 고유 해시태그 집합
  Set<String> get allUniqueHashtags {
    final set = <String>{};
    for (final group in _groups) {
      set.addAll(group.hashtags);
    }
    return set;
  }

  /// 최근 사용 해시태그 목록
  List<String> get recentlyUsedHashtags => List.unmodifiable(_recentlyUsed);

  /// 가장 많이 사용된 그룹 (상위 5개)
  List<HashtagGroup> get mostUsedGroups {
    final sorted = List<HashtagGroup>.from(_groups)
      ..sort((a, b) => b.usageCount.compareTo(a.usageCount));
    return sorted.take(5).toList();
  }

  // ============ 액션 ============

  /// 초기화 (비동기 로드)
  Future<void> init() async {
    _groups = await _storageService.loadHashtagGroups();
    _recentlyUsed = await _storageService.loadRecentlyUsedHashtags();
    notifyListeners();
  }

  /// 해시태그 그룹 추가
  Future<void> addGroup(HashtagGroup group) async {
    _groups.insert(0, group);
    await _save();
    notifyListeners();
  }

  /// 해시태그 그룹 수정
  Future<void> updateGroup(HashtagGroup group) async {
    final index = _groups.indexWhere((g) => g.id == group.id);
    if (index != -1) {
      _groups[index] = group.copyWith(updatedAt: DateTime.now());
      await _save();
      notifyListeners();
    }
  }

  /// 해시태그 그룹 삭제
  Future<void> deleteGroup(String id) async {
    _groups.removeWhere((g) => g.id == id);
    await _save();
    notifyListeners();
  }

  /// 사용 횟수 증가
  Future<void> incrementUsage(String id) async {
    final index = _groups.indexWhere((g) => g.id == id);
    if (index != -1) {
      final group = _groups[index];
      _groups[index] = group.copyWith(
        usageCount: group.usageCount + 1,
        updatedAt: DateTime.now(),
      );
      await _save();
      notifyListeners();
    }
  }

  /// 최근 사용 해시태그 추적 (최대 50개)
  void trackRecentUsage(List<String> hashtags) {
    for (final tag in hashtags) {
      _recentlyUsed.remove(tag);
      _recentlyUsed.insert(0, tag);
    }
    // 최대 50개까지만 유지
    if (_recentlyUsed.length > 50) {
      _recentlyUsed = _recentlyUsed.sublist(0, 50);
    }
    _storageService.saveRecentlyUsedHashtags(_recentlyUsed);
    notifyListeners();
  }

  /// 해시태그 검색 제안 (모든 그룹에서 검색)
  List<String> suggestHashtags(String query) {
    if (query.isEmpty) return [];
    final lowerQuery = query.toLowerCase();
    final suggestions = <String>{};

    for (final group in _groups) {
      for (final tag in group.hashtags) {
        if (tag.toLowerCase().contains(lowerQuery)) {
          suggestions.add(tag);
        }
      }
    }

    return suggestions.toList();
  }

  /// 저장소에 저장
  Future<void> _save() async {
    await _storageService.saveHashtagGroups(_groups);
  }
}
