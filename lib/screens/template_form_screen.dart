import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../config/constants.dart';
import '../models/content_template.dart';
import '../models/enums.dart';
import '../providers/template_provider.dart';

/// 템플릿 생성/편집 폼 화면
class TemplateFormScreen extends StatefulWidget {
  final String? templateId;

  const TemplateFormScreen({super.key, this.templateId});

  @override
  State<TemplateFormScreen> createState() => _TemplateFormScreenState();
}

class _TemplateFormScreenState extends State<TemplateFormScreen> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _captionTemplateController = TextEditingController();
  final _hashtagController = TextEditingController();

  ContentType _contentType = ContentType.image;
  List<String> _defaultHashtags = [];
  int _selectedColorIndex = 0;
  int _selectedIconIndex = 0;

  bool get _isEditing => widget.templateId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadExistingTemplate();
      });
    }
  }

  void _loadExistingTemplate() {
    final template =
        context.read<TemplateProvider>().getTemplateById(widget.templateId!);
    if (template != null) {
      setState(() {
        _nameController.text = template.name;
        _descController.text = template.description;
        _captionTemplateController.text = template.captionTemplate;
        _contentType = template.contentType;
        _defaultHashtags = List.from(template.defaultHashtags);

        // 색상 인덱스 찾기
        final colorIndex = DefaultHashtagGroups.colorPalette
            .indexWhere((c) => c.toARGB32() == template.color);
        if (colorIndex >= 0) _selectedColorIndex = colorIndex;

        // 아이콘 인덱스 찾기
        final iconIndex = DefaultHashtagGroups.iconOptions
            .indexWhere((ic) => ic.codePoint == template.icon);
        if (iconIndex >= 0) _selectedIconIndex = iconIndex;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _captionTemplateController.dispose();
    _hashtagController.dispose();
    super.dispose();
  }

  void _addHashtag() {
    final text = _hashtagController.text.trim();
    if (text.isEmpty) return;
    final tag = text.startsWith('#') ? text : '#$text';
    if (!_defaultHashtags.contains(tag)) {
      setState(() {
        _defaultHashtags.add(tag);
        _hashtagController.clear();
      });
    }
  }

  void _removeHashtag(int index) {
    setState(() => _defaultHashtags.removeAt(index));
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('템플릿 이름을 입력하세요')),
      );
      return;
    }

    final provider = context.read<TemplateProvider>();
    final now = DateTime.now();
    final selectedColor =
        DefaultHashtagGroups.colorPalette[_selectedColorIndex].toARGB32();
    final selectedIcon =
        DefaultHashtagGroups.iconOptions[_selectedIconIndex].codePoint;

    if (_isEditing) {
      final existing = provider.getTemplateById(widget.templateId!);
      if (existing != null) {
        final updated = existing.copyWith(
          name: name,
          description: _descController.text.trim(),
          contentType: _contentType,
          captionTemplate: _captionTemplateController.text,
          defaultHashtags: _defaultHashtags,
          color: selectedColor,
          icon: selectedIcon,
        );
        provider.updateTemplate(updated);
      }
    } else {
      final template = ContentTemplate(
        id: const Uuid().v4(),
        name: name,
        description: _descController.text.trim(),
        contentType: _contentType,
        captionTemplate: _captionTemplateController.text,
        defaultHashtags: _defaultHashtags,
        color: selectedColor,
        icon: selectedIcon,
        createdAt: now,
      );
      provider.addTemplate(template);
    }

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? '템플릿 편집' : '새 템플릿'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('저장'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이름
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '템플릿 이름',
                hintText: '예: 제품 리뷰, 일상 포스트',
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            // 설명
            TextField(
              controller: _descController,
              decoration: const InputDecoration(
                labelText: '설명 (선택)',
                hintText: '템플릿 용도를 설명하세요',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 24),

            // 콘텐츠 유형
            Text('콘텐츠 유형', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            SegmentedButton<ContentType>(
              segments: ContentType.values.map((type) {
                return ButtonSegment<ContentType>(
                  value: type,
                  label: Text(type.label),
                  icon: Icon(type.icon, size: 18),
                );
              }).toList(),
              selected: {_contentType},
              onSelectionChanged: (selected) {
                setState(() => _contentType = selected.first);
              },
            ),
            const SizedBox(height: 24),

            // 캡션 템플릿
            Text('캡션 템플릿', style: theme.textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(
              '플레이스홀더: {제목}, {날짜}, {위치}',
              style: theme.textTheme.labelSmall,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _captionTemplateController,
              decoration: const InputDecoration(
                hintText: '캡션 템플릿을 입력하세요...\n\n예: {제목}\n\n{날짜}에 기록한 이야기',
                alignLabelWithHint: true,
              ),
              maxLines: 6,
              minLines: 3,
            ),
            const SizedBox(height: 24),

            // 기본 해시태그
            Text('기본 해시태그', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _hashtagController,
                    decoration: const InputDecoration(
                      hintText: '#해시태그 입력',
                      prefixText: '# ',
                    ),
                    onSubmitted: (_) => _addHashtag(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  icon: const Icon(Icons.add),
                  onPressed: _addHashtag,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: List.generate(_defaultHashtags.length, (index) {
                final tag = _defaultHashtags[index];
                return Chip(
                  label: Text(tag, style: const TextStyle(fontSize: 12)),
                  onDeleted: () => _removeHashtag(index),
                  deleteIconColor: theme.colorScheme.onSurfaceVariant,
                  visualDensity: VisualDensity.compact,
                );
              }),
            ),
            const SizedBox(height: 24),

            // 색상 선택
            Text('색상', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(
                DefaultHashtagGroups.colorPalette.length,
                (index) {
                  final color = DefaultHashtagGroups.colorPalette[index];
                  final isSelected = _selectedColorIndex == index;
                  return GestureDetector(
                    onTap: () =>
                        setState(() => _selectedColorIndex = index),
                    child: Container(
                      width: 36,
                      height: 36,
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
                              size: 18, color: Colors.white)
                          : null,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // 아이콘 선택
            Text('아이콘', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(
                DefaultHashtagGroups.iconOptions.length,
                (index) {
                  final icon = DefaultHashtagGroups.iconOptions[index];
                  final isSelected = _selectedIconIndex == index;
                  final selectedColor =
                      DefaultHashtagGroups.colorPalette[_selectedColorIndex];
                  return GestureDetector(
                    onTap: () =>
                        setState(() => _selectedIconIndex = index),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? selectedColor.withAlpha(30)
                            : theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(10),
                        border: isSelected
                            ? Border.all(color: selectedColor, width: 2)
                            : null,
                      ),
                      child: Icon(
                        icon,
                        size: 22,
                        color: isSelected
                            ? selectedColor
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
