import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class MunicipalSession {
  final String accessToken;
  final int expiresInSeconds;
  final String operatorId;
  final String organizationId;
  final String phone;
  final String role;
  final List<String> wardIds;
  final List<String> zoneIds;
  final List<String> valveIds;

  const MunicipalSession({
    required this.accessToken,
    required this.expiresInSeconds,
    required this.operatorId,
    required this.organizationId,
    required this.phone,
    required this.role,
    required this.wardIds,
    required this.zoneIds,
    required this.valveIds,
  });

  factory MunicipalSession.fromJson(Map<String, dynamic> json) {
    return MunicipalSession(
      accessToken: json['access_token'] as String,
      expiresInSeconds: (json['expires_in_seconds'] as num).toInt(),
      operatorId: json['operator_id'].toString(),
      organizationId: json['organization_id'].toString(),
      phone: json['phone'].toString(),
      role: json['role'].toString(),
      wardIds: (json['ward_ids'] as List? ?? const []).map((e) => e.toString()).toList(),
      zoneIds: (json['zone_ids'] as List? ?? const []).map((e) => e.toString()).toList(),
      valveIds: (json['valve_ids'] as List? ?? const []).map((e) => e.toString()).toList(),
    );
  }
}

class MunicipalAuthException implements Exception {
  final String message;
  const MunicipalAuthException(this.message);

  @override
  String toString() => message;
}

class MunicipalAuthService {
  MunicipalAuthService({
    http.Client? client,
    FlutterSecureStorage? storage,
  })  : _client = client ?? http.Client(),
        _storage = storage ?? const FlutterSecureStorage();

  static const String configuredBaseUrl =
      String.fromEnvironment('MUNICIPAL_API_BASE_URL');
  final http.Client _client;
  final FlutterSecureStorage _storage;

  bool get isConfigured => configuredBaseUrl.trim().isNotEmpty;

  Uri _uri(String path) {
    final base = configuredBaseUrl.trim().replaceFirst(RegExp(r'/+$'), '');
    return Uri.parse('$base$path');
  }

  String _errorMessage(http.Response response) {
    try {
      final body = jsonDecode(response.body);
      if (body is Map && body['detail'] != null) return body['detail'].toString();
    } catch (_) {
      // Use the HTTP status when the response is not JSON.
    }
    return 'Municipal server returned HTTP ${response.statusCode}.';
  }

  Future<int> requestOtp(String phone) async {
    if (!isConfigured) {
      throw const MunicipalAuthException(
        'Server URL is not configured. Set MUNICIPAL_API_BASE_URL when building the APK.',
      );
    }
    final response = await _client
        .post(
          _uri('/api/v1/municipal/auth/request-otp'),
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode({'phone': phone}),
        )
        .timeout(const Duration(seconds: 15));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw MunicipalAuthException(_errorMessage(response));
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return (data['expires_in_seconds'] as num?)?.toInt() ?? 300;
  }

  Future<MunicipalSession> verifyOtp(String phone, String otp) async {
    if (!isConfigured) {
      throw const MunicipalAuthException(
        'Server URL is not configured. OTP verification cannot run yet.',
      );
    }
    final response = await _client
        .post(
          _uri('/api/v1/municipal/auth/verify-otp'),
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode({'phone': phone, 'otp': otp}),
        )
        .timeout(const Duration(seconds: 15));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw MunicipalAuthException(_errorMessage(response));
    }
    final session = MunicipalSession.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
    await _saveSession(session);
    return session;
  }

  Future<void> _saveSession(MunicipalSession session) async {
    final expiresAt = DateTime.now()
        .add(Duration(seconds: session.expiresInSeconds))
        .millisecondsSinceEpoch;
    await _storage.write(key: 'municipal_access_token', value: session.accessToken);
    await _storage.write(key: 'municipal_session_expires_at', value: '$expiresAt');
    await _storage.write(key: 'municipal_operator_id', value: session.operatorId);
    await _storage.write(key: 'municipal_organization_id', value: session.organizationId);
    await _storage.write(key: 'municipal_phone', value: session.phone);
    await _storage.write(key: 'municipal_role', value: session.role);
    await _storage.write(key: 'municipal_ward_ids', value: jsonEncode(session.wardIds));
    await _storage.write(key: 'municipal_zone_ids', value: jsonEncode(session.zoneIds));
    await _storage.write(key: 'municipal_valve_ids', value: jsonEncode(session.valveIds));
  }

  Future<bool> hasValidSession() async {
    final token = await _storage.read(key: 'municipal_access_token');
    final expiry = int.tryParse(
      await _storage.read(key: 'municipal_session_expires_at') ?? '',
    );
    return token != null &&
        token.isNotEmpty &&
        expiry != null &&
        DateTime.now().millisecondsSinceEpoch < expiry;
  }

  Future<void> clearSession() async {
    await _storage.deleteAll();
  }

  void dispose() => _client.close();
}
