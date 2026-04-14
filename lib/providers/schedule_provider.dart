import 'package:flutter/material.dart';
import '../models/schedule.dart';
import '../services/storage_service.dart';
import '../utils/date_utils.dart';

/// 스케줄 상태 관리 Provider
class ScheduleProvider extends ChangeNotifier {
  final StorageService _storageService;

  List<Schedule> _schedules = [];

  ScheduleProvider({StorageService? storageService})
      : _storageService = storageService ?? StorageService();

  // ============ Getters ============

  /// 전체 스케줄 목록
  List<Schedule> get allSchedules => List.unmodifiable(_schedules);

  /// 예정된 스케줄 (미래, 미완료, 날짜순 정렬)
  List<Schedule> get upcomingSchedules {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final result = _schedules.where((s) {
      final scheduleDate = DateTime(
        s.scheduledAt.year,
        s.scheduledAt.month,
        s.scheduledAt.day,
      );
      return !s.isCompleted && !scheduleDate.isBefore(today);
    }).toList();
    result.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    return result;
  }

  /// 오늘 스케줄
  List<Schedule> get todaySchedules {
    final now = DateTime.now();
    return _schedules
        .where((s) => AppDateUtils.isSameDay(s.scheduledAt, now))
        .toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
  }

  /// 지연된 스케줄 (과거, 미완료)
  List<Schedule> get overdueSchedules {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final result = _schedules.where((s) {
      final scheduleDate = DateTime(
        s.scheduledAt.year,
        s.scheduledAt.month,
        s.scheduledAt.day,
      );
      return !s.isCompleted && scheduleDate.isBefore(today);
    }).toList();
    result.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    return result;
  }

  /// 완료된 스케줄
  List<Schedule> get completedSchedules {
    final result = _schedules.where((s) => s.isCompleted).toList();
    result.sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));
    return result;
  }

  /// 특정 날짜의 스케줄
  List<Schedule> schedulesByDate(DateTime date) {
    return _schedules
        .where((s) => AppDateUtils.isSameDay(s.scheduledAt, date))
        .toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
  }

  /// 특정 월의 스케줄
  List<Schedule> schedulesByMonth(int year, int month) {
    return _schedules
        .where(
            (s) => s.scheduledAt.year == year && s.scheduledAt.month == month)
        .toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
  }

  /// ID로 스케줄 찾기
  Schedule? getScheduleById(String id) {
    try {
      return _schedules.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  /// 콘텐츠 ID로 스케줄 찾기
  Schedule? getScheduleByContentId(String contentId) {
    try {
      return _schedules.firstWhere((s) => s.contentId == contentId);
    } catch (_) {
      return null;
    }
  }

  /// 요일별 스케줄 수 (0=Mon..6=Sun)
  Map<int, int> get scheduledCountByWeekday {
    final map = <int, int>{};
    for (int i = 0; i < 7; i++) {
      map[i] = 0;
    }
    for (final s in _schedules) {
      // DateTime.weekday: 1=Mon..7=Sun -> 0=Mon..6=Sun
      final weekday = s.scheduledAt.weekday - 1;
      map[weekday] = (map[weekday] ?? 0) + 1;
    }
    return map;
  }

  /// 이번 주 예약 수
  int get thisWeekScheduledCount {
    final now = DateTime.now();
    final weekStart = AppDateUtils.startOfWeek(now);
    final weekEnd = AppDateUtils.endOfWeek(now);
    return _schedules.where((s) {
      return !s.scheduledAt.isBefore(weekStart) &&
          !s.scheduledAt.isAfter(weekEnd);
    }).length;
  }

  // ============ Actions ============

  /// 초기화 (비동기 로드)
  Future<void> init() async {
    _schedules = await _storageService.loadSchedules();
    notifyListeners();
  }

  /// 스케줄 추가
  Future<void> addSchedule(Schedule schedule) async {
    _schedules.insert(0, schedule);
    await _save();
    notifyListeners();
  }

  /// 스케줄 수정
  Future<void> updateSchedule(Schedule schedule) async {
    final index = _schedules.indexWhere((s) => s.id == schedule.id);
    if (index != -1) {
      _schedules[index] = schedule.copyWith(updatedAt: DateTime.now());
      await _save();
      notifyListeners();
    }
  }

  /// 스케줄 삭제
  Future<void> deleteSchedule(String id) async {
    _schedules.removeWhere((s) => s.id == id);
    await _save();
    notifyListeners();
  }

  /// 완료 표시
  Future<void> markAsCompleted(String id) async {
    final index = _schedules.indexWhere((s) => s.id == id);
    if (index != -1) {
      _schedules[index] = _schedules[index].copyWith(
        isCompleted: true,
        updatedAt: DateTime.now(),
      );
      await _save();
      notifyListeners();
    }
  }

  /// 일정 변경
  Future<void> reschedule(String id, DateTime newDate) async {
    final index = _schedules.indexWhere((s) => s.id == id);
    if (index != -1) {
      _schedules[index] = _schedules[index].copyWith(
        scheduledAt: newDate,
        updatedAt: DateTime.now(),
      );
      await _save();
      notifyListeners();
    }
  }

  /// 저장소에 저장
  Future<void> _save() async {
    await _storageService.saveSchedules(_schedules);
  }
}
