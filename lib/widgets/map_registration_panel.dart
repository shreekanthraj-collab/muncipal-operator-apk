import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../services/municipal_api.dart';

class MapRegistrationPanel extends StatefulWidget {
  final Future<void> Function() onRegistered;

  const MapRegistrationPanel({super.key, required this.onRegistered});

  @override
  State<MapRegistrationPanel> createState() => _MapRegistrationPanelState();
}

class _MapRegistrationPanelState extends State<MapRegistrationPanel> {
  bool _busy = false;

  void _message(String value) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }

  Future<Position> _currentPosition() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw Exception('Enable GPS/location services before registering.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw Exception('Location permission is required for valve registration.');
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 25),
      ),
    );
  }

  Future<String?> _scanToken() {
    return Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const _ValveQrScannerPage()),
    );
  }

  Future<void> _startQrRegistration() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final token = await _scanToken();
      if (!mounted || token == null || token.trim().isEmpty) return;

      final preview = await municipalApi.scanPreview(token.trim());
      if (!mounted) return;

      final valveId = (preview['valve_id'] ?? '').toString();
      final rawTransport = (preview['transport_type'] ?? '').toString().trim().toUpperCase();
      final transport = (rawTransport == 'LORA') ? 'LORA' : 'GSM';

      if (valveId.isEmpty || (rawTransport != 'LORA' &&
          rawTransport != 'GSM' && rawTransport != 'LTE' &&
          rawTransport != 'CELLULAR')) {
        throw Exception('QR preview returned an invalid valve identity or transport.');
      }

      await _showRegistrationCard(
        registrationToken: token.trim(),
        scannedValveId: valveId,
        scannedTransport: transport,
      );
    } catch (error) {
      _message(error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _startManualRegistration() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await _showRegistrationCard();
    } catch (error) {
      _message(error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _showRegistrationCard({
    String? registrationToken,
    String? scannedValveId,
    String? scannedTransport,
  }) async {
    final position = await _currentPosition();
    if (!mounted) return;

    final valveIdController = TextEditingController(text: scannedValveId ?? '');
    final wardController = TextEditingController();
    final zoneController = TextEditingController();
    var transportType = scannedTransport ?? 'GSM';
    var valveType = 'DISTRIBUTION';
    var submitting = false;

    final registered = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            registrationToken == null ? 'REGISTER BY VALVE ID' : 'REGISTER VALVE QR',
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w500),
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 460,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (registrationToken == null) ...[
                    TextField(
                      controller: valveIdController,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(labelText: 'Valve ID'),
                    ),
                    const SizedBox(height: 10),
                  ],
                  DropdownButtonFormField<String>(
                    value: transportType,
                    decoration: const InputDecoration(labelText: 'Transport Type'),
                    items: const [
                      DropdownMenuItem(value: 'GSM', child: Text('GSM / LTE')),
                      DropdownMenuItem(value: 'LORA', child: Text('LoRa')),
                    ],
                    onChanged: registrationToken != null
                        ? null
                        : (value) {
                            if (value != null) {
                              setDialogState(() => transportType = value);
                            }
                          },
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: valveType,
                    decoration: const InputDecoration(labelText: 'Valve Type'),
                    items: const [
                      DropdownMenuItem(value: 'MAIN', child: Text('MAIN')),
                      DropdownMenuItem(value: 'DISTRIBUTION', child: Text('DISTRIBUTION')),
                    ],
                    onChanged: (value) {
                      if (value != null) setDialogState(() => valveType = value);
                    },
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: wardController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(labelText: 'Ward ID'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: zoneController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(labelText: 'Zone ID'),
                  ),
                  const SizedBox(height: 10),
                  InputDecorator(
                    decoration: const InputDecoration(labelText: 'Latitude'),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(position.latitude.toStringAsFixed(6)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  InputDecorator(
                    decoration: const InputDecoration(labelText: 'Longitude'),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(position.longitude.toStringAsFixed(6)),
                    ),
                  ),
                  if (registrationToken != null) ...[
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Scanned valve: ' + (scannedValveId ?? ''),
                        style: const TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: submitting ? null : () => Navigator.pop(dialogContext, false),
              child: const Text('CANCEL'),
            ),
            FilledButton(
              onPressed: submitting
                  ? null
                  : () async {
                      final ward = wardController.text.trim();
                      final zone = zoneController.text.trim();
                      final valveId = valveIdController.text.trim();

                      if (ward.isEmpty || zone.isEmpty ||
                          (registrationToken == null && valveId.isEmpty)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Enter Valve ID, Ward ID and Zone ID.')),
                        );
                        return;
                      }

                      setDialogState(() => submitting = true);
                      try {
                        if (registrationToken != null) {
                          await municipalApi.registerPlacement(
                            registrationToken: registrationToken,
                            wardId: ward,
                            zoneId: zone,
                            latitude: position.latitude,
                            longitude: position.longitude,
                            transportType: transportType,
                            valveType: valveType,
                          );
                        } else {
                          await municipalApi.registerByValveId(
                            valveId: valveId,
                            wardId: ward,
                            zoneId: zone,
                            latitude: position.latitude,
                            longitude: position.longitude,
                            transportType: transportType,
                            valveType: valveType,
                          );
                        }
                        if (dialogContext.mounted) {
                          Navigator.pop(dialogContext, true);
                        }
                      } catch (error) {
                        if (dialogContext.mounted) {
                          setDialogState(() => submitting = false);
                          ScaffoldMessenger.of(dialogContext).showSnackBar(
                            SnackBar(content: Text(error.toString())),
                          );
                        }
                      }
                    },
              child: submitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('REGISTER'),
            ),
          ],
        ),
      ),
    );

    valveIdController.dispose();
    wardController.dispose();
    zoneController.dispose();

    if (registered == true && mounted) {
      _message('Valve registration saved to server.');
      await widget.onRegistered();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'VALVE ID (GSM + LoRa)',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _busy ? null : _startQrRegistration,
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('SCAN VALVE QR'),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: _busy ? null : _startManualRegistration,
              icon: const Icon(Icons.edit_note),
              label: const Text('REGISTER BY VALVE ID'),
            ),
            if (_busy) const LinearProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

class _ValveQrScannerPage extends StatefulWidget {
  const _ValveQrScannerPage();

  @override
  State<_ValveQrScannerPage> createState() => _ValveQrScannerPageState();
}

class _ValveQrScannerPageState extends State<_ValveQrScannerPage> {
  bool _handled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SCAN VALVE QR')),
      body: MobileScanner(
        onDetect: (capture) {
          if (_handled || capture.barcodes.isEmpty) return;
          final value = capture.barcodes.first.rawValue?.trim();
          if (value == null || value.isEmpty) return;
          _handled = true;
          Navigator.of(context).pop(value);
        },
      ),
    );
  }
}
