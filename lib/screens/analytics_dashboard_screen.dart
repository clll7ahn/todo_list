import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../models/enums.dart';
import '../providers/analytics_provider.dart';
import '../providers/content_provider.dart';
import '../utils/instagram_utils.dart';
import '../widgets/analytics_chart.dart';
import '../widgets/empty_state.dart';
import '../widgets/performance_badge.dart';
import '../widgets/stat_card.dart';

/// 분석 대시보드 화면 (탭 4)
class AnalyticsDashboardScreen extends StatelessWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('분석'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_chart),
            tooltip: '분석 입력',
            onPressed: () => context.push('/analytics/input'),
          ),
        ],
      ),
      body: Consumer<AnalyticsProvider>(
        builder: (context, provider, _) {
          if (provider.allRecords.isEmpty) {
            return EmptyState(
              icon: Icons.analytics_outlined,
              title: '분석 데이터가 없습니다',
              subtitle: '콘텐츠의 성과 데이터를 입력해 보세요',
              actionLabel: '데이터 입력',
              onAction: () => context.push('/analytics/input'),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.init(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 기간 선택 탭
                  _buildPeriodTabs(context, provider),
                  const SizedBox(height: 16),

                  // 요약 통계 카드
                  _buildSummaryCards(context, provider),
                  const SizedBox(height: 24),

                  // 참여율 추이 차트
                  _buildSection(
                    context,
                    title: '참여율 추이',
                    child: _buildEngagementChart(provider),
                  ),
                  const SizedBox(height: 24),

                  // 도달/노출 추이 차트
                  _buildSection(
                    context,
                    title: '도달/노출 추이',
                    child: _buildReachChart(provider),
                  ),
                  const SizedBox(height: 8),
                  // 범례
                  _buildReachLegend(context),
                  const SizedBox(height: 24),

                  // 콘텐츠 유형별 성과
                  _buildSection(
                    context,
                    title: '콘텐츠 유형별 성과',
                    child: _buildContentTypePieChart(context, provider),
                  ),
                  const SizedBox(height: 24),

                  // 요일별 성과
                  _buildSection(
                    context,
                    title: '요일별 성과',
                    child: WeekdayPerformanceChart(
                      data: provider.performanceByDayOfWeek,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 최고 성과 시간대
                  _buildSection(
                    context,
                    title: '최고 성과 시간대',
                    child: _buildTimeSlotCards(context, provider),
                  ),
                  const SizedBox(height: 24),

                  // TOP 5 콘텐츠
                  _buildSection(
                    context,
                    title: 'TOP 5 콘텐츠',
                    child: _buildTopContents(context, provider),
                  ),
                  const SizedBox(height: 24),

                  // 재등록 추천
                  _buildSection(
                    context,
                    title: '재등록 추천',
                    child: _buildRepostCandidates(context, provider),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// 기간 선택 탭
  Widget _buildPeriodTabs(BuildContext context, AnalyticsProvider provider) {
    final periods = [
      (AnalyticsPeriod.week, '주간'),
      (AnalyticsPeriod.month, '월간'),
      (AnalyticsPeriod.quarter, '분기'),
      (AnalyticsPeriod.year, '연간'),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: periods.map((entry) {
          final isSelected = provider.currentPeriod == entry.$1;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(entry.$2),
              selected: isSelected,
              onSelected: (_) => provider.setPeriod(entry.$1),
              selectedColor: AppTheme.instagramPurple.withValues(alpha: 0.15),
              checkmarkColor: AppTheme.instagramPurple,
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 요약 통계 카드 4개
  Widget _buildSummaryCards(
      BuildContext context, AnalyticsProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: StatCard(
                  icon: Icons.article,
                  label: '총 게시물',
                  value: '${provider.allRecords.length}',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatCard(
                  icon: Icons.favorite,
                  label: '평균 좋아요',
                  value: InstagramUtils.formatFollowerCount(
                      provider.averageLikes.round()),
                  color: AppTheme.instagramPink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  icon: Icons.trending_up,
                  label: '평균 참여율',
                  value: InstagramUtils.formatEngagementRate(
                      provider.averageEngagementRate),
                  color: AppTheme.instagramPurple,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatCard(
                  icon: Icons.visibility,
                  label: '총 도달',
                  value: InstagramUtils.formatFollowerCount(
                      provider.totalReach),
                  color: const Color(0xFF1976D2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 섹션 래퍼
  Widget _buildSection(
    BuildContext context, {
    required String title,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  /// 참여율 추이 차트
  Widget _buildEngagementChart(AnalyticsProvider provider) {
    final days = _getDaysForPeriod(provider.currentPeriod);
    final data = provider.engagementTrend(days);
    final labels = _generateDateLabels(days);

    return EngagementLineChart(
      dataPoints: data,
      labels: labels,
    );
  }

  /// 도달/노출 추이 차트
  Widget _buildReachChart(AnalyticsProvider provider) {
    final days = _getDaysForPeriod(provider.currentPeriod);
    final reachData = provider.reachTrend(days);
    final labels = _generateDateLabels(days);

    // 노출 데이터: 도달 기반으로 레코드에서 추출
    final now = DateTime.now();
    final impressionsData = <int>[];
    for (int i = days - 1; i >= 0; i--) {
      final date = DateTime(now.year, now.month, now.day - i);
      final nextDate = date.add(const Duration(days: 1));
      final dayRecords = provider.allRecords.where((r) =>
          !r.recordedAt.isBefore(date) && r.recordedAt.isBefore(nextDate));
      final totalImpressions =
          dayRecords.fold<int>(0, (sum, r) => sum + r.impressions);
      impressionsData.add(totalImpressions);
    }

    return ReachBarChart(
      reach: reachData,
      impressions: impressionsData,
      labels: labels,
    );
  }

  /// 도달/노출 범례
  Widget _buildReachLegend(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: const Color(0xFF1976D2),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 4),
          Text('도달', style: theme.textTheme.bodySmall),
          const SizedBox(width: 16),
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: AppTheme.instagramPurple,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 4),
          Text('노출', style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }

  /// 콘텐츠 유형별 파이 차트
  Widget _buildContentTypePieChart(
      BuildContext context, AnalyticsProvider provider) {
    // ContentProvider에서 콘텐츠 유형 정보를 가져와서 결합
    final contentProvider =
        Provider.of<ContentProvider>(context, listen: false);
    final Map<String, double> data = {};

    for (final record in provider.allRecords) {
      final content = contentProvider.getContentById(record.contentId);
      final label = content?.contentType.label ?? '기타';
      data[label] = (data[label] ?? 0) + record.engagementRate;
    }

    return ContentTypePieChart(data: data);
  }

  /// 시간대별 성과 카드
  Widget _buildTimeSlotCards(
      BuildContext context, AnalyticsProvider provider) {
    final theme = Theme.of(context);
    final timeSlotData = provider.performanceByTimeSlot;

    // 최고 성과 시간대 찾기
    PostTimeSlot? bestSlot;
    double bestRate = 0;
    timeSlotData.forEach((slot, rate) {
      if (rate > bestRate) {
        bestRate = rate;
        bestSlot = slot;
      }
    });

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: PostTimeSlot.values.map((slot) {
        final rate = timeSlotData[slot] ?? 0.0;
        final isBest = slot == bestSlot && bestRate > 0;

        return Container(
          width: (MediaQuery.of(context).size.width - 48) / 2,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isBest
                ? AppTheme.instagramPurple.withValues(alpha: 0.08)
                : theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
            border: isBest
                ? Border.all(
                    color: AppTheme.instagramPurple.withValues(alpha: 0.3),
                    width: 1.5,
                  )
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    slot.icon,
                    size: 18,
                    color: isBest
                        ? AppTheme.instagramPurple
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    slot.label,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: isBest
                          ? AppTheme.instagramPurple
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  if (isBest) ...[
                    const Spacer(),
                    Icon(
                      Icons.star,
                      size: 16,
                      color: const Color(0xFFFFB300),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Text(
                InstagramUtils.formatEngagementRate(rate),
                style: theme.textTheme.titleLarge?.copyWith(
                  color: isBest
                      ? AppTheme.instagramPurple
                      : theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// TOP 5 콘텐츠 리스트
  Widget _buildTopContents(
      BuildContext context, AnalyticsProvider provider) {
    final theme = Theme.of(context);
    final contentProvider =
        Provider.of<ContentProvider>(context, listen: false);
    final topRecords = provider.topPerformingRecords.take(5).toList();

    if (topRecords.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text(
            '데이터가 없습니다',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return Column(
      children: topRecords.asMap().entries.map((entry) {
        final index = entry.key;
        final record = entry.value;
        final content = contentProvider.getContentById(record.contentId);

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => context.push('/analytics/detail/${record.id}'),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // 순위
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: index < 3
                          ? AppTheme.instagramPurple.withValues(alpha: 0.1)
                          : theme.colorScheme.surfaceContainerHighest,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: index < 3
                            ? AppTheme.instagramPurple
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // 콘텐츠 정보
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          content?.title ?? '삭제된 콘텐츠',
                          style: theme.textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '참여율 ${InstagramUtils.formatEngagementRate(record.engagementRate)}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),

                  // 성과 뱃지
                  PerformanceBadge(grade: record.grade),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  /// 재등록 추천 섹션
  Widget _buildRepostCandidates(
      BuildContext context, AnalyticsProvider provider) {
    final theme = Theme.of(context);
    final contentProvider =
        Provider.of<ContentProvider>(context, listen: false);
    final candidateIds = provider.repostCandidateContentIds;

    if (candidateIds.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text(
            '재등록 추천 콘텐츠가 없습니다',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return Column(
      children: candidateIds.take(5).map((contentId) {
        final content = contentProvider.getContentById(contentId);
        final record = provider.getRecordByContentId(contentId);

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: record != null
                ? () => context.push('/analytics/detail/${record.id}')
                : null,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color:
                          const Color(0xFF43A047).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.replay,
                      size: 22,
                      color: Color(0xFF43A047),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          content?.title ?? '삭제된 콘텐츠',
                          style: theme.textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (record != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            '참여율 ${InstagramUtils.formatEngagementRate(record.engagementRate)}',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (record != null)
                    PerformanceBadge(grade: record.grade),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  /// 기간에 따른 일수 반환
  int _getDaysForPeriod(AnalyticsPeriod period) {
    switch (period) {
      case AnalyticsPeriod.week:
        return 7;
      case AnalyticsPeriod.month:
        return 30;
      case AnalyticsPeriod.quarter:
        return 90;
      case AnalyticsPeriod.year:
        return 365;
    }
  }

  /// 날짜 레이블 생성
  List<String> _generateDateLabels(int days) {
    final now = DateTime.now();
    final labels = <String>[];
    for (int i = days - 1; i >= 0; i--) {
      final date = DateTime(now.year, now.month, now.day - i);
      labels.add('${date.month}/${date.day}');
    }
    return labels;
  }
}
