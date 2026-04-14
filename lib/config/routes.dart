import 'package:go_router/go_router.dart';
import '../screens/analytics_dashboard_screen.dart';
import '../screens/analytics_detail_screen.dart';
import '../screens/analytics_input_screen.dart';
import '../screens/calendar_screen.dart';
import '../screens/category_screen.dart';
import '../screens/home_screen.dart';
import '../screens/schedule_calendar_screen.dart';
import '../screens/schedule_form_screen.dart';
import '../screens/schedule_list_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/stats_screen.dart';
import '../screens/todo_form_screen.dart';
import '../screens/shell_screen.dart';

/// 라우터 설정
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    /// 하단 네비게이션 쉘
    ShellRoute(
      builder: (context, state, child) => ShellScreen(child: child),
      routes: [
        GoRoute(
          path: '/',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: HomeScreen(),
          ),
        ),
        GoRoute(
          path: '/schedule',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: ScheduleCalendarScreen(),
          ),
        ),
        GoRoute(
          path: '/calendar',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: CalendarScreen(),
          ),
        ),
        GoRoute(
          path: '/stats',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: StatsScreen(),
          ),
        ),
        GoRoute(
          path: '/analytics',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: AnalyticsDashboardScreen(),
          ),
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: SettingsScreen(),
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/todo/add',
      builder: (context, state) => const TodoFormScreen(),
    ),
    GoRoute(
      path: '/todo/edit/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return TodoFormScreen(todoId: id);
      },
    ),
    GoRoute(
      path: '/categories',
      builder: (context, state) => const CategoryScreen(),
    ),
    GoRoute(
      path: '/schedule/add',
      builder: (context, state) => const ScheduleFormScreen(),
    ),
    GoRoute(
      path: '/schedule/edit/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return ScheduleFormScreen(scheduleId: id);
      },
    ),
    GoRoute(
      path: '/schedule/list',
      builder: (context, state) => const ScheduleListScreen(),
    ),
    GoRoute(
      path: '/analytics/detail/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return AnalyticsDetailScreen(recordId: id);
      },
    ),
    GoRoute(
      path: '/analytics/input',
      builder: (context, state) {
        final extra = state.extra as Map<String, String>?;
        return AnalyticsInputScreen(
          contentId: extra?['contentId'],
          recordId: extra?['recordId'],
        );
      },
    ),
  ],
);
