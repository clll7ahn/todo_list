import 'package:uuid/uuid.dart';

import 'enums.dart';

/// 콘텐츠 템플릿 모델
/// 재사용 가능한 게시물 템플릿을 나타냅니다.
/// captionTemplate에 {title}, {date} 등의 플레이스홀더를 사용할 수 있습니다.
class ContentTemplate {
  /// 고유 식별자 (UUID)
  final String id;

  /// 템플릿 이름
  final String name;

  /// 템플릿 설명
  final String description;

  /// 콘텐츠 유형
  final ContentType contentType;

  /// 캡션 템플릿 ({title}, {date} 등 플레이스홀더 포함)
  final String captionTemplate;

  /// 기본 해시태그 목록
  final List<String> defaultHashtags;

  /// 해시태그 그룹 ID (선택)
  final String? hashtagGroupId;

  /// 색상 값 (Color.value)
  final int color;

  /// 아이콘 코드포인트 (IconData.codePoint)
  final int icon;

  /// 생성일
  final DateTime createdAt;

  /// 사용 횟수
  final int usageCount;

  const ContentTemplate({
    required this.id,
    required this.name,
    this.description = '',
    this.contentType = ContentType.image,
    this.captionTemplate = '',
    this.defaultHashtags = const [],
    this.hashtagGroupId,
    required this.color,
    required this.icon,
    required this.createdAt,
    this.usageCount = 0,
  });

  /// JSON에서 ContentTemplate 생성
  factory ContentTemplate.fromJson(Map<String, dynamic> json) {
    return ContentTemplate(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      contentType: ContentTypeExtension.fromValue(
        json['contentType'] as String? ?? 'image',
      ),
      captionTemplate: json['captionTemplate'] as String? ?? '',
      defaultHashtags: (json['defaultHashtags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      hashtagGroupId: json['hashtagGroupId'] as String?,
      color: json['color'] as int,
      icon: json['icon'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      usageCount: json['usageCount'] as int? ?? 0,
    );
  }

  /// ContentTemplate를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'contentType': contentType.value,
      'captionTemplate': captionTemplate,
      'defaultHashtags': defaultHashtags,
      'hashtagGroupId': hashtagGroupId,
      'color': color,
      'icon': icon,
      'createdAt': createdAt.toIso8601String(),
      'usageCount': usageCount,
    };
  }

  /// 복사본 생성 (일부 필드 변경)
  ContentTemplate copyWith({
    String? id,
    String? name,
    String? description,
    ContentType? contentType,
    String? captionTemplate,
    List<String>? defaultHashtags,
    String? hashtagGroupId,
    int? color,
    int? icon,
    DateTime? createdAt,
    int? usageCount,
    bool clearHashtagGroupId = false,
  }) {
    return ContentTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      contentType: contentType ?? this.contentType,
      captionTemplate: captionTemplate ?? this.captionTemplate,
      defaultHashtags: defaultHashtags ?? this.defaultHashtags,
      hashtagGroupId: clearHashtagGroupId
          ? null
          : (hashtagGroupId ?? this.hashtagGroupId),
      color: color ?? this.color,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
      usageCount: usageCount ?? this.usageCount,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContentTemplate &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
