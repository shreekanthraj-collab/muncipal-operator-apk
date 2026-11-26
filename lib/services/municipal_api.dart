import 'dart:convert';
import 'dart:io';

class ApiException implements Exception {
  final int statusCode;
  final String message;
  const ApiException(this.statusCode, this.message);
  @override
  String toString() => message;
}

String _normalizeValveType(dynamic value) {
  final normalized = (value ?? 'DISTRIBUTION').toString().trim().toUpperCase();
  return normalized == 'MAIN' ? 'MAIN' : 'DISTRIBUTION';
}

class MunicipalValve {
  final String valveId;
  final String transport;
  final String status;
  final String zoneId;
  final String wardId;
  final String valveType;
  final double? latitude;
  final double? longitude;
  final String? deviceId;

  const MunicipalValve({
    required this.valveId,
    required this.transport,
    required this.status,
    required this.zoneId,
    required this.wardId,
    this.valveType = 'DISTRIBUTION',
    this.latitude,
    this.longitude,
    this.deviceId,
  });

  factory MunicipalValve.fromJson(Map<String, dynamic> json) {
    double? number(dynamic value) =>
        value is num ? value.toDouble() : double.tryParse('${value ?? ''}');
    return MunicipalValve(
      valveId: (json['valve_id'] ?? json['id'] ?? '').toString(),
      transport: (json['transport'] ?? json['valve_transport'] ?? '').toString().toUpperCase(),
      status: (json['status'] ?? 'UNKNOWN').toString().toUpperCase(),
      zoneId: (json['zone_id'] ?? json['zone'] ?? '').toString(),
      wardId: (json['ward_id'] ?? json['ward'] ?? '').toString(),
      valveType: _normalizeValveType(json['valve_type']),
      latitude: number(json['latitude']),
      longitude: number(json['longitude']),
      deviceId: json['device_id']?.toString(),
    );
  }

  bool get isLora => transport == 'LORA';
  bool get hasCoordinates =>
      latitude != null && longitude != null &&
      latitude! >= -90 && latitude! <= 90 &&
      longitude! >= -180 && longitude! <= 180;
}

class MunicipalApi {
  MunicipalApi({String? baseUrl})
      : _baseUrl = (baseUrl ?? const String.fromEnvironment('ORB_API_BASE_URL')).trim();

  final String _baseUrl;
  String? _token;
  final HttpClient _client = HttpClient()..connectionTimeout = const Duration(seconds: 15);

  bool get configured => _baseUrl.isNotEmpty;
  bool get authenticated => _token != null;

  Uri _uri(String path) {
    if (!configured) {
      throw const ApiException(0, 'Server URL is not configured. Build with --dart-define=ORB_API_BASE_URL=https://your-server');
    }
    final base = Uri.parse(_baseUrl);
    return base.resolve(path);
  }

  Future<dynamic> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
    bool auth = false,
  }) async {
    final request = await _client.openUrl(method, _uri(path));
    request.headers.set(HttpHeaders.acceptHeader, 'application/json');
    request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
    if (auth) {
      final token = _token;
      if (token == null || token.isEmpty) {
        throw const ApiException(401, 'Please sign in again.');
      }
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
    }
    if (body != null) request.write(jsonEncode(body));
    final response = await request.close();
    final text = await response.transform(utf8.decoder).join();
    dynamic decoded;
    if (text.isNotEmpty) {
      try {
        decoded = jsonDecode(text);
      } catch (_) {
        decoded = text;
      }
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = decoded is Map
          ? (decoded['detail'] ?? decoded['message'] ?? 'Server request failed').toString()
          : 'Server request failed (${response.statusCode})';
      if (response.statusCode == 401) _token = null;
      throw ApiException(response.statusCode, message);
    }
    return decoded;
  }

  Future<Map<String, dynamic>> requestOtp(String phone) async {
    final result = await _request('POST', '/api/v1/municipal/auth/request-otp',
        body: {'phone': phone});
    return Map<String, dynamic>.from(result as Map);
  }

  Future<Map<String, dynamic>> verifyOtp(String phone, String otp) async {
    final result = await _request('POST', '/api/v1/municipal/auth/verify-otp',
        body: {'phone': phone, 'otp': otp});
    final data = Map<String, dynamic>.from(result as Map);
    final token = data['access_token']?.toString();
    if (token == null || token.isEmpty) {
      throw const ApiException(502, 'Authentication response did not contain an access token.');
    }
    _token = token;
    return data;
  }

  Future<List<MunicipalValve>> registeredValves() async {
    final result = await _request('GET', '/api/v1/municipal/valves/registered', auth: true);
    if (result is! List) {
      throw const ApiException(502, 'Unexpected registered-valves response.');
    }
    return result
        .whereType<Map>()
        .map((item) => MunicipalValve.fromJson(Map<String, dynamic>.from(item)))
        .where((item) => item.valveId.isNotEmpty)
        .toList(growable: false);
  }


  static void _validateValveType(String valveType) {
    if (valveType != 'MAIN' && valveType != 'DISTRIBUTION') {
      throw ArgumentError.value(
        valveType,
        'valveType',
        'Must be MAIN or DISTRIBUTION',
      );
    }
  }

  Future<List<Map<String, dynamic>>> activeOhts() async {
    final result = await _request('GET', '/api/v1/municipal/ohts', auth: true);
    if (result is! List) {
      throw const ApiException(502, 'Unexpected OHT list response.');
    }
    return result.whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .where((item) => item['oht_id'] != null)
        .toList(growable: false);
  }

  Future<Map<String, dynamic>> scanPreview(String registrationToken) async {
    final result = await _request(
      'GET',
      '/api/v1/municipal/valves/scan-preview/${Uri.encodeComponent(registrationToken)}',
      auth: true,
    );
    return Map<String, dynamic>.from(result as Map);
  }

  Future<Map<String, dynamic>> registerPlacement({
    required String registrationToken,
    required String wardId,
    required String zoneId,
    required double latitude,
    required double longitude,
    required String transportType,
    String valveType = 'DISTRIBUTION',
    String? ohtId,
  }) async {
    _validateValveType(valveType);
    if (valveType == 'MAIN' && (ohtId == null || ohtId.isEmpty)) {
      throw ArgumentError('Select an existing OHT for a MAIN valve.');
    }
    if (valveType == 'DISTRIBUTION' && ohtId != null) {
      throw ArgumentError('DISTRIBUTION valves cannot be assigned to an OHT.');
    }
    if (transportType != 'GSM' && transportType != 'LORA') {
      throw ArgumentError.value(transportType, 'transportType');
    }
    final result = await _request(
      'POST',
      '/api/v1/municipal/valves/register-placement',
      auth: true,
      body: {
        'registration_token': registrationToken,
        'ward_id': wardId,
        'zone_id': zoneId,
        'valve_type': valveType,
        if (ohtId != null) 'oht_id': ohtId,
        'transport_type': transportType,
        'latitude': latitude,
        'longitude': longitude,
      },
    );
    return Map<String, dynamic>.from(result as Map);
  }

  Future<Map<String, dynamic>> registerByValveId({
    required String valveId,
    required String wardId,
    required String zoneId,
    required double latitude,
    required double longitude,
    required String transportType,
    String valveType = 'DISTRIBUTION',
    String? ohtId,
  }) async {
    _validateValveType(valveType);
    if (valveType == 'MAIN' && (ohtId == null || ohtId.isEmpty)) {
      throw ArgumentError('Select an existing OHT for a MAIN valve.');
    }
    if (valveType == 'DISTRIBUTION' && ohtId != null) {
      throw ArgumentError('DISTRIBUTION valves cannot be assigned to an OHT.');
    }
    if (transportType != 'GSM' && transportType != 'LORA') {
      throw ArgumentError.value(transportType, 'transportType');
    }
    final result = await _request(
      'POST',
      '/api/v1/municipal/valves/register-by-valve-id',
      auth: true,
      body: {
        'valve_id': valveId,
        'ward_id': wardId,
        'zone_id': zoneId,
        'valve_type': valveType,
        if (ohtId != null) 'oht_id': ohtId,
        'transport_type': transportType,
        'latitude': latitude,
        'longitude': longitude,
      },
    );
    return Map<String, dynamic>.from(result as Map);
  }

  Future<Map<String, dynamic>> command(String valveId, String command) async {
    final result = await _request(
      'POST',
      '/api/v1/municipal/valves/${Uri.encodeComponent(valveId)}/command',
      auth: true,
      body: {'command': command},
    );
    return Map<String, dynamic>.from(result as Map);
  }

  Future<Map<String, dynamic>> getTarget(String valveId) async {
    final result = await _request(
      'GET',
      '/api/v1/municipal/valves/${Uri.encodeComponent(valveId)}/target',
      auth: true,
    );
    return Map<String, dynamic>.from(result as Map);
  }

  Future<Map<String, dynamic>> saveTarget(String valveId, int targetPct) async {
    final result = await _request(
      'PUT',
      '/api/v1/municipal/valves/${Uri.encodeComponent(valveId)}/target',
      auth: true,
      body: {'target_pct': targetPct},
    );
    return Map<String, dynamic>.from(result as Map);
  }

  void signOut() => _token = null;
  void close() => _client.close(force: true);
}
