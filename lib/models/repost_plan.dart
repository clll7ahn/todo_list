import 'package:uuid/uuid.dart';

import 'enums.dart';

/// 리포스트 계획 모델
/// 성과가 좋은 콘텐츠를 재게시하기 위한 계획을 관리합니다.
class RepostPlan {
  /// 고유 식별자 (UUID)
  final String id;

  /// 원본 콘텐츠 ID
  final String originalContentId;

  /// 리포스트 전략
  final RepostStrategy strategy;

  /// 수정된 캡션 (선택)
  final String? modifiedCaption;

  /// 수정된 해시태그 목록 (선택)
  final List<String>? modifiedHashtags;

  /// 예정 게시일
  final DateTime plannedAt;

  /// 실행 완료 여부
  final bool isExecuted;

  /// 새로 생성된 콘텐츠 ID (실행 후)
  final String? newContentId;

  /// 메모 (선택)
  final String? notes;

  /// 생성일
  final DateTime createdAt;

  const RepostPlan({
    required this.id,
    required this.originalContentId,
    this.strategy = RepostStrategy.exact,
    this.modifiedCaption,
    this.modifiedHashtags,
    required this.plannedAt,
    this.isExecuted = false,
    this.newContentId,
    this.notes,
    required this.createdAt,
  });

  /// JSON에서 RepostPlan 생성
  factory RepostPlan.fromJson(Map<String, dynamic> json) {
    return RepostPlan(
      id: json['id'] as String,
      originalContentId: json['originalContentId'] as String,
      strategy: RepostStrategyExtension.fromValue(
        json['strategy'] as String? ?? 'exact',
      ),
      modifiedCaption: json['modifiedCaption'] as String?,
      modifiedHashtags: (json['modifiedHashtags'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      plannedAt: DateTime.parse(json['plannedAt'] as String),
      isExecuted: json['isExecuted'] as bool? ?? false,
      newContentId: json['newContentId'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// RepostPlan을 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'originalContentId': originalContentId,
      'strategy': strategy.value,
      'modifiedCaption': modifiedCaption,
      'modifiedHashtags': modifiedHashtags,
      'plannedAt': plannedAt.toIso8601String(),
      'isExecuted': isExecuted,
      'newContentId': newContentId,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// 복사본 생성 (일부 필드 변경)
  RepostPlan copyWith({
    String? id,
    String? originalContentId,
    RepostStrategy? strategy,
    String? modifiedCaption,
    List<String>? modifiedHashtags,
    DateTime? plannedAt,
    bool? isExecuted,
    String? newContentId,
    String? notes,
    DateTime? createdAt,
    bool clearModifiedCaption = false,
    bool clearModifiedHashtags = false,
    bool clearNewContentId = false,
    bool clearNotes = false,
  }) {
    return RepostPlan(
      id: id ?? this.id,
      originalContentId: originalContentId ?? this.originalContentId,
      strategy: strategy ?? this.strategy,
      modifiedCaption: clearModifiedCaption
          ? null
          : (modifiedCaption ?? this.modifiedCaption),
      modifiedHashtags: clearModifiedHashtags
          ? null
          : (modifiedHashtags ?? this.modifiedHashtags),
      plannedAt: plannedAt ?? this.plannedAt,
      isExecuted: isExecuted ?? this.isExecuted,
      newContentId:
          clearNewContentId ? null : (newContentId ?? this.newContentId),
      notes: clearNotes ? null : (notes ?? this.notes),
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RepostPlan &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
