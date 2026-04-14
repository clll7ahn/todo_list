import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/content.dart';
import '../models/enums.dart';
import '../models/repost_plan.dart';
import '../providers/analytics_provider.dart';
import '../providers/content_provider.dart';
import '../providers/repost_provider.dart';
import '../widgets/performance_badge.dart';

/// 리포스트 계획 생성/편집 폼 화면
class RepostFormScreen extends StatefulWidget {
  final String? planId;
  final String? contentId;

  const RepostFormScreen({super.key, this.planId, this.contentId});

  @override
  State<RepostFormScreen> createState() => _RepostFormScreenState();
}

class _RepostFormScreenState extends State<RepostFormScreen> {
  final _captionController = TextEditingController();
  final _hashtagInputController = TextEditingController();
  final _notesController = TextEditingController();

  RepostStrategy _strategy = RepostStrategy.exact;
  List<String> _modifiedHashtags = [];
  DateTime _plannedAt = DateTime.now().add(const Duration(days: 1));
  String? _originalContentId;

  bool get _isEditing => widget.planId != null;

  @override
  void initState() {
    super.initState();
    _originalContentId = widget.contentId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isEditing) {
        _loadExistingPlan();
      } else if (_originalContentId != null) {
        _prefillFromContent();
      }
    });
  }

  void _loadExistingPlan() {
    final plan =
        context.read<RepostProvider>().getPlanById(widget.planId!);
    if (plan != null) {
      final content =
          context.read<ContentProvider>().getContentById(plan.originalContentId);
      setState(() {
        _originalContentId = plan.originalContentId;
        _strategy = plan.strategy;
        _captionController.text = plan.modifiedCaption ?? content?.caption ?? '';
        _modifiedHashtags =
            List.from(plan.modifiedHashtags ?? content?.hashtags ?? []);
        _plannedAt = plan.plannedAt;
        _notesController.text = plan.notes ?? '';
      });
    }
  }

  void _prefillFromContent() {
    final content =
        context.read<ContentProvider>().getContentById(_originalContentId!);
    if (content != null) {
      setState(() {
        _captionController.text = content.caption;
        _modifiedHashtags = List.from(content.hashtags);
      });
    }
  }

  @override
  void dispose() {
    _captionController.dispose();
    _hashtagInputController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _addHashtag() {
    final text = _hashtagInputController.text.trim();
    if (text.isEmpty) return;
    final tag = text.startsWith('#') ? text : '#$text';
    if (!_modifiedHashtags.contains(tag)) {
      setState(() {
        _modifiedHashtags.add(tag);
        _hashtagInputController.clear();
      });
    }
  }

  void _removeHashtag(int index) {
    setState(() => _modifiedHashtags.removeAt(index));
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _plannedAt,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('ko', 'KR'),
    );
    if (picked != null) {
      setState(() => _plannedAt = picked);
    }
  }

  void _save() {
    if (_originalContentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('원본 콘텐츠를 선택하세요')),
      );
      return;
    }

    final provider = context.read<RepostProvider>();
    final now = DateTime.now();

    if (_isEditing) {
      final existing = provider.getPlanById(widget.planId!);
      if (existing != null) {
        final updated = existing.copyWith(
          strategy: _strategy,
          modifiedCaption: _strategy != RepostStrategy.exact
              ? _captionController.text
              : null,
          modifiedHashtags: _strategy != RepostStrategy.exact
              ? _modifiedHashtags
              : null,
          plannedAt: _plannedAt,
          notes: _notesController.text.trim().isNotEmpty
              ? _notesController.text.trim()
              : null,
          clearModifiedCaption: _strategy == RepostStrategy.exact,
          clearModifiedHashtags: _strategy == RepostStrategy.exact,
          clearNotes: _notesController.text.trim().isEmpty,
        );
        provider.updatePlan(updated);
      }
    } else {
      final plan = RepostPlan(
        id: const Uuid().v4(),
        originalContentId: _originalContentId!,
        strategy: _strategy,
        modifiedCaption: _strategy != RepostStrategy.exact
            ? _captionController.text
            : null,
        modifiedHashtags: _strategy != RepostStrategy.exact
            ? _modifiedHashtags
            : null,
        plannedAt: _plannedAt,
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
        createdAt: now,
      );
      provider.createPlan(plan);
    }

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? '재등록 계획 편집' : '새 재등록 계획'),
      ),
      body: Consumer2<ContentProvider, AnalyticsProvider>(
        builder: (context, contentProvider, analyticsProvider, _) {
          final originalContent = _originalContentId != null
              ? contentProvider.getContentById(_originalContentId!)
              : null;
          final record = _originalContentId != null
              ? analyticsProvider.getRecordByContentId(_originalContentId!)
              : null;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 원본 콘텐츠 미리보기
                Text('원본 콘텐츠', style: theme.textTheme.titleSmall),
                const SizedBox(height: 8),
                if (originalContent != null)
                  _buildOriginalPreview(theme, originalContent, record)
                else
                  _buildContentSelector(theme, contentProvider),
                const SizedBox(height: 24),

                // 전략 선택
                Text('재등록 전략', style: theme.textTheme.titleSmall),
                const SizedBox(height: 8),
                SegmentedButton<RepostStrategy>(
                  segments: [
                    ButtonSegment<RepostStrategy>(
                      value: RepostStrategy.exact,
                      label: const Text('그대로 재게시'),
                      icon: Icon(RepostStrategy.exact.icon, size: 18),
                    ),
                    ButtonSegment<RepostStrategy>(
                      value: RepostStrategy.modified,
                      label: const Text('캡션/해시태그 수정'),
                      icon: Icon(RepostStrategy.modified.icon, size: 18),
                    ),
                    ButtonSegment<RepostStrategy>(
                      value: RepostStrategy.remixed,
                      label: const Text('새롭게 리믹스'),
                      icon: Icon(RepostStrategy.remixed.icon, size: 18),
                    ),
                  ],
                  selected: {_strategy},
                  onSelectionChanged: (selected) {
                    setState(() => _strategy = selected.first);
                  },
                ),
                const SizedBox(height: 24),

                // 수정 가능한 필드 (modified/remixed 전략일 때)
                if (_strategy != RepostStrategy.exact) ...[
                  // 캡션 에디터
                  Text('캡션', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _captionController,
                    decoration: const InputDecoration(
                      hintText: '캡션을 입력하세요',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 5,
                    maxLength: 2200,
                  ),
                  const SizedBox(height: 16),

                  // 해시태그 에디터
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('해시태그', style: theme.textTheme.titleSmall),
                      Text(
                        '${_modifiedHashtags.length} / 30',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: _modifiedHashtags.length >= 30
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
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: List.generate(_modifiedHashtags.length, (index) {
                      return Chip(
                        label: Text(
                          _modifiedHashtags[index],
                          style: theme.textTheme.labelMedium,
                        ),
                        onDeleted: () => _removeHashtag(index),
                        deleteIconColor: theme.colorScheme.onSurfaceVariant,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      );
                    }),
                  ),
                  const SizedBox(height: 24),
                ],

                // 예정일 선택
                Text('예정 게시일', style: theme.textTheme.titleSmall),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      border:
                          Border.all(color: theme.colorScheme.outline),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 20,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          DateFormat('yyyy년 MM월 dd일 (E)', 'ko_KR')
                              .format(_plannedAt),
                          style: theme.textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 메모
                Text('메모 (선택)', style: theme.textTheme.titleSmall),
                const SizedBox(height: 8),
                TextField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    hintText: '재등록에 대한 메모를 작성하세요',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),

                // 원본 성과 데이터 참조 섹션
                if (record != null) ...[
                  Text('원본 성과 데이터', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  _buildPerformanceReference(theme, record),
                ],

                const SizedBox(height: 40),
              ],
            ),
          );
        },
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

  /// 원본 콘텐츠 미리보기 카드
  Widget _buildOriginalPreview(
    ThemeData theme,
    Content content,
    dynamic record,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // 썸네일
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 72,
                height: 72,
                child: content.imagePaths.isNotEmpty
                    ? Image.file(
                        File(content.imagePaths.first),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _buildPlaceholder(theme, content),
                      )
                    : _buildPlaceholder(theme, content),
              ),
            ),
            const SizedBox(width: 12),
            // 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    content.title,
                    style: theme.textTheme.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (content.caption.isNotEmpty)
                    Text(
                      content.caption,
                      style: theme.textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        content.contentType.icon,
                        size: 14,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        content.contentType.label,
                        style: theme.textTheme.labelSmall,
                      ),
                      if (record != null) ...[
                        const SizedBox(width: 8),
                        PerformanceBadge(grade: record.grade),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 콘텐츠 선택기 (원본이 없을 때)
  Widget _buildContentSelector(
      ThemeData theme, ContentProvider contentProvider) {
    final contents = contentProvider.postedContents;

    return InkWell(
      onTap: () => _showContentPicker(theme, contents),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          border: Border.all(
            color: theme.colorScheme.outline,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              size: 32,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 8),
            Text(
              '원본 콘텐츠를 선택하세요',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showContentPicker(ThemeData theme, List<Content> contents) {
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
                    '콘텐츠 선택',
                    style: theme.textTheme.headlineSmall,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: contents.isEmpty
                      ? const Center(child: Text('게시된 콘텐츠가 없습니다'))
                      : ListView.builder(
                          controller: scrollController,
                          itemCount: contents.length,
                          itemBuilder: (context, index) {
                            final content = contents[index];
                            return ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: SizedBox(
                                  width: 48,
                                  height: 48,
                                  child: content.imagePaths.isNotEmpty
                                      ? Image.file(
                                          File(content.imagePaths.first),
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              Container(
                                            color: theme.colorScheme
                                                .surfaceContainerHighest,
                                            child: Icon(
                                              content.contentType.icon,
                                              size: 20,
                                              color: theme.colorScheme
                                                  .onSurfaceVariant,
                                            ),
                                          ),
                                        )
                                      : Container(
                                          color: theme.colorScheme
                                              .surfaceContainerHighest,
                                          child: Icon(
                                            content.contentType.icon,
                                            size: 20,
                                            color: theme.colorScheme
                                                .onSurfaceVariant,
                                          ),
                                        ),
                                ),
                              ),
                              title: Text(content.title),
                              subtitle: Text(
                                content.caption,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall,
                              ),
                              onTap: () {
                                setState(() {
                                  _originalContentId = content.id;
                                  _captionController.text = content.caption;
                                  _modifiedHashtags =
                                      List.from(content.hashtags);
                                });
                                Navigator.pop(context);
                              },
                            );
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

  Widget _buildPlaceholder(ThemeData theme, Content content) {
    return Container(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          content.contentType.icon,
          size: 28,
          color: theme.colorScheme.onSurfaceVariant.withAlpha(120),
        ),
      ),
    );
  }

  /// 원본 성과 데이터 참조 (읽기 전용)
  Widget _buildPerformanceReference(ThemeData theme, dynamic record) {
    return Card(
      color: theme.colorScheme.surfaceContainerHighest.withAlpha(120),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                PerformanceBadge(grade: record.grade),
                const Spacer(),
                Text(
                  '참여율 ${record.engagementRate.toStringAsFixed(1)}%',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                      theme, Icons.favorite, '좋아요', '${record.likes}'),
                ),
                Expanded(
                  child: _buildStatItem(
                      theme, Icons.comment, '댓글', '${record.comments}'),
                ),
                Expanded(
                  child: _buildStatItem(
                      theme, Icons.share, '공유', '${record.shares}'),
                ),
                Expanded(
                  child: _buildStatItem(
                      theme, Icons.bookmark, '저장', '${record.saves}'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                      theme, Icons.visibility, '도달', '${record.reach}'),
                ),
                Expanded(
                  child: _buildStatItem(theme, Icons.remove_red_eye,
                      '노출', '${record.impressions}'),
                ),
                const Expanded(child: SizedBox()),
                const Expanded(child: SizedBox()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    ThemeData theme,
    IconData icon,
    String label,
    String value,
  ) {
    return Column(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleSmall,
        ),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
