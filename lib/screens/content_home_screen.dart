import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../config/constants.dart';
import '../models/content.dart';
import '../models/enums.dart';
import '../providers/content_provider.dart';
import '../widgets/content_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/stat_card.dart';

/// 콘텐츠 홈 화면 - 메인 대시보드 (탭 1)
class ContentHomeScreen extends StatefulWidget {
  const ContentHomeScreen({super.key});

  @override
  State<ContentHomeScreen> createState() => _ContentHomeScreenState();
}

class _ContentHomeScreenState extends State<ContentHomeScreen> {
  bool _isGridMode = true;
  bool _isSearching = false;
  final _searchController = TextEditingController();
  ContentStatus? _statusFilter;
  ContentSortType _sortType = ContentSortType.createdAt;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: '콘텐츠 검색...',
                  border: InputBorder.none,
                  filled: false,
                ),
                onChanged: (value) {
                  context.read<ContentProvider>().setSearchQuery(value);
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
                  context.read<ContentProvider>().setSearchQuery('');
                }
              });
            },
          ),
          // 뷰 토글
          IconButton(
            icon: Icon(_isGridMode ? Icons.view_list : Icons.grid_view),
            tooltip: _isGridMode ? '리스트 보기' : '그리드 보기',
            onPressed: () {
              setState(() => _isGridMode = !_isGridMode);
            },
          ),
          // 정렬 메뉴
          PopupMenuButton<ContentSortType>(
            icon: const Icon(Icons.sort),
            tooltip: '정렬',
            onSelected: (sort) {
              setState(() => _sortType = sort);
              context.read<ContentProvider>().setSortType(sort);
            },
            itemBuilder: (context) => [
              _buildSortMenuItem(ContentSortType.createdAt, '최신순', theme),
              _buildSortMenuItem(ContentSortType.scheduledAt, '마감일순', theme),
              _buildSortMenuItem(ContentSortType.performance, '성과순', theme),
              _buildSortMenuItem(ContentSortType.title, '이름순', theme),
            ],
          ),
        ],
      ),
      body: Consumer<ContentProvider>(
        builder: (context, provider, _) {
          final contents = _filterContents(provider.contents);

          return RefreshIndicator(
            onRefresh: () async => provider.loadContents(),
            child: CustomScrollView(
              slivers: [
                // 통계 카드 섹션
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: _buildStatCards(provider),
                  ),
                ),

                // 필터 칩 섹션
                SliverToBoxAdapter(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        _buildFilterChip(null, '전체', provider),
                        _buildFilterChip(ContentStatus.draft, '초안', provider),
                        _buildFilterChip(
                            ContentStatus.ready, '준비완료', provider),
                        _buildFilterChip(
                            ContentStatus.scheduled, '예약됨', provider),
                        _buildFilterChip(
                            ContentStatus.posted, '게시됨', provider),
                        _buildFilterChip(
                            ContentStatus.archived, '보관됨', provider),
                      ],
                    ),
                  ),
                ),

                // 콘텐츠 목록/그리드
                if (contents.isEmpty)
                  SliverFillRemaining(
                    child: EmptyState(
                      icon: Icons.photo_library_outlined,
                      title: '콘텐츠가 없습니다',
                      subtitle: '새로운 콘텐츠를 만들어 보세요',
                      actionLabel: '콘텐츠 만들기',
                      onAction: () => context.push('/content/create'),
                    ),
                  )
                else if (_isGridMode)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.75,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final content = contents[index];
                          return ContentCard(
                            content: content,
                            isGridMode: true,
                            onTap: () =>
                                context.push('/content/${content.id}'),
                          );
                        },
                        childCount: contents.length,
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.only(bottom: 80),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final content = contents[index];
                          return ContentCard(
                            content: content,
                            isGridMode: false,
                            onTap: () =>
                                context.push('/content/${content.id}'),
                          );
                        },
                        childCount: contents.length,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/content/create'),
        child: const Icon(Icons.add),
      ),
    );
  }

  /// 통계 카드 3개 빌드
  Widget _buildStatCards(ContentProvider provider) {
    final allContents = provider.contents;
    final totalCount = allContents.length;
    final scheduledCount = allContents
        .where((c) => c.status == ContentStatus.scheduled)
        .length;
    final postedCount = allContents
        .where((c) => c.status == ContentStatus.posted)
        .length;

    return Row(
      children: [
        Expanded(
          child: StatCard(
            icon: Icons.photo_library,
            label: '총 콘텐츠',
            value: '$totalCount',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: StatCard(
            icon: Icons.schedule,
            label: '이번 주 예약',
            value: '$scheduledCount',
            color: const Color(0xFF1976D2),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: StatCard(
            icon: Icons.check_circle,
            label: '게시 완료',
            value: '$postedCount',
            color: const Color(0xFF43A047),
          ),
        ),
      ],
    );
  }

  /// 필터 칩 빌드
  Widget _buildFilterChip(
    ContentStatus? status,
    String label,
    ContentProvider provider,
  ) {
    final isSelected = _statusFilter == status;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) {
          setState(() {
            _statusFilter = status;
          });
          provider.setStatusFilter(status);
        },
      ),
    );
  }

  /// 정렬 메뉴 아이템
  PopupMenuItem<ContentSortType> _buildSortMenuItem(
    ContentSortType sort,
    String label,
    ThemeData theme,
  ) {
    return PopupMenuItem(
      value: sort,
      child: Row(
        children: [
          if (_sortType == sort)
            Icon(Icons.check, size: 18, color: theme.colorScheme.primary)
          else
            const SizedBox(width: 18),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }

  /// 로컬 필터 적용
  List<Content> _filterContents(List<Content> contents) {
    var result = contents;
    if (_statusFilter != null) {
      result = result.where((c) => c.status == _statusFilter).toList();
    }
    return result;
  }
}
