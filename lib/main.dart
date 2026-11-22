import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'services/municipal_api.dart';

const Color kBlue = Color(0xFF2B6F9F);
const Color kPage = Color(0xFFF7F7FF);
const Color kGreen = Color(0xFF12A84A);
const Color kRed = Color(0xFFE92B2B);
const Color kOrange = Color(0xFFFF8A00);

final MunicipalApi municipalApi = MunicipalApi();

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Smart Valve Management',
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: kPage,
          colorScheme: ColorScheme.fromSeed(seedColor: kBlue),
          appBarTheme: const AppBarTheme(
            backgroundColor: kPage,
            foregroundColor: Colors.black87,
            elevation: 0,
            centerTitle: false,
          ),
          cardTheme: CardThemeData(
            elevation: 1,
            margin: const EdgeInsets.symmetric(vertical: 7),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: kPage,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.black54),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
          ),
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              backgroundColor: kBlue,
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              textStyle: const TextStyle(fontSize: 16),
            ),
          ),
        ),
        home: const Login(),
      );
}

class Login extends StatefulWidget {
  const Login({super.key});
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final phone = TextEditingController();
  final otp = TextEditingController();
  bool otpRequested = false;
  bool busy = false;
  String? developmentOtp;

  @override
  void dispose() {
    phone.dispose();
    otp.dispose();
    super.dispose();
  }

  void message(String value) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }

  Future<void> requestOtp() async {
    final digits = phone.text.replaceAll(RegExp(r'\\D'), '');
    if (digits.length < 10) {
      message('Enter the registered 10-digit mobile number.');
      return;
    }
    setState(() => busy = true);
    try {
      final result = await municipalApi.requestOtp(digits.substring(digits.length - 10));
      setState(() {
        otpRequested = true;
        developmentOtp = result['debug_otp']?.toString();
      });
      message('OTP request accepted. Check the registered mobile.');
    } catch (e) {
      message(e.toString());
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> verifyOtp() async {
    final digits = phone.text.replaceAll(RegExp(r'\\D'), '');
    if (digits.length < 10 || otp.text.trim().length != 6) {
      message('Enter the registered mobile number and 6-digit OTP.');
      return;
    }
    setState(() => busy = true);
    try {
      await municipalApi.verifyOtp(digits.substring(digits.length - 10), otp.text.trim());
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Home()));
    } catch (e) {
      message(e.toString());
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(22),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 22),
                  child: Column(
                    children: [
                      const Icon(Icons.water_drop, size: 76, color: Colors.blue),
                      const SizedBox(height: 10),
                      const Text('Smart Valve\\nManagement',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 31, fontWeight: FontWeight.w500, height: 1.18)),
                      const SizedBox(height: 4),
                      const Text('Monitor  •  Control  •  Manage', style: TextStyle(fontSize: 18)),
                      const SizedBox(height: 28),
                      const Text('Login', style: TextStyle(fontSize: 31, fontWeight: FontWeight.w500)),
                      const Text('Agent / Operator', style: TextStyle(fontSize: 18)),
                      const SizedBox(height: 20),
                      TextField(
                        controller: phone,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        decoration: const InputDecoration(
                          labelText: 'Registered mobile number',
                          prefixIcon: Icon(Icons.phone),
                          counterText: '',
                        ),
                      ),
                      if (otpRequested) ...[
                        const SizedBox(height: 12),
                        TextField(
                          controller: otp,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          decoration: const InputDecoration(
                            labelText: '6-digit OTP',
                            prefixIcon: Icon(Icons.lock),
                            counterText: '',
                          ),
                        ),
                        if (developmentOtp != null)
                          Info('Development OTP: $developmentOtp'),
                      ],
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: busy ? null : (otpRequested ? verifyOtp : requestOtp),
                          child: Text(busy ? 'PLEASE WAIT...' : (otpRequested ? 'VERIFY OTP' : 'REQUEST OTP')),
                        ),
                      ),
                      if (otpRequested)
                        TextButton(
                          onPressed: busy ? null : () => setState(() {
                                otpRequested = false;
                                otp.clear();
                                developmentOtp = null;
                              }),
                          child: const Text('Change mobile number'),
                        ),
                      const SizedBox(height: 14),
                      const Info('Authentication uses the municipality operator phone registered with the server.'),
                      const SizedBox(height: 8),
                      const Info('Changing the app mobile number requires fresh authentication.'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}

class Info extends StatelessWidget {
  final String text;
  const Info(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.lightBlue.shade50, borderRadius: BorderRadius.circular(12)),
        child: Text(text, style: const TextStyle(fontSize: 15, height: 1.35)),
      );
}

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int tab = 0;
  int? zoneIndex;
  String? selectedZone;
  String? selectedWard;
  late Future<List<MunicipalValve>> inventory;

  @override
  void initState() {
    super.initState();
    inventory = municipalApi.registeredValves();
  }

  Future<void> refresh() async {
    setState(() => inventory = municipalApi.registeredValves());
    try { await inventory; } catch (_) { /* FutureBuilder renders the API error. */ }
  }

  void logout() {
    municipalApi.signOut();
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const Login()), (_) => false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(
            tab == 0 ? 'Smart Valve Management' : (tab == 1 ? 'GSM / LTE Valves' : (tab == 2 ? 'LoRa Valves' : 'MAP')),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
          ),
          actions: [
            IconButton(onPressed: refresh, icon: const Icon(Icons.refresh), tooltip: 'Refresh from server'),
            IconButton(onPressed: logout, icon: const Icon(Icons.logout), tooltip: 'Sign out'),
          ],
        ),
        body: FutureBuilder<List<MunicipalValve>>(
          future: inventory,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.cloud_off, size: 48, color: kRed),
                    const SizedBox(height: 12),
                    Text(snapshot.error.toString(), textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    FilledButton.icon(onPressed: refresh, icon: const Icon(Icons.refresh), label: const Text('RETRY')),
                  ]),
                ),
              );
            }
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            final valves = snapshot.data!;
            final zones = valves.map((v) => v.zoneId).where((v) => v.isNotEmpty).toSet().toList()..sort();
            final activeZone = zones.contains(selectedZone) ? selectedZone : null;
            final wards = valves
                .where((v) => activeZone == null || v.zoneId == activeZone)
                .map((v) => v.wardId)
                .where((v) => v.isNotEmpty)
                .toSet()
                .toList()
              ..sort();
            final activeWard = wards.contains(selectedWard) ? selectedWard : null;
            final scoped = valves.where((v) =>
                (activeZone == null || v.zoneId == activeZone) &&
                (activeWard == null || v.wardId == activeWard)).toList();

            if (tab == 1) return ValvePage(title: 'GSM / LTE Valve Control', valves: scoped.where((v) => !v.isLora).toList());
            if (tab == 2) return ValvePage(title: 'LoRa Valve Control', valves: scoped.where((v) => v.isLora).toList());
            if (tab == 3) return MapPage(valves: scoped);
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 28, 18, 24),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    const Text('Select Zone and\\nWard',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600, height: 1.15)),
                    const SizedBox(height: 24),
                    DropdownButtonFormField<String>(
                      value: activeZone,
                      decoration: const InputDecoration(labelText: 'Zone No'),
                      items: zones.map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(),
                      onChanged: (x) => setState(() {
                        selectedZone = x;
                        selectedWard = null;
                      }),
                    ),
                    const SizedBox(height: 18),
                    DropdownButtonFormField<String>(
                      value: activeWard,
                      decoration: const InputDecoration(labelText: 'Ward No'),
                      items: wards.map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(),
                      onChanged: (x) => setState(() => selectedWard = x),
                    ),
                    const SizedBox(height: 22),
                    Info('Server inventory: ${scoped.length} registered valves. Zone and ward choices are derived from authorized server placements.'),
                    const SizedBox(height: 18),
                    Row(children: [
                      Expanded(child: Btn('GSM / LTE\\nValve View', Icons.cell_tower, () => setState(() => tab = 1))),
                      const SizedBox(width: 14),
                      Expanded(child: Btn('LoRa\\nValve View', Icons.cell_tower, () => setState(() => tab = 2))),
                    ]),
                    const SizedBox(height: 14),
                    Btn('MAP View', Icons.map, () => setState(() => tab = 3)),
                  ]),
                ),
              ),
            );
          },
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: tab,
          onDestinationSelected: (value) => setState(() => tab = value),
          height: 78,
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
            NavigationDestination(icon: Icon(Icons.cell_tower), label: 'GSM'),
            NavigationDestination(icon: Icon(Icons.cell_tower), label: 'LoRa'),
            NavigationDestination(icon: Icon(Icons.map), label: 'MAP'),
          ],
        ),
      );
}

class Btn extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onTap;
  const Btn(this.text, this.icon, this.onTap, {super.key});
  @override
  Widget build(BuildContext context) => FilledButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(text, textAlign: TextAlign.center),
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 58),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      );
}

class ValvePage extends StatefulWidget {
  final String title;
  final List<MunicipalValve> valves;
  const ValvePage({super.key, required this.title, required this.valves});
  @override
  State<ValvePage> createState() => _ValvePageState();
}

class _ValvePageState extends State<ValvePage> {
  String? valveId;
  int target = 0;
  bool busy = false;
  String? targetUpdatedAt;

  MunicipalValve? get selected {
    for (final valve in widget.valves) {
      if (valve.valveId == valveId) return valve;
    }
    return widget.valves.isEmpty ? null : widget.valves.first;
  }

  @override
  void didUpdateWidget(covariant ValvePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.valves.any((v) => v.valveId == valveId)) valveId = null;
  }

  Future<void> loadTarget(String id) async {
    try {
      final data = await municipalApi.getTarget(id);
      if (!mounted || selected?.valveId != id) return;
      setState(() => target = (data['target_pct'] as num?)?.toInt() ?? 0);
    } catch (_) {
      // A missing target is a normal first-use state.
    }
  }

  void showMessage(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> sendCommand(String command) async {
    final valve = selected;
    if (valve == null || busy) return;
    setState(() => busy = true);
    try {
      final result = await municipalApi.command(valve.valveId, command);
      final accepted = result['accepted'] == true;
      final delivery = result['delivery']?.toString() ?? 'UNKNOWN';
      final ack = result['acknowledgement']?.toString() ?? 'UNKNOWN';
      showMessage(accepted
          ? '$command accepted by server. Delivery: $delivery; acknowledgement: $ack. Physical movement is not inferred.'
          : '$command was not accepted.');
    } catch (e) {
      showMessage(e.toString());
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> saveTarget() async {
    final valve = selected;
    if (valve == null || busy) return;
    setState(() => busy = true);
    try {
      final result = await municipalApi.saveTarget(valve.valveId, target);
      setState(() => targetUpdatedAt = result['updated_at']?.toString());
      showMessage('Requested display target saved. This does not move the valve.');
    } catch (e) {
      showMessage(e.toString());
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Widget statBox(String title, String value, {IconData? icon}) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black12),
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              if (icon != null) Icon(icon, size: 23, color: kBlue),
              if (icon != null) const SizedBox(width: 6),
              Flexible(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.indigo))),
            ]),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(fontSize: 16)),
          ]),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final valve = selected;
    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 18),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: widget.valves.isEmpty
                ? const Info('No registered valves are available in this transport and selected zone/ward.')
                : Column(children: [
                    DropdownButtonFormField<String>(
                      value: valve?.valveId,
                      decoration: const InputDecoration(labelText: 'Registered Valve ID'),
                      items: widget.valves.map((v) => DropdownMenuItem(value: v.valveId, child: Text(v.valveId))).toList(),
                      onChanged: (id) {
                        setState(() => valveId = id);
                        if (id != null) loadTarget(id);
                      },
                    ),
                    const SizedBox(height: 10),
                    Row(children: [
                      statBox('Transport', valve?.transport ?? '—', icon: Icons.cell_tower),
                      const SizedBox(width: 8),
                      statBox('Server Status', valve?.status ?? '—', icon: Icons.info_outline),
                    ]),
                    if (valve?.deviceId != null) Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Align(alignment: Alignment.centerLeft, child: Text('Device: ${valve!.deviceId}')),
                    ),
                  ]),
          ),
        ),
        if (valve != null) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Valve Position Target', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.indigo)),
                const Text('Requested target only; actual position comes from actuator telemetry.'),
                Row(children: [
                  Expanded(child: Slider(value: target.toDouble(), min: 0, max: 100, divisions: 100, label: '$target%', onChanged: busy ? null : (x) => setState(() => target = x.round()))),
                  Container(width: 72, padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.blueGrey.shade50, borderRadius: BorderRadius.circular(8)), child: Text('$target%', textAlign: TextAlign.center)),
                ]),
                Row(children: [
                  for (final value in [0, 25, 50, 75, 100])
                    Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 2), child: OutlinedButton(onPressed: busy ? null : () => setState(() => target = value), child: Text('$value%')))),
                ]),
                const SizedBox(height: 8),
                SizedBox(width: double.infinity, child: FilledButton(onPressed: busy ? null : saveTarget, child: const Text('SAVE REQUESTED TARGET'))),
                if (targetUpdatedAt != null) Text('Last saved: $targetUpdatedAt', style: const TextStyle(fontSize: 12)),
              ]),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                const Text('Valve Commands', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.indigo)),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(child: FilledButton.icon(onPressed: busy ? null : () => sendCommand('OPEN'), icon: const Icon(Icons.arrow_upward), label: const Text('OPEN'), style: FilledButton.styleFrom(backgroundColor: kGreen))),
                  const SizedBox(width: 6),
                  Expanded(child: FilledButton.icon(onPressed: busy ? null : () => sendCommand('CLOSE'), icon: const Icon(Icons.arrow_downward), label: const Text('CLOSE'), style: FilledButton.styleFrom(backgroundColor: kRed))),
                  const SizedBox(width: 6),
                  Expanded(child: FilledButton.icon(onPressed: busy ? null : () => sendCommand('STOP'), icon: const Icon(Icons.stop), label: const Text('STOP'), style: FilledButton.styleFrom(backgroundColor: kOrange))),
                ]),
                const SizedBox(height: 8),
                const Info('Commands pass through the municipal server, which checks operator scope and transport delivery. STOP is supported; a separate emergency-stop command is not exposed by this server API.'),
              ]),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                const Text('Live Electrical Telemetry', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.indigo)),
                const SizedBox(height: 8),
                const Info('Voltage, current, OC trip and low-voltage bypass are not included in the registered-valves API response. No sample or fabricated values are displayed here.'),
              ]),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                const Text('Calibration / Scheduling', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.indigo)),
                const SizedBox(height: 8),
                const Info('These actions are not connected to municipal server endpoints yet and are intentionally disabled.'),
                Wrap(spacing: 8, runSpacing: 4, children: [
                  for (final label in ['CALIBRATION', 'SCHEDULE', 'CLOCK', 'VOLTAGE BYPASS', 'OWNER REBIND'])
                    OutlinedButton(onPressed: null, child: Text(label)),
                ]),
              ]),
            ),
          ),
        ],
      ],
    );
  }
}

class MapPage extends StatelessWidget {
  final List<MunicipalValve> valves;
  const MapPage({super.key, required this.valves});

  @override
  Widget build(BuildContext context) {
    final located = valves.where((v) => v.hasCoordinates).toList();
    final center = located.isNotEmpty
        ? LatLng(located.first.latitude!, located.first.longitude!)
        : const LatLng(20.5937, 78.9629);
    final markers = located.map((v) => Marker(
          point: LatLng(v.latitude!, v.longitude!),
          width: 48,
          height: 48,
          child: Tooltip(
            message: '${v.valveId} • ${v.transport} • Ward ${v.wardId}',
            child: Icon(Icons.location_pin, size: 44, color: v.isLora ? Colors.deepPurple : kRed),
          ),
        )).toList();

    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
        child: Row(children: [
          const Expanded(child: Text('Municipal Valve Map', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600))),
          Text('${located.length} mapped / ${valves.length} registered'),
        ]),
      ),
      SizedBox(
        height: 330,
        child: FlutterMap(
          options: MapOptions(initialCenter: center, initialZoom: located.isNotEmpty ? 12 : 4),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.muncipal_operator_apk',
            ),
            MarkerLayer(markers: markers),
          ],
        ),
      ),
      Expanded(
        child: valves.isEmpty
            ? const Center(child: Info('No municipal valves are registered for this operator scope.'))
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                children: [
                  const Text('Valve List', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  for (final valve in valves)
                    ListTile(
                      leading: Icon(Icons.location_pin, color: valve.isLora ? Colors.deepPurple : kRed, size: 34),
                      title: Text('Valve ID: ${valve.valveId}', style: const TextStyle(fontSize: 18)),
                      subtitle: Text('Transport: ${valve.transport} • Zone: ${valve.zoneId} • Ward: ${valve.wardId}\n${valve.hasCoordinates ? '${valve.latitude}, ${valve.longitude}' : 'GPS coordinates not registered'}'),
                      trailing: const Icon(Icons.link),
                    ),
                ],
              ),
      ),
    ]);
  }
}
