import 'package:flutter/material.dart';
import '../models/repost_plan.dart';
import '../services/storage_service.dart';

/// 리포스트 계획 상태 관리 Provider
class RepostProvider extends ChangeNotifier {
  final StorageService _storageService;

  List<RepostPlan> _plans = [];

  RepostProvider({StorageService? storageService})
      : _storageService = storageService ?? StorageService();

  // ============ Getters ============

  /// 전체 리포스트 계획 목록
  List<RepostPlan> get allPlans => List.unmodifiable(_plans);

  /// 미실행 계획 목록 (예정일 기준 정렬)
  List<RepostPlan> get pendingPlans {
    final pending = _plans.where((p) => !p.isExecuted).toList()
      ..sort((a, b) => a.plannedAt.compareTo(b.plannedAt));
    return pending;
  }

  /// 실행 완료 계획 목록
  List<RepostPlan> get executedPlans =>
      _plans.where((p) => p.isExecuted).toList();

  /// ID로 계획 찾기
  RepostPlan? getPlanById(String id) {
    try {
      return _plans.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  /// 콘텐츠 ID로 계획 목록 찾기
  List<RepostPlan> getPlansForContent(String contentId) {
    return _plans
        .where((p) => p.originalContentId == contentId)
        .toList();
  }

  /// 미실행 계획 수
  int get pendingCount => _plans.where((p) => !p.isExecuted).length;

  /// 실행 완료 계획 수
  int get executedCount => _plans.where((p) => p.isExecuted).length;

  // ============ 액션 ============

  /// 초기화 (비동기 로드)
  Future<void> init() async {
    _plans = await _storageService.loadRepostPlans();
    notifyListeners();
  }

  /// 계획 생성
  Future<void> createPlan(RepostPlan plan) async {
    _plans.insert(0, plan);
    await _save();
    notifyListeners();
  }

  /// 계획 수정
  Future<void> updatePlan(RepostPlan plan) async {
    final index = _plans.indexWhere((p) => p.id == plan.id);
    if (index != -1) {
      _plans[index] = plan;
      await _save();
      notifyListeners();
    }
  }

  /// 계획 삭제
  Future<void> deletePlan(String id) async {
    _plans.removeWhere((p) => p.id == id);
    await _save();
    notifyListeners();
  }

  /// 계획 실행 완료 처리
  Future<void> executePlan(String id, String newContentId) async {
    final index = _plans.indexWhere((p) => p.id == id);
    if (index != -1) {
      _plans[index] = _plans[index].copyWith(
        isExecuted: true,
        newContentId: newContentId,
      );
      await _save();
      notifyListeners();
    }
  }

  /// 저장소에 저장
  Future<void> _save() async {
    await _storageService.saveRepostPlans(_plans);
  }
}
