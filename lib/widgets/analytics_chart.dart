import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../config/theme.dart';

/// 참여율 추이 라인 차트
class EngagementLineChart extends StatelessWidget {
  const EngagementLineChart({
    super.key,
    required this.dataPoints,
    required this.labels,
  });

  /// 참여율 데이터 포인트
  final List<double> dataPoints;

  /// X축 날짜 레이블
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (dataPoints.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Text(
            '데이터가 없습니다',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    final maxY = dataPoints.isEmpty
        ? 10.0
        : (dataPoints.reduce((a, b) => a > b ? a : b) * 1.3).clamp(1.0, 100.0);

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxY / 4,
            getDrawingHorizontalLine: (value) => FlLine(
              color: colorScheme.outlineVariant.withValues(alpha: 0.3),
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toStringAsFixed(1)}%',
                    style: theme.textTheme.labelSmall,
                  );
                },
                interval: maxY / 4,
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= labels.length) {
                    return const SizedBox.shrink();
                  }
                  // 레이블이 많으면 간격을 두고 표시
                  if (labels.length > 7 && index % (labels.length ~/ 7) != 0) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      labels[index],
                      style: theme.textTheme.labelSmall,
                    ),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: (dataPoints.length - 1).toDouble(),
          minY: 0,
          maxY: maxY,
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) =>
                  colorScheme.inverseSurface.withValues(alpha: 0.9),
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  return LineTooltipItem(
                    '${spot.y.toStringAsFixed(1)}%',
                    TextStyle(
                      color: colorScheme.onInverseSurface,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  );
                }).toList();
              },
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(
                dataPoints.length,
                (i) => FlSpot(i.toDouble(), dataPoints[i]),
              ),
              isCurved: true,
              preventCurveOverShooting: true,
              color: AppTheme.instagramPurple,
              barWidth: 2.5,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: dataPoints.length <= 14,
                getDotPainter: (spot, percent, barData, index) =>
                    FlDotCirclePainter(
                  radius: 3,
                  color: Colors.white,
                  strokeWidth: 2,
                  strokeColor: AppTheme.instagramPurple,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    AppTheme.instagramPurple.withValues(alpha: 0.3),
                    AppTheme.instagramPurple.withValues(alpha: 0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 도달/노출 막대 차트
class ReachBarChart extends StatelessWidget {
  const ReachBarChart({
    super.key,
    required this.reach,
    required this.impressions,
    required this.labels,
  });

  /// 도달 수 데이터
  final List<int> reach;

  /// 노출 수 데이터
  final List<int> impressions;

  /// X축 레이블
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (reach.isEmpty && impressions.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Text(
            '데이터가 없습니다',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    final allValues = [...reach, ...impressions];
    final maxVal = allValues.isEmpty
        ? 100.0
        : allValues.reduce((a, b) => a > b ? a : b).toDouble() * 1.2;

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxVal,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxVal / 4,
            getDrawingHorizontalLine: (value) => FlLine(
              color: colorScheme.outlineVariant.withValues(alpha: 0.3),
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 48,
                getTitlesWidget: (value, meta) {
                  return Text(
                    _formatNumber(value.toInt()),
                    style: theme.textTheme.labelSmall,
                  );
                },
                interval: maxVal / 4,
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= labels.length) {
                    return const SizedBox.shrink();
                  }
                  if (labels.length > 7 && index % (labels.length ~/ 7) != 0) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      labels[index],
                      style: theme.textTheme.labelSmall,
                    ),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) =>
                  colorScheme.inverseSurface.withValues(alpha: 0.9),
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final label = rodIndex == 0 ? '도달' : '노출';
                return BarTooltipItem(
                  '$label: ${_formatNumber(rod.toY.toInt())}',
                  TextStyle(
                    color: colorScheme.onInverseSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
          barGroups: List.generate(reach.length, (i) {
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: reach[i].toDouble(),
                  color: const Color(0xFF1976D2),
                  width: 8,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                ),
                BarChartRodData(
                  toY: i < impressions.length
                      ? impressions[i].toDouble()
                      : 0,
                  color: AppTheme.instagramPurple,
                  width: 8,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    }
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}

/// 콘텐츠 유형별 분포 파이 차트
class ContentTypePieChart extends StatelessWidget {
  const ContentTypePieChart({
    super.key,
    required this.data,
  });

  /// 유형별 데이터 (레이블 -> 값)
  final Map<String, double> data;

  static const List<Color> _pieColors = [
    AppTheme.instagramPurple,
    AppTheme.instagramPink,
    AppTheme.instagramOrange,
    AppTheme.instagramYellow,
    Color(0xFF1976D2),
    Color(0xFF43A047),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (data.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Text(
            '데이터가 없습니다',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    final total = data.values.fold<double>(0.0, (sum, v) => sum + v);
    final entries = data.entries.toList();

    return SizedBox(
      height: 220,
      child: Row(
        children: [
          // 파이 차트
          Expanded(
            flex: 3,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 36,
                sections: List.generate(entries.length, (i) {
                  final entry = entries[i];
                  final percentage =
                      total > 0 ? (entry.value / total * 100) : 0.0;
                  return PieChartSectionData(
                    color: _pieColors[i % _pieColors.length],
                    value: entry.value,
                    title: '${percentage.toStringAsFixed(0)}%',
                    titleStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    radius: 50,
                  );
                }),
              ),
            ),
          ),
          // 범례
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(entries.length, (i) {
                final entry = entries[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: _pieColors[i % _pieColors.length],
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          entry.key,
                          style: theme.textTheme.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

/// 요일별 성과 막대 차트
class WeekdayPerformanceChart extends StatelessWidget {
  const WeekdayPerformanceChart({
    super.key,
    required this.data,
  });

  /// 요일별 데이터 (0=월 ~ 6=일 -> 참여율)
  final Map<int, double> data;

  static const List<String> _weekdayLabels = [
    '월',
    '화',
    '수',
    '목',
    '금',
    '토',
    '일',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (data.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Text(
            '데이터가 없습니다',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    final maxVal = data.values.isEmpty
        ? 10.0
        : data.values.reduce((a, b) => a > b ? a : b) * 1.3;
    final effectiveMax = maxVal.clamp(1.0, 100.0);

    // 최고 성과 요일 찾기
    int bestDay = 0;
    double bestVal = 0;
    data.forEach((day, val) {
      if (val > bestVal) {
        bestVal = val;
        bestDay = day;
      }
    });

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: effectiveMax,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: effectiveMax / 4,
            getDrawingHorizontalLine: (value) => FlLine(
              color: colorScheme.outlineVariant.withValues(alpha: 0.3),
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toStringAsFixed(1)}%',
                    style: theme.textTheme.labelSmall,
                  );
                },
                interval: effectiveMax / 4,
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= _weekdayLabels.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _weekdayLabels[index],
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: index == bestDay
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: index == bestDay
                            ? AppTheme.instagramPurple
                            : null,
                      ),
                    ),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) =>
                  colorScheme.inverseSurface.withValues(alpha: 0.9),
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final dayLabel = _weekdayLabels[group.x];
                return BarTooltipItem(
                  '$dayLabel: ${rod.toY.toStringAsFixed(1)}%',
                  TextStyle(
                    color: colorScheme.onInverseSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
          barGroups: List.generate(7, (i) {
            final value = data[i] ?? 0.0;
            final isBest = i == bestDay && bestVal > 0;
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: value,
                  gradient: isBest
                      ? const LinearGradient(
                          colors: [
                            AppTheme.instagramPurple,
                            AppTheme.instagramPink,
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        )
                      : null,
                  color: isBest ? null : AppTheme.instagramPurple.withValues(alpha: 0.4),
                  width: 24,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
