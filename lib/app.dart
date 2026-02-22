import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/constants.dart';
import 'config/routes.dart';
import 'config/theme.dart';
import 'providers/settings_provider.dart';

/// 메인 앱 위젯
class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settingsProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      routerConfig: appRouter,
    );
  }
}
