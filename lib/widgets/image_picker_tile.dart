import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// 이미지 선택 타일 위젯
/// 이미지 썸네일 또는 추가(+) 플레이스홀더 표시
class ImagePickerTile extends StatelessWidget {
  const ImagePickerTile({
    super.key,
    this.imagePath,
    this.index,
    this.onImagePicked,
    this.onRemove,
    this.showDragHandle = false,
  });

  /// 선택된 이미지 경로 (null이면 추가 플레이스홀더)
  final String? imagePath;

  /// 이미지 인덱스 번호
  final int? index;

  /// 이미지 선택 콜백
  final ValueChanged<String>? onImagePicked;

  /// 이미지 제거 콜백
  final VoidCallback? onRemove;

  /// 드래그 핸들 표시 여부
  final bool showDragHandle;

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1080,
      maxHeight: 1080,
      imageQuality: 85,
    );
    if (picked != null) {
      onImagePicked?.call(picked.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasImage = imagePath != null && imagePath!.isNotEmpty;

    return GestureDetector(
      onTap: () => _pickImage(context),
      onLongPress: hasImage ? onRemove : null,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasImage
                ? Colors.transparent
                : colorScheme.outline.withAlpha(80),
            width: 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: hasImage ? _buildImageTile(context) : _buildAddTile(context),
      ),
    );
  }

  /// 이미지 썸네일
  Widget _buildImageTile(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.file(
          File(imagePath!),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: theme.colorScheme.errorContainer,
            child: Icon(
              Icons.broken_image,
              color: theme.colorScheme.onErrorContainer,
            ),
          ),
        ),
        // 인덱스 번호
        if (index != null)
          Positioned(
            top: 4,
            left: 4,
            child: Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${index! + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        // 삭제 버튼
        if (onRemove != null)
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        // 드래그 핸들
        if (showDragHandle)
          Positioned(
            bottom: 4,
            right: 4,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.black38,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(
                Icons.drag_handle,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }

  /// 추가 플레이스홀더
  Widget _buildAddTile(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_photo_alternate_outlined,
          size: 28,
          color: colorScheme.onSurfaceVariant.withAlpha(150),
        ),
        const SizedBox(height: 4),
        Text(
          '추가',
          style: TextStyle(
            fontSize: 11,
            color: colorScheme.onSurfaceVariant.withAlpha(150),
          ),
        ),
      ],
    );
  }
}
