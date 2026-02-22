import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/todo_provider.dart';
import '../utils/date_utils.dart';
import '../widgets/todo_tile.dart';

/// 캘린더 뷰 화면
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final todoProvider = context.watch<TodoProvider>();
    final todosByDate = todoProvider.todosByDate;

    final selectedTodos = _selectedDay != null
        ? todoProvider.getTodosForDate(_selectedDay!)
        : <dynamic>[];

    return Scaffold(
      appBar: AppBar(
        title: const Text('캘린더'),
      ),
      body: Column(
        children: [
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
              final key = DateTime(day.year, day.month, day.day);
              return todosByDate[key] ?? [];
            },
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: theme.colorScheme.primary.withAlpha(60),
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: theme.colorScheme.tertiary,
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
                border: Border.all(color: theme.colorScheme.outline),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const Divider(),
          // 선택된 날짜의 할일 목록
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                    label: const Text('할일 추가'),
                    onPressed: () => context.push('/todo/add'),
                  ),
              ],
            ),
          ),
          Expanded(
            child: selectedTodos.isEmpty
                ? Center(
                    child: Text(
                      '이 날짜에 할일이 없습니다',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: selectedTodos.length,
                    itemBuilder: (context, index) {
                      final todo = selectedTodos[index];
                      return TodoTile(
                        todo: todo,
                        onTap: () => context.push('/todo/edit/${todo.id}'),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
