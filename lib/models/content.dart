import 'package:uuid/uuid.dart';

import 'enums.dart';

/// 인스타그램 콘텐츠 모델
/// 단일 게시물(이미지, 캐러셀, 릴스, 스토리)을 나타냅니다.
class Content {
  /// 고유 식별자 (UUID)
  final String id;

  /// 콘텐츠 제목
  final String title;

  /// 게시물 캡션
  final String caption;

  /// 콘텐츠 유형 (이미지, 캐러셀, 릴스, 스토리)
  final ContentType contentType;

  /// 콘텐츠 상태 (초안, 준비 완료, 예약됨, 게시됨, 보관됨)
  final ContentStatus status;

  /// 이미지 파일 경로 목록
  final List<String> imagePaths;

  /// 해시태그 목록
  final List<String> hashtags;

  /// 해시태그 그룹 ID (선택)
  final String? hashtagGroupId;

  /// 템플릿 ID (선택)
  final String? templateId;

  /// 메모
  final String notes;

  /// 위치 정보 (선택)
  final String? location;

  /// 멘션 목록
  final List<String> mentions;

  /// 생성일
  final DateTime createdAt;

  /// 수정일
  final DateTime updatedAt;

  /// 예약 게시일 (선택)
  final DateTime? scheduledAt;

  /// 실제 게시일 (선택)
  final DateTime? postedAt;

  /// Instagram 미디어 ID (API 게시된 경우)
  final String? instagramMediaId;

  /// Instagram 게시물 퍼머링크 (API 게시된 경우)
  final String? instagramPermalink;

  /// 즐겨찾기 여부
  final bool isFavorite;

  const Content({
    required this.id,
    required this.title,
    this.caption = '',
    this.contentType = ContentType.image,
    this.status = ContentStatus.draft,
    this.imagePaths = const [],
    this.hashtags = const [],
    this.hashtagGroupId,
    this.templateId,
    this.notes = '',
    this.location,
    this.mentions = const [],
    required this.createdAt,
    required this.updatedAt,
    this.scheduledAt,
    this.postedAt,
    this.instagramMediaId,
    this.instagramPermalink,
    this.isFavorite = false,
  });

  /// JSON에서 Content 생성
  factory Content.fromJson(Map<String, dynamic> json) {
    return Content(
      id: json['id'] as String,
      title: json['title'] as String,
      caption: json['caption'] as String? ?? '',
      contentType: ContentTypeExtension.fromValue(
        json['contentType'] as String? ?? 'image',
      ),
      status: ContentStatusExtension.fromValue(
        json['status'] as String? ?? 'draft',
      ),
      imagePaths: (json['imagePaths'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      hashtags: (json['hashtags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      hashtagGroupId: json['hashtagGroupId'] as String?,
      templateId: json['templateId'] as String?,
      notes: json['notes'] as String? ?? '',
      location: json['location'] as String?,
      mentions: (json['mentions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      scheduledAt: json['scheduledAt'] != null
          ? DateTime.parse(json['scheduledAt'] as String)
          : null,
      postedAt: json['postedAt'] != null
          ? DateTime.parse(json['postedAt'] as String)
          : null,
      instagramMediaId: json['instagramMediaId'] as String?,
      instagramPermalink: json['instagramPermalink'] as String?,
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }

  /// Content를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'caption': caption,
      'contentType': contentType.value,
      'status': status.value,
      'imagePaths': imagePaths,
      'hashtags': hashtags,
      'hashtagGroupId': hashtagGroupId,
      'templateId': templateId,
      'notes': notes,
      'location': location,
      'mentions': mentions,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'scheduledAt': scheduledAt?.toIso8601String(),
      'postedAt': postedAt?.toIso8601String(),
      'instagramMediaId': instagramMediaId,
      'instagramPermalink': instagramPermalink,
      'isFavorite': isFavorite,
    };
  }

  /// 복사본 생성 (일부 필드 변경)
  Content copyWith({
    String? id,
    String? title,
    String? caption,
    ContentType? contentType,
    ContentStatus? status,
    List<String>? imagePaths,
    List<String>? hashtags,
    String? hashtagGroupId,
    String? templateId,
    String? notes,
    String? location,
    List<String>? mentions,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? scheduledAt,
    DateTime? postedAt,
    String? instagramMediaId,
    String? instagramPermalink,
    bool? isFavorite,
    bool clearHashtagGroupId = false,
    bool clearTemplateId = false,
    bool clearLocation = false,
    bool clearScheduledAt = false,
    bool clearPostedAt = false,
    bool clearInstagramMediaId = false,
    bool clearInstagramPermalink = false,
  }) {
    return Content(
      id: id ?? this.id,
      title: title ?? this.title,
      caption: caption ?? this.caption,
      contentType: contentType ?? this.contentType,
      status: status ?? this.status,
      imagePaths: imagePaths ?? this.imagePaths,
      hashtags: hashtags ?? this.hashtags,
      hashtagGroupId: clearHashtagGroupId
          ? null
          : (hashtagGroupId ?? this.hashtagGroupId),
      templateId:
          clearTemplateId ? null : (templateId ?? this.templateId),
      notes: notes ?? this.notes,
      location: clearLocation ? null : (location ?? this.location),
      mentions: mentions ?? this.mentions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      scheduledAt:
          clearScheduledAt ? null : (scheduledAt ?? this.scheduledAt),
      postedAt: clearPostedAt ? null : (postedAt ?? this.postedAt),
      instagramMediaId: clearInstagramMediaId
          ? null
          : (instagramMediaId ?? this.instagramMediaId),
      instagramPermalink: clearInstagramPermalink
          ? null
          : (instagramPermalink ?? this.instagramPermalink),
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Content && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
