import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/schedule.dart';
import '../models/enums.dart';
import '../providers/content_provider.dart';
import '../providers/schedule_provider.dart';
import '../utils/date_utils.dart';

/// 스케줄 목록 아이템 위젯
class ScheduleTile extends StatelessWidget {
  const ScheduleTile({
    super.key,
    required this.schedule,
    this.onTap,
    this.showDate = false,
  });

  /// 스케줄 데이터
  final Schedule schedule;

  /// 탭 콜백
  final VoidCallback? onTap;

  /// 날짜 표시 여부 (리스트 뷰에서 사용)
  final bool showDate;

  /// 스케줄 상태 색상
  Color _statusColor(BuildContext context) {
    if (schedule.isCompleted) {
      return const Color(0xFF43A047); // green
    }
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final scheduleDate = DateTime(
      schedule.scheduledAt.year,
      schedule.scheduledAt.month,
      schedule.scheduledAt.day,
    );
    if (scheduleDate.isBefore(today)) {
      return const Color(0xFFE53935); // red - overdue
    }
    return const Color(0xFF1976D2); // blue - upcoming
  }

  String _statusLabel() {
    if (schedule.isCompleted) return '완료';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final scheduleDate = DateTime(
      schedule.scheduledAt.year,
      schedule.scheduledAt.month,
      schedule.scheduledAt.day,
    );
    if (scheduleDate.isBefore(today)) return '지연';
    return '예정';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final statusColor = _statusColor(context);
    final content =
        context.watch<ContentProvider>().getContentById(schedule.contentId);
    final contentTitle = content?.title ?? '삭제된 콘텐츠';
    final contentType = content?.contentType;

    final hour = schedule.scheduledAt.hour.toString().padLeft(2, '0');
    final minute = schedule.scheduledAt.minute.toString().padLeft(2, '0');
    final timeStr = '$hour:$minute';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              // 완료 체크박스
              SizedBox(
                width: 32,
                height: 32,
                child: Checkbox(
                  value: schedule.isCompleted,
                  onChanged: schedule.isCompleted
                      ? null
                      : (_) {
                          context
                              .read<ScheduleProvider>()
                              .markAsCompleted(schedule.id);
                        },
                  shape: const CircleBorder(),
                  activeColor: statusColor,
                ),
              ),
              const SizedBox(width: 8),

              // 시간 표시
              SizedBox(
                width: 48,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      timeStr,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: schedule.isCompleted
                            ? colorScheme.onSurfaceVariant
                            : colorScheme.onSurface,
                        decoration: schedule.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    Text(
                      schedule.timeSlot.label,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // 콘텐츠 타입 아이콘
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  contentType?.icon ?? Icons.help_outline,
                  size: 18,
                  color: statusColor,
                ),
              ),
              const SizedBox(width: 12),

              // 콘텐츠 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      contentTitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: schedule.isCompleted
                            ? colorScheme.onSurfaceVariant
                            : colorScheme.onSurface,
                        decoration: schedule.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        if (showDate) ...[
                          Text(
                            AppDateUtils.formatRelativeDate(
                                schedule.scheduledAt),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        if (schedule.repeatType != ScheduleRepeatType.none) ...[
                          Icon(
                            schedule.repeatType.icon,
                            size: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            schedule.repeatType.label,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        if (schedule.memo != null &&
                            schedule.memo!.isNotEmpty) ...[
                          Icon(
                            Icons.note_outlined,
                            size: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // 상태 배지
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _statusLabel(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
