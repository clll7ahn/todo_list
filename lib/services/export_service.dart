import 'package:flutter/services.dart';
import '../models/content.dart';
import '../models/analytics_record.dart';

/// 콘텐츠 내보내기 서비스
/// 캡션 복사, 분석 데이터 CSV 내보내기 등을 처리합니다.
class ExportService {
  // ==========================================
  // 클립보드 복사
  // ==========================================

  /// 텍스트를 클립보드에 복사
  Future<void> copyToClipboard(String text) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
    } catch (e) {
      throw ExportException(message: '클립보드 복사 실패: $e');
    }
  }

  // ==========================================
  // 캡션 포맷팅
  // ==========================================

  /// 콘텐츠를 인스타그램 게시용 형식으로 포맷팅
  /// 캡션 + 줄바꿈 + 해시태그 형식으로 반환합니다.
  String formatCaptionForExport(Content content) {
    try {
      final caption = content.caption ?? '';
      final hashtags = content.hashtags ?? [];

      if (caption.isEmpty && hashtags.isEmpty) return '';

      // 해시태그를 '#' 접두사 포함 문자열로 변환
      final formattedHashtags = hashtags.map((tag) {
        final trimmed = tag.trim();
        return trimmed.startsWith('#') ? trimmed : '#$trimmed';
      }).join(' ');

      if (caption.isEmpty) return formattedHashtags;
      if (formattedHashtags.isEmpty) return caption;

      // 캡션과 해시태그 사이에 줄바꿈 2개 추가 (인스타그램 일반 포맷)
      return '$caption\n\n$formattedHashtags';
    } catch (e) {
      return '';
    }
  }

  // ==========================================
  // 분석 데이터 CSV 내보내기
  // ==========================================

  /// 분석 기록 목록을 CSV 형식 문자열로 변환
  /// 헤더 포함, 각 레코드를 한 줄로 변환합니다.
  String exportAnalyticsAsCsv(List<AnalyticsRecord> records) {
    try {
      if (records.isEmpty) return '';

      // CSV 헤더
      final buffer = StringBuffer();
      buffer.writeln(
        'id,content_id,date,impressions,reach,likes,comments,shares,saves,engagement_rate',
      );

      // 각 레코드를 CSV 행으로 변환
      for (final record in records) {
        final row = [
          _escapeCsvField(record.id ?? ''),
          _escapeCsvField(record.contentId ?? ''),
          _escapeCsvField(record.date?.toIso8601String() ?? ''),
          record.impressions ?? 0,
          record.reach ?? 0,
          record.likes ?? 0,
          record.comments ?? 0,
          record.shares ?? 0,
          record.saves ?? 0,
          record.engagementRate?.toStringAsFixed(2) ?? '0.00',
        ].join(',');
        buffer.writeln(row);
      }

      return buffer.toString();
    } catch (e) {
      throw ExportException(message: '분석 데이터 CSV 변환 실패: $e');
    }
  }

  /// CSV 필드 이스케이프 처리
  /// 쉼표, 따옴표, 줄바꿈이 포함된 필드를 따옴표로 감쌉니다.
  String _escapeCsvField(String field) {
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }
}

/// 내보내기 예외 클래스
class ExportException implements Exception {
  final String message;

  const ExportException({required this.message});

  @override
  String toString() => 'ExportException(message: $message)';
}
