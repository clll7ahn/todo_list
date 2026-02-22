import 'package:flutter/material.dart';
import '../models/enums.dart';
import '../models/todo.dart';
import '../services/storage_service.dart';
import '../utils/date_utils.dart';

/// 할일 상태 관리 Provider
class TodoProvider extends ChangeNotifier {
  final StorageService _storage;
  List<Todo> _todos = [];
  String _searchQuery = '';
  FilterType _filterType = FilterType.all;
  SortType _sortType = SortType.createdAt;
  String? _selectedCategoryId;

  TodoProvider(this._storage);

  // ============ Getters ============

  List<Todo> get allTodos => List.unmodifiable(_todos);
  String get searchQuery => _searchQuery;
  FilterType get filterType => _filterType;
  SortType get sortType => _sortType;
  String? get selectedCategoryId => _selectedCategoryId;

  /// 초기화 (비동기 로드)
  Future<void> init() async {
    _todos = await _storage.loadTodos();
    notifyListeners();
  }

  /// 필터+검색+정렬 적용된 할일 목록
  List<Todo> get filteredTodos {
    var result = List<Todo>.from(_todos);

    // 검색 필터
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result.where((t) {
        return t.title.toLowerCase().contains(query) ||
            t.description.toLowerCase().contains(query);
      }).toList();
    }

    // 카테고리 필터
    if (_selectedCategoryId != null) {
      result =
          result.where((t) => t.categoryId == _selectedCategoryId).toList();
    }

    // 상태 필터
    switch (_filterType) {
      case FilterType.active:
        result = result.where((t) => !t.isCompleted).toList();
        break;
      case FilterType.completed:
        result = result.where((t) => t.isCompleted).toList();
        break;
      case FilterType.important:
        result = result.where((t) => t.isImportant && !t.isCompleted).toList();
        break;
      case FilterType.today:
        result = result.where((t) => !t.isCompleted && t.isDueToday).toList();
        break;
      case FilterType.all:
        result = result.where((t) => !t.isCompleted).toList();
        break;
    }

    // 정렬
    result.sort((a, b) {
      // 중요 표시 우선
      if (a.isImportant && !b.isImportant) return -1;
      if (!a.isImportant && b.isImportant) return 1;

      switch (_sortType) {
        case SortType.dueDate:
          if (a.dueDate == null && b.dueDate == null) return 0;
          if (a.dueDate == null) return 1;
          if (b.dueDate == null) return -1;
          return a.dueDate!.compareTo(b.dueDate!);
        case SortType.priority:
          return a.priority.sortOrder.compareTo(b.priority.sortOrder);
        case SortType.createdAt:
          return b.createdAt.compareTo(a.createdAt);
        case SortType.title:
          return a.title.compareTo(b.title);
      }
    });

    return result;
  }

  /// 특정 날짜의 할일 목록
  List<Todo> getTodosForDate(DateTime date) {
    return _todos.where((t) {
      if (t.dueDate == null) return false;
      return AppDateUtils.isSameDay(t.dueDate!, date);
    }).toList();
  }

  /// 마감일별 할일 맵 (캘린더용)
  Map<DateTime, List<Todo>> get todosByDate {
    final map = <DateTime, List<Todo>>{};
    for (final todo in _todos) {
      if (todo.dueDate != null) {
        final key = DateTime(
          todo.dueDate!.year,
          todo.dueDate!.month,
          todo.dueDate!.day,
        );
        map.putIfAbsent(key, () => []).add(todo);
      }
    }
    return map;
  }

  /// ID로 할일 찾기
  Todo? getTodoById(String id) {
    try {
      return _todos.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  // ============ 통계 ============

  int get totalCount => _todos.length;
  int get completedCount => _todos.where((t) => t.isCompleted).length;
  int get pendingCount => _todos.where((t) => !t.isCompleted).length;

  double get completionRate {
    if (_todos.isEmpty) return 0;
    return completedCount / totalCount;
  }

  int get todayCompletedCount {
    final now = DateTime.now();
    return _todos.where((t) {
      return t.isCompleted && AppDateUtils.isSameDay(t.updatedAt, now);
    }).length;
  }

  int get todayDueCount {
    return _todos.where((t) => !t.isCompleted && t.isDueToday).length;
  }

  Map<String, int> get todoCountByCategory {
    final map = <String, int>{};
    for (final todo in _todos.where((t) => !t.isCompleted)) {
      final catId = todo.categoryId.isEmpty ? 'uncategorized' : todo.categoryId;
      map[catId] = (map[catId] ?? 0) + 1;
    }
    return map;
  }

  Map<Priority, int> get todoCountByPriority {
    final map = <Priority, int>{};
    for (final todo in _todos.where((t) => !t.isCompleted)) {
      map[todo.priority] = (map[todo.priority] ?? 0) + 1;
    }
    return map;
  }

  /// 최근 7일 완료 추이
  List<int> get weeklyCompletionTrend {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final date = now.subtract(Duration(days: 6 - i));
      return _todos.where((t) {
        return t.isCompleted && AppDateUtils.isSameDay(t.updatedAt, date);
      }).length;
    });
  }

  // ============ 액션 ============

  /// 할일 추가
  Future<void> addTodo(Todo todo) async {
    _todos.insert(0, todo);
    await _storage.saveTodos(_todos);
    notifyListeners();
  }

  /// 할일 수정
  Future<void> updateTodo(Todo todo) async {
    final index = _todos.indexWhere((t) => t.id == todo.id);
    if (index != -1) {
      _todos[index] = todo.copyWith(updatedAt: DateTime.now());
      await _storage.saveTodos(_todos);
      notifyListeners();
    }
  }

  /// 할일 삭제
  Future<void> deleteTodo(String id) async {
    _todos.removeWhere((t) => t.id == id);
    await _storage.saveTodos(_todos);
    notifyListeners();
  }

  /// 완료 토글
  Future<void> toggleComplete(String id) async {
    final index = _todos.indexWhere((t) => t.id == id);
    if (index != -1) {
      final todo = _todos[index];
      _todos[index] = todo.copyWith(
        isCompleted: !todo.isCompleted,
        updatedAt: DateTime.now(),
      );
      await _storage.saveTodos(_todos);
      notifyListeners();
    }
  }

  /// 중요 표시 토글
  Future<void> toggleImportant(String id) async {
    final index = _todos.indexWhere((t) => t.id == id);
    if (index != -1) {
      final todo = _todos[index];
      _todos[index] = todo.copyWith(
        isImportant: !todo.isImportant,
        updatedAt: DateTime.now(),
      );
      await _storage.saveTodos(_todos);
      notifyListeners();
    }
  }

  /// 서브태스크 완료 토글
  Future<void> toggleSubtask(String todoId, String subtaskId) async {
    final index = _todos.indexWhere((t) => t.id == todoId);
    if (index != -1) {
      final todo = _todos[index];
      final updatedSubtasks = todo.subtasks.map((s) {
        if (s.id == subtaskId) {
          return s.copyWith(isCompleted: !s.isCompleted);
        }
        return s;
      }).toList();
      _todos[index] = todo.copyWith(
        subtasks: updatedSubtasks,
        updatedAt: DateTime.now(),
      );
      await _storage.saveTodos(_todos);
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilter(FilterType filter) {
    _filterType = filter;
    notifyListeners();
  }

  void setSortType(SortType sort) {
    _sortType = sort;
    notifyListeners();
  }

  void setCategoryFilter(String? categoryId) {
    _selectedCategoryId = categoryId;
    notifyListeners();
  }

  Future<void> clearAll() async {
    _todos.clear();
    await _storage.saveTodos(_todos);
    notifyListeners();
  }
}
