import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/category.dart';
import '../services/storage_service.dart';

/// 카테고리 상태 관리 Provider
class CategoryProvider extends ChangeNotifier {
  final StorageService _storageService;
  final Uuid _uuid = const Uuid();

  List<Category> _categories = [];
  bool _isLoading = false;

  CategoryProvider({StorageService? storageService})
      : _storageService = storageService ?? StorageService();

  /// 카테고리 목록
  List<Category> get categories => List.unmodifiable(_categories);

  /// 로딩 상태
  bool get isLoading => _isLoading;

  /// 초기 데이터 로드
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    _categories = await _storageService.loadCategories();

    _isLoading = false;
    notifyListeners();
  }

  /// ID로 카테고리 조회
  Category? getCategoryById(String id) {
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  /// 카테고리 추가
  Future<void> addCategory({
    required String name,
    required int color,
    required int icon,
  }) async {
    final category = Category(
      id: _uuid.v4(),
      name: name,
      color: color,
      icon: icon,
    );
    _categories.add(category);
    await _storageService.saveCategories(_categories);
    notifyListeners();
  }

  /// 카테고리 수정
  Future<void> updateCategory(Category updated) async {
    final index = _categories.indexWhere((c) => c.id == updated.id);
    if (index == -1) return;
    _categories[index] = updated;
    await _storageService.saveCategories(_categories);
    notifyListeners();
  }

  /// 카테고리 삭제
  Future<void> deleteCategory(String id) async {
    _categories.removeWhere((c) => c.id == id);
    await _storageService.saveCategories(_categories);
    notifyListeners();
  }

  /// 기본 카테고리 여부 확인
  bool isDefaultCategory(String id) {
    return StorageService.defaultCategories.any((c) => c.id == id);
  }
}
