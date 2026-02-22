import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../config/constants.dart';
import '../providers/settings_provider.dart';
import '../providers/todo_provider.dart';

/// 설정 화면
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('설정')),
      body: ListView(
        children: [
          // 테마 설정
          _SectionHeader(title: '화면'),
          SwitchListTile(
            title: const Text('다크 모드'),
            subtitle: const Text('어두운 테마를 사용합니다'),
            secondary: Icon(
              settingsProvider.isDarkMode
                  ? Icons.dark_mode
                  : Icons.light_mode,
            ),
            value: settingsProvider.isDarkMode,
            onChanged: (_) => settingsProvider.toggleDarkMode(),
          ),
          const Divider(),

          // 데이터 관리
          _SectionHeader(title: '데이터'),
          ListTile(
            leading: const Icon(Icons.category),
            title: const Text('카테고리 관리'),
            subtitle: const Text('카테고리를 추가/편집/삭제합니다'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/categories'),
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('데이터 초기화'),
            subtitle: const Text('모든 할일과 설정을 삭제합니다'),
            onTap: () => _showResetDialog(context),
          ),
          const Divider(),

          // 앱 정보
          _SectionHeader(title: '앱 정보'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text(AppConstants.appName),
            subtitle: const Text('버전 ${AppConstants.appVersion}'),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('데이터 초기화'),
        content: const Text('모든 할일과 설정이 삭제됩니다.\n이 작업은 되돌릴 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              context.read<TodoProvider>().clearAll();
              context.read<SettingsProvider>().setDarkMode(false);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('데이터가 초기화되었습니다')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('초기화'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}
