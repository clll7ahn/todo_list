import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/content.dart';
import '../models/enums.dart';
import '../providers/content_provider.dart';
import '../widgets/hashtag_chip.dart';

/// 콘텐츠 상세 보기 화면
class ContentDetailScreen extends StatelessWidget {
  final String contentId;

  const ContentDetailScreen({super.key, required this.contentId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Consumer<ContentProvider>(
      builder: (context, provider, _) {
        final content = provider.getContentById(contentId);

        if (content == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('콘텐츠')),
            body: const Center(child: Text('콘텐츠를 찾을 수 없습니다')),
          );
        }

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // 앱바 + 이미지 캐러셀
              SliverAppBar(
                expandedHeight: content.imagePaths.isNotEmpty ? 300 : 0,
                pinned: true,
                title: Text(content.title),
                flexibleSpace: content.imagePaths.isNotEmpty
                    ? FlexibleSpaceBar(
                        background: _buildImageViewer(context, content),
                      )
                    : null,
                actions: [
                  IconButton(
                    icon: Icon(
                      content.isFavorite ? Icons.star : Icons.star_border,
                      color: content.isFavorite ? Colors.amber : null,
                    ),
                    onPressed: () => provider.toggleFavorite(contentId),
                  ),
                ],
              ),

              // 콘텐츠 정보
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 유형 & 상태 배지
                      Row(
                        children: [
                          _buildTypeBadge(theme, content.contentType),
                          const SizedBox(width: 8),
                          _buildStatusBadge(theme, content.status),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // 제목
                      Text(
                        content.title,
                        style: theme.textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 16),

                      // 캡션
                      if (content.caption.isNotEmpty) ...[
                        Text('캡션', style: theme.textTheme.titleSmall),
                        const SizedBox(height: 8),
                        _buildCaptionText(theme, content.caption),
                        const SizedBox(height: 16),
                      ],

                      // 해시태그
                      if (content.hashtags.isNotEmpty) ...[
                        Text('해시태그', style: theme.textTheme.titleSmall),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: content.hashtags
                              .map((tag) => HashtagChip(hashtag: tag))
                              .toList(),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // 멘션 & 위치
                      if (content.mentions.isNotEmpty) ...[
                        _buildInfoRow(
                          theme,
                          Icons.alternate_email,
                          '멘션',
                          content.mentions.join(', '),
                        ),
                        const SizedBox(height: 8),
                      ],
                      if (content.location != null &&
                          content.location!.isNotEmpty) ...[
                        _buildInfoRow(
                          theme,
                          Icons.location_on,
                          '위치',
                          content.location!,
                        ),
                        const SizedBox(height: 8),
                      ],

                      // 스케줄 정보
                      if (content.scheduledAt != null) ...[
                        const Divider(height: 32),
                        Text('예약 정보', style: theme.textTheme.titleSmall),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          theme,
                          Icons.schedule,
                          '예약 시간',
                          DateFormat('yyyy.MM.dd HH:mm')
                              .format(content.scheduledAt!),
                        ),
                        const SizedBox(height: 8),
                      ],

                      // 게시 정보
                      if (content.postedAt != null) ...[
                        const Divider(height: 32),
                        Text('게시 정보', style: theme.textTheme.titleSmall),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          theme,
                          Icons.publish,
                          '게시 시간',
                          DateFormat('yyyy.MM.dd HH:mm')
                              .format(content.postedAt!),
                        ),
                        if (content.instagramPermalink != null) ...[
                          const SizedBox(height: 4),
                          _buildInfoRow(
                            theme,
                            Icons.link,
                            '링크',
                            content.instagramPermalink!,
                          ),
                        ],
                        const SizedBox(height: 8),
                      ],

                      // 내부 메모
                      if (content.notes.isNotEmpty) ...[
                        const Divider(height: 32),
                        Text('내부 메모', style: theme.textTheme.titleSmall),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            content.notes,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      // 날짜 정보
                      Text(
                        '생성: ${DateFormat('yyyy.MM.dd HH:mm').format(content.createdAt)}',
                        style: theme.textTheme.labelSmall,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '수정: ${DateFormat('yyyy.MM.dd HH:mm').format(content.updatedAt)}',
                        style: theme.textTheme.labelSmall,
                      ),

                      const SizedBox(height: 32),

                      // 액션 버튼 행
                      _buildActionButtons(context, content, provider),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 이미지 뷰어 (캐러셀 지원)
  Widget _buildImageViewer(BuildContext context, Content content) {
    if (content.imagePaths.length == 1) {
      return Image.file(
        File(content.imagePaths.first),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildImagePlaceholder(context),
      );
    }

    return PageView.builder(
      itemCount: content.imagePaths.length,
      itemBuilder: (context, index) {
        return Stack(
          fit: StackFit.expand,
          children: [
            Image.file(
              File(content.imagePaths[index]),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _buildImagePlaceholder(context),
            ),
            // 페이지 인디케이터
            Positioned(
              bottom: 16,
              right: 16,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${index + 1}/${content.imagePaths.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildImagePlaceholder(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.image,
        size: 64,
        color: Theme.of(context).colorScheme.onSurfaceVariant.withAlpha(100),
      ),
    );
  }

  /// 유형 배지
  Widget _buildTypeBadge(ThemeData theme, ContentType type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(type.icon, size: 14, color: theme.colorScheme.onPrimaryContainer),
          const SizedBox(width: 4),
          Text(
            type.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  /// 상태 배지
  Widget _buildStatusBadge(ThemeData theme, ContentStatus status) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(80), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

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

  /// 캡션 텍스트 (해시태그 하이라이팅)
  Widget _buildCaptionText(ThemeData theme, String caption) {
    final spans = <TextSpan>[];
    final regex = RegExp(r'(#\w+)');
    int lastEnd = 0;

    for (final match in regex.allMatches(caption)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(
          text: caption.substring(lastEnd, match.start),
          style: theme.textTheme.bodyLarge,
        ));
      }
      spans.add(TextSpan(
        text: match.group(0),
        style: theme.textTheme.labelLarge,
      ));
      lastEnd = match.end;
    }
    if (lastEnd < caption.length) {
      spans.add(TextSpan(
        text: caption.substring(lastEnd),
        style: theme.textTheme.bodyLarge,
      ));
    }

    return RichText(text: TextSpan(children: spans));
  }

  /// 정보 행
  Widget _buildInfoRow(
    ThemeData theme,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodySmall,
          ),
        ),
      ],
    );
  }

  /// 액션 버튼들
  Widget _buildActionButtons(
    BuildContext context,
    Content content,
    ContentProvider provider,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        // 편집
        FilledButton.icon(
          icon: const Icon(Icons.edit, size: 18),
          label: const Text('편집'),
          onPressed: () =>
              context.push('/content/edit/${content.id}'),
        ),
        // 스케줄
        OutlinedButton.icon(
          icon: const Icon(Icons.schedule, size: 18),
          label: const Text('스케줄'),
          onPressed: () =>
              context.push('/schedule/add?contentId=${content.id}'),
        ),
        // 성과 입력
        OutlinedButton.icon(
          icon: const Icon(Icons.bar_chart, size: 18),
          label: const Text('성과 입력'),
          onPressed: () =>
              context.push('/analytics/input?contentId=${content.id}'),
        ),
        // 재등록
        OutlinedButton.icon(
          icon: const Icon(Icons.repeat, size: 18),
          label: const Text('재등록'),
          onPressed: () =>
              context.push('/content/repost/${content.id}'),
        ),
        // 삭제
        OutlinedButton.icon(
          icon: Icon(Icons.delete_outline,
              size: 18, color: Theme.of(context).colorScheme.error),
          label: Text(
            '삭제',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          style: OutlinedButton.styleFrom(
            side: BorderSide(
                color: Theme.of(context).colorScheme.error.withAlpha(120)),
          ),
          onPressed: () => _confirmDelete(context, content, provider),
        ),
      ],
    );
  }

  /// 삭제 확인 다이얼로그
  void _confirmDelete(
    BuildContext context,
    Content content,
    ContentProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('콘텐츠 삭제'),
          content: Text('"${content.title}"을(를) 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('취소'),
            ),
            FilledButton(
              onPressed: () {
                provider.deleteContent(content.id);
                Navigator.pop(ctx);
                context.pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('"${content.title}" 삭제됨')),
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('삭제'),
            ),
          ],
        );
      },
    );
  }
}
