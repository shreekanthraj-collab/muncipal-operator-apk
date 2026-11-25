import 'package:flutter_test/flutter_test.dart';
import 'package:muncipal_operator_apk/services/municipal_api.dart';

void main() {
  group('MunicipalValve location contract', () {
    test('parses MAIN valve with ward, zone, GPS and transport identity', () {
      final valve = MunicipalValve.fromJson({
        'valve_id': 'VALVE-MAIN-01',
        'ward_id': 'WARD-01',
        'zone_id': 'ZONE-02',
        'valve_type': 'MAIN',
        'latitude': 13.3409,
        'longitude': 74.7421,
        'transport': 'GSM',
        'device_id': 'ESP32-001',
        'status': 'ACTIVE',
      });

      expect(valve.valveId, 'VALVE-MAIN-01');
      expect(valve.wardId, 'WARD-01');
      expect(valve.zoneId, 'ZONE-02');
      expect(valve.valveType, 'MAIN');
      expect(valve.latitude, 13.3409);
      expect(valve.longitude, 74.7421);
      expect(valve.transport, 'GSM');
      expect(valve.deviceId, 'ESP32-001');
      expect(valve.hasCoordinates, isTrue);
    });

    test('parses DISTRIBUTION valve type without changing GPS or ward-zone data', () {
      final valve = MunicipalValve.fromJson({
        'id': 'VALVE-DIST-01',
        'ward': 'WARD-03',
        'zone': 'ZONE-04',
        'valve_type': 'DISTRIBUTION',
        'latitude': '13.35',
        'longitude': '74.75',
        'valve_transport': 'LORA',
      });

      expect(valve.valveId, 'VALVE-DIST-01');
      expect(valve.wardId, 'WARD-03');
      expect(valve.zoneId, 'ZONE-04');
      expect(valve.valveType, 'DISTRIBUTION');
      expect(valve.transport, 'LORA');
      expect(valve.hasCoordinates, isTrue);
    });

    test('legacy server records default to DISTRIBUTION', () {
      final valve = MunicipalValve.fromJson({
        'valve_id': 'VALVE-LEGACY-01',
        'ward_id': 'WARD-01',
        'zone_id': 'ZONE-01',
      });

      expect(valve.valveType, 'DISTRIBUTION');
      expect(valve.hasCoordinates, isFalse);
    });
  });
}
