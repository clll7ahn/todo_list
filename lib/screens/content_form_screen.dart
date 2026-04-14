import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../config/constants.dart';
import '../models/content.dart';
import '../models/enums.dart';
import '../models/hashtag_group.dart';
import '../providers/content_provider.dart';
import '../providers/hashtag_provider.dart';
import '../providers/template_provider.dart';
import '../widgets/caption_editor.dart';
import '../widgets/hashtag_chip.dart';
import '../widgets/image_picker_tile.dart';

/// 콘텐츠 생성/편집 폼 화면
class ContentFormScreen extends StatefulWidget {
  final String? contentId;

  const ContentFormScreen({super.key, this.contentId});

  @override
  State<ContentFormScreen> createState() => _ContentFormScreenState();
}

class _ContentFormScreenState extends State<ContentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _captionController = TextEditingController();
  final _hashtagInputController = TextEditingController();
  final _mentionController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();

  ContentType _contentType = ContentType.image;
  ContentStatus _status = ContentStatus.draft;
  List<String> _imagePaths = [];
  List<String> _hashtags = [];
  String? _templateId;

  bool get _isEditing => widget.contentId != null;

  int get _maxImages {
    return _contentType == ContentType.carousel
        ? AppConstants.maxCarouselImages
        : 1;
  }

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadExistingContent();
      });
    }
  }

  void _loadExistingContent() {
    final content =
        context.read<ContentProvider>().getContentById(widget.contentId!);
    if (content != null) {
      setState(() {
        _titleController.text = content.title;
        _captionController.text = content.caption;
        _contentType = content.contentType;
        _status = content.status;
        _imagePaths = List.from(content.imagePaths);
        _hashtags = List.from(content.hashtags);
        _templateId = content.templateId;
        _mentionController.text = content.mentions.join(', ');
        _locationController.text = content.location ?? '';
        _notesController.text = content.notes;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _captionController.dispose();
    _hashtagInputController.dispose();
    _mentionController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _addHashtag() {
    final text = _hashtagInputController.text.trim();
    if (text.isEmpty) return;
    final tag = text.startsWith('#') ? text : '#$text';
    if (_hashtags.length >= AppConstants.maxHashtags) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('해시태그는 최대 30개까지 추가할 수 있습니다')),
      );
      return;
    }
    if (!_hashtags.contains(tag)) {
      setState(() {
        _hashtags.add(tag);
        _hashtagInputController.clear();
      });
    }
  }

  void _removeHashtag(int index) {
    setState(() => _hashtags.removeAt(index));
  }

  void _addImagePath(String path) {
    if (_imagePaths.length >= _maxImages) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('최대 $_maxImages개의 이미지를 추가할 수 있습니다')),
      );
      return;
    }
    setState(() => _imagePaths.add(path));
  }

  void _removeImage(int index) {
    setState(() => _imagePaths.removeAt(index));
  }

  void _showHashtagGroupSheet() {
    final hashtagProvider = context.read<HashtagProvider>();
    final groups = hashtagProvider.groups;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                // 핸들바
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    '해시태그 그룹에서 추가',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: groups.isEmpty
                      ? const Center(child: Text('해시태그 그룹이 없습니다'))
                      : ListView.builder(
                          controller: scrollController,
                          itemCount: groups.length,
                          itemBuilder: (context, index) {
                            final group = groups[index];
                            return _buildHashtagGroupTile(group);
                          },
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildHashtagGroupTile(HashtagGroup group) {
    final theme = Theme.of(context);
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Color(group.color).withAlpha(40),
        child: Icon(
          group.category.icon,
          color: Color(group.color),
          size: 20,
        ),
      ),
      title: Text(group.name),
      subtitle: Text(
        group.hashtags.take(3).join(' '),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodySmall,
      ),
      trailing: Text(
        '${group.hashtags.length}개',
        style: theme.textTheme.labelSmall,
      ),
      onTap: () {
        final remaining = AppConstants.maxHashtags - _hashtags.length;
        final toAdd = group.hashtags.take(remaining).where(
              (tag) => !_hashtags.contains(tag),
            );
        setState(() {
          _hashtags.addAll(toAdd);
        });
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${toAdd.length}개 해시태그 추가됨')),
        );
      },
    );
  }

  void _showTemplateApplySheet() {
    final templateProvider = context.read<TemplateProvider>();
    final templates = templateProvider.templates;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                '템플릿 적용',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            if (templates.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Text('저장된 템플릿이 없습니다'),
              )
            else
              ...templates.map((template) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Color(template.color).withAlpha(40),
                    child: Icon(
                      IconData(template.icon, fontFamily: 'MaterialIcons'),
                      color: Color(template.color),
                    ),
                  ),
                  title: Text(template.name),
                  subtitle: Text(
                    template.contentType.label,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  onTap: () {
                    setState(() {
                      _contentType = template.contentType;
                      if (template.captionTemplate.isNotEmpty) {
                        _captionController.text = template.captionTemplate;
                      }
                      if (template.defaultHashtags.isNotEmpty) {
                        for (final tag in template.defaultHashtags) {
                          if (!_hashtags.contains(tag) &&
                              _hashtags.length < AppConstants.maxHashtags) {
                            _hashtags.add(tag);
                          }
                        }
                      }
                      _templateId = template.id;
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${template.name} 템플릿 적용됨')),
                    );
                  },
                );
              }),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  void _saveAsTemplate() {
    context.push('/templates/add');
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('제목을 입력하세요')),
      );
      return;
    }

    // 멘션 파싱
    final mentionText = _mentionController.text.trim();
    final mentions = mentionText.isEmpty
        ? <String>[]
        : mentionText
            .split(',')
            .map((m) => m.trim())
            .where((m) => m.isNotEmpty)
            .toList();

    final locationText = _locationController.text.trim();
    final provider = context.read<ContentProvider>();
    final now = DateTime.now();

    if (_isEditing) {
      final existing = provider.getContentById(widget.contentId!);
      if (existing != null) {
        final updated = existing.copyWith(
          title: title,
          caption: _captionController.text,
          contentType: _contentType,
          status: _status,
          imagePaths: _imagePaths,
          hashtags: _hashtags,
          templateId: _templateId,
          notes: _notesController.text.trim(),
          location: locationText.isNotEmpty ? locationText : null,
          mentions: mentions,
          updatedAt: now,
          clearLocation: locationText.isEmpty && existing.location != null,
        );
        provider.updateContent(updated);
      }
    } else {
      final content = Content(
        id: const Uuid().v4(),
        title: title,
        caption: _captionController.text,
        contentType: _contentType,
        status: _status,
        imagePaths: _imagePaths,
        hashtags: _hashtags,
        templateId: _templateId,
        notes: _notesController.text.trim(),
        location: locationText.isNotEmpty ? locationText : null,
        mentions: mentions,
        createdAt: now,
        updatedAt: now,
      );
      provider.addContent(content);
    }

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? '콘텐츠 편집' : '새 콘텐츠'),
        actions: [
          TextButton(
            onPressed: () {
              // 미리보기: 현재 상태 그대로 detail로 이동하지 않고 간단 다이얼로그
              _showPreviewDialog();
            },
            child: const Text('미리보기'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 이미지 섹션
              Text('이미지', style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              SizedBox(
                height: 110,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _imagePaths.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    if (index == _imagePaths.length) {
                      // 추가 타일
                      if (_imagePaths.length >= _maxImages) {
                        return const SizedBox.shrink();
                      }
                      return ImagePickerTile(
                        onImagePicked: _addImagePath,
                      );
                    }
                    return ImagePickerTile(
                      imagePath: _imagePaths[index],
                      index: index,
                      onImagePicked: (path) {
                        setState(() => _imagePaths[index] = path);
                      },
                      onRemove: () => _removeImage(index),
                      showDragHandle: _imagePaths.length > 1,
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // 콘텐츠 유형 선택
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
                  setState(() {
                    _contentType = selected.first;
                    // 캐러셀이 아닌 유형으로 변경시 이미지 1장 제한
                    if (_contentType != ContentType.carousel &&
                        _imagePaths.length > 1) {
                      _imagePaths = [_imagePaths.first];
                    }
                  });
                },
              ),
              const SizedBox(height: 24),

              // 제목
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: '제목',
                  hintText: '콘텐츠 제목을 입력하세요',
                ),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '제목을 입력하세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 캡션 에디터
              CaptionEditor(
                controller: _captionController,
              ),
              const SizedBox(height: 24),

              // 해시태그 섹션
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('해시태그', style: theme.textTheme.titleSmall),
                  Text(
                    '${_hashtags.length} / ${AppConstants.maxHashtags}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: _hashtags.length >= AppConstants.maxHashtags
                          ? theme.colorScheme.error
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _hashtagInputController,
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
              OutlinedButton.icon(
                icon: const Icon(Icons.folder_open, size: 18),
                label: const Text('그룹에서 추가'),
                onPressed: _showHashtagGroupSheet,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: List.generate(_hashtags.length, (index) {
                  return HashtagChip(
                    hashtag: _hashtags[index],
                    onDelete: () => _removeHashtag(index),
                  );
                }),
              ),
              const SizedBox(height: 24),

              // 멘션
              TextField(
                controller: _mentionController,
                decoration: const InputDecoration(
                  labelText: '멘션',
                  hintText: '@사용자1, @사용자2',
                  prefixIcon: Icon(Icons.alternate_email, size: 20),
                ),
              ),
              const SizedBox(height: 16),

              // 위치
              TextField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: '위치',
                  hintText: '장소를 입력하세요',
                  prefixIcon: Icon(Icons.location_on_outlined, size: 20),
                ),
              ),
              const SizedBox(height: 24),

              // 템플릿 섹션
              Text('템플릿', style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.style, size: 18),
                      label: const Text('템플릿 적용'),
                      onPressed: _showTemplateApplySheet,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.save_outlined, size: 18),
                      label: const Text('템플릿으로 저장'),
                      onPressed: _saveAsTemplate,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 내부 메모
              TextField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: '내부 메모 (선택)',
                  hintText: '팀 내부용 메모를 작성하세요',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // 상태 선택
              Text('상태', style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              Row(
                children: [
                  ChoiceChip(
                    label: const Text('초안'),
                    selected: _status == ContentStatus.draft,
                    onSelected: (_) =>
                        setState(() => _status = ContentStatus.draft),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('준비완료'),
                    selected: _status == ContentStatus.ready,
                    onSelected: (_) =>
                        setState(() => _status = ContentStatus.ready),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: FilledButton(
            onPressed: _save,
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
            child: const Text('저장'),
          ),
        ),
      ),
    );
  }

  /// 미리보기 다이얼로그
  void _showPreviewDialog() {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('미리보기'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 타입 표시
                Row(
                  children: [
                    Icon(_contentType.icon, size: 18),
                    const SizedBox(width: 6),
                    Text(_contentType.label),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _titleController.text.isNotEmpty
                      ? _titleController.text
                      : '(제목 없음)',
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  _captionController.text.isNotEmpty
                      ? _captionController.text
                      : '(캡션 없음)',
                  style: theme.textTheme.bodyMedium,
                ),
                if (_hashtags.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: _hashtags
                        .map((tag) => Text(
                              tag,
                              style: theme.textTheme.labelLarge,
                            ))
                        .toList(),
                  ),
                ],
                if (_locationController.text.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14),
                      const SizedBox(width: 4),
                      Text(_locationController.text),
                    ],
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('닫기'),
            ),
          ],
        );
      },
    );
  }
}
