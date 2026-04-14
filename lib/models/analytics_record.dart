import 'package:uuid/uuid.dart';

import 'enums.dart';

/// 분석 기록 모델
/// 게시된 콘텐츠의 성과 데이터를 기록합니다.
class AnalyticsRecord {
  /// 고유 식별자 (UUID)
  final String id;

  /// 연결된 콘텐츠 ID
  final String contentId;

  /// 기록 일시
  final DateTime recordedAt;

  /// 좋아요 수
  final int likes;

  /// 댓글 수
  final int comments;

  /// 공유 수
  final int shares;

  /// 저장 수
  final int saves;

  /// 도달 수
  final int reach;

  /// 노출 수
  final int impressions;

  /// 프로필 방문 수
  final int profileVisits;

  /// 게시물을 통한 팔로우 수
  final int followsFromPost;

  /// 참여율 (자동 계산)
  final double engagementRate;

  /// 성과 등급
  final PerformanceGrade grade;

  /// 메모 (선택)
  final String? notes;

  /// 생성일
  final DateTime createdAt;

  /// 수정일
  final DateTime updatedAt;

  const AnalyticsRecord({
    required this.id,
    required this.contentId,
    required this.recordedAt,
    this.likes = 0,
    this.comments = 0,
    this.shares = 0,
    this.saves = 0,
    this.reach = 0,
    this.impressions = 0,
    this.profileVisits = 0,
    this.followsFromPost = 0,
    this.engagementRate = 0.0,
    this.grade = PerformanceGrade.average,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  /// JSON에서 AnalyticsRecord 생성
  factory AnalyticsRecord.fromJson(Map<String, dynamic> json) {
    return AnalyticsRecord(
      id: json['id'] as String,
      contentId: json['contentId'] as String,
      recordedAt: DateTime.parse(json['recordedAt'] as String),
      likes: json['likes'] as int? ?? 0,
      comments: json['comments'] as int? ?? 0,
      shares: json['shares'] as int? ?? 0,
      saves: json['saves'] as int? ?? 0,
      reach: json['reach'] as int? ?? 0,
      impressions: json['impressions'] as int? ?? 0,
      profileVisits: json['profileVisits'] as int? ?? 0,
      followsFromPost: json['followsFromPost'] as int? ?? 0,
      engagementRate: (json['engagementRate'] as num?)?.toDouble() ?? 0.0,
      grade: PerformanceGradeExtension.fromValue(
        json['grade'] as String? ?? 'average',
      ),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// AnalyticsRecord를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contentId': contentId,
      'recordedAt': recordedAt.toIso8601String(),
      'likes': likes,
      'comments': comments,
      'shares': shares,
      'saves': saves,
      'reach': reach,
      'impressions': impressions,
      'profileVisits': profileVisits,
      'followsFromPost': followsFromPost,
      'engagementRate': engagementRate,
      'grade': grade.value,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// 복사본 생성 (일부 필드 변경)
  AnalyticsRecord copyWith({
    String? id,
    String? contentId,
    DateTime? recordedAt,
    int? likes,
    int? comments,
    int? shares,
    int? saves,
    int? reach,
    int? impressions,
    int? profileVisits,
    int? followsFromPost,
    double? engagementRate,
    PerformanceGrade? grade,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearNotes = false,
  }) {
    return AnalyticsRecord(
      id: id ?? this.id,
      contentId: contentId ?? this.contentId,
      recordedAt: recordedAt ?? this.recordedAt,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      shares: shares ?? this.shares,
      saves: saves ?? this.saves,
      reach: reach ?? this.reach,
      impressions: impressions ?? this.impressions,
      profileVisits: profileVisits ?? this.profileVisits,
      followsFromPost: followsFromPost ?? this.followsFromPost,
      engagementRate: engagementRate ?? this.engagementRate,
      grade: grade ?? this.grade,
      notes: clearNotes ? null : (notes ?? this.notes),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 참여율 계산
  /// (좋아요 + 댓글 + 공유 + 저장) / 도달 수 * 100
  static double calculateEngagementRate(
    int likes,
    int comments,
    int shares,
    int saves,
    int reach,
  ) {
    if (reach == 0) return 0.0;
    return (likes + comments + shares + saves) / reach * 100;
  }

  /// 참여율 기반 성과 등급 산정
  /// - 10% 이상: 매우 우수
  /// - 5% 이상: 우수
  /// - 2% 이상: 보통
  /// - 2% 미만: 미흡
  static PerformanceGrade calculateGrade(double engagementRate) {
    if (engagementRate >= 10.0) return PerformanceGrade.excellent;
    if (engagementRate >= 5.0) return PerformanceGrade.good;
    if (engagementRate >= 2.0) return PerformanceGrade.average;
    return PerformanceGrade.poor;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnalyticsRecord &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
