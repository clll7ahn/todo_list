import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/content_template.dart';
import '../models/enums.dart';
import '../providers/template_provider.dart';
import '../widgets/empty_state.dart';

/// 템플릿 관리 화면
class TemplateListScreen extends StatelessWidget {
  const TemplateListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('콘텐츠 템플릿'),
      ),
      body: Consumer<TemplateProvider>(
        builder: (context, provider, _) {
          final templates = provider.templates;

          if (templates.isEmpty) {
            return EmptyState(
              icon: Icons.style_outlined,
              title: '템플릿이 없습니다',
              subtitle: '자주 사용하는 콘텐츠 형식을 템플릿으로 저장하세요',
              actionLabel: '템플릿 만들기',
              onAction: () => context.push('/templates/add'),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: templates.length,
            itemBuilder: (context, index) {
              final template = templates[index];
              return _buildTemplateCard(context, template, provider);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/templates/add'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTemplateCard(
    BuildContext context,
    ContentTemplate template,
    TemplateProvider provider,
  ) {
    final theme = Theme.of(context);
    final color = Color(template.color);

    return Card(
      child: InkWell(
        onTap: () => context.push('/templates/edit/${template.id}'),
        onLongPress: () =>
            _showTemplateOptions(context, template, provider),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 아이콘 + 유형
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color.withAlpha(30),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      IconData(template.icon, fontFamily: 'MaterialIcons'),
                      color: color,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          template.contentType.icon,
                          size: 14,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 이름
              Text(
                template.name,
                style: theme.textTheme.titleSmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),

              // 사용 횟수
              Text(
                '${template.usageCount}회 사용',
                style: theme.textTheme.labelSmall,
              ),
              const Spacer(),

              // 기본 해시태그 미리보기
              if (template.defaultHashtags.isNotEmpty)
                Text(
                  template.defaultHashtags.take(3).join(' '),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// 템플릿 옵션 메뉴 (롱프레스)
  void _showTemplateOptions(
    BuildContext context,
    ContentTemplate template,
    TemplateProvider provider,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  template.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.copy),
                title: const Text('복제'),
                onTap: () {
                  provider.duplicateTemplate(template.id);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('템플릿이 복제되었습니다')),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.delete_outline,
                    color: Theme.of(context).colorScheme.error),
                title: Text(
                  '삭제',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.error),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _confirmDelete(context, template, provider);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  /// 삭제 확인
  void _confirmDelete(
    BuildContext context,
    ContentTemplate template,
    TemplateProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('템플릿 삭제'),
          content: Text('"${template.name}" 템플릿을 삭제하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('취소'),
            ),
            FilledButton(
              onPressed: () {
                provider.deleteTemplate(template.id);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('"${template.name}" 삭제됨')),
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('삭제'),
            ),
          ],
        );
      },
    );
  }
}
