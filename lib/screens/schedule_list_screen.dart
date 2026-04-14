import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/schedule.dart';
import '../providers/schedule_provider.dart';
import '../utils/date_utils.dart';
import '../widgets/empty_state.dart';
import '../widgets/schedule_tile.dart';

/// 스케줄 타임라인 리스트 화면
class ScheduleListScreen extends StatefulWidget {
  const ScheduleListScreen({super.key});

  @override
  State<ScheduleListScreen> createState() => _ScheduleListScreenState();
}

class _ScheduleListScreenState extends State<ScheduleListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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

  /// 날짜 헤더 텍스트 생성
  String _dateHeader(DateTime date) {
    final now = DateTime.now();
    if (AppDateUtils.isToday(date)) return '오늘';
    if (AppDateUtils.isTomorrow(date)) return '내일';

    final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final weekday = weekdays[date.weekday - 1];
    return '${date.month}월 ${date.day}일 ${weekday}요일';
  }

  /// 스케줄을 날짜별로 그룹화
  Map<DateTime, List<Schedule>> _groupByDate(List<Schedule> schedules) {
    final map = <DateTime, List<Schedule>>{};
    for (final s in schedules) {
      final key = DateTime(
        s.scheduledAt.year,
        s.scheduledAt.month,
        s.scheduledAt.day,
      );
      map.putIfAbsent(key, () => []).add(s);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('스케줄 목록'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '예정'),
            Tab(text: '완료'),
            Tab(text: '지연'),
          ],
        ),
      ),
      body: Consumer<ScheduleProvider>(
        builder: (context, provider, _) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildScheduleList(
                provider.upcomingSchedules,
                emptyIcon: Icons.event_available,
                emptyTitle: '예정된 스케줄이 없습니다',
                emptySubtitle: '새로운 스케줄을 추가해 보세요',
                showAction: true,
              ),
              _buildScheduleList(
                provider.completedSchedules,
                emptyIcon: Icons.check_circle_outline,
                emptyTitle: '완료된 스케줄이 없습니다',
                emptySubtitle: '스케줄을 완료하면 여기에 표시됩니다',
              ),
              _buildScheduleList(
                provider.overdueSchedules,
                emptyIcon: Icons.schedule,
                emptyTitle: '지연된 스케줄이 없습니다',
                emptySubtitle: '모든 스케줄이 정상입니다',
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

  Widget _buildScheduleList(
    List<Schedule> schedules, {
    required IconData emptyIcon,
    required String emptyTitle,
    required String emptySubtitle,
    bool showAction = false,
  }) {
    if (schedules.isEmpty) {
      return EmptyState(
        icon: emptyIcon,
        title: emptyTitle,
        subtitle: emptySubtitle,
        actionLabel: showAction ? '스케줄 추가' : null,
        onAction: showAction ? () => context.push('/schedule/add') : null,
      );
    }

    final grouped = _groupByDate(schedules);
    final sortedDates = grouped.keys.toList()..sort();

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 80),
      itemCount: _countItems(grouped, sortedDates),
      itemBuilder: (context, index) {
        // 날짜 헤더와 스케줄 아이템을 함께 렌더링
        int currentIndex = 0;
        for (final date in sortedDates) {
          // 날짜 헤더
          if (currentIndex == index) {
            return _buildDateHeader(date);
          }
          currentIndex++;

          // 해당 날짜의 스케줄들
          final items = grouped[date]!;
          for (int i = 0; i < items.length; i++) {
            if (currentIndex == index) {
              return _buildScheduleItem(items[i]);
            }
            currentIndex++;
          }
        }
        return const SizedBox.shrink();
      },
    );
  }

  int _countItems(
      Map<DateTime, List<Schedule>> grouped, List<DateTime> sortedDates) {
    int count = 0;
    for (final date in sortedDates) {
      count++; // 날짜 헤더
      count += grouped[date]!.length; // 스케줄 아이템
    }
    return count;
  }

  Widget _buildDateHeader(DateTime date) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isToday = AppDateUtils.isToday(date);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Row(
        children: [
          if (isToday)
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
          Text(
            _dateHeader(date),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: isToday
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleItem(Schedule schedule) {
    final provider = context.read<ScheduleProvider>();

    return Dismissible(
      key: ValueKey(schedule.id),
      direction: schedule.isCompleted
          ? DismissDirection.none
          : DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        color: const Color(0xFF43A047),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check, color: Colors.white),
            SizedBox(height: 2),
            Text(
              '완료',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        if (!schedule.isCompleted) {
          await provider.markAsCompleted(schedule.id);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('스케줄을 완료했습니다')),
            );
          }
        }
        return false;
      },
      child: ScheduleTile(
        schedule: schedule,
        showDate: false,
        onTap: () => context.push('/schedule/edit/${schedule.id}'),
      ),
    );
  }
}
