import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/schedule_provider.dart';
import '../utils/date_utils.dart';
import '../widgets/empty_state.dart';
import '../widgets/schedule_tile.dart';
import '../widgets/stat_card.dart';

/// 스케줄 캘린더 화면 (탭 2)
class ScheduleCalendarScreen extends StatefulWidget {
  const ScheduleCalendarScreen({super.key});

  @override
  State<ScheduleCalendarScreen> createState() => _ScheduleCalendarScreenState();
}

class _ScheduleCalendarScreenState extends State<ScheduleCalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
  }

  void _goToToday() {
    setState(() {
      _focusedDay = DateTime.now();
      _selectedDay = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('스케줄'),
        actions: [
          TextButton.icon(
            onPressed: _goToToday,
            icon: const Icon(Icons.today, size: 18),
            label: const Text('오늘'),
          ),
        ],
      ),
      body: Consumer<ScheduleProvider>(
        builder: (context, provider, _) {
          final selectedSchedules = _selectedDay != null
              ? provider.schedulesByDate(_selectedDay!)
              : <dynamic>[];

          return Column(
            children: [
              // 이번 주 요약 통계
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        icon: Icons.calendar_month,
                        label: '이번 주 예약',
                        value: '${provider.thisWeekScheduledCount}개',
                        color: const Color(0xFF1976D2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: StatCard(
                        icon: Icons.warning_amber_rounded,
                        label: '지연',
                        value: '${provider.overdueSchedules.length}개',
                        color: provider.overdueSchedules.isNotEmpty
                            ? const Color(0xFFE53935)
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: StatCard(
                        icon: Icons.check_circle,
                        label: '완료',
                        value: '${provider.completedSchedules.length}개',
                        color: const Color(0xFF43A047),
                      ),
                    ),
                  ],
                ),
              ),

              // 캘린더 위젯
              TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                locale: 'ko_KR',
                availableCalendarFormats: const {
                  CalendarFormat.month: '월간',
                  CalendarFormat.twoWeeks: '2주',
                  CalendarFormat.week: '주간',
                },
                selectedDayPredicate: (day) {
                  return _selectedDay != null &&
                      AppDateUtils.isSameDay(_selectedDay!, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                onFormatChanged: (format) {
                  setState(() => _calendarFormat = format);
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
                eventLoader: (day) {
                  return provider.schedulesByDate(day);
                },
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: colorScheme.primary.withAlpha(60),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: BoxDecoration(
                    color: colorScheme.tertiary,
                    shape: BoxShape.circle,
                  ),
                  markersMaxCount: 3,
                  markerSize: 6,
                  markerMargin: const EdgeInsets.symmetric(horizontal: 0.5),
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: true,
                  titleCentered: true,
                  titleTextStyle: theme.textTheme.titleMedium!,
                  formatButtonTextStyle: theme.textTheme.labelSmall!,
                  formatButtonDecoration: BoxDecoration(
                    border: Border.all(color: colorScheme.outline),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const Divider(),

              // 선택된 날짜 헤더
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Text(
                      _selectedDay != null
                          ? AppDateUtils.formatDateWithWeekday(_selectedDay!)
                          : '날짜를 선택하세요',
                      style: theme.textTheme.titleSmall,
                    ),
                    const Spacer(),
                    if (_selectedDay != null)
                      TextButton.icon(
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('스케줄 추가'),
                        onPressed: () => context.push('/schedule/add'),
                      ),
                  ],
                ),
              ),

              // 선택된 날짜의 스케줄 리스트
              Expanded(
                child: selectedSchedules.isEmpty
                    ? EmptyState(
                        icon: Icons.event_available,
                        title: '스케줄이 없습니다',
                        subtitle: '이 날짜에 예약된 스케줄이 없습니다',
                        actionLabel: '스케줄 추가',
                        onAction: () => context.push('/schedule/add'),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount: selectedSchedules.length,
                        itemBuilder: (context, index) {
                          final schedule = selectedSchedules[index];
                          return Dismissible(
                            key: ValueKey(schedule.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 24),
                              color: const Color(0xFF43A047),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                              ),
                            ),
                            confirmDismiss: (direction) async {
                              if (!schedule.isCompleted) {
                                await provider
                                    .markAsCompleted(schedule.id);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('스케줄을 완료했습니다')),
                                  );
                                }
                              }
                              return false;
                            },
                            child: ScheduleTile(
                              schedule: schedule,
                              onTap: () => context
                                  .push('/schedule/edit/${schedule.id}'),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/schedule/add'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
