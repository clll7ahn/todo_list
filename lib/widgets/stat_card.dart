import 'package:flutter/material.dart';

/// 트렌드 방향
enum TrendDirection {
  up,
  down,
  neutral,
}

/// 통계 카드 위젯
/// 대시보드 및 요약 섹션에서 사용
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.trend,
    this.trendValue,
    this.color,
    this.onTap,
  });

  /// 카드 아이콘
  final IconData icon;

  /// 통계 레이블 (예: "팔로워", "참여율")
  final String label;

  /// 통계 값 (예: "1.2K", "3.5%")
  final String value;

  /// 트렌드 방향 (선택)
  final TrendDirection? trend;

  /// 트렌드 수치 텍스트 (선택, 예: "+2.3%")
  final String? trendValue;

  /// 커스텀 색상 (선택)
  final Color? color;

  /// 탭 콜백 (선택)
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final effectiveColor = color ?? colorScheme.primary;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // 아이콘 + 트렌드
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: effectiveColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      icon,
                      size: 22,
                      color: effectiveColor,
                    ),
                  ),
                  if (trend != null) _buildTrendIndicator(theme),
                ],
              ),
              const SizedBox(height: 12),

              // 값
              Text(
                value,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),

              // 레이블
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 트렌드 표시기 빌드
  Widget _buildTrendIndicator(ThemeData theme) {
    final Color trendColor;
    final IconData trendIcon;

    switch (trend!) {
      case TrendDirection.up:
        trendColor = const Color(0xFF4CAF50);
        trendIcon = Icons.trending_up;
      case TrendDirection.down:
        trendColor = const Color(0xFFE53935);
        trendIcon = Icons.trending_down;
      case TrendDirection.neutral:
        trendColor = const Color(0xFF9E9E9E);
        trendIcon = Icons.trending_flat;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(trendIcon, size: 16, color: trendColor),
        if (trendValue != null) ...[
          const SizedBox(width: 2),
          Text(
            trendValue!,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: trendColor,
            ),
          ),
        ],
      ],
    );
  }
}
