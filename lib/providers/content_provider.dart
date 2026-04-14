import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/content.dart';
import '../models/enums.dart';
import '../services/storage_service.dart';

/// 콘텐츠 상태 관리 Provider
class ContentProvider extends ChangeNotifier {
  final StorageService _storageService;
  final Uuid _uuid = const Uuid();

  List<Content> _contents = [];
  ContentStatus? _statusFilter;
  ContentType? _typeFilter;
  ContentSortType _sortType = ContentSortType.createdAt;
  String _searchQuery = '';

  ContentProvider({StorageService? storageService})
      : _storageService = storageService ?? StorageService();

  // ============ Getters ============

  /// 전체 콘텐츠 목록
  List<Content> get allContents => List.unmodifiable(_contents);

  /// 필터+검색+정렬 적용된 콘텐츠 목록
  List<Content> get filteredContents {
    var result = List<Content>.from(_contents);

    // 상태 필터
    if (_statusFilter != null) {
      result = result.where((c) => c.status == _statusFilter).toList();
    }

    // 유형 필터
    if (_typeFilter != null) {
      result = result.where((c) => c.contentType == _typeFilter).toList();
    }

    // 검색 필터
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result.where((c) {
        return c.title.toLowerCase().contains(query) ||
            c.caption.toLowerCase().contains(query) ||
            c.notes.toLowerCase().contains(query) ||
            c.hashtags.any((h) => h.toLowerCase().contains(query));
      }).toList();
    }

    // 정렬
    result.sort((a, b) {
      switch (_sortType) {
        case ContentSortType.createdAt:
          return b.createdAt.compareTo(a.createdAt);
        case ContentSortType.scheduledAt:
          if (a.scheduledAt == null && b.scheduledAt == null) return 0;
          if (a.scheduledAt == null) return 1;
          if (b.scheduledAt == null) return -1;
          return a.scheduledAt!.compareTo(b.scheduledAt!);
        case ContentSortType.title:
          return a.title.compareTo(b.title);
        case ContentSortType.performance:
          // 성과 순은 게시일 기준으로 최신 우선 (성과 데이터는 별도 관리)
          return b.updatedAt.compareTo(a.updatedAt);
      }
    });

    return result;
  }

  /// 초안 콘텐츠 목록
  List<Content> get draftContents =>
      _contents.where((c) => c.status == ContentStatus.draft).toList();

  /// 준비 완료 콘텐츠 목록
  List<Content> get readyContents =>
      _contents.where((c) => c.status == ContentStatus.ready).toList();

  /// 예약된 콘텐츠 목록
  List<Content> get scheduledContents =>
      _contents.where((c) => c.status == ContentStatus.scheduled).toList();

  /// 게시된 콘텐츠 목록
  List<Content> get postedContents =>
      _contents.where((c) => c.status == ContentStatus.posted).toList();

  /// 보관된 콘텐츠 목록
  List<Content> get archivedContents =>
      _contents.where((c) => c.status == ContentStatus.archived).toList();

  /// 즐겨찾기 콘텐츠 목록
  List<Content> get favoriteContents =>
      _contents.where((c) => c.isFavorite).toList();

  /// ID로 콘텐츠 찾기
  Content? getContentById(String id) {
    try {
      return _contents.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  /// 전체 콘텐츠 수
  int get totalCount => _contents.length;

  /// 상태별 콘텐츠 수
  Map<ContentStatus, int> get countByStatus {
    final map = <ContentStatus, int>{};
    for (final status in ContentStatus.values) {
      map[status] = _contents.where((c) => c.status == status).length;
    }
    return map;
  }

  /// 유형별 콘텐츠 수
  Map<ContentType, int> get countByType {
    final map = <ContentType, int>{};
    for (final type in ContentType.values) {
      map[type] = _contents.where((c) => c.contentType == type).length;
    }
    return map;
  }

  // ============ 액션 ============

  /// 초기화 (비동기 로드)
  Future<void> init() async {
    _contents = await _storageService.loadContents();
    notifyListeners();
  }

  /// 콘텐츠 추가
  Future<void> addContent(Content content) async {
    _contents.insert(0, content);
    await _save();
    notifyListeners();
  }

  /// 콘텐츠 수정
  Future<void> updateContent(Content content) async {
    final index = _contents.indexWhere((c) => c.id == content.id);
    if (index != -1) {
      _contents[index] = content.copyWith(updatedAt: DateTime.now());
      await _save();
      notifyListeners();
    }
  }

  /// 콘텐츠 삭제
  Future<void> deleteContent(String id) async {
    _contents.removeWhere((c) => c.id == id);
    await _save();
    notifyListeners();
  }

  /// 콘텐츠 상태 변경
  Future<void> updateStatus(String id, ContentStatus status) async {
    final index = _contents.indexWhere((c) => c.id == id);
    if (index != -1) {
      _contents[index] = _contents[index].copyWith(
        status: status,
        updatedAt: DateTime.now(),
      );
      await _save();
      notifyListeners();
    }
  }

  /// 즐겨찾기 토글
  Future<void> toggleFavorite(String id) async {
    final index = _contents.indexWhere((c) => c.id == id);
    if (index != -1) {
      final content = _contents[index];
      _contents[index] = content.copyWith(
        isFavorite: !content.isFavorite,
        updatedAt: DateTime.now(),
      );
      await _save();
      notifyListeners();
    }
  }

  /// 콘텐츠 복제 (복사본 생성)
  Future<void> duplicateContent(String id) async {
    final original = getContentById(id);
    if (original == null) return;

    final now = DateTime.now();
    final copy = original.copyWith(
      id: _uuid.v4(),
      title: '${original.title} 복사본',
      status: ContentStatus.draft,
      createdAt: now,
      updatedAt: now,
      clearScheduledAt: true,
      clearPostedAt: true,
      clearInstagramMediaId: true,
      clearInstagramPermalink: true,
      isFavorite: false,
    );

    _contents.insert(0, copy);
    await _save();
    notifyListeners();
  }

  /// 상태 필터 설정
  void setStatusFilter(ContentStatus? status) {
    _statusFilter = status;
    notifyListeners();
  }

  /// 유형 필터 설정
  void setTypeFilter(ContentType? type) {
    _typeFilter = type;
    notifyListeners();
  }

  /// 정렬 유형 설정
  void setSortType(ContentSortType sort) {
    _sortType = sort;
    notifyListeners();
  }

  /// 검색어 설정
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// 저장소에 저장
  Future<void> _save() async {
    await _storageService.saveContents(_contents);
  }
}
