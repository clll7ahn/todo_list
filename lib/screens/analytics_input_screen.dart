import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../config/theme.dart';
import '../models/analytics_record.dart';
import '../models/content.dart';
import '../models/enums.dart';
import '../providers/analytics_provider.dart';
import '../providers/content_provider.dart';
import '../utils/instagram_utils.dart';
import '../widgets/performance_badge.dart';

/// 분석 데이터 수동 입력 화면
class AnalyticsInputScreen extends StatefulWidget {
  const AnalyticsInputScreen({
    super.key,
    this.contentId,
    this.recordId,
  });

  /// 사전 선택할 콘텐츠 ID (선택)
  final String? contentId;

  /// 편집할 기존 기록 ID (선택)
  final String? recordId;

  @override
  State<AnalyticsInputScreen> createState() => _AnalyticsInputScreenState();
}

class _AnalyticsInputScreenState extends State<AnalyticsInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _uuid = const Uuid();

  // 컨트롤러
  final _likesController = TextEditingController(text: '0');
  final _commentsController = TextEditingController(text: '0');
  final _sharesController = TextEditingController(text: '0');
  final _savesController = TextEditingController(text: '0');
  final _reachController = TextEditingController(text: '0');
  final _impressionsController = TextEditingController(text: '0');
  final _profileVisitsController = TextEditingController(text: '0');
  final _followsController = TextEditingController(text: '0');
  final _notesController = TextEditingController();

  String? _selectedContentId;
  bool _isEditing = false;
  AnalyticsRecord? _existingRecord;
  AnalyticsRecord? _previousRecord; // 이전 기록 (비교용)

  // 실시간 계산 값
  double _engagementRate = 0.0;
  PerformanceGrade _grade = PerformanceGrade.average;

  @override
  void initState() {
    super.initState();
    _selectedContentId = widget.contentId;

    // 모든 숫자 필드에 리스너 추가
    _likesController.addListener(_recalculate);
    _commentsController.addListener(_recalculate);
    _sharesController.addListener(_recalculate);
    _savesController.addListener(_recalculate);
    _reachController.addListener(_recalculate);
    _impressionsController.addListener(_recalculate);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExistingRecord();
    });
  }

  /// 기존 기록 로드 (편집 모드)
  void _loadExistingRecord() {
    final analyticsProvider =
        Provider.of<AnalyticsProvider>(context, listen: false);

    if (widget.recordId != null) {
      final record = analyticsProvider.getRecordById(widget.recordId!);
      if (record != null) {
        _isEditing = true;
        _existingRecord = record;
        _selectedContentId = record.contentId;
        _likesController.text = record.likes.toString();
        _commentsController.text = record.comments.toString();
        _sharesController.text = record.shares.toString();
        _savesController.text = record.saves.toString();
        _reachController.text = record.reach.toString();
        _impressionsController.text = record.impressions.toString();
        _profileVisitsController.text = record.profileVisits.toString();
        _followsController.text = record.followsFromPost.toString();
        _notesController.text = record.notes ?? '';
        setState(() {});
      }
    } else if (_selectedContentId != null) {
      // contentId가 있으면 이전 기록 찾기
      _previousRecord =
          analyticsProvider.getRecordByContentId(_selectedContentId!);
    }
  }

  /// 참여율 및 등급 재계산
  void _recalculate() {
    final likes = int.tryParse(_likesController.text) ?? 0;
    final comments = int.tryParse(_commentsController.text) ?? 0;
    final shares = int.tryParse(_sharesController.text) ?? 0;
    final saves = int.tryParse(_savesController.text) ?? 0;
    final reach = int.tryParse(_reachController.text) ?? 0;

    final rate = AnalyticsRecord.calculateEngagementRate(
        likes, comments, shares, saves, reach);
    final grade = AnalyticsRecord.calculateGrade(rate);

    setState(() {
      _engagementRate = rate;
      _grade = grade;
    });
  }

  @override
  void dispose() {
    _likesController.dispose();
    _commentsController.dispose();
    _sharesController.dispose();
    _savesController.dispose();
    _reachController.dispose();
    _impressionsController.dispose();
    _profileVisitsController.dispose();
    _followsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final contentProvider =
        Provider.of<ContentProvider>(context, listen: false);
    final postedContents = contentProvider.allContents
        .where((c) => c.status == ContentStatus.posted)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? '분석 수정' : '분석 입력'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 콘텐츠 선택
              Text('콘텐츠 선택', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 8),
              _buildContentSelector(context, postedContents),
              const SizedBox(height: 24),

              // 실시간 참여율 & 등급 표시
              _buildEngagementDisplay(context),
              const SizedBox(height: 24),

              // 지표 입력 필드
              Text('성과 지표 입력', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 12),

              // 좋아요 / 댓글
              Row(
                children: [
                  Expanded(
                    child: _buildNumberField(
                      controller: _likesController,
                      label: '좋아요',
                      icon: Icons.favorite,
                      previousValue: _previousRecord?.likes,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildNumberField(
                      controller: _commentsController,
                      label: '댓글',
                      icon: Icons.chat_bubble_outline,
                      previousValue: _previousRecord?.comments,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 공유 / 저장
              Row(
                children: [
                  Expanded(
                    child: _buildNumberField(
                      controller: _sharesController,
                      label: '공유',
                      icon: Icons.share,
                      previousValue: _previousRecord?.shares,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildNumberField(
                      controller: _savesController,
                      label: '저장',
                      icon: Icons.bookmark_border,
                      previousValue: _previousRecord?.saves,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 도달 / 노출
              Row(
                children: [
                  Expanded(
                    child: _buildNumberField(
                      controller: _reachController,
                      label: '도달',
                      icon: Icons.visibility,
                      previousValue: _previousRecord?.reach,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildNumberField(
                      controller: _impressionsController,
                      label: '노출',
                      icon: Icons.remove_red_eye_outlined,
                      previousValue: _previousRecord?.impressions,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 프로필 방문 / 팔로우
              Row(
                children: [
                  Expanded(
                    child: _buildNumberField(
                      controller: _profileVisitsController,
                      label: '프로필 방문',
                      icon: Icons.person_outline,
                      previousValue: _previousRecord?.profileVisits,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildNumberField(
                      controller: _followsController,
                      label: '팔로우',
                      icon: Icons.person_add_outlined,
                      previousValue: _previousRecord?.followsFromPost,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 메모 필드
              Text('메모', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: '메모를 입력하세요 (선택)',
                ),
              ),
              const SizedBox(height: 32),

              // 저장 버튼
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed:
                      _selectedContentId != null ? _handleSave : null,
                  icon: const Icon(Icons.save),
                  label: Text(_isEditing ? '수정 완료' : '저장'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  /// 콘텐츠 드롭다운 선택기
  Widget _buildContentSelector(
      BuildContext context, List<Content> contents) {
    final theme = Theme.of(context);

    if (contents.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest
              .withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '게시된 콘텐츠가 없습니다.\n먼저 콘텐츠를 게시해 주세요.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return DropdownButtonFormField<String>(
      value: _selectedContentId,
      decoration: const InputDecoration(
        hintText: '콘텐츠를 선택하세요',
        prefixIcon: Icon(Icons.article),
      ),
      items: contents.map((content) {
        return DropdownMenuItem<String>(
          value: content.id,
          child: Text(
            content.title,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: _isEditing
          ? null
          : (value) {
              setState(() {
                _selectedContentId = value;
              });
              // 이전 기록 확인
              if (value != null) {
                final analyticsProvider =
                    Provider.of<AnalyticsProvider>(context, listen: false);
                _previousRecord =
                    analyticsProvider.getRecordByContentId(value);
                setState(() {});
              }
            },
      validator: (value) {
        if (value == null) return '콘텐츠를 선택해 주세요';
        return null;
      },
    );
  }

  /// 실시간 참여율 & 등급 표시
  Widget _buildEngagementDisplay(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.instagramPurple.withValues(alpha: 0.08),
            AppTheme.instagramPink.withValues(alpha: 0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.instagramPurple.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 참여율
          Column(
            children: [
              Text(
                '참여율',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                InstagramUtils.formatEngagementRate(_engagementRate),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.instagramPurple,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          Container(
            width: 1,
            height: 50,
            color: theme.colorScheme.outlineVariant,
          ),
          // 등급
          Column(
            children: [
              Text(
                '등급',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              PerformanceBadge(grade: _grade),
            ],
          ),
        ],
      ),
    );
  }

  /// 숫자 입력 필드
  Widget _buildNumberField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int? previousValue,
  }) {
    final theme = Theme.of(context);
    final currentValue = int.tryParse(controller.text) ?? 0;
    final diff =
        previousValue != null ? currentValue - previousValue : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon, size: 20),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return '숫자를 입력해 주세요';
            return null;
          },
        ),
        // 이전 기록과의 비교 표시
        if (previousValue != null && diff != null) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                diff > 0
                    ? Icons.arrow_upward
                    : diff < 0
                        ? Icons.arrow_downward
                        : Icons.remove,
                size: 12,
                color: diff > 0
                    ? const Color(0xFF43A047)
                    : diff < 0
                        ? const Color(0xFFE53935)
                        : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 2),
              Text(
                diff > 0
                    ? '+${InstagramUtils.formatFollowerCount(diff)}'
                    : diff < 0
                        ? InstagramUtils.formatFollowerCount(diff)
                        : '0',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: diff > 0
                      ? const Color(0xFF43A047)
                      : diff < 0
                          ? const Color(0xFFE53935)
                          : theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '이전: ${InstagramUtils.formatFollowerCount(previousValue)}',
                style: theme.textTheme.labelSmall,
              ),
            ],
          ),
        ],
      ],
    );
  }

  /// 저장 처리
  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedContentId == null) return;

    final analyticsProvider =
        Provider.of<AnalyticsProvider>(context, listen: false);

    final now = DateTime.now();
    final likes = int.tryParse(_likesController.text) ?? 0;
    final comments = int.tryParse(_commentsController.text) ?? 0;
    final shares = int.tryParse(_sharesController.text) ?? 0;
    final saves = int.tryParse(_savesController.text) ?? 0;
    final reach = int.tryParse(_reachController.text) ?? 0;
    final impressions = int.tryParse(_impressionsController.text) ?? 0;
    final profileVisits = int.tryParse(_profileVisitsController.text) ?? 0;
    final follows = int.tryParse(_followsController.text) ?? 0;
    final notes = _notesController.text.trim();

    final engagementRate = AnalyticsRecord.calculateEngagementRate(
        likes, comments, shares, saves, reach);
    final grade = AnalyticsRecord.calculateGrade(engagementRate);

    if (_isEditing && _existingRecord != null) {
      // 수정
      final updated = _existingRecord!.copyWith(
        likes: likes,
        comments: comments,
        shares: shares,
        saves: saves,
        reach: reach,
        impressions: impressions,
        profileVisits: profileVisits,
        followsFromPost: follows,
        engagementRate: engagementRate,
        grade: grade,
        notes: notes.isEmpty ? null : notes,
        clearNotes: notes.isEmpty,
        updatedAt: now,
      );
      await analyticsProvider.updateRecord(updated);
    } else {
      // 신규 생성
      final record = AnalyticsRecord(
        id: _uuid.v4(),
        contentId: _selectedContentId!,
        recordedAt: now,
        likes: likes,
        comments: comments,
        shares: shares,
        saves: saves,
        reach: reach,
        impressions: impressions,
        profileVisits: profileVisits,
        followsFromPost: follows,
        engagementRate: engagementRate,
        grade: grade,
        notes: notes.isEmpty ? null : notes,
        createdAt: now,
        updatedAt: now,
      );
      await analyticsProvider.addRecord(record);
    }

    if (mounted) {
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? '분석 기록이 수정되었습니다' : '분석 기록이 저장되었습니다'),
        ),
      );
    }
  }
}
