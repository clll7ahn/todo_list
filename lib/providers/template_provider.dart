import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/content.dart';
import '../models/content_template.dart';
import '../models/enums.dart';
import '../services/storage_service.dart';

/// 콘텐츠 템플릿 상태 관리 Provider
class TemplateProvider extends ChangeNotifier {
  final StorageService _storageService;
  final Uuid _uuid = const Uuid();

  List<ContentTemplate> _templates = [];

  TemplateProvider({StorageService? storageService})
      : _storageService = storageService ?? StorageService();

  // ============ Getters ============

  /// 전체 템플릿 목록
  List<ContentTemplate> get templates => List.unmodifiable(_templates);

  /// ID로 템플릿 찾기
  ContentTemplate? getTemplateById(String id) {
    try {
      return _templates.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  /// 콘텐츠 유형별 템플릿 목록
  List<ContentTemplate> templatesByType(ContentType type) {
    return _templates.where((t) => t.contentType == type).toList();
  }

  /// 가장 많이 사용된 템플릿 (상위 5개)
  List<ContentTemplate> get mostUsedTemplates {
    final sorted = List<ContentTemplate>.from(_templates)
      ..sort((a, b) => b.usageCount.compareTo(a.usageCount));
    return sorted.take(5).toList();
  }

  // ============ 액션 ============

  /// 초기화 (비동기 로드)
  Future<void> init() async {
    _templates = await _storageService.loadContentTemplates();
    notifyListeners();
  }

  /// 템플릿 추가
  Future<void> addTemplate(ContentTemplate template) async {
    _templates.insert(0, template);
    await _save();
    notifyListeners();
  }

  /// 템플릿 수정
  Future<void> updateTemplate(ContentTemplate template) async {
    final index = _templates.indexWhere((t) => t.id == template.id);
    if (index != -1) {
      _templates[index] = template;
      await _save();
      notifyListeners();
    }
  }

  /// 템플릿 삭제
  Future<void> deleteTemplate(String id) async {
    _templates.removeWhere((t) => t.id == id);
    await _save();
    notifyListeners();
  }

  /// 사용 횟수 증가
  Future<void> incrementUsage(String id) async {
    final index = _templates.indexWhere((t) => t.id == id);
    if (index != -1) {
      final template = _templates[index];
      _templates[index] = template.copyWith(
        usageCount: template.usageCount + 1,
      );
      await _save();
      notifyListeners();
    }
  }

  /// 템플릿으로부터 새 콘텐츠 생성
  Content createContentFromTemplate(ContentTemplate template) {
    final now = DateTime.now();
    return Content(
      id: _uuid.v4(),
      title: template.name,
      caption: template.captionTemplate,
      contentType: template.contentType,
      status: ContentStatus.draft,
      hashtags: List<String>.from(template.defaultHashtags),
      hashtagGroupId: template.hashtagGroupId,
      templateId: template.id,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// 저장소에 저장
  Future<void> _save() async {
    await _storageService.saveContentTemplates(_templates);
  }
}
