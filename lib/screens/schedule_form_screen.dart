import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/content.dart';
import '../models/enums.dart';
import '../models/schedule.dart';
import '../providers/content_provider.dart';
import '../providers/schedule_provider.dart';
import '../widgets/time_slot_picker.dart';

/// 스케줄 생성/편집 폼 화면
class ScheduleFormScreen extends StatefulWidget {
  final String? scheduleId;

  const ScheduleFormScreen({super.key, this.scheduleId});

  @override
  State<ScheduleFormScreen> createState() => _ScheduleFormScreenState();
}

class _ScheduleFormScreenState extends State<ScheduleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _memoController = TextEditingController();

  String? _selectedContentId;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  PostTimeSlot _selectedTimeSlot = PostTimeSlot.morning;
  ScheduleRepeatType _repeatType = ScheduleRepeatType.none;

  bool get _isEditing => widget.scheduleId != null;

  @override
  void initState() {
    super.initState();
    // 시간대에 따라 초기 시간 설정
    _updateTimeFromSlot(_selectedTimeSlot);
    if (_isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadExistingSchedule();
      });
    }
  }

  void _loadExistingSchedule() {
    final schedule = context
        .read<ScheduleProvider>()
        .getScheduleById(widget.scheduleId!);
    if (schedule != null) {
      setState(() {
        _selectedContentId = schedule.contentId;
        _selectedDate = schedule.scheduledAt;
        _selectedTime = TimeOfDay(
          hour: schedule.scheduledAt.hour,
          minute: schedule.scheduledAt.minute,
        );
        _selectedTimeSlot = schedule.timeSlot;
        _repeatType = schedule.repeatType;
        _memoController.text = schedule.memo ?? '';
      });
    }
  }

  void _updateTimeFromSlot(PostTimeSlot slot) {
    switch (slot) {
      case PostTimeSlot.morning:
        _selectedTime = const TimeOfDay(hour: 9, minute: 0);
      case PostTimeSlot.afternoon:
        _selectedTime = const TimeOfDay(hour: 14, minute: 0);
      case PostTimeSlot.evening:
        _selectedTime = const TimeOfDay(hour: 19, minute: 0);
      case PostTimeSlot.night:
        _selectedTime = const TimeOfDay(hour: 22, minute: 0);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030, 12, 31),
      locale: const Locale('ko', 'KR'),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  void _showContentSelector() {
    final contentProvider = context.read<ContentProvider>();
    final contents = [
      ...contentProvider.readyContents,
      ...contentProvider.draftContents,
    ];

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
                    '콘텐츠 선택',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: contents.isEmpty
                      ? const Center(child: Text('사용 가능한 콘텐츠가 없습니다'))
                      : ListView.builder(
                          controller: scrollController,
                          itemCount: contents.length,
                          itemBuilder: (context, index) {
                            final content = contents[index];
                            return _buildContentTile(content);
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

  Widget _buildContentTile(Content content) {
    final theme = Theme.of(context);
    final isSelected = _selectedContentId == content.id;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isSelected
            ? theme.colorScheme.primary.withAlpha(40)
            : theme.colorScheme.surfaceContainerHighest,
        child: Icon(
          content.contentType.icon,
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurfaceVariant,
          size: 20,
        ),
      ),
      title: Text(
        content.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Row(
        children: [
          Text(
            content.contentType.label,
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: content.status == ContentStatus.ready
                  ? const Color(0xFF43A047).withAlpha(25)
                  : theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              content.status.label,
              style: TextStyle(
                fontSize: 10,
                color: content.status == ContentStatus.ready
                    ? const Color(0xFF43A047)
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
          : null,
      onTap: () {
        setState(() => _selectedContentId = content.id);
        Navigator.pop(context);
      },
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedContentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('콘텐츠를 선택하세요')),
      );
      return;
    }

    final scheduledAt = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final memoText = _memoController.text.trim();
    final provider = context.read<ScheduleProvider>();
    final now = DateTime.now();

    if (_isEditing) {
      final existing = provider.getScheduleById(widget.scheduleId!);
      if (existing != null) {
        final updated = existing.copyWith(
          contentId: _selectedContentId,
          scheduledAt: scheduledAt,
          timeSlot: _selectedTimeSlot,
          repeatType: _repeatType,
          memo: memoText.isNotEmpty ? memoText : null,
          updatedAt: now,
          clearMemo: memoText.isEmpty && existing.memo != null,
        );
        provider.updateSchedule(updated);
      }
    } else {
      final schedule = Schedule(
        id: const Uuid().v4(),
        contentId: _selectedContentId!,
        scheduledAt: scheduledAt,
        timeSlot: _selectedTimeSlot,
        repeatType: _repeatType,
        memo: memoText.isNotEmpty ? memoText : null,
        createdAt: now,
        updatedAt: now,
      );
      provider.addSchedule(schedule);
    }

    context.pop();
  }

  @override
  void dispose() {
    _memoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // 선택된 콘텐츠 정보
    final selectedContent = _selectedContentId != null
        ? context.watch<ContentProvider>().getContentById(_selectedContentId!)
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? '스케줄 편집' : '새 스케줄'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 콘텐츠 선택 섹션
              Text('콘텐츠', style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              InkWell(
                onTap: _showContentSelector,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _selectedContentId == null
                          ? colorScheme.error.withAlpha(150)
                          : colorScheme.outlineVariant,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    color: colorScheme.surfaceContainerLowest,
                  ),
                  child: selectedContent != null
                      ? Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor:
                                  colorScheme.primary.withAlpha(25),
                              child: Icon(
                                selectedContent.contentType.icon,
                                color: colorScheme.primary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    selectedContent.title,
                                    style: theme.textTheme.bodyMedium
                                        ?.copyWith(
                                            fontWeight: FontWeight.w600),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${selectedContent.contentType.label} - ${selectedContent.status.label}',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            Icon(
                              Icons.add_circle_outline,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '게시할 콘텐츠를 선택하세요',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 24),

              // 날짜 선택
              Text('게시 날짜', style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: colorScheme.outlineVariant),
                    borderRadius: BorderRadius.circular(12),
                    color: colorScheme.surfaceContainerLowest,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${_selectedDate.year}년 ${_selectedDate.month}월 ${_selectedDate.day}일',
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.chevron_right,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 시간대 선택 (빠른 선택)
              Text('시간대', style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              TimeSlotPicker(
                selected: _selectedTimeSlot,
                onSelected: (slot) {
                  setState(() {
                    _selectedTimeSlot = slot;
                    _updateTimeFromSlot(slot);
                  });
                },
              ),
              const SizedBox(height: 16),

              // 정확한 시간 선택
              Text('정확한 시간', style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickTime,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: colorScheme.outlineVariant),
                    borderRadius: BorderRadius.circular(12),
                    color: colorScheme.surfaceContainerLowest,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        color: colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.chevron_right,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // 최적 시간 추천 텍스트
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withAlpha(40),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      size: 16,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '이전 게시물 분석: 오후 6시가 가장 효과적',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 반복 유형 선택
              Text('반복 설정', style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ScheduleRepeatType.values.map((type) {
                  final isSelected = type == _repeatType;
                  return ChoiceChip(
                    label: Text(type.label),
                    avatar: Icon(type.icon, size: 16),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() => _repeatType = type);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // 메모
              Text('메모 (선택)', style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              TextField(
                controller: _memoController,
                decoration: const InputDecoration(
                  hintText: '스케줄에 대한 메모를 작성하세요',
                ),
                maxLines: 3,
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
            child: Text(_isEditing ? '수정' : '저장'),
          ),
        ),
      ),
    );
  }
}
