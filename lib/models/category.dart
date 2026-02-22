// 카테고리 모델

class Category {
  /// 고유 식별자
  final String id;

  /// 카테고리 이름
  final String name;

  /// 색상 값 (Color.value)
  final int color;

  /// 아이콘 코드포인트 (IconData.codePoint)
  final int icon;

  const Category({
    required this.id,
    required this.name,
    required this.color,
    required this.icon,
  });

  /// JSON에서 Category 생성
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      color: json['color'] as int,
      icon: json['icon'] as int,
    );
  }

  /// Category를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'icon': icon,
    };
  }

  /// 복사본 생성 (일부 필드 변경)
  Category copyWith({
    String? id,
    String? name,
    int? color,
    int? icon,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      icon: icon ?? this.icon,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Category && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
