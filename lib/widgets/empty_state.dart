import 'package:flutter/material.dart';

/// 빈 상태 위젯
/// 리스트가 비어있을 때 (콘텐츠 없음, 일정 없음 등) 표시
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  /// 상단에 표시될 아이콘
  final IconData icon;

  /// 제목 텍스트
  final String title;

  /// 부가 설명 텍스트 (선택)
  final String? subtitle;

  /// 액션 버튼 레이블 (선택)
  final String? actionLabel;

  /// 액션 버튼 콜백 (선택)
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 아이콘
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 40,
                color: colorScheme.primary.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),

            // 제목
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),

            // 부가 설명
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            // 액션 버튼
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add, size: 18),
                label: Text(actionLabel!),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
