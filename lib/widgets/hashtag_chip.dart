import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/enums.dart';

/// 해시태그 칩 위젯
/// 단일 해시태그 표시, 탭으로 복사, 선택적 삭제 버튼
class HashtagChip extends StatelessWidget {
  const HashtagChip({
    super.key,
    required this.hashtag,
    this.category,
    this.onDelete,
  });

  /// 해시태그 텍스트 (# 접두사 없이 전달해도 자동 추가)
  final String hashtag;

  /// 해시태그 카테고리 (선택, 색상 결정에 사용)
  final HashtagCategory? category;

  /// 삭제 콜백 (선택, 있으면 X 버튼 표시)
  final VoidCallback? onDelete;

  /// # 접두사가 없으면 추가
  String get _displayText {
    return hashtag.startsWith('#') ? hashtag : '#$hashtag';
  }

  /// 카테고리별 색상
  Color _categoryColor() {
    if (category == null) return const Color(0xFF833AB4);
    switch (category!) {
      case HashtagCategory.brand:
        return const Color(0xFF833AB4);
      case HashtagCategory.niche:
        return const Color(0xFF1976D2);
      case HashtagCategory.trending:
        return const Color(0xFFE53935);
      case HashtagCategory.location:
        return const Color(0xFF43A047);
      case HashtagCategory.general:
        return const Color(0xFF757575);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _categoryColor();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Clipboard.setData(ClipboardData(text: _displayText));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$_displayText 복사됨'),
              duration: const Duration(seconds: 1),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.only(
            left: 10,
            right: onDelete != null ? 4 : 10,
            top: 4,
            bottom: 4,
          ),
          decoration: BoxDecoration(
            color: color.withAlpha(20),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withAlpha(60), width: 0.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _displayText,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
              if (onDelete != null) ...[
                const SizedBox(width: 2),
                InkWell(
                  onTap: onDelete,
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: Icon(
                      Icons.close,
                      size: 14,
                      color: color,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
