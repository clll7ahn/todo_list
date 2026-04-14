import 'package:go_router/go_router.dart';
import '../screens/analytics_dashboard_screen.dart';
import '../screens/analytics_detail_screen.dart';
import '../screens/analytics_input_screen.dart';
import '../screens/content_detail_screen.dart';
import '../screens/content_form_screen.dart';
import '../screens/content_home_screen.dart';
import '../screens/hashtag_manage_screen.dart';
import '../screens/repost_form_screen.dart';
import '../screens/repost_screen.dart';
import '../screens/schedule_calendar_screen.dart';
import '../screens/schedule_form_screen.dart';
import '../screens/schedule_list_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/shell_screen.dart';
import '../screens/template_form_screen.dart';
import '../screens/template_list_screen.dart';

/// 라우터 설정
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // ==========================================
    // ShellRoute (하단 네비게이션 5-tab)
    // ==========================================
    ShellRoute(
      builder: (context, state, child) => ShellScreen(child: child),
      routes: [
        GoRoute(
          path: '/',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: ContentHomeScreen(),
          ),
        ),
        GoRoute(
          path: '/calendar',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: ScheduleCalendarScreen(),
          ),
        ),
        GoRoute(
          path: '/create',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: ContentFormScreen(),
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

    // ==========================================
    // 콘텐츠 관련 라우트
    // ==========================================
    GoRoute(
      path: '/content/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return ContentDetailScreen(contentId: id);
      },
    ),
    GoRoute(
      path: '/content/edit/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return ContentFormScreen(contentId: id);
      },
    ),

    // ==========================================
    // 템플릿 관련 라우트
    // ==========================================
    GoRoute(
      path: '/templates',
      builder: (context, state) => const TemplateListScreen(),
    ),
    GoRoute(
      path: '/templates/add',
      builder: (context, state) => const TemplateFormScreen(),
    ),
    GoRoute(
      path: '/templates/edit/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return TemplateFormScreen(templateId: id);
      },
    ),

    // ==========================================
    // 해시태그 관련 라우트
    // ==========================================
    GoRoute(
      path: '/hashtags',
      builder: (context, state) => const HashtagManageScreen(),
    ),

    // ==========================================
    // 스케줄 관련 라우트
    // ==========================================
    GoRoute(
      path: '/schedule/add',
      builder: (context, state) => const ScheduleFormScreen(),
    ),
    GoRoute(
      path: '/schedule/add/:contentId',
      builder: (context, state) {
        // contentId를 전달하지만 ScheduleFormScreen은 scheduleId만 받음
        // 콘텐츠 사전선택은 별도 처리 필요
        return const ScheduleFormScreen();
      },
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

    // ==========================================
    // 분석 관련 라우트
    // ==========================================
    GoRoute(
      path: '/analytics/content/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return AnalyticsDetailScreen(recordId: id);
      },
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
    GoRoute(
      path: '/analytics/input/:contentId',
      builder: (context, state) {
        final contentId = state.pathParameters['contentId']!;
        return AnalyticsInputScreen(contentId: contentId);
      },
    ),

    // ==========================================
    // 리포스트 관련 라우트
    // ==========================================
    GoRoute(
      path: '/repost',
      builder: (context, state) => const RepostScreen(),
    ),
    GoRoute(
      path: '/repost/add',
      builder: (context, state) {
        final contentId = state.uri.queryParameters['contentId'];
        return RepostFormScreen(contentId: contentId);
      },
    ),
    GoRoute(
      path: '/repost/add/:contentId',
      builder: (context, state) {
        final contentId = state.pathParameters['contentId']!;
        return RepostFormScreen(contentId: contentId);
      },
    ),
    GoRoute(
      path: '/repost/edit/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return RepostFormScreen(planId: id);
      },
    ),
    GoRoute(
      path: '/content/repost/:contentId',
      builder: (context, state) {
        final contentId = state.pathParameters['contentId']!;
        return RepostFormScreen(contentId: contentId);
      },
    ),
  ],
);
