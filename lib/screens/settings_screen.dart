import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../config/constants.dart';
import '../models/enums.dart';
import '../providers/settings_provider.dart';

/// InstaPlanner 설정 화면
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('설정')),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return ListView(
            children: [
              // ==========================================
              // Instagram 계정
              // ==========================================
              const _SectionHeader(title: 'Instagram 계정'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Instagram 사용자명',
                    hintText: '@사용자명을 입력하세요',
                    prefixIcon: Icon(Icons.alternate_email),
                  ),
                  controller: TextEditingController(
                    text: settings.instagramUsername,
                  ),
                  onChanged: (value) => settings.setInstagramUsername(value),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => _showAuthFlowDialog(context),
                        icon: const Icon(Icons.link),
                        label: const Text('Instagram 연결'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    _ConnectionStatusIndicator(
                      isConnected: settings.instagramUsername.isNotEmpty,
                    ),
                  ],
                ),
              ),
              const Divider(height: 32),

              // ==========================================
              // 게시 설정
              // ==========================================
              const _SectionHeader(title: '게시 설정'),

              // 주간 게시 목표
              ListTile(
                leading: const Icon(Icons.flag_outlined),
                title: const Text('주간 게시 목표'),
                subtitle: Text('${settings.defaultPostsPerWeek}회 / 주'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: settings.defaultPostsPerWeek > 1
                          ? () => settings.setDefaultPostsPerWeek(
                              settings.defaultPostsPerWeek - 1)
                          : null,
                    ),
                    Text(
                      '${settings.defaultPostsPerWeek}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: settings.defaultPostsPerWeek < 14
                          ? () => settings.setDefaultPostsPerWeek(
                              settings.defaultPostsPerWeek + 1)
                          : null,
                    ),
                  ],
                ),
              ),

              // 선호 게시 시간대
              ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text('선호 게시 시간대'),
                trailing: DropdownButton<PostTimeSlot>(
                  value: settings.preferredTimeSlot,
                  underline: const SizedBox.shrink(),
                  items: PostTimeSlot.values.map((slot) {
                    return DropdownMenuItem<PostTimeSlot>(
                      value: slot,
                      child: Text(
                        AppConstants.timeSlotLabels[slot.value] ?? slot.label,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      settings.setPreferredTimeSlot(value);
                    }
                  },
                ),
              ),

              // 알림 설정
              SwitchListTile(
                secondary: const Icon(Icons.notifications_outlined),
                title: const Text('알림 설정'),
                subtitle: const Text('게시 예정 알림을 받습니다'),
                value: settings.showNotifications,
                onChanged: (value) => settings.setShowNotifications(value),
              ),
              const Divider(height: 32),

              // ==========================================
              // 분석 설정
              // ==========================================
              const _SectionHeader(title: '분석 설정'),
              ListTile(
                leading: const Icon(Icons.trending_up),
                title: const Text('고성과 기준 참여율'),
                subtitle: Text(
                  '${settings.engagementRateThreshold.toStringAsFixed(1)}%',
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Slider(
                  value: settings.engagementRateThreshold,
                  min: 1.0,
                  max: 10.0,
                  divisions: 18,
                  label:
                      '${settings.engagementRateThreshold.toStringAsFixed(1)}%',
                  onChanged: (value) {
                    settings.setEngagementRateThreshold(
                      double.parse(value.toStringAsFixed(1)),
                    );
                  },
                ),
              ),
              const Divider(height: 32),

              // ==========================================
              // 테마
              // ==========================================
              const _SectionHeader(title: '테마'),
              SwitchListTile(
                secondary: Icon(
                  settings.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                ),
                title: const Text('다크 모드'),
                subtitle: const Text('어두운 테마를 사용합니다'),
                value: settings.isDarkMode,
                onChanged: (_) => settings.toggleDarkMode(),
              ),
              const Divider(height: 32),

              // ==========================================
              // 데이터 관리
              // ==========================================
              const _SectionHeader(title: '데이터 관리'),
              ListTile(
                leading: const Icon(Icons.style_outlined),
                title: const Text('템플릿 관리'),
                subtitle: const Text('콘텐츠 템플릿을 관리합니다'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/templates'),
              ),
              ListTile(
                leading: const Icon(Icons.tag),
                title: const Text('해시태그 관리'),
                subtitle: const Text('해시태그 그룹을 관리합니다'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/hashtags'),
              ),
              ListTile(
                leading: const Icon(Icons.download_outlined),
                title: const Text('데이터 내보내기'),
                subtitle: const Text('콘텐츠 및 분석 데이터를 내보냅니다'),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('데이터 내보내기 기능은 추후 업데이트 예정입니다'),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.red),
                title: const Text('전체 데이터 초기화'),
                subtitle: const Text('모든 데이터와 설정을 삭제합니다'),
                onTap: () => _showResetDialog(context, settings),
              ),
              const Divider(height: 32),

              // ==========================================
              // 앱 정보
              // ==========================================
              const _SectionHeader(title: '앱 정보'),
              const ListTile(
                leading: Icon(Icons.info_outline),
                title: Text('버전: ${AppConstants.appVersion}'),
                subtitle: Text('InstaPlanner by Smurf Factory'),
              ),
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  /// Instagram 연결 인증 플로우 설명 다이얼로그
  void _showAuthFlowDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Instagram 연결'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Instagram API 연결 방법:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text('1. Meta for Developers에서 앱을 생성합니다.'),
              SizedBox(height: 4),
              Text('2. Instagram Basic Display API를 설정합니다.'),
              SizedBox(height: 4),
              Text('3. OAuth 인증을 통해 액세스 토큰을 발급받습니다.'),
              SizedBox(height: 4),
              Text('4. 발급받은 토큰으로 Instagram 데이터에 접근할 수 있습니다.'),
              SizedBox(height: 16),
              Text(
                '이 기능은 Instagram Graph API 연동 후 사용 가능합니다.',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  /// 데이터 초기화 확인 다이얼로그
  void _showResetDialog(BuildContext context, SettingsProvider settings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('전체 데이터 초기화'),
        content: const Text(
          '모든 콘텐츠, 스케줄, 분석 데이터 및 설정이 삭제됩니다.\n이 작업은 되돌릴 수 없습니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              settings.setDarkMode(false);
              settings.setInstagramUsername('');
              settings.setDefaultPostsPerWeek(AppConstants.defaultPostsPerWeek);
              settings.setPreferredTimeSlot(PostTimeSlot.afternoon);
              settings.setShowNotifications(true);
              settings.setEngagementRateThreshold(
                AppConstants.defaultEngagementThreshold,
              );
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

/// 연결 상태 인디케이터
class _ConnectionStatusIndicator extends StatelessWidget {
  final bool isConnected;

  const _ConnectionStatusIndicator({required this.isConnected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isConnected
            ? const Color(0xFF43A047).withAlpha(25)
            : Colors.grey.withAlpha(25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isConnected
              ? const Color(0xFF43A047).withAlpha(100)
              : Colors.grey.withAlpha(100),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isConnected ? Icons.check_circle : Icons.cancel,
            size: 16,
            color: isConnected ? const Color(0xFF43A047) : Colors.grey,
          ),
          const SizedBox(width: 4),
          Text(
            isConnected ? '연결됨' : '미연결',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isConnected ? const Color(0xFF43A047) : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

/// 섹션 헤더 위젯
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
