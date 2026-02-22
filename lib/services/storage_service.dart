import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/todo.dart';
import '../models/category.dart';

/// 로컬 저장소 서비스 (shared_preferences 기반)
class StorageService {
  static const String _todosKey = 'todos';
  static const String _categoriesKey = 'categories';
  static const String _darkModeKey = 'isDarkMode';

  /// 기본 카테고리 목록
  static List<Category> get defaultCategories => [
        const Category(
          id: 'cat_personal',
          name: '개인',
          color: 0xFF4CAF50,
          icon: 0xe7fd, // Icons.person
        ),
        const Category(
          id: 'cat_work',
          name: '업무',
          color: 0xFF2196F3,
          icon: 0xe8f9, // Icons.work
        ),
        const Category(
          id: 'cat_shopping',
          name: '쇼핑',
          color: 0xFFFF9800,
          icon: 0xe8cc, // Icons.shopping_cart
        ),
        const Category(
          id: 'cat_health',
          name: '건강',
          color: 0xFFE91E63,
          icon: 0xe87d, // Icons.favorite
        ),
      ];

  /// Todo 목록 저장
  Future<void> saveTodos(List<Todo> todos) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = todos.map((t) => t.toJson()).toList();
    await prefs.setString(_todosKey, jsonEncode(jsonList));
  }

  /// Todo 목록 로드
  Future<List<Todo>> loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_todosKey);
    if (jsonString == null) return [];
    try {
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map((e) => Todo.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Todo 로드 오류: $e');
      return [];
    }
  }

  /// Category 목록 저장
  Future<void> saveCategories(List<Category> categories) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = categories.map((c) => c.toJson()).toList();
    await prefs.setString(_categoriesKey, jsonEncode(jsonList));
  }

  /// Category 목록 로드 (없으면 기본 카테고리 반환)
  Future<List<Category>> loadCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_categoriesKey);
    if (jsonString == null) return defaultCategories;
    try {
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      final categories = jsonList
          .map((e) => Category.fromJson(e as Map<String, dynamic>))
          .toList();
      return categories.isEmpty ? defaultCategories : categories;
    } catch (e) {
      debugPrint('Category 로드 오류: $e');
      return defaultCategories;
    }
  }

  /// 다크모드 설정 저장
  Future<void> saveDarkMode(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, isDarkMode);
  }

  /// 다크모드 설정 로드
  Future<bool> loadDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_darkModeKey) ?? false;
  }

  /// 모든 데이터 초기화
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_todosKey);
    await prefs.remove(_categoriesKey);
  }
}
