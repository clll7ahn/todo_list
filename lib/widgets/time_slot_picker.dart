import 'package:flutter/material.dart';
import '../models/enums.dart';

/// 시간대 선택 위젯
/// 아침/오후/저녁/밤 4가지 시간대 카드를 표시합니다.
class TimeSlotPicker extends StatelessWidget {
  const TimeSlotPicker({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  /// 현재 선택된 시간대
  final PostTimeSlot selected;

  /// 시간대 선택 콜백
  final ValueChanged<PostTimeSlot> onSelected;

  /// 시간대별 아이콘
  IconData _slotIcon(PostTimeSlot slot) {
    switch (slot) {
      case PostTimeSlot.morning:
        return Icons.wb_sunny;
      case PostTimeSlot.afternoon:
        return Icons.wb_cloudy;
      case PostTimeSlot.evening:
        return Icons.wb_twilight;
      case PostTimeSlot.night:
        return Icons.nightlight_round;
    }
  }

  /// 시간대별 시간 범위 텍스트
  String _timeRange(PostTimeSlot slot) {
    switch (slot) {
      case PostTimeSlot.morning:
        return '06:00~12:00';
      case PostTimeSlot.afternoon:
        return '12:00~18:00';
      case PostTimeSlot.evening:
        return '18:00~22:00';
      case PostTimeSlot.night:
        return '22:00~06:00';
    }
  }

  /// 시간대별 색상
  Color _slotColor(PostTimeSlot slot) {
    switch (slot) {
      case PostTimeSlot.morning:
        return const Color(0xFFFFA726); // orange
      case PostTimeSlot.afternoon:
        return const Color(0xFF42A5F5); // blue
      case PostTimeSlot.evening:
        return const Color(0xFFEF5350); // red-orange
      case PostTimeSlot.night:
        return const Color(0xFF5C6BC0); // indigo
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: PostTimeSlot.values.map((slot) {
          final isSelected = slot == selected;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _TimeSlotCard(
              slot: slot,
              icon: _slotIcon(slot),
              label: slot.label,
              timeRange: _timeRange(slot),
              color: _slotColor(slot),
              isSelected: isSelected,
              onTap: () => onSelected(slot),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _TimeSlotCard extends StatelessWidget {
  const _TimeSlotCard({
    required this.slot,
    required this.icon,
    required this.label,
    required this.timeRange,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final PostTimeSlot slot;
  final IconData icon;
  final String label;
  final String timeRange;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 90,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withAlpha(30) : colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? color : colorScheme.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 28,
              color: isSelected ? color : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? color : colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              timeRange,
              style: TextStyle(
                fontSize: 9,
                color: isSelected ? color : colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
