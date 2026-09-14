class ValveData {
  final String valveId;
  final String status;
  final int requested;
  final int actual;
  final bool connected;
  final double? voltage;

  const ValveData({
    required this.valveId,
    required this.status,
    required this.requested,
    required this.actual,
    required this.connected,
    this.voltage,
  });

  factory ValveData.fromJson(Map<String, dynamic> json) => ValveData(
        valveId: json['valve_id']?.toString() ?? '',
        status: json['status']?.toString() ?? 'STOPPED',
        requested: _int(json['requested']),
        actual: _int(json['actual']),
        connected: json['connected'] == true,
        voltage: _double(json['voltage']),
      );

  static int _int(dynamic value) => value is num ? value.round() : int.tryParse('$value') ?? 0;
  static double? _double(dynamic value) => value is num ? value.toDouble() : double.tryParse('$value');
}
