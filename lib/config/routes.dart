import 'package:go_router/go_router.dart';
import '../screens/calendar_screen.dart';
import '../screens/category_screen.dart';
import '../screens/home_screen.dart';
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
  ],
);
