import 'package:uuid/uuid.dart';

import 'enums.dart';

/// 콘텐츠 게시 스케줄 모델
/// 콘텐츠의 예약 게시 일정을 관리합니다.
class Schedule {
  /// 고유 식별자 (UUID)
  final String id;

  /// 연결된 콘텐츠 ID
  final String contentId;

  /// 예약 게시 일시
  final DateTime scheduledAt;

  /// 게시 시간대
  final PostTimeSlot timeSlot;

  /// 반복 유형
  final ScheduleRepeatType repeatType;

  /// 완료 여부
  final bool isCompleted;

  /// 메모 (선택)
  final String? memo;

  /// 생성일
  final DateTime createdAt;

  /// 수정일
  final DateTime updatedAt;

  const Schedule({
    required this.id,
    required this.contentId,
    required this.scheduledAt,
    this.timeSlot = PostTimeSlot.morning,
    this.repeatType = ScheduleRepeatType.none,
    this.isCompleted = false,
    this.memo,
    required this.createdAt,
    required this.updatedAt,
  });

  /// JSON에서 Schedule 생성
  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'] as String,
      contentId: json['contentId'] as String,
      scheduledAt: DateTime.parse(json['scheduledAt'] as String),
      timeSlot: PostTimeSlotExtension.fromValue(
        json['timeSlot'] as String? ?? 'morning',
      ),
      repeatType: ScheduleRepeatTypeExtension.fromValue(
        json['repeatType'] as String? ?? 'none',
      ),
      isCompleted: json['isCompleted'] as bool? ?? false,
      memo: json['memo'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Schedule를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contentId': contentId,
      'scheduledAt': scheduledAt.toIso8601String(),
      'timeSlot': timeSlot.value,
      'repeatType': repeatType.value,
      'isCompleted': isCompleted,
      'memo': memo,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// 복사본 생성 (일부 필드 변경)
  Schedule copyWith({
    String? id,
    String? contentId,
    DateTime? scheduledAt,
    PostTimeSlot? timeSlot,
    ScheduleRepeatType? repeatType,
    bool? isCompleted,
    String? memo,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearMemo = false,
  }) {
    return Schedule(
      id: id ?? this.id,
      contentId: contentId ?? this.contentId,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      timeSlot: timeSlot ?? this.timeSlot,
      repeatType: repeatType ?? this.repeatType,
      isCompleted: isCompleted ?? this.isCompleted,
      memo: clearMemo ? null : (memo ?? this.memo),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Schedule && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
