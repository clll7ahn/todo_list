/// 하위 작업(서브태스크) 모델
class Subtask {
  /// 고유 식별자
  final String id;

  /// 서브태스크 제목
  final String title;

  /// 완료 여부
  final bool isCompleted;

  const Subtask({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });

  /// JSON에서 Subtask 생성
  factory Subtask.fromJson(Map<String, dynamic> json) {
    return Subtask(
      id: json['id'] as String,
      title: json['title'] as String,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  /// Subtask를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
    };
  }

  /// 복사본 생성 (일부 필드 변경)
  Subtask copyWith({
    String? id,
    String? title,
    bool? isCompleted,
  }) {
    return Subtask(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Subtask && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
