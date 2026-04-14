import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../config/constants.dart';
import '../models/enums.dart';
import '../models/hashtag_group.dart';
import '../providers/hashtag_provider.dart';
import '../widgets/empty_state.dart';
import '../widgets/hashtag_chip.dart';

/// 해시태그 그룹 관리 화면
class HashtagManageScreen extends StatelessWidget {
  const HashtagManageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('해시태그 관리'),
      ),
      body: Consumer<HashtagProvider>(
        builder: (context, provider, _) {
          final groups = provider.groups;

          if (groups.isEmpty) {
            return EmptyState(
              icon: Icons.tag,
              title: '해시태그 그룹이 없습니다',
              subtitle: '자주 사용하는 해시태그를 그룹으로 관리하세요',
              actionLabel: '그룹 만들기',
              onAction: () => _showAddGroupDialog(context, provider),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: groups.length,
            itemBuilder: (context, index) {
              final group = groups[index];
              return _HashtagGroupTile(
                group: group,
                provider: provider,
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final provider = context.read<HashtagProvider>();
          _showAddGroupDialog(context, provider);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  /// 그룹 추가 다이얼로그
  static void _showAddGroupDialog(
    BuildContext context,
    HashtagProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => _AddGroupDialog(provider: provider),
    );
  }
}

/// 해시태그 그룹 확장 타일
class _HashtagGroupTile extends StatelessWidget {
  final HashtagGroup group;
  final HashtagProvider provider;

  const _HashtagGroupTile({
    required this.group,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = Color(group.color);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: color.withAlpha(40),
          child: Icon(
            group.category.icon,
            color: color,
            size: 20,
          ),
        ),
        title: Text(
          group.name,
          style: theme.textTheme.titleSmall,
        ),
        subtitle: Row(
          children: [
            Text(
              '${group.hashtags.length}개',
              style: theme.textTheme.labelSmall,
            ),
            const SizedBox(width: 8),
            Text(
              '${group.usageCount}회 사용',
              style: theme.textTheme.labelSmall,
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: color.withAlpha(20),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                group.category.label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              onPressed: () => _showEditGroupDialog(context),
              tooltip: '편집',
            ),
            IconButton(
              icon: Icon(Icons.delete_outline,
                  size: 20, color: theme.colorScheme.error),
              onPressed: () => _confirmDelete(context),
              tooltip: '삭제',
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 전체 복사 버튼
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    icon: const Icon(Icons.copy, size: 16),
                    label: const Text('전체 복사'),
                    onPressed: () {
                      final allTags = group.hashtags.join(' ');
                      Clipboard.setData(ClipboardData(text: allTags));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${group.hashtags.length}개 해시태그 복사됨',
                          ),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                ),
                // 해시태그 칩 목록
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: group.hashtags
                      .map((tag) => HashtagChip(
                            hashtag: tag,
                            category: group.category,
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEditGroupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => _AddGroupDialog(
        provider: provider,
        existingGroup: group,
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('그룹 삭제'),
          content: Text('"${group.name}" 그룹을 삭제하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('취소'),
            ),
            FilledButton(
              onPressed: () {
                provider.deleteGroup(group.id);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('"${group.name}" 삭제됨')),
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

/// 그룹 추가/편집 다이얼로그
class _AddGroupDialog extends StatefulWidget {
  final HashtagProvider provider;
  final HashtagGroup? existingGroup;

  const _AddGroupDialog({
    required this.provider,
    this.existingGroup,
  });

  @override
  State<_AddGroupDialog> createState() => _AddGroupDialogState();
}

class _AddGroupDialogState extends State<_AddGroupDialog> {
  final _nameController = TextEditingController();
  final _hashtagInputController = TextEditingController();
  HashtagCategory _category = HashtagCategory.general;
  int _selectedColorIndex = 0;
  List<String> _hashtags = [];

  bool get _isEditing => widget.existingGroup != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final group = widget.existingGroup!;
      _nameController.text = group.name;
      _category = group.category;
      _hashtags = List.from(group.hashtags);

      final colorIndex = DefaultHashtagGroups.colorPalette
          .indexWhere((c) => c.toARGB32() == group.color);
      if (colorIndex >= 0) _selectedColorIndex = colorIndex;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _hashtagInputController.dispose();
    super.dispose();
  }

  void _addHashtags() {
    final text = _hashtagInputController.text.trim();
    if (text.isEmpty) return;
    // 콤마 또는 공백으로 분리
    final tags = text.split(RegExp(r'[,\s]+'));
    for (var tag in tags) {
      tag = tag.trim();
      if (tag.isEmpty) continue;
      if (!tag.startsWith('#')) tag = '#$tag';
      if (!_hashtags.contains(tag)) {
        _hashtags.add(tag);
      }
    }
    setState(() {
      _hashtagInputController.clear();
    });
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('그룹 이름을 입력하세요')),
      );
      return;
    }

    final selectedColor =
        DefaultHashtagGroups.colorPalette[_selectedColorIndex].toARGB32();
    final now = DateTime.now();

    if (_isEditing) {
      final updated = widget.existingGroup!.copyWith(
        name: name,
        category: _category,
        hashtags: _hashtags,
        color: selectedColor,
        updatedAt: now,
      );
      widget.provider.updateGroup(updated);
    } else {
      final group = HashtagGroup(
        id: const Uuid().v4(),
        name: name,
        category: _category,
        hashtags: _hashtags,
        color: selectedColor,
        createdAt: now,
        updatedAt: now,
      );
      widget.provider.addGroup(group);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(_isEditing ? '그룹 편집' : '새 해시태그 그룹'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이름
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '그룹 이름',
                hintText: '예: 일상, 맛집, 여행',
              ),
            ),
            const SizedBox(height: 16),

            // 카테고리 드롭다운
            Text('카테고리', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            DropdownButtonFormField<HashtagCategory>(
              value: _category,
              decoration: const InputDecoration(
                hintText: '카테고리 선택',
              ),
              items: HashtagCategory.values.map((cat) {
                return DropdownMenuItem(
                  value: cat,
                  child: Row(
                    children: [
                      Icon(cat.icon, size: 18),
                      const SizedBox(width: 8),
                      Text(cat.label),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _category = value);
                }
              },
            ),
            const SizedBox(height: 16),

            // 해시태그 입력
            Text('해시태그', style: theme.textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(
              '콤마 또는 공백으로 구분',
              style: theme.textTheme.labelSmall,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _hashtagInputController,
                    decoration: const InputDecoration(
                      hintText: '#태그1, #태그2',
                      isDense: true,
                    ),
                    onSubmitted: (_) => _addHashtags(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addHashtags,
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_hashtags.isNotEmpty)
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: List.generate(_hashtags.length, (index) {
                  return Chip(
                    label: Text(
                      _hashtags[index],
                      style: const TextStyle(fontSize: 11),
                    ),
                    onDeleted: () {
                      setState(() => _hashtags.removeAt(index));
                    },
                    visualDensity: VisualDensity.compact,
                  );
                }),
              ),
            const SizedBox(height: 16),

            // 색상 선택
            Text('색상', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(
                DefaultHashtagGroups.colorPalette.length,
                (index) {
                  final color = DefaultHashtagGroups.colorPalette[index];
                  final isSelected = _selectedColorIndex == index;
                  return GestureDetector(
                    onTap: () =>
                        setState(() => _selectedColorIndex = index),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(
                                color: theme.colorScheme.onSurface,
                                width: 3)
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(Icons.check,
                              size: 16, color: Colors.white)
                          : null,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        FilledButton(
          onPressed: _save,
          child: Text(_isEditing ? '수정' : '만들기'),
        ),
      ],
    );
  }
}
