import 'dart:io';

import 'package:flutter/material.dart';
import '../models/content.dart';
import '../models/enums.dart';

/// 콘텐츠 카드 위젯
/// 그리드/리스트 모드 지원
class ContentCard extends StatelessWidget {
  const ContentCard({
    super.key,
    required this.content,
    this.isGridMode = false,
    this.onTap,
  });

  /// 표시할 콘텐츠
  final Content content;

  /// 그리드 모드 여부 (false면 리스트 모드)
  final bool isGridMode;

  /// 탭 콜백
  final VoidCallback? onTap;

  /// 상태별 색상
  Color _statusColor(ContentStatus status) {
    switch (status) {
      case ContentStatus.draft:
        return const Color(0xFF9E9E9E);
      case ContentStatus.ready:
        return const Color(0xFF43A047);
      case ContentStatus.scheduled:
        return const Color(0xFF1976D2);
      case ContentStatus.posted:
        return const Color(0xFF833AB4);
      case ContentStatus.archived:
        return const Color(0xFF795548);
    }
  }

  @override
  Widget build(BuildContext context) {
    return isGridMode ? _buildGridCard(context) : _buildListCard(context);
  }

  /// 그리드 모드 카드
  Widget _buildGridCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 썸네일 영역
            Expanded(
              flex: 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // 썸네일 이미지 또는 플레이스홀더
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: _buildThumbnail(colorScheme),
                  ),
                  // 콘텐츠 유형 아이콘 배지 (좌상단)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        content.contentType.icon,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  // 즐겨찾기 별 (우상단)
                  if (content.isFavorite)
                    const Positioned(
                      top: 8,
                      right: 8,
                      child: Icon(
                        Icons.star,
                        size: 18,
                        color: Colors.amber,
                      ),
                    ),
                ],
              ),
            ),
            // 정보 영역
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 제목
                    Text(
                      content.title,
                      style: theme.textTheme.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // 상태 배지
                    _buildStatusBadge(theme),
                    const Spacer(),
                    // 해시태그 카운트
                    if (content.hashtags.isNotEmpty)
                      Text(
                        '#${content.hashtags.length}',
                        style: theme.textTheme.labelSmall,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 리스트 모드 카드
  Widget _buildListCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // 썸네일
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: _buildThumbnail(colorScheme),
                ),
              ),
              const SizedBox(width: 12),
              // 정보 영역
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 제목 + 즐겨찾기
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            content.title,
                            style: theme.textTheme.titleSmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (content.isFavorite)
                          const Icon(
                            Icons.star,
                            size: 16,
                            color: Colors.amber,
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // 캡션 미리보기
                    if (content.caption.isNotEmpty)
                      Text(
                        content.caption,
                        style: theme.textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 6),
                    // 상태 배지 + 유형 + 해시태그 카운트
                    Row(
                      children: [
                        _buildStatusBadge(theme),
                        const SizedBox(width: 8),
                        Icon(
                          content.contentType.icon,
                          size: 14,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          content.contentType.label,
                          style: theme.textTheme.labelSmall,
                        ),
                        if (content.hashtags.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Icon(
                            Icons.tag,
                            size: 14,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${content.hashtags.length}',
                            style: theme.textTheme.labelSmall,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 썸네일 빌드
  Widget _buildThumbnail(ColorScheme colorScheme) {
    if (content.imagePaths.isNotEmpty) {
      final path = content.imagePaths.first;
      return Image.file(
        File(path),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildPlaceholder(colorScheme),
      );
    }
    return _buildPlaceholder(colorScheme);
  }

  /// 플레이스홀더 아이콘
  Widget _buildPlaceholder(ColorScheme colorScheme) {
    return Container(
      color: colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          content.contentType.icon,
          size: 32,
          color: colorScheme.onSurfaceVariant.withAlpha(120),
        ),
      ),
    );
  }

  /// 상태 배지
  Widget _buildStatusBadge(ThemeData theme) {
    final color = _statusColor(content.status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withAlpha(80), width: 0.5),
      ),
      child: Text(
        content.status.label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
