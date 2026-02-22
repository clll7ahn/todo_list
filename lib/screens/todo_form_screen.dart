import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/enums.dart';
import '../models/subtask.dart';
import '../models/todo.dart';
import '../providers/category_provider.dart';
import '../providers/todo_provider.dart';
import '../utils/date_utils.dart';

/// 할일 추가/편집 화면
class TodoFormScreen extends StatefulWidget {
  final String? todoId;

  const TodoFormScreen({super.key, this.todoId});

  @override
  State<TodoFormScreen> createState() => _TodoFormScreenState();
}

class _TodoFormScreenState extends State<TodoFormScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _subtaskController = TextEditingController();

  Priority _priority = Priority.medium;
  String _categoryId = '';
  DateTime? _dueDate;
  TimeOfDay? _dueTime;
  bool _isImportant = false;
  RepeatType _repeatType = RepeatType.none;
  List<Subtask> _subtasks = [];

  bool get _isEditing => widget.todoId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final todo = context.read<TodoProvider>().getTodoById(widget.todoId!);
        if (todo != null) {
          setState(() {
            _titleController.text = todo.title;
            _descController.text = todo.description;
            _priority = todo.priority;
            _categoryId = todo.categoryId;
            _dueDate = todo.dueDate;
            if (todo.dueDate != null) {
              _dueTime = TimeOfDay.fromDateTime(todo.dueDate!);
            }
            _isImportant = todo.isImportant;
            _repeatType = todo.repeatType;
            _subtasks = List.from(todo.subtasks);
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _subtaskController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
      locale: const Locale('ko', 'KR'),
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _dueTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _dueTime = picked);
    }
  }

  void _addSubtask() {
    final title = _subtaskController.text.trim();
    if (title.isEmpty) return;
    setState(() {
      _subtasks.add(Subtask(
        id: const Uuid().v4(),
        title: title,
      ));
      _subtaskController.clear();
    });
  }

  void _removeSubtask(int index) {
    setState(() => _subtasks.removeAt(index));
  }

  void _save() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('제목을 입력하세요')),
      );
      return;
    }

    // 날짜+시간 조합
    DateTime? finalDueDate = _dueDate;
    if (finalDueDate != null && _dueTime != null) {
      finalDueDate = DateTime(
        finalDueDate.year,
        finalDueDate.month,
        finalDueDate.day,
        _dueTime!.hour,
        _dueTime!.minute,
      );
    }

    final todoProvider = context.read<TodoProvider>();
    final now = DateTime.now();

    if (_isEditing) {
      final existing = todoProvider.getTodoById(widget.todoId!);
      if (existing != null) {
        final updated = existing.copyWith(
          title: title,
          description: _descController.text.trim(),
          categoryId: _categoryId,
          priority: _priority,
          dueDate: finalDueDate,
          isImportant: _isImportant,
          repeatType: _repeatType,
          subtasks: _subtasks,
          updatedAt: now,
          clearDueDate: finalDueDate == null && existing.dueDate != null,
        );
        todoProvider.updateTodo(updated);
      }
    } else {
      final todo = Todo(
        id: const Uuid().v4(),
        title: title,
        description: _descController.text.trim(),
        categoryId: _categoryId,
        priority: _priority,
        dueDate: finalDueDate,
        isImportant: _isImportant,
        repeatType: _repeatType,
        subtasks: _subtasks,
        createdAt: now,
        updatedAt: now,
      );
      todoProvider.addTodo(todo);
    }

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categories = context.watch<CategoryProvider>().categories;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? '할일 편집' : '새 할일'),
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
            // 제목 입력
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: '제목',
                hintText: '할일을 입력하세요',
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            // 설명 입력
            TextField(
              controller: _descController,
              decoration: const InputDecoration(
                labelText: '설명 (선택)',
                hintText: '상세 내용을 입력하세요',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // 우선순위 선택
            Text('우선순위', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Row(
              children: Priority.values.map((p) {
                final isSelected = _priority == p;
                final chipColor = switch (p) {
                  Priority.high => const Color(0xFFE53935),
                  Priority.medium => const Color(0xFFFB8C00),
                  Priority.low => const Color(0xFF43A047),
                };
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(p.label),
                    selected: isSelected,
                    selectedColor: chipColor.withAlpha(50),
                    onSelected: (_) => setState(() => _priority = p),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // 카테고리 선택
            Text('카테고리', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _categoryId.isEmpty ? null : _categoryId,
              decoration: const InputDecoration(
                hintText: '카테고리 선택',
              ),
              items: [
                const DropdownMenuItem(
                  value: '',
                  child: Text('없음'),
                ),
                ...categories.map((cat) {
                  return DropdownMenuItem(
                    value: cat.id,
                    child: Row(
                      children: [
                        Icon(
                          IconData(cat.icon, fontFamily: 'MaterialIcons'),
                          color: Color(cat.color),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(cat.name),
                      ],
                    ),
                  );
                }),
              ],
              onChanged: (value) {
                setState(() => _categoryId = value ?? '');
              },
            ),
            const SizedBox(height: 24),

            // 마감일/시간
            Text('마감일', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_today, size: 18),
                    label: Text(
                      _dueDate != null
                          ? AppDateUtils.formatRelativeDate(_dueDate!)
                          : '날짜 선택',
                    ),
                    onPressed: _selectDate,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.access_time, size: 18),
                    label: Text(
                      _dueTime != null
                          ? _dueTime!.format(context)
                          : '시간 선택',
                    ),
                    onPressed: _selectTime,
                  ),
                ),
                if (_dueDate != null)
                  IconButton(
                    icon: const Icon(Icons.clear, size: 20),
                    onPressed: () {
                      setState(() {
                        _dueDate = null;
                        _dueTime = null;
                      });
                    },
                  ),
              ],
            ),
            const SizedBox(height: 24),

            // 반복 설정
            Text('반복', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: RepeatType.values.map((r) {
                return ChoiceChip(
                  label: Text(r.label),
                  selected: _repeatType == r,
                  onSelected: (_) => setState(() => _repeatType = r),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // 중요 표시
            SwitchListTile(
              title: const Text('중요 표시'),
              subtitle: const Text('중요한 할일로 표시합니다'),
              secondary: Icon(
                _isImportant ? Icons.star : Icons.star_border,
                color: _isImportant ? Colors.amber : null,
              ),
              value: _isImportant,
              onChanged: (value) => setState(() => _isImportant = value),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 24),

            // 하위 작업
            Text('하위 작업', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _subtaskController,
                    decoration: const InputDecoration(
                      hintText: '하위 작업 추가',
                    ),
                    onSubmitted: (_) => _addSubtask(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  icon: const Icon(Icons.add),
                  onPressed: _addSubtask,
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...List.generate(_subtasks.length, (index) {
              final subtask = _subtasks[index];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Checkbox(
                  value: subtask.isCompleted,
                  onChanged: (value) {
                    setState(() {
                      _subtasks[index] = subtask.copyWith(
                        isCompleted: value ?? false,
                      );
                    });
                  },
                ),
                title: Text(
                  subtask.title,
                  style: TextStyle(
                    decoration:
                        subtask.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () => _removeSubtask(index),
                ),
              );
            }),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
