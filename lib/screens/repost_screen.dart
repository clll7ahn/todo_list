import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/content.dart';
import '../models/enums.dart';
import '../models/repost_plan.dart';
import '../providers/analytics_provider.dart';
import '../providers/content_provider.dart';
import '../providers/repost_provider.dart';
import '../widgets/content_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/performance_badge.dart';

/// 리포스트 관리 화면
class RepostScreen extends StatefulWidget {
  const RepostScreen({super.key});

  @override
  State<RepostScreen> createState() => _RepostScreenState();
}

class _RepostScreenState extends State<RepostScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('재등록 관리'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '추천'),
            Tab(text: '진행중'),
            Tab(text: '완료'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRecommendTab(theme),
          _buildPendingTab(theme),
          _buildCompletedTab(theme),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/repost/add'),
        child: const Icon(Icons.add),
      ),
    );
  }

  // ============ 추천 탭 ============

  Widget _buildRecommendTab(ThemeData theme) {
    return Consumer2<AnalyticsProvider, ContentProvider>(
      builder: (context, analyticsProvider, contentProvider, _) {
        final candidateIds = analyticsProvider.repostCandidateContentIds;
        final candidates = <Content>[];
        for (final id in candidateIds) {
          final content = contentProvider.getContentById(id);
          if (content != null) {
            candidates.add(content);
          }
        }

        if (candidates.isEmpty) {
          return const EmptyState(
            icon: Icons.auto_awesome,
            title: '아직 성과 데이터가 없어요',
            subtitle: '콘텐츠를 게시하고 성과를 기록하면\n재등록 추천을 받을 수 있어요',
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 헤더
            Text(
              '재등록 추천 콘텐츠',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 4),
            Text(
              '높은 성과를 기록한 콘텐츠를 재등록하여 더 많은 도달을 얻어보세요',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            // 추천 목록
            ...candidates.map((content) {
              final record =
                  analyticsProvider.getRecordByContentId(content.id);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildRecommendItem(theme, content, record),
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildRecommendItem(
    ThemeData theme,
    Content content,
    dynamic record,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 콘텐츠 카드 영역
            Row(
              children: [
                // 썸네일
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: 64,
                    height: 64,
                    child: content.imagePaths.isNotEmpty
                        ? Image.file(
                            File(content.imagePaths.first),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _buildPlaceholder(theme, content),
                          )
                        : _buildPlaceholder(theme, content),
                  ),
                ),
                const SizedBox(width: 12),
                // 정보
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        content.title,
                        style: theme.textTheme.titleSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      if (content.caption.isNotEmpty)
                        Text(
                          content.caption,
                          style: theme.textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            content.contentType.icon,
                            size: 14,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            content.contentType.label,
                            style: theme.textTheme.labelSmall,
                          ),
                          if (record != null) ...[
                            const SizedBox(width: 8),
                            PerformanceBadge(grade: record.grade),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // 성과 요약
            if (record != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildMiniStat(
                      theme, Icons.favorite, '${record.likes}'),
                  const SizedBox(width: 16),
                  _buildMiniStat(
                      theme, Icons.comment, '${record.comments}'),
                  const SizedBox(width: 16),
                  _buildMiniStat(
                      theme, Icons.visibility, '${record.reach}'),
                  const SizedBox(width: 16),
                  _buildMiniStat(
                    theme,
                    Icons.trending_up,
                    '${record.engagementRate.toStringAsFixed(1)}%',
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            // 재등록 버튼
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: const Icon(Icons.repeat, size: 18),
                label: const Text('재등록 계획'),
                onPressed: () =>
                    context.push('/repost/add?contentId=${content.id}'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(ThemeData theme, IconData icon, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          value,
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder(ThemeData theme, Content content) {
    return Container(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          content.contentType.icon,
          size: 28,
          color: theme.colorScheme.onSurfaceVariant.withAlpha(120),
        ),
      ),
    );
  }

  // ============ 진행중 탭 ============

  Widget _buildPendingTab(ThemeData theme) {
    return Consumer2<RepostProvider, ContentProvider>(
      builder: (context, repostProvider, contentProvider, _) {
        final plans = repostProvider.pendingPlans;

        if (plans.isEmpty) {
          return EmptyState(
            icon: Icons.pending_actions,
            title: '진행중인 재등록 계획이 없어요',
            subtitle: '추천 탭에서 콘텐츠를 선택하거나\n새 계획을 만들어보세요',
            actionLabel: '새 계획 만들기',
            onAction: () => context.push('/repost/add'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: plans.length,
          itemBuilder: (context, index) {
            final plan = plans[index];
            return _buildPendingPlanItem(
                theme, plan, contentProvider, repostProvider);
          },
        );
      },
    );
  }

  Widget _buildPendingPlanItem(
    ThemeData theme,
    RepostPlan plan,
    ContentProvider contentProvider,
    RepostProvider repostProvider,
  ) {
    final originalContent =
        contentProvider.getContentById(plan.originalContentId);

    return Dismissible(
      key: Key(plan.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        color: theme.colorScheme.error,
        child: Icon(Icons.delete, color: theme.colorScheme.onError),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('계획 삭제'),
            content: const Text('이 재등록 계획을 삭제하시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('취소'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,
                ),
                child: const Text('삭제'),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) {
        repostProvider.deletePlan(plan.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('재등록 계획이 삭제되었습니다')),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: InkWell(
          onTap: () => context.push('/repost/edit/${plan.id}'),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // 원본 콘텐츠 썸네일
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: 56,
                    height: 56,
                    child: originalContent != null &&
                            originalContent.imagePaths.isNotEmpty
                        ? Image.file(
                            File(originalContent.imagePaths.first),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _buildSmallPlaceholder(theme),
                          )
                        : _buildSmallPlaceholder(theme),
                  ),
                ),
                const SizedBox(width: 12),
                // 정보
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        originalContent?.title ?? '삭제된 콘텐츠',
                        style: theme.textTheme.titleSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _buildStrategyBadge(theme, plan.strategy),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.schedule,
                            size: 14,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('MM.dd (E)', 'ko_KR')
                                .format(plan.plannedAt),
                            style: theme.textTheme.labelSmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSmallPlaceholder(ThemeData theme) {
    return Container(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.image,
          size: 24,
          color: theme.colorScheme.onSurfaceVariant.withAlpha(120),
        ),
      ),
    );
  }

  Widget _buildStrategyBadge(ThemeData theme, RepostStrategy strategy) {
    final Color color;
    switch (strategy) {
      case RepostStrategy.exact:
        color = const Color(0xFF1976D2);
      case RepostStrategy.modified:
        color = const Color(0xFFF57C00);
      case RepostStrategy.remixed:
        color = const Color(0xFF833AB4);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withAlpha(80), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(strategy.icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            strategy.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ============ 완료 탭 ============

  Widget _buildCompletedTab(ThemeData theme) {
    return Consumer3<RepostProvider, ContentProvider, AnalyticsProvider>(
      builder: (context, repostProvider, contentProvider, analyticsProvider, _) {
        final plans = repostProvider.executedPlans;

        if (plans.isEmpty) {
          return const EmptyState(
            icon: Icons.check_circle_outline,
            title: '완료된 재등록이 없어요',
            subtitle: '진행중인 계획을 실행하면\n여기에 표시됩니다',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: plans.length,
          itemBuilder: (context, index) {
            final plan = plans[index];
            return _buildCompletedPlanItem(
              theme,
              plan,
              contentProvider,
              analyticsProvider,
            );
          },
        );
      },
    );
  }

  Widget _buildCompletedPlanItem(
    ThemeData theme,
    RepostPlan plan,
    ContentProvider contentProvider,
    AnalyticsProvider analyticsProvider,
  ) {
    final originalContent =
        contentProvider.getContentById(plan.originalContentId);
    final newContent = plan.newContentId != null
        ? contentProvider.getContentById(plan.newContentId!)
        : null;
    final originalRecord =
        analyticsProvider.getRecordByContentId(plan.originalContentId);
    final newRecord = plan.newContentId != null
        ? analyticsProvider.getRecordByContentId(plan.newContentId!)
        : null;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더: 전략 배지 + 날짜
            Row(
              children: [
                _buildStrategyBadge(theme, plan.strategy),
                const Spacer(),
                Text(
                  DateFormat('yyyy.MM.dd').format(plan.plannedAt),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // 원본 vs 재등록 비교
            Row(
              children: [
                // 원본
                Expanded(
                  child: _buildComparisonCard(
                    theme,
                    '원본',
                    originalContent,
                    originalRecord,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(
                    Icons.arrow_forward,
                    size: 20,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                // 재등록
                Expanded(
                  child: _buildComparisonCard(
                    theme,
                    '재등록',
                    newContent,
                    newRecord,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonCard(
    ThemeData theme,
    String label,
    Content? content,
    dynamic record,
  ) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withAlpha(120),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            content?.title ?? '(삭제됨)',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (record != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.favorite, size: 12,
                    color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 2),
                Text('${record.likes}', style: theme.textTheme.labelSmall),
                const SizedBox(width: 6),
                Icon(Icons.trending_up, size: 12,
                    color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 2),
                Text(
                  '${record.engagementRate.toStringAsFixed(1)}%',
                  style: theme.textTheme.labelSmall,
                ),
              ],
            ),
          ] else ...[
            const SizedBox(height: 4),
            Text(
              '성과 데이터 없음',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
