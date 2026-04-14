import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'storage_service.dart';

/// Instagram OAuth2 인증 서비스
/// 인스타그램 로그인, 토큰 교환, 토큰 갱신 등을 처리합니다.
class AuthService {
  // Instagram OAuth2 설정 URL
  static const String _authUrl = 'https://www.instagram.com/oauth/authorize';
  static const String _tokenUrl =
      'https://api.instagram.com/oauth/access_token';
  static const String _longLivedTokenUrl =
      'https://graph.instagram.com/access_token';
  static const String _refreshTokenUrl =
      'https://graph.instagram.com/refresh_access_token';

  /// 필요한 Instagram API 권한 범위
  static const String _scopes =
      'instagram_basic,instagram_content_publish,instagram_manage_insights,pages_show_list,pages_read_engagement';

  final StorageService _storageService;

  AuthService({required StorageService storageService})
      : _storageService = storageService;

  // ==========================================
  // OAuth2 인증 URL 생성
  // ==========================================

  /// WebView/브라우저에서 사용할 인증 URL 생성
  /// 사용자가 이 URL에서 Instagram 로그인 후 권한을 승인합니다.
  String getAuthorizationUrl({
    required String appId,
    required String redirectUri,
  }) {
    final params = {
      'client_id': appId,
      'redirect_uri': redirectUri,
      'scope': _scopes,
      'response_type': 'code',
    };
    final uri = Uri.parse(_authUrl).replace(queryParameters: params);
    return uri.toString();
  }

  // ==========================================
  // 토큰 교환 (Token Exchange)
  // ==========================================

  /// 인증 코드를 단기 액세스 토큰으로 교환
  /// 인스타그램 로그인 후 리다이렉트에서 받은 code를 토큰으로 변환합니다.
  Future<Map<String, dynamic>> exchangeCodeForToken({
    required String code,
    required String appId,
    required String appSecret,
    required String redirectUri,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_tokenUrl),
        body: {
          'client_id': appId,
          'client_secret': appSecret,
          'grant_type': 'authorization_code',
          'redirect_uri': redirectUri,
          'code': code,
        },
      );

      if (response.statusCode != 200) {
        throw AuthException(
          message: '인증 코드 교환 실패: ${response.body}',
          statusCode: response.statusCode,
        );
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data;
    } catch (e) {
      debugPrint('인증 코드 교환 오류: $e');
      rethrow;
    }
  }

  /// 단기 토큰을 장기 토큰으로 교환
  /// 단기 토큰(1시간)을 장기 토큰(60일)으로 변환합니다.
  Future<Map<String, dynamic>> exchangeLongLivedToken({
    required String shortLivedToken,
    required String appSecret,
  }) async {
    try {
      final uri = Uri.parse(_longLivedTokenUrl).replace(
        queryParameters: {
          'grant_type': 'ig_exchange_token',
          'client_secret': appSecret,
          'access_token': shortLivedToken,
        },
      );

      final response = await http.get(uri);

      if (response.statusCode != 200) {
        throw AuthException(
          message: '장기 토큰 교환 실패: ${response.body}',
          statusCode: response.statusCode,
        );
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data;
    } catch (e) {
      debugPrint('장기 토큰 교환 오류: $e');
      rethrow;
    }
  }

  /// 장기 토큰 갱신
  /// 만료되기 전에 장기 토큰을 갱신합니다. (만료 전 최소 24시간 이내 갱신 가능)
  Future<Map<String, dynamic>> refreshToken({required String token}) async {
    try {
      final uri = Uri.parse(_refreshTokenUrl).replace(
        queryParameters: {
          'grant_type': 'ig_refresh_token',
          'access_token': token,
        },
      );

      final response = await http.get(uri);

      if (response.statusCode != 200) {
        throw AuthException(
          message: '토큰 갱신 실패: ${response.body}',
          statusCode: response.statusCode,
        );
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data;
    } catch (e) {
      debugPrint('토큰 갱신 오류: $e');
      rethrow;
    }
  }

  // ==========================================
  // 토큰 저장/로드/삭제
  // ==========================================

  /// 인증 토큰 정보 저장
  Future<void> saveTokens({
    required String accessToken,
    required String userId,
    DateTime? expiresAt,
  }) async {
    try {
      await _storageService.saveAccessToken(accessToken);
      await _storageService.saveUserId(userId);
      if (expiresAt != null) {
        await _storageService.saveTokenExpiry(expiresAt);
      }
    } catch (e) {
      debugPrint('토큰 저장 오류: $e');
      rethrow;
    }
  }

  /// 저장된 토큰 정보 로드
  Future<Map<String, String?>> loadTokens() async {
    try {
      final accessToken = await _storageService.loadAccessToken();
      final userId = await _storageService.loadUserId();
      final expiresAt = await _storageService.loadTokenExpiry();
      return {
        'accessToken': accessToken,
        'userId': userId,
        'expiresAt': expiresAt?.toIso8601String(),
      };
    } catch (e) {
      debugPrint('토큰 로드 오류: $e');
      return {
        'accessToken': null,
        'userId': null,
        'expiresAt': null,
      };
    }
  }

  /// 저장된 토큰 정보 삭제 (로그아웃)
  Future<void> clearTokens() async {
    try {
      await _storageService.deleteAccessToken();
      await _storageService.deleteUserId();
      await _storageService.deleteTokenExpiry();
    } catch (e) {
      debugPrint('토큰 삭제 오류: $e');
      rethrow;
    }
  }

  // ==========================================
  // 토큰 만료 확인
  // ==========================================

  /// 토큰 만료 여부 확인
  /// expiresAt이 null이면 만료된 것으로 간주합니다.
  bool isTokenExpired(DateTime? expiresAt) {
    if (expiresAt == null) return true;
    return DateTime.now().isAfter(expiresAt);
  }
}

/// 인증 예외 클래스
class AuthException implements Exception {
  final String message;
  final int statusCode;

  const AuthException({
    required this.message,
    required this.statusCode,
  });

  @override
  String toString() =>
      'AuthException(statusCode: $statusCode, message: $message)';
}
