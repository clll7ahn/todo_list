import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/enums.dart';
import '../providers/category_provider.dart';
import '../providers/todo_provider.dart';

/// 통계/대시보드 화면
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final todoProvider = context.watch<TodoProvider>();
    final categoryProvider = context.watch<CategoryProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('통계')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 요약 카드
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: '전체',
                    value: '${todoProvider.totalCount}',
                    icon: Icons.list_alt,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: '완료',
                    value: '${todoProvider.completedCount}',
                    icon: Icons.check_circle,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: '진행중',
                    value: '${todoProvider.pendingCount}',
                    icon: Icons.pending_actions,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 완료율 원형 차트
            Text('전체 완료율', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 160,
                      height: 160,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 50,
                          sections: [
                            PieChartSectionData(
                              value: todoProvider.completedCount.toDouble(),
                              color: theme.colorScheme.primary,
                              radius: 25,
                              showTitle: false,
                            ),
                            PieChartSectionData(
                              value: todoProvider.pendingCount.toDouble() == 0 &&
                                      todoProvider.completedCount == 0
                                  ? 1
                                  : todoProvider.pendingCount.toDouble(),
                              color: theme.colorScheme.surfaceContainerHigh,
                              radius: 25,
                              showTitle: false,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Text(
                      '${(todoProvider.completionRate * 100).toInt()}%',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 오늘 통계
            Text('오늘', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: '오늘 완료',
                    value: '${todoProvider.todayCompletedCount}',
                    icon: Icons.done_all,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: '오늘 마감',
                    value: '${todoProvider.todayDueCount}',
                    icon: Icons.alarm,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 주간 완료 추이
            Text('주간 완료 추이', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: _WeeklyChart(data: todoProvider.weeklyCompletionTrend),
            ),
            const SizedBox(height: 24),

            // 우선순위별 분포
            Text('우선순위별 할일', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            ...Priority.values.map((p) {
              final count = todoProvider.todoCountByPriority[p] ?? 0;
              final barColor = switch (p) {
                Priority.high => const Color(0xFFE53935),
                Priority.medium => const Color(0xFFFB8C00),
                Priority.low => const Color(0xFF43A047),
              };
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    SizedBox(width: 48, child: Text(p.label)),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: todoProvider.pendingCount > 0
                            ? count / todoProvider.pendingCount
                            : 0,
                        backgroundColor: theme.colorScheme.surfaceContainerHigh,
                        color: barColor,
                        borderRadius: BorderRadius.circular(4),
                        minHeight: 12,
                      ),
                    ),
                    SizedBox(
                      width: 32,
                      child: Text(
                        '$count',
                        textAlign: TextAlign.right,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 24),

            // 카테고리별 분포
            Text('카테고리별 할일', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            ...todoProvider.todoCountByCategory.entries.map((entry) {
              final cat = categoryProvider.getCategoryById(entry.key);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    if (cat != null)
                      Icon(
                        IconData(cat.icon, fontFamily: 'MaterialIcons'),
                        color: Color(cat.color),
                        size: 18,
                      )
                    else
                      const Icon(Icons.label, size: 18),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 64,
                      child: Text(cat?.name ?? '미분류'),
                    ),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: todoProvider.pendingCount > 0
                            ? entry.value / todoProvider.pendingCount
                            : 0,
                        backgroundColor: theme.colorScheme.surfaceContainerHigh,
                        color: cat != null
                            ? Color(cat.color)
                            : theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(4),
                        minHeight: 12,
                      ),
                    ),
                    SizedBox(
                      width: 32,
                      child: Text(
                        '${entry.value}',
                        textAlign: TextAlign.right,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

/// 통계 카드 위젯
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 주간 완료 추이 막대 차트
class _WeeklyChart extends StatelessWidget {
  final List<int> data;

  const _WeeklyChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final weekdays = List.generate(7, (i) {
      final date = now.subtract(Duration(days: 6 - i));
      const days = ['월', '화', '수', '목', '금', '토', '일'];
      return days[date.weekday - 1];
    });

    final maxY = data.reduce((a, b) => a > b ? a : b).toDouble();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY > 0 ? maxY + 1 : 5,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx >= 0 && idx < weekdays.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      weekdays[idx],
                      style: theme.textTheme.labelSmall,
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(7, (i) {
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: data[i].toDouble(),
                color: theme.colorScheme.primary,
                width: 24,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
