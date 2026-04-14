import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// Instagram Graph API 서비스
/// Instagram 콘텐츠 게시, 미디어 인사이트, 계정 정보 조회 등을 처리합니다.
class InstagramApiService {
  static const String _baseUrl = 'https://graph.instagram.com';
  static const String _graphUrl = 'https://graph.facebook.com/v21.0';

  String? _accessToken;
  String? _userId;

  /// 인증 정보 설정
  void setCredentials({required String accessToken, required String userId}) {
    _accessToken = accessToken;
    _userId = userId;
  }

  /// 인증 상태 확인
  bool get isAuthenticated => _accessToken != null;

  // ==========================================
  // 계정 정보 (Account Info)
  // ==========================================

  /// 프로필 정보 조회
  /// id, username, account_type, media_count, followers_count, follows_count 반환
  Future<Map<String, dynamic>> getProfile() async {
    _ensureAuthenticated();
    try {
      final response = await _get(
        '$_graphUrl/$_userId',
        {
          'fields':
              'id,username,account_type,media_count,followers_count,follows_count',
        },
      );
      _handleError(response);
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('프로필 조회 오류: $e');
      rethrow;
    }
  }

  // ==========================================
  // 미디어 게시 (Media Publishing)
  // ==========================================

  /// 단일 이미지 게시
  /// 1단계: 미디어 컨테이너 생성 -> 2단계: 미디어 게시
  Future<String> publishSingleImage({
    required String imageUrl,
    required String caption,
  }) async {
    _ensureAuthenticated();
    try {
      // 1단계: 미디어 컨테이너 생성
      final containerResponse = await _post(
        '$_graphUrl/$_userId/media',
        {
          'image_url': imageUrl,
          'caption': caption,
          'access_token': _accessToken!,
        },
      );
      _handleError(containerResponse);
      final containerData =
          jsonDecode(containerResponse.body) as Map<String, dynamic>;
      final creationId = containerData['id'] as String;

      // 2단계: 미디어 게시
      final publishResponse = await _post(
        '$_graphUrl/$_userId/media_publish',
        {
          'creation_id': creationId,
          'access_token': _accessToken!,
        },
      );
      _handleError(publishResponse);
      final publishData =
          jsonDecode(publishResponse.body) as Map<String, dynamic>;
      return publishData['id'] as String;
    } catch (e) {
      debugPrint('단일 이미지 게시 오류: $e');
      rethrow;
    }
  }

  /// 캐러셀(다중 이미지) 게시
  /// 1단계: 각 이미지별 컨테이너 생성
  /// 2단계: 캐러셀 컨테이너 생성
  /// 3단계: 게시
  Future<String> publishCarousel({
    required List<String> imageUrls,
    required String caption,
  }) async {
    _ensureAuthenticated();
    try {
      // 1단계: 각 이미지별 아이템 컨테이너 생성
      final List<String> childIds = [];
      for (final imageUrl in imageUrls) {
        final itemResponse = await _post(
          '$_graphUrl/$_userId/media',
          {
            'image_url': imageUrl,
            'is_carousel_item': 'true',
            'access_token': _accessToken!,
          },
        );
        _handleError(itemResponse);
        final itemData =
            jsonDecode(itemResponse.body) as Map<String, dynamic>;
        childIds.add(itemData['id'] as String);
      }

      // 2단계: 캐러셀 컨테이너 생성
      final carouselResponse = await _post(
        '$_graphUrl/$_userId/media',
        {
          'media_type': 'CAROUSEL',
          'children': childIds.join(','),
          'caption': caption,
          'access_token': _accessToken!,
        },
      );
      _handleError(carouselResponse);
      final carouselData =
          jsonDecode(carouselResponse.body) as Map<String, dynamic>;
      final creationId = carouselData['id'] as String;

      // 3단계: 게시
      final publishResponse = await _post(
        '$_graphUrl/$_userId/media_publish',
        {
          'creation_id': creationId,
          'access_token': _accessToken!,
        },
      );
      _handleError(publishResponse);
      final publishData =
          jsonDecode(publishResponse.body) as Map<String, dynamic>;
      return publishData['id'] as String;
    } catch (e) {
      debugPrint('캐러셀 게시 오류: $e');
      rethrow;
    }
  }

  /// 릴스(동영상) 게시
  Future<String> publishReel({
    required String videoUrl,
    required String caption,
  }) async {
    _ensureAuthenticated();
    try {
      // 1단계: 릴스 컨테이너 생성
      final containerResponse = await _post(
        '$_graphUrl/$_userId/media',
        {
          'media_type': 'REELS',
          'video_url': videoUrl,
          'caption': caption,
          'access_token': _accessToken!,
        },
      );
      _handleError(containerResponse);
      final containerData =
          jsonDecode(containerResponse.body) as Map<String, dynamic>;
      final creationId = containerData['id'] as String;

      // 2단계: 게시 (동영상 처리 완료 대기 후)
      final publishResponse = await _post(
        '$_graphUrl/$_userId/media_publish',
        {
          'creation_id': creationId,
          'access_token': _accessToken!,
        },
      );
      _handleError(publishResponse);
      final publishData =
          jsonDecode(publishResponse.body) as Map<String, dynamic>;
      return publishData['id'] as String;
    } catch (e) {
      debugPrint('릴스 게시 오류: $e');
      rethrow;
    }
  }

  // ==========================================
  // 미디어 인사이트 (Media Insights)
  // ==========================================

  /// 특정 미디어의 인사이트 조회
  /// impressions, reach, likes, comments, shares, saved, engagement 지표 반환
  Future<Map<String, dynamic>> getMediaInsights(String mediaId) async {
    _ensureAuthenticated();
    try {
      final response = await _get(
        '$_graphUrl/$mediaId/insights',
        {
          'metric': 'impressions,reach,likes,comments,shares,saved,engagement',
        },
      );
      _handleError(response);
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('미디어 인사이트 조회 오류: $e');
      rethrow;
    }
  }

  /// 최근 미디어 목록 조회
  /// id, caption, media_type, timestamp, permalink, like_count, comments_count 반환
  Future<List<Map<String, dynamic>>> getRecentMedia({int limit = 25}) async {
    _ensureAuthenticated();
    try {
      final response = await _get(
        '$_graphUrl/$_userId/media',
        {
          'fields':
              'id,caption,media_type,timestamp,permalink,like_count,comments_count',
          'limit': limit.toString(),
        },
      );
      _handleError(response);
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final mediaList = data['data'] as List<dynamic>?;
      if (mediaList == null) return [];
      return mediaList
          .map((e) => e as Map<String, dynamic>)
          .toList();
    } catch (e) {
      debugPrint('최근 미디어 조회 오류: $e');
      rethrow;
    }
  }

  // ==========================================
  // 계정 인사이트 (Account Insights)
  // ==========================================

  /// 계정 인사이트 조회
  /// impressions, reach, follower_count, profile_views 지표 반환
  /// period: 'day', 'week', 'days_28'
  Future<Map<String, dynamic>> getAccountInsights({
    required String period,
    required String since,
    required String until,
  }) async {
    _ensureAuthenticated();
    try {
      final response = await _get(
        '$_graphUrl/$_userId/insights',
        {
          'metric': 'impressions,reach,follower_count,profile_views',
          'period': period,
          'since': since,
          'until': until,
        },
      );
      _handleError(response);
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('계정 인사이트 조회 오류: $e');
      rethrow;
    }
  }

  // ==========================================
  // 헬퍼 메서드 (Helpers)
  // ==========================================

  /// 인증 상태 확인 (미인증 시 예외 발생)
  void _ensureAuthenticated() {
    if (_accessToken == null || _userId == null) {
      throw Exception('Instagram API 인증이 필요합니다. setCredentials()를 먼저 호출하세요.');
    }
  }

  /// GET 요청 실행
  Future<http.Response> _get(
    String url,
    Map<String, String> params,
  ) async {
    try {
      // 액세스 토큰을 파라미터에 추가
      final queryParams = Map<String, String>.from(params);
      queryParams['access_token'] = _accessToken!;

      final uri = Uri.parse(url).replace(queryParameters: queryParams);
      final response = await http.get(uri);
      return response;
    } catch (e) {
      debugPrint('GET 요청 오류: $url - $e');
      rethrow;
    }
  }

  /// POST 요청 실행
  Future<http.Response> _post(
    String url,
    Map<String, String> body,
  ) async {
    try {
      final uri = Uri.parse(url);
      final response = await http.post(uri, body: body);
      return response;
    } catch (e) {
      debugPrint('POST 요청 오류: $url - $e');
      rethrow;
    }
  }

  /// HTTP 응답 에러 처리
  void _handleError(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final error = body['error'] as Map<String, dynamic>?;
      final message = error?['message'] ?? '알 수 없는 오류가 발생했습니다.';
      final code = error?['code'] ?? response.statusCode;
      throw InstagramApiException(
        message: message.toString(),
        statusCode: response.statusCode,
        errorCode: code is int ? code : int.tryParse(code.toString()) ?? 0,
      );
    }
  }
}

/// Instagram API 예외 클래스
class InstagramApiException implements Exception {
  final String message;
  final int statusCode;
  final int errorCode;

  const InstagramApiException({
    required this.message,
    required this.statusCode,
    required this.errorCode,
  });

  @override
  String toString() =>
      'InstagramApiException(statusCode: $statusCode, errorCode: $errorCode, message: $message)';
}
