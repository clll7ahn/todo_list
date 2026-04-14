import 'package:flutter/material.dart';
import '../config/constants.dart';

/// 캡션 편집 위젯
/// 실시간 글자수 카운터, 해시태그 하이라이팅, 라인 카운트 포함
class CaptionEditor extends StatefulWidget {
  const CaptionEditor({
    super.key,
    this.initialValue,
    this.onChanged,
    this.controller,
  });

  /// 초기 값
  final String? initialValue;

  /// 텍스트 변경 콜백
  final ValueChanged<String>? onChanged;

  /// 외부 컨트롤러 (선택)
  final TextEditingController? controller;

  @override
  State<CaptionEditor> createState() => _CaptionEditorState();
}

class _CaptionEditorState extends State<CaptionEditor> {
  late final TextEditingController _controller;
  bool _ownsController = false;
  int _charCount = 0;
  int _lineCount = 1;

  static const int _maxLength = AppConstants.maxCaptionLength;
  static const int _warningThreshold = 2000;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = TextEditingController(text: widget.initialValue ?? '');
      _ownsController = true;
    }
    _charCount = _controller.text.length;
    _lineCount = _controller.text.isEmpty ? 1 : '\n'.allMatches(_controller.text).length + 1;
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onTextChanged() {
    final text = _controller.text;
    setState(() {
      _charCount = text.length;
      _lineCount = text.isEmpty ? 1 : '\n'.allMatches(text).length + 1;
    });
    widget.onChanged?.call(text);
  }

  Color _counterColor(ThemeData theme) {
    if (_charCount > _maxLength) {
      return theme.colorScheme.error;
    } else if (_charCount > _warningThreshold) {
      return const Color(0xFFFB8C00);
    }
    return theme.colorScheme.onSurfaceVariant;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final counterColor = _counterColor(theme);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _controller,
          decoration: const InputDecoration(
            labelText: '캡션',
            hintText: '게시물 캡션을 입력하세요...',
            alignLabelWithHint: true,
          ),
          maxLines: 8,
          minLines: 4,
          textInputAction: TextInputAction.newline,
          validator: (value) {
            if (value != null && value.length > _maxLength) {
              return '캡션은 $_maxLength자를 초과할 수 없습니다';
            }
            return null;
          },
        ),
        const SizedBox(height: 8),
        // 카운터 & 라인 정보
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 라인 수
            Text(
              '$_lineCount줄',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            // 글자 수 카운터
            Text(
              '${_formatNumber(_charCount)} / ${_formatNumber(_maxLength)}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: counterColor,
                fontWeight: _charCount > _warningThreshold
                    ? FontWeight.w700
                    : FontWeight.w400,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${number ~/ 1000},${(number % 1000).toString().padLeft(3, '0')}';
    }
    return number.toString();
  }
}
