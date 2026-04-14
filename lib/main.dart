import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'providers/analytics_provider.dart';
import 'providers/content_provider.dart';
import 'providers/hashtag_provider.dart';
import 'providers/repost_provider.dart';
import 'providers/schedule_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/template_provider.dart';
import 'services/storage_service.dart';

/// 앱 진입점
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 한국어 로케일 데이터 초기화
  await initializeDateFormatting('ko_KR');

  // 서비스 초기화
  final storageService = StorageService();

  // Provider 초기화
  final settingsProvider = SettingsProvider(storageService: storageService);
  final contentProvider = ContentProvider(storageService: storageService);
  final templateProvider = TemplateProvider(storageService: storageService);
  final hashtagProvider = HashtagProvider(storageService: storageService);
  final scheduleProvider = ScheduleProvider(storageService: storageService);
  final analyticsProvider = AnalyticsProvider(storageService: storageService);
  final repostProvider = RepostProvider(storageService: storageService);

  // 비동기 데이터 로드
  await Future.wait([
    settingsProvider.initialize(),
    contentProvider.init(),
    templateProvider.init(),
    hashtagProvider.init(),
    scheduleProvider.init(),
    analyticsProvider.init(),
    repostProvider.init(),
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settingsProvider),
        ChangeNotifierProvider.value(value: contentProvider),
        ChangeNotifierProvider.value(value: templateProvider),
        ChangeNotifierProvider.value(value: hashtagProvider),
        ChangeNotifierProvider.value(value: scheduleProvider),
        ChangeNotifierProvider.value(value: analyticsProvider),
        ChangeNotifierProvider.value(value: repostProvider),
      ],
      child: const InstaPlanner(),
    ),
  );
}
