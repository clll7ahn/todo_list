import 'package:uuid/uuid.dart';

import 'enums.dart';

/// 해시태그 그룹 모델
/// 해시태그를 카테고리별로 묶어서 관리합니다.
class HashtagGroup {
  /// 고유 식별자 (UUID)
  final String id;

  /// 그룹 이름
  final String name;

  /// 해시태그 목록
  final List<String> hashtags;

  /// 해시태그 카테고리
  final HashtagCategory category;

  /// 색상 값 (Color.value)
  final int color;

  /// 생성일
  final DateTime createdAt;

  /// 수정일
  final DateTime updatedAt;

  /// 사용 횟수
  final int usageCount;

  const HashtagGroup({
    required this.id,
    required this.name,
    this.hashtags = const [],
    this.category = HashtagCategory.general,
    required this.color,
    required this.createdAt,
    required this.updatedAt,
    this.usageCount = 0,
  });

  /// JSON에서 HashtagGroup 생성
  factory HashtagGroup.fromJson(Map<String, dynamic> json) {
    return HashtagGroup(
      id: json['id'] as String,
      name: json['name'] as String,
      hashtags: (json['hashtags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      category: HashtagCategoryExtension.fromValue(
        json['category'] as String? ?? 'general',
      ),
      color: json['color'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      usageCount: json['usageCount'] as int? ?? 0,
    );
  }

  /// HashtagGroup를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'hashtags': hashtags,
      'category': category.value,
      'color': color,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'usageCount': usageCount,
    };
  }

  /// 복사본 생성 (일부 필드 변경)
  HashtagGroup copyWith({
    String? id,
    String? name,
    List<String>? hashtags,
    HashtagCategory? category,
    int? color,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? usageCount,
  }) {
    return HashtagGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      hashtags: hashtags ?? this.hashtags,
      category: category ?? this.category,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      usageCount: usageCount ?? this.usageCount,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HashtagGroup &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
