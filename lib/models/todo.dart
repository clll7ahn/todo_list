import 'enums.dart';
import 'subtask.dart';

/// 할일 모델
class Todo {
  /// 고유 식별자 (UUID)
  final String id;

  /// 할일 제목
  final String title;

  /// 할일 설명
  final String description;

  /// 카테고리 ID
  final String categoryId;

  /// 우선순위
  final Priority priority;

  /// 마감일
  final DateTime? dueDate;

  /// 완료 여부
  final bool isCompleted;

  /// 중요 표시
  final bool isImportant;

  /// 반복 유형
  final RepeatType repeatType;

  /// 하위 작업 목록
  final List<Subtask> subtasks;

  /// 생성일
  final DateTime createdAt;

  /// 수정일
  final DateTime updatedAt;

  const Todo({
    required this.id,
    required this.title,
    this.description = '',
    this.categoryId = '',
    this.priority = Priority.medium,
    this.dueDate,
    this.isCompleted = false,
    this.isImportant = false,
    this.repeatType = RepeatType.none,
    this.subtasks = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  /// JSON에서 Todo 생성
  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      categoryId: json['categoryId'] as String? ?? '',
      priority: PriorityExtension.fromValue(
        json['priority'] as String? ?? 'medium',
      ),
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : null,
      isCompleted: json['isCompleted'] as bool? ?? false,
      isImportant: json['isImportant'] as bool? ?? false,
      repeatType: RepeatTypeExtension.fromValue(
        json['repeatType'] as String? ?? 'none',
      ),
      subtasks: (json['subtasks'] as List<dynamic>?)
              ?.map((e) => Subtask.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Todo를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'categoryId': categoryId,
      'priority': priority.value,
      'dueDate': dueDate?.toIso8601String(),
      'isCompleted': isCompleted,
      'isImportant': isImportant,
      'repeatType': repeatType.value,
      'subtasks': subtasks.map((s) => s.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// 복사본 생성 (일부 필드 변경)
  Todo copyWith({
    String? id,
    String? title,
    String? description,
    String? categoryId,
    Priority? priority,
    DateTime? dueDate,
    bool? isCompleted,
    bool? isImportant,
    RepeatType? repeatType,
    List<Subtask>? subtasks,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearDueDate = false,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      priority: priority ?? this.priority,
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      isCompleted: isCompleted ?? this.isCompleted,
      isImportant: isImportant ?? this.isImportant,
      repeatType: repeatType ?? this.repeatType,
      subtasks: subtasks ?? this.subtasks,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 완료된 하위 작업 수
  int get completedSubtaskCount =>
      subtasks.where((s) => s.isCompleted).length;

  /// 하위 작업 완료율 (0.0 ~ 1.0)
  double get subtaskProgress {
    if (subtasks.isEmpty) return 0.0;
    return completedSubtaskCount / subtasks.length;
  }

  /// 오늘 마감 여부
  bool get isDueToday {
    if (dueDate == null) return false;
    final now = DateTime.now();
    return dueDate!.year == now.year &&
        dueDate!.month == now.month &&
        dueDate!.day == now.day;
  }

  /// 마감일 초과 여부
  bool get isOverdue {
    if (dueDate == null || isCompleted) return false;
    return dueDate!.isBefore(DateTime.now());
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Todo && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
