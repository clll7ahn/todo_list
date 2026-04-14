import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/analytics_provider.dart';
import '../providers/content_provider.dart';
import '../models/enums.dart';
import '../utils/instagram_utils.dart';
import '../widgets/performance_badge.dart';
import '../widgets/stat_card.dart';

/// 개별 콘텐츠 분석 상세 화면
class AnalyticsDetailScreen extends StatelessWidget {
  const AnalyticsDetailScreen({
    super.key,
    required this.recordId,
  });

  /// 분석 기록 ID
  final String recordId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Consumer<AnalyticsProvider>(
      builder: (context, analyticsProvider, _) {
        final record = analyticsProvider.getRecordById(recordId);

        if (record == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('분석 상세')),
            body: const Center(
              child: Text('분석 기록을 찾을 수 없습니다'),
            ),
          );
        }

        final contentProvider =
            Provider.of<ContentProvider>(context, listen: false);
        final content = contentProvider.getContentById(record.contentId);
        final isRepostCandidate = record.grade == PerformanceGrade.good ||
            record.grade == PerformanceGrade.excellent;

        return Scaffold(
          appBar: AppBar(
            title: const Text('분석 상세'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                tooltip: '수정',
                onPressed: () => context.push(
                  '/analytics/input',
                  extra: {'recordId': record.id},
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: '삭제',
                onPressed: () => _showDeleteDialog(context, analyticsProvider),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 콘텐츠 미리보기
                if (content != null) _buildContentPreview(context, content),
                const SizedBox(height: 16),

                // 성과 등급 뱃지 (큰 모드)
                Center(
                  child: PerformanceBadge(
                    grade: record.grade,
                    isLarge: true,
                  ),
                ),
                const SizedBox(height: 24),

                // 참여율 하이라이트
                _buildEngagementHighlight(context, record.engagementRate),
                const SizedBox(height: 24),

                // 지표 그리드
                Text('상세 지표', style: theme.textTheme.headlineSmall),
                const SizedBox(height: 12),
                _buildMetricsGrid(context, record),
                const SizedBox(height: 24),

                // 메모 섹션
                if (record.notes != null && record.notes!.isNotEmpty) ...[
                  Text('메모', style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      record.notes!,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // 재등록 추천 버튼
                if (isRepostCandidate)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('재등록 추천 기능은 추후 업데이트 예정입니다'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.replay),
                      label: const Text('재등록 추천'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF43A047),
                        side: const BorderSide(color: Color(0xFF43A047)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),

                // 기록일
                Center(
                  child: Text(
                    '기록일: ${_formatDate(record.recordedAt)}',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 콘텐츠 미리보기
  Widget _buildContentPreview(BuildContext context, dynamic content) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // 이미지 썸네일
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: content.imagePaths.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        content.imagePaths.first,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                          content.contentType.icon,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  : Icon(
                      content.contentType.icon,
                      color: colorScheme.onSurfaceVariant,
                    ),
            ),
            const SizedBox(width: 12),
            // 텍스트 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    content.title,
                    style: theme.textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (content.caption.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      content.caption,
                      style: theme.textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            // 유형 뱃지
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.instagramPurple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                content.contentType.label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.instagramPurple,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 참여율 하이라이트
  Widget _buildEngagementHighlight(BuildContext context, double rate) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.instagramPurple.withValues(alpha: 0.1),
            AppTheme.instagramPink.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.instagramPurple.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Text(
            '참여율',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            InstagramUtils.formatEngagementRate(rate),
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: AppTheme.instagramPurple,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  /// 지표 그리드 (2열 4행)
  Widget _buildMetricsGrid(BuildContext context, dynamic record) {
    final metrics = [
      (Icons.favorite, '좋아요', InstagramUtils.formatFollowerCount(record.likes)),
      (
        Icons.chat_bubble_outline,
        '댓글',
        InstagramUtils.formatFollowerCount(record.comments)
      ),
      (Icons.share, '공유', InstagramUtils.formatFollowerCount(record.shares)),
      (
        Icons.bookmark_border,
        '저장',
        InstagramUtils.formatFollowerCount(record.saves)
      ),
      (
        Icons.visibility,
        '도달',
        InstagramUtils.formatFollowerCount(record.reach)
      ),
      (
        Icons.remove_red_eye_outlined,
        '노출',
        InstagramUtils.formatFollowerCount(record.impressions)
      ),
      (
        Icons.person_outline,
        '프로필 방문',
        InstagramUtils.formatFollowerCount(record.profileVisits)
      ),
      (
        Icons.person_add_outlined,
        '팔로우',
        InstagramUtils.formatFollowerCount(record.followsFromPost)
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.6,
      ),
      itemCount: metrics.length,
      itemBuilder: (context, index) {
        final (icon, label, value) = metrics[index];
        return StatCard(
          icon: icon,
          label: label,
          value: value,
        );
      },
    );
  }

  /// 삭제 확인 다이얼로그
  void _showDeleteDialog(
      BuildContext context, AnalyticsProvider provider) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('분석 기록 삭제'),
        content: const Text('이 분석 기록을 삭제하시겠습니까?\n삭제된 기록은 복구할 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await provider.deleteRecord(recordId);
              if (context.mounted) {
                context.pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('분석 기록이 삭제되었습니다')),
                );
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFE53935),
            ),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }

  /// 날짜 포맷
  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }
}
