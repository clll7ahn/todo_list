import 'package:flutter/material.dart';
import '../models/analytics_record.dart';
import '../models/enums.dart';
import '../services/storage_service.dart';

/// 분석 데이터 상태 관리 Provider
class AnalyticsProvider extends ChangeNotifier {
  final StorageService _storageService;

  List<AnalyticsRecord> _records = [];
  AnalyticsPeriod _period = AnalyticsPeriod.month;

  AnalyticsProvider({StorageService? storageService})
      : _storageService = storageService ?? StorageService();

  // ============ Getters ============

  /// 전체 분석 기록 목록
  List<AnalyticsRecord> get allRecords => List.unmodifiable(_records);

  /// ID로 분석 기록 찾기
  AnalyticsRecord? getRecordById(String id) {
    try {
      return _records.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  /// 콘텐츠 ID로 분석 기록 찾기
  AnalyticsRecord? getRecordByContentId(String contentId) {
    try {
      return _records.firstWhere((r) => r.contentId == contentId);
    } catch (_) {
      return null;
    }
  }

  /// 기간 내 분석 기록 목록
  List<AnalyticsRecord> recordsInPeriod(DateTime start, DateTime end) {
    return _records.where((r) {
      return !r.recordedAt.isBefore(start) && !r.recordedAt.isAfter(end);
    }).toList();
  }

  /// 참여율 상위 10개 기록
  List<AnalyticsRecord> get topPerformingRecords {
    final sorted = List<AnalyticsRecord>.from(_records)
      ..sort((a, b) => b.engagementRate.compareTo(a.engagementRate));
    return sorted.take(10).toList();
  }

  /// 재등록 추천 콘텐츠 ID 목록
  /// 참여율이 기본 임계값(5%) 이상이고, 등급이 good 또는 excellent인 기록
  List<String> get repostCandidateContentIds {
    return _records
        .where((r) =>
            r.engagementRate >= 5.0 &&
            (r.grade == PerformanceGrade.good ||
                r.grade == PerformanceGrade.excellent))
        .map((r) => r.contentId)
        .toList();
  }

  /// 현재 분석 기간
  AnalyticsPeriod get currentPeriod => _period;

  // ============ 통계 ============

  /// 평균 참여율
  double get averageEngagementRate {
    if (_records.isEmpty) return 0.0;
    final total =
        _records.fold<double>(0.0, (sum, r) => sum + r.engagementRate);
    return total / _records.length;
  }

  /// 총 도달 수
  int get totalReach {
    return _records.fold<int>(0, (sum, r) => sum + r.reach);
  }

  /// 총 노출 수
  int get totalImpressions {
    return _records.fold<int>(0, (sum, r) => sum + r.impressions);
  }

  /// 평균 좋아요 수
  double get averageLikes {
    if (_records.isEmpty) return 0.0;
    final total = _records.fold<int>(0, (sum, r) => sum + r.likes);
    return total / _records.length;
  }

  /// 평균 댓글 수
  double get averageComments {
    if (_records.isEmpty) return 0.0;
    final total = _records.fold<int>(0, (sum, r) => sum + r.comments);
    return total / _records.length;
  }

  /// 최근 N일간 일별 참여율 추이
  List<double> engagementTrend(int days) {
    final now = DateTime.now();
    final result = <double>[];

    for (int i = days - 1; i >= 0; i--) {
      final date = DateTime(now.year, now.month, now.day - i);
      final nextDate = date.add(const Duration(days: 1));

      final dayRecords = _records.where((r) =>
          !r.recordedAt.isBefore(date) && r.recordedAt.isBefore(nextDate));

      if (dayRecords.isEmpty) {
        result.add(0.0);
      } else {
        final avg = dayRecords.fold<double>(
                0.0, (sum, r) => sum + r.engagementRate) /
            dayRecords.length;
        result.add(avg);
      }
    }

    return result;
  }

  /// 최근 N일간 일별 도달 수 추이
  List<int> reachTrend(int days) {
    final now = DateTime.now();
    final result = <int>[];

    for (int i = days - 1; i >= 0; i--) {
      final date = DateTime(now.year, now.month, now.day - i);
      final nextDate = date.add(const Duration(days: 1));

      final dayRecords = _records.where((r) =>
          !r.recordedAt.isBefore(date) && r.recordedAt.isBefore(nextDate));

      final totalReach =
          dayRecords.fold<int>(0, (sum, r) => sum + r.reach);
      result.add(totalReach);
    }

    return result;
  }

  /// 요일별 평균 참여율 (0=월요일 ~ 6=일요일)
  Map<int, double> get performanceByDayOfWeek {
    final Map<int, List<double>> grouped = {};
    for (int i = 0; i < 7; i++) {
      grouped[i] = [];
    }

    for (final record in _records) {
      // DateTime.weekday: 1=Mon, 7=Sun -> 0=Mon, 6=Sun
      final dayIndex = record.recordedAt.weekday - 1;
      grouped[dayIndex]!.add(record.engagementRate);
    }

    final result = <int, double>{};
    grouped.forEach((day, rates) {
      if (rates.isEmpty) {
        result[day] = 0.0;
      } else {
        result[day] = rates.reduce((a, b) => a + b) / rates.length;
      }
    });

    return result;
  }

  /// 시간대별 평균 참여율
  Map<PostTimeSlot, double> get performanceByTimeSlot {
    final Map<PostTimeSlot, List<double>> grouped = {};
    for (final slot in PostTimeSlot.values) {
      grouped[slot] = [];
    }

    for (final record in _records) {
      final hour = record.recordedAt.hour;
      PostTimeSlot slot;
      if (hour >= 6 && hour < 12) {
        slot = PostTimeSlot.morning;
      } else if (hour >= 12 && hour < 18) {
        slot = PostTimeSlot.afternoon;
      } else if (hour >= 18 && hour < 22) {
        slot = PostTimeSlot.evening;
      } else {
        slot = PostTimeSlot.night;
      }
      grouped[slot]!.add(record.engagementRate);
    }

    final result = <PostTimeSlot, double>{};
    grouped.forEach((slot, rates) {
      if (rates.isEmpty) {
        result[slot] = 0.0;
      } else {
        result[slot] = rates.reduce((a, b) => a + b) / rates.length;
      }
    });

    return result;
  }

  /// 가장 성과가 좋은 콘텐츠 유형
  /// 콘텐츠 유형 정보는 별도로 관리되므로, 여기서는 null 반환
  /// (콘텐츠 Provider와 결합하여 사용)
  ContentType? get bestPerformingContentType {
    // 분석 기록에는 contentType이 없으므로 null 반환
    // 대시보드에서 ContentProvider와 결합하여 계산
    return null;
  }

  // ============ 액션 ============

  /// 초기화 (비동기 로드)
  Future<void> init() async {
    _records = await _storageService.loadAnalyticsRecords();
    notifyListeners();
  }

  /// 분석 기록 추가
  Future<void> addRecord(AnalyticsRecord record) async {
    _records.insert(0, record);
    await _save();
    notifyListeners();
  }

  /// 분석 기록 수정
  Future<void> updateRecord(AnalyticsRecord record) async {
    final index = _records.indexWhere((r) => r.id == record.id);
    if (index != -1) {
      _records[index] = record.copyWith(updatedAt: DateTime.now());
      await _save();
      notifyListeners();
    }
  }

  /// 분석 기록 삭제
  Future<void> deleteRecord(String id) async {
    _records.removeWhere((r) => r.id == id);
    await _save();
    notifyListeners();
  }

  /// 분석 기간 설정
  void setPeriod(AnalyticsPeriod period) {
    _period = period;
    notifyListeners();
  }

  /// 저장소에 저장
  Future<void> _save() async {
    await _storageService.saveAnalyticsRecords(_records);
  }
}
