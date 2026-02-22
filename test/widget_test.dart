import 'package:flutter_test/flutter_test.dart';
import 'package:todo_list/models/todo.dart';
import 'package:todo_list/models/subtask.dart';
import 'package:todo_list/models/category.dart';
import 'package:todo_list/models/enums.dart';

void main() {
  group('Todo 모델 테스트', () {
    test('Todo 생성 테스트', () {
      final now = DateTime.now();
      final todo = Todo(
        id: 'test-1',
        title: '테스트 할일',
        createdAt: now,
        updatedAt: now,
      );

      expect(todo.title, '테스트 할일');
      expect(todo.isCompleted, false);
      expect(todo.priority, Priority.medium);
    });

    test('Todo JSON 직렬화 테스트', () {
      final now = DateTime.now();
      final todo = Todo(
        id: 'test-1',
        title: '테스트 할일',
        description: '설명',
        priority: Priority.high,
        isImportant: true,
        createdAt: now,
        updatedAt: now,
      );

      final json = todo.toJson();
      final restored = Todo.fromJson(json);

      expect(restored.id, todo.id);
      expect(restored.title, todo.title);
      expect(restored.description, todo.description);
      expect(restored.priority, Priority.high);
      expect(restored.isImportant, true);
    });

    test('Todo copyWith 테스트', () {
      final now = DateTime.now();
      final todo = Todo(
        id: 'test-1',
        title: '원래 제목',
        createdAt: now,
        updatedAt: now,
      );

      final updated = todo.copyWith(title: '변경된 제목', isCompleted: true);

      expect(updated.title, '변경된 제목');
      expect(updated.isCompleted, true);
      expect(updated.id, todo.id);
    });

    test('Todo 마감일 관련 테스트', () {
      final now = DateTime.now();
      final overdueTodo = Todo(
        id: 'test-1',
        title: '지난 할일',
        dueDate: now.subtract(const Duration(days: 1)),
        createdAt: now,
        updatedAt: now,
      );

      expect(overdueTodo.isOverdue, true);

      final todayTodo = Todo(
        id: 'test-2',
        title: '오늘 할일',
        dueDate: now,
        createdAt: now,
        updatedAt: now,
      );

      expect(todayTodo.isDueToday, true);
    });
  });

  group('Subtask 모델 테스트', () {
    test('Subtask 생성 테스트', () {
      const subtask = Subtask(
        id: 'sub-1',
        title: '하위 작업',
      );

      expect(subtask.title, '하위 작업');
      expect(subtask.isCompleted, false);
    });

    test('Subtask JSON 직렬화 테스트', () {
      const subtask = Subtask(
        id: 'sub-1',
        title: '하위 작업',
        isCompleted: true,
      );

      final json = subtask.toJson();
      final restored = Subtask.fromJson(json);

      expect(restored.id, subtask.id);
      expect(restored.title, subtask.title);
      expect(restored.isCompleted, true);
    });
  });

  group('Category 모델 테스트', () {
    test('Category 생성 테스트', () {
      const category = Category(
        id: 'cat-1',
        name: '업무',
        color: 0xFF1976D2,
        icon: 0xe8f9,
      );

      expect(category.name, '업무');
      expect(category.color, 0xFF1976D2);
    });

    test('Category JSON 직렬화 테스트', () {
      const category = Category(
        id: 'cat-1',
        name: '개인',
        color: 0xFF7B1FA2,
        icon: 0xe7fd,
      );

      final json = category.toJson();
      final restored = Category.fromJson(json);

      expect(restored.id, category.id);
      expect(restored.name, category.name);
      expect(restored.color, category.color);
    });
  });

  group('Enum 테스트', () {
    test('Priority 라벨 테스트', () {
      expect(Priority.high.label, '높음');
      expect(Priority.medium.label, '중간');
      expect(Priority.low.label, '낮음');
    });

    test('RepeatType 라벨 테스트', () {
      expect(RepeatType.none.label, '반복 없음');
      expect(RepeatType.daily.label, '매일');
    });

    test('Priority fromValue 테스트', () {
      expect(PriorityExtension.fromValue('high'), Priority.high);
      expect(PriorityExtension.fromValue('medium'), Priority.medium);
      expect(PriorityExtension.fromValue('unknown'), Priority.low);
    });
  });
}
