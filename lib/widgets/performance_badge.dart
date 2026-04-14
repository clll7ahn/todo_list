import 'package:flutter/material.dart';
import '../models/enums.dart';

/// 성과 등급 뱃지 위젯
/// 참여율 등급에 따라 색상, 아이콘, 레이블을 표시합니다.
class PerformanceBadge extends StatelessWidget {
  const PerformanceBadge({
    super.key,
    required this.grade,
    this.isLarge = false,
  });

  /// 성과 등급
  final PerformanceGrade grade;

  /// 큰 모드 (상세 화면용)
  final bool isLarge;

  /// 등급별 색상
  Color get _color {
    switch (grade) {
      case PerformanceGrade.excellent:
        return const Color(0xFFFFB300); // gold
      case PerformanceGrade.good:
        return const Color(0xFF43A047); // green
      case PerformanceGrade.average:
        return const Color(0xFF1976D2); // blue
      case PerformanceGrade.poor:
        return const Color(0xFFE53935); // red
    }
  }

  /// 등급별 아이콘
  IconData get _icon {
    switch (grade) {
      case PerformanceGrade.excellent:
        return Icons.star;
      case PerformanceGrade.good:
        return Icons.thumb_up;
      case PerformanceGrade.average:
        return Icons.remove;
      case PerformanceGrade.poor:
        return Icons.arrow_downward;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLarge) {
      return _buildLarge(context);
    }
    return _buildCompact(context);
  }

  /// 콤팩트 칩 스타일
  Widget _buildCompact(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 14, color: _color),
          const SizedBox(width: 4),
          Text(
            grade.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _color,
            ),
          ),
        ],
      ),
    );
  }

  /// 큰 모드 (상세 화면)
  Widget _buildLarge(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _color.withValues(alpha: 0.15),
            _color.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _color.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(_icon, size: 24, color: _color),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '성과 등급',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                grade.label,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
