import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../config/constants.dart';
import '../models/enums.dart';
import '../providers/category_provider.dart';
import '../providers/todo_provider.dart';
import '../widgets/todo_tile.dart';

/// 홈 화면 - 할일 목록 메인 화면
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isSearching = false;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final todoProvider = context.watch<TodoProvider>();
    final categoryProvider = context.watch<CategoryProvider>();
    final todos = todoProvider.filteredTodos;

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: '할일 검색...',
                  border: InputBorder.none,
                  filled: false,
                ),
                onChanged: (value) {
                  todoProvider.setSearchQuery(value);
                },
              )
            : const Text(AppConstants.appName),
        actions: [
          // 검색 버튼
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  todoProvider.setSearchQuery('');
                }
              });
            },
          ),
          // 정렬 메뉴
          PopupMenuButton<SortType>(
            icon: const Icon(Icons.sort),
            tooltip: '정렬',
            onSelected: (sort) => todoProvider.setSortType(sort),
            itemBuilder: (context) => SortType.values.map((sort) {
              return PopupMenuItem(
                value: sort,
                child: Row(
                  children: [
                    if (todoProvider.sortType == sort)
                      Icon(Icons.check, size: 18, color: theme.colorScheme.primary)
                    else
                      const SizedBox(width: 18),
                    const SizedBox(width: 8),
                    Text(_sortLabel(sort)),
                  ],
                ),
              );
            }).toList(),
          ),
          // 카테고리 관리
          IconButton(
            icon: const Icon(Icons.category),
            tooltip: '카테고리 관리',
            onPressed: () => context.push('/categories'),
          ),
        ],
      ),
      body: Column(
        children: [
          // 필터 탭
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                ...FilterType.values.map((filter) {
                  final isSelected = todoProvider.filterType == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(_filterLabel(filter)),
                      selected: isSelected,
                      onSelected: (_) => todoProvider.setFilter(filter),
                    ),
                  );
                }),
                const SizedBox(width: 8),
                // 카테고리 필터
                ...categoryProvider.categories.map((cat) {
                  final isSelected = todoProvider.selectedCategoryId == cat.id;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      avatar: Icon(
                        IconData(cat.icon, fontFamily: 'MaterialIcons'),
                        size: 16,
                        color: Color(cat.color),
                      ),
                      label: Text(cat.name),
                      selected: isSelected,
                      onSelected: (_) {
                        todoProvider.setCategoryFilter(
                          isSelected ? null : cat.id,
                        );
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
          // 할일 목록
          Expanded(
            child: todos.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.task_alt,
                          size: 64,
                          color: theme.colorScheme.onSurfaceVariant
                              .withAlpha(100),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '할일이 없습니다',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '+ 버튼을 눌러 새 할일을 추가하세요',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: todos.length,
                    itemBuilder: (context, index) {
                      final todo = todos[index];
                      return TodoTile(
                        todo: todo,
                        onTap: () => context.push('/todo/edit/${todo.id}'),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/todo/add'),
        child: const Icon(Icons.add),
      ),
    );
  }

  String _filterLabel(FilterType filter) {
    switch (filter) {
      case FilterType.all:
        return '전체';
      case FilterType.active:
        return '진행중';
      case FilterType.completed:
        return '완료';
      case FilterType.important:
        return '중요';
      case FilterType.today:
        return '오늘';
    }
  }

  String _sortLabel(SortType sort) {
    switch (sort) {
      case SortType.createdAt:
        return '최신순';
      case SortType.dueDate:
        return '마감일순';
      case SortType.priority:
        return '우선순위순';
      case SortType.title:
        return '이름순';
    }
  }
}
