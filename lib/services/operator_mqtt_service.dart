import 'dart:async';
import 'dart:convert';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

import '../models/valve_command.dart';
import '../models/valve_data.dart';

class OperatorMqttService {
  OperatorMqttService({
    required this.host,
    required this.clientId,
    this.port = 8883,
  }) : _client = MqttServerClient(host, clientId) {
    _client.port = port;
    _client.keepAlivePeriod = 30;
    _client.logging(on: false);
    _client.autoReconnect = true;
    _client.resubscribeOnAutoReconnect = true;
    _client.onConnected = _onConnected;
    _client.onDisconnected = _onDisconnected;
  }

  final String host;
  final int port;
  final String clientId;
  final MqttServerClient _client;
  final StreamController<ValveData> _status = StreamController.broadcast();
  StreamSubscription<List<MqttReceivedMessage<MqttMessage>>>? _updates;
  bool _connected = false;

  bool get connected => _connected;
  Stream<ValveData> get statusStream => _status.stream;

  Future<void> connect() async {
    if (_connected) return;
    try {
      await _client.connect();
    } catch (_) {
      _client.disconnect();
      rethrow;
    }
  }

  void watchValve(String valveId) {
    if (!_connected) return;
    _client.subscribe('orb/node/$valveId/status', MqttQos.atLeastOnce);
  }

  Future<void> send(ValveCommand command) async {
    if (!_connected) {
      throw StateError('MQTT is not connected');
    }
    final payload = MqttClientPayloadBuilder()
      ..addString(jsonEncode(command.toJson()));
    _client.publishMessage(
      'orb/node/${command.valveId}/cmd',
      MqttQos.atLeastOnce,
      payload.payload!,
    );
  }

  void _onConnected() {
    _connected = true;
    _updates?.cancel();
    _updates = _client.updates?.listen(_handleMessages);
  }

  void _onDisconnected() => _connected = false;

  void _handleMessages(List<MqttReceivedMessage<MqttMessage>> messages) {
    for (final message in messages) {
      final packet = message.payload;
      if (packet is! MqttPublishMessage) continue;
      final raw = MqttPublishPayload.bytesToStringAsString(packet.payload.message);
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          _status.add(ValveData.fromJson(decoded));
        }
      } catch (_) {
        // Ignore malformed status packets; they must not crash the operator UI.
      }
    }
  }

  void dispose() {
    _updates?.cancel();
    _client.disconnect();
    _status.close();
  }
}
