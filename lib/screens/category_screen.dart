import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/constants.dart';
import '../models/category.dart';
import '../providers/category_provider.dart';
import '../providers/todo_provider.dart';

/// 카테고리 관리 화면
class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryProvider = context.watch<CategoryProvider>();
    final todoProvider = context.watch<TodoProvider>();
    final categories = categoryProvider.categories;

    return Scaffold(
      appBar: AppBar(title: const Text('카테고리 관리')),
      body: categories.isEmpty
          ? Center(
              child: Text(
                '카테고리가 없습니다',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                final count = todoProvider.todoCountByCategory[cat.id] ?? 0;
                return Dismissible(
                  key: Key(cat.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    color: theme.colorScheme.error,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (_) async {
                    return await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('카테고리 삭제'),
                        content: Text('"${cat.name}" 카테고리를 삭제하시겠습니까?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('취소'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                            child: const Text('삭제'),
                          ),
                        ],
                      ),
                    );
                  },
                  onDismissed: (_) {
                    categoryProvider.deleteCategory(cat.id);
                  },
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Color(cat.color).withAlpha(30),
                      child: Icon(
                        IconData(cat.icon, fontFamily: 'MaterialIcons'),
                        color: Color(cat.color),
                      ),
                    ),
                    title: Text(cat.name),
                    subtitle: Text('$count개의 할일'),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showEditDialog(context, cat),
                    ),
                    onTap: () => _showEditDialog(context, cat),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    _showCategoryDialog(context, null);
  }

  void _showEditDialog(BuildContext context, Category category) {
    _showCategoryDialog(context, category);
  }

  void _showCategoryDialog(BuildContext context, Category? existing) {
    final nameController = TextEditingController(text: existing?.name ?? '');
    int selectedColorIndex = existing != null
        ? DefaultCategories.colorPalette.indexWhere(
            (c) => c.toARGB32() == existing.color,
          )
        : 0;
    if (selectedColorIndex < 0) selectedColorIndex = 0;

    int selectedIconIndex = existing != null
        ? DefaultCategories.iconOptions.indexWhere(
            (i) => i.codePoint == existing.icon,
          )
        : 0;
    if (selectedIconIndex < 0) selectedIconIndex = 0;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(existing != null ? '카테고리 편집' : '카테고리 추가'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: '카테고리 이름',
                        hintText: '이름을 입력하세요',
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('색상'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(
                        DefaultCategories.colorPalette.length,
                        (i) {
                          final isSelected = i == selectedColorIndex;
                          return GestureDetector(
                            onTap: () {
                              setDialogState(() => selectedColorIndex = i);
                            },
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: DefaultCategories.colorPalette[i],
                                shape: BoxShape.circle,
                                border: isSelected
                                    ? Border.all(
                                        color: Colors.white,
                                        width: 3,
                                      )
                                    : null,
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: DefaultCategories.colorPalette[i]
                                              .withAlpha(120),
                                          blurRadius: 8,
                                        ),
                                      ]
                                    : null,
                              ),
                              child: isSelected
                                  ? const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 18,
                                    )
                                  : null,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('아이콘'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(
                        DefaultCategories.iconOptions.length,
                        (i) {
                          final isSelected = i == selectedIconIndex;
                          return GestureDetector(
                            onTap: () {
                              setDialogState(() => selectedIconIndex = i);
                            },
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? DefaultCategories.colorPalette[selectedColorIndex]
                                        .withAlpha(30)
                                    : null,
                                borderRadius: BorderRadius.circular(8),
                                border: isSelected
                                    ? Border.all(
                                        color: DefaultCategories.colorPalette[
                                            selectedColorIndex],
                                      )
                                    : null,
                              ),
                              child: Icon(
                                DefaultCategories.iconOptions[i],
                                color: isSelected
                                    ? DefaultCategories.colorPalette[selectedColorIndex]
                                    : null,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('취소'),
                ),
                FilledButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    if (name.isEmpty) return;

                    final provider = context.read<CategoryProvider>();
                    final color =
                        DefaultCategories.colorPalette[selectedColorIndex].toARGB32();
                    final icon = DefaultCategories.iconOptions[selectedIconIndex].codePoint;

                    if (existing != null) {
                      provider.updateCategory(existing.copyWith(
                        name: name,
                        color: color,
                        icon: icon,
                      ));
                    } else {
                      provider.addCategory(
                        name: name,
                        color: color,
                        icon: icon,
                      );
                    }
                    Navigator.pop(context);
                  },
                  child: const Text('저장'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
