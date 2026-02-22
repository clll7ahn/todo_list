import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/enums.dart';
import '../models/todo.dart';
import '../providers/category_provider.dart';
import '../providers/todo_provider.dart';
import '../utils/date_utils.dart';

/// 할일 목록 아이템 위젯
class TodoTile extends StatelessWidget {
  final Todo todo;
  final VoidCallback? onTap;

  const TodoTile({super.key, required this.todo, this.onTap});

  Color _priorityColor() {
    switch (todo.priority) {
      case Priority.high:
        return const Color(0xFFE53935);
      case Priority.medium:
        return const Color(0xFFFB8C00);
      case Priority.low:
        return const Color(0xFF43A047);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryProvider = context.read<CategoryProvider>();
    final category = categoryProvider.getCategoryById(todo.categoryId);

    return Dismissible(
      key: Key(todo.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: theme.colorScheme.error,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        context.read<TodoProvider>().deleteTodo(todo.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('"${todo.title}" 삭제됨')),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // 우선순위 표시 바
                Container(
                  width: 4,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _priorityColor(),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                // 완료 체크박스
                Checkbox(
                  value: todo.isCompleted,
                  onChanged: (_) {
                    context.read<TodoProvider>().toggleComplete(todo.id);
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 8),
                // 내용 영역
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        todo.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          decoration: todo.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          color: todo.isCompleted
                              ? theme.colorScheme.onSurfaceVariant
                              : null,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          // 카테고리 태그
                          if (category != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Color(category.color).withAlpha(30),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                category.name,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: Color(category.color),
                                ),
                              ),
                            ),
                          if (category != null && todo.dueDate != null)
                            const SizedBox(width: 8),
                          // 마감일
                          if (todo.dueDate != null)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.schedule,
                                  size: 14,
                                  color: todo.isOverdue
                                      ? theme.colorScheme.error
                                      : theme.colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  AppDateUtils.formatRelativeDate(todo.dueDate!),
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: todo.isOverdue
                                        ? theme.colorScheme.error
                                        : theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          // 서브태스크 카운트
                          if (todo.subtasks.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Icon(
                              Icons.checklist,
                              size: 14,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${todo.completedSubtaskCount}/${todo.subtasks.length}',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                // 중요 표시 버튼
                IconButton(
                  icon: Icon(
                    todo.isImportant ? Icons.star : Icons.star_border,
                    color: todo.isImportant ? Colors.amber : null,
                    size: 22,
                  ),
                  onPressed: () {
                    context.read<TodoProvider>().toggleImportant(todo.id);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
