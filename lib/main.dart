import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

const Color kBlue = Color(0xFF2B6F9F);
const Color kPage = Color(0xFFF7F7FF);
const Color kGreen = Color(0xFF12A84A);
const Color kRed = Color(0xFFE92B2B);
const Color kOrange = Color(0xFFFF8A00);

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: kBlue,
            minimumSize: const Size(0, 48),
            side: const BorderSide(color: Colors.black54),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          ),
        ),
      ),
      home: const Login(),
    );
  }
}

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    const Text('Smart Valve\nManagement', textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 31, fontWeight: FontWeight.w500, height: 1.18)),
                    const SizedBox(height: 4),
                    const Text('Monitor  •  Control  •  Manage', style: TextStyle(fontSize: 18)),
                    const SizedBox(height: 28),
                    const Text('Login', style: TextStyle(fontSize: 31, fontWeight: FontWeight.w500)),
                    const Text('Agent / Operator', style: TextStyle(fontSize: 18)),
                    const SizedBox(height: 20),
                    const TextField(obscureText: true,
                        decoration: InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock))),
                    const SizedBox(height: 4),
                    Align(alignment: Alignment.centerRight,
                        child: TextButton(onPressed: () {}, child: const Text('Forgot Password?'))),
                    SizedBox(width: double.infinity,
                        child: FilledButton(onPressed: () {
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Home()));
                        }, child: const Text('LOGIN', style: TextStyle(fontSize: 17)))),
                    const SizedBox(height: 14),
                    const Info('Authentication will be sent to your registered mobile number.'),
                    const SizedBox(height: 8),
                    const Info('If app mobile number changes / phone changes, re-authentication is required.'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class Info extends StatelessWidget {
  final String text;
  const Info(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: Colors.lightBlue.shade50, borderRadius: BorderRadius.circular(12)),
    child: Text(text, style: const TextStyle(fontSize: 16, height: 1.35)),
  );
}

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int tab = 0;
  int? zone;
  int? ward;

  void nav(int value) => setState(() => tab = value);

  void add(String what) {
    showDialog<void>(context: context, builder: (context) => AlertDialog(
      title: Text('Add $what'),
      content: TextField(keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: '$what No')),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
        FilledButton(onPressed: () => Navigator.pop(context), child: const Text('ADD')),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    if (tab == 1) return const Shell(index: 1, child: Gsm());
    if (tab == 2) return const Shell(index: 2, child: Lora());
    if (tab == 3) return const Shell(index: 3, child: MapPage());

    return Scaffold(
      appBar: AppBar(title: const Text('Smart Valve Management', style: TextStyle(fontSize: 27, fontWeight: FontWeight.w500))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
        child: Card(child: Padding(padding: const EdgeInsets.fromLTRB(18, 28, 18, 24), child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Select Zone and\nWard', textAlign: TextAlign.center,
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600, height: 1.15)),
            const SizedBox(height: 24),
            DropdownButtonFormField<int>(value: zone, decoration: const InputDecoration(labelText: 'Zone No'),
              items: [1,2,3,4,5].map((x) => DropdownMenuItem(value: x, child: Text('Zone $x'))).toList(),
              onChanged: (x) => setState(() => zone = x)),
            const SizedBox(height: 8),
            OutlinedButton.icon(onPressed: () => add('Zone'), icon: const Icon(Icons.add), label: const Text('ADD ZONE', style: TextStyle(fontSize: 17))),
            const SizedBox(height: 18),
            DropdownButtonFormField<int>(value: ward, decoration: const InputDecoration(labelText: 'Ward No'),
              items: [1,2,3,4,5,6,7,8].map((x) => DropdownMenuItem(value: x, child: Text('Ward $x'))).toList(),
              onChanged: (x) => setState(() => ward = x)),
            const SizedBox(height: 8),
            OutlinedButton.icon(onPressed: () => add('Ward'), icon: const Icon(Icons.add), label: const Text('ADD WARD', style: TextStyle(fontSize: 17))),
            const SizedBox(height: 24),
            Row(children: [
              Expanded(child: Btn('GSM / LTE\nValve View', Icons.cell_tower, () => nav(1))),
              const SizedBox(width: 14),
              Expanded(child: Btn('LoRa\nValve View', Icons.cell_tower, () => nav(2))),
            ]),
            const SizedBox(height: 14),
            Btn('MAP View', Icons.map, () => nav(3)),
          ],
        ))),
      ),
      bottomNavigationBar: Nav(index: 0, onTap: nav),
    );
  }
}

class Btn extends StatelessWidget {
  final String text; final IconData icon; final VoidCallback onTap;
  const Btn(this.text, this.icon, this.onTap, {super.key});
  @override
  Widget build(BuildContext context) => FilledButton.icon(
    onPressed: onTap, icon: Icon(icon), label: Text(text, textAlign: TextAlign.center),
    style: FilledButton.styleFrom(minimumSize: const Size(0, 58), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12)),
  );
}

class Shell extends StatelessWidget {
  final Widget child; final int index;
  const Shell({super.key, required this.child, required this.index});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: child,
    bottomNavigationBar: Nav(index: index, onTap: (i) {
      if (i == 0) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Home()));
      if (i == 1) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Gsm()));
      if (i == 2) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Lora()));
      if (i == 3) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MapPage()));
    }),
  );
}

class Nav extends StatelessWidget {
  final int index; final ValueChanged<int> onTap;
  const Nav({super.key, required this.index, required this.onTap});
  @override
  Widget build(BuildContext context) => NavigationBar(
    selectedIndex: index, onDestinationSelected: onTap, height: 78,
    destinations: const [
      NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
      NavigationDestination(icon: Icon(Icons.cell_tower), label: 'GSM'),
      NavigationDestination(icon: Icon(Icons.cell_tower), label: 'LoRa'),
      NavigationDestination(icon: Icon(Icons.map), label: 'MAP'),
    ],
  );
}

class Gsm extends StatelessWidget {
  const Gsm({super.key});
  @override
  Widget build(BuildContext context) => const Valve(title: 'GSM Valve Control', type: 'GSM');
}

class Lora extends StatelessWidget {
  const Lora({super.key});
  @override
  Widget build(BuildContext context) => const Valve(title: 'LoRa Valve Control', type: 'LoRa');
}

class Valve extends StatefulWidget {
  final String title; final String type;
  const Valve({super.key, required this.title, required this.type});
  @override
  State<Valve> createState() => _ValveState();
}

class _ValveState extends State<Valve> {
  double pos = 0;
  bool bypass = false;
  bool schedule = false;

  Widget statBox(String title, String value, {IconData? icon}) => Expanded(child: Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(border: Border.all(color: Colors.black12), borderRadius: BorderRadius.circular(12), color: Colors.white),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [if (icon != null) Icon(icon, size: 23, color: kBlue), if (icon != null) const SizedBox(width: 6), Flexible(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.indigo)))]),
      const SizedBox(height: 6), Text(value, style: const TextStyle(fontSize: 16)),
    ]),
  ));

  Widget actionButton(String text, Color color, IconData icon) => Expanded(child: FilledButton.icon(
    onPressed: () {}, icon: Icon(icon, size: 20), label: Text(text),
    style: FilledButton.styleFrom(backgroundColor: color, minimumSize: const Size(0, 58), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
  ));

  Widget calibration() => Card(child: Padding(padding: const EdgeInsets.fromLTRB(12, 10, 12, 12), child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Row(children: [Icon(Icons.settings, color: kBlue), SizedBox(width: 8), Text('Calibration', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.indigo))]),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(child: FilledButton(onPressed: () {}, child: const Text('START'))),
        const SizedBox(width: 8),
        Expanded(child: FilledButton(onPressed: () {}, style: FilledButton.styleFrom(backgroundColor: kGreen), child: const Text('OPEN'))),
        const SizedBox(width: 8),
        Expanded(child: FilledButton(onPressed: () {}, style: FilledButton.styleFrom(backgroundColor: kRed), child: const Text('CLOSE'))),
        const SizedBox(width: 8),
        Expanded(child: FilledButton(onPressed: () {}, style: FilledButton.styleFrom(backgroundColor: Colors.cyan.shade700), child: const Text('COMPLETE\nSAVE TO NVS'))),
      ]),
    ],
  )));

  @override
  Widget build(BuildContext context) {
    final bool lora = widget.type == 'LoRa';
    return Scaffold(
      appBar: AppBar(title: Text(widget.title, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w600))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(14, 4, 14, 18),
        child: Column(children: [
          Card(child: Padding(padding: const EdgeInsets.all(10), child: Row(children: [
            Expanded(child: DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Valve ID (${widget.type})'),
              items: ['${widget.type}-001', '${widget.type}-002'].map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(),
              onChanged: (_) {},
            )),
            const SizedBox(width: 10),
            statBox(lora ? 'LoRa Status' : 'GSM Status', 'Online', icon: lora ? Icons.network_cell : Icons.sim_card),
            const SizedBox(width: 10),
            statBox('FW Version', lora ? 'v1.2.1' : 'v1.0.3', icon: Icons.description),
          ]))),

          Card(child: Padding(padding: const EdgeInsets.fromLTRB(12, 10, 12, 12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Valve Position', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.indigo)),
            const Text('Requested / Actual', style: TextStyle(fontSize: 17)),
            const SizedBox(height: 4),
            Row(children: [Expanded(child: Slider(value: pos, divisions: 100, label: '${pos.round()}%', onChanged: (x) => setState(() => pos = x))), Container(width: 72, padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.blueGrey.shade50, borderRadius: BorderRadius.circular(8)), child: Text('${pos.round()}%', textAlign: TextAlign.center, style: const TextStyle(fontSize: 17))) ]),
            Row(children: [
              for (final v in [0,25,50,75,100]) ...[
                Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 3), child: OutlinedButton(onPressed: () => setState(() => pos = v.toDouble()), child: Text('$v%')))),
              ],
            ]),
            const SizedBox(height: 8),
            Center(child: FilledButton(onPressed: () {}, child: Text('SET VALVE TO ${pos.round()}%'))),
            const SizedBox(height: 10),
            Row(children: [actionButton('OPEN', kGreen, Icons.arrow_upward), const SizedBox(width: 6), actionButton('CLOSE', kRed, Icons.arrow_downward), const SizedBox(width: 6), actionButton('STOP', kOrange, Icons.stop), const SizedBox(width: 6), actionButton('E-STOP', kRed, Icons.warning)]),
          ]))),

          calibration(),

          Card(child: Padding(padding: const EdgeInsets.all(10), child: Row(children: [
            statBox('Voltage', '11.50 V', icon: Icons.bolt),
            const SizedBox(width: 8),
            statBox('Over Current', 'Trip 5.0 A / Reset 6.0 A', icon: Icons.monitor_heart),
          ]))),

          Card(child: Padding(padding: const EdgeInsets.all(10), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Row(children: [Icon(Icons.schedule, color: kBlue), SizedBox(width: 8), Text('Scheduling / Clock', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.indigo))]),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: OutlinedButton(onPressed: () {}, child: const Text('VIEW\nSCHEDULE'))),
              const SizedBox(width: 5), Expanded(child: OutlinedButton(onPressed: () {}, child: const Text('START'))),
              const SizedBox(width: 5), Expanded(child: OutlinedButton(onPressed: () {}, child: const Text('SET\nSCHEDULE'))),
              const SizedBox(width: 5), Expanded(child: OutlinedButton(onPressed: () {}, child: const Text('CANCEL\nALL'))),
              const SizedBox(width: 5), Expanded(child: OutlinedButton(onPressed: () {}, child: const Text('CLOCK\nVIEW'))),
            ]),
            const SizedBox(height: 8),
            const Row(children: [Expanded(child: InfoCell('Start Time', '08:00')), SizedBox(width: 5), Expanded(child: InfoCell('Stop Time', '18:00')), SizedBox(width: 5), Expanded(child: InfoCell('Date Set', '14-09-2026')), SizedBox(width: 5), Expanded(child: InfoCell('WEEK', 'Mon - Sun'))]),
          ]))),

          Card(child: ListTile(leading: const Icon(Icons.person_add_alt_1, color: Colors.indigo), title: const Text('OWNER REBIND', style: TextStyle(fontWeight: FontWeight.w700)), onTap: () {})),
        ]),
      ),
    );
  }
}

class InfoCell extends StatelessWidget {
  final String title; final String value;
  const InfoCell(this.title, this.value, {super.key});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
    decoration: BoxDecoration(color: Colors.blueGrey.shade50, borderRadius: BorderRadius.circular(7)),
    child: Column(children: [Text(title, style: const TextStyle(fontSize: 11)), const SizedBox(height: 3), Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12))]),
  );
}

class MapPage extends StatefulWidget {
  const MapPage({super.key});
  @override State<MapPage> createState() => _MapState();
}

class _MapState extends State<MapPage> {
  final MapController map = MapController();
  final List<Marker> markers = [
    const Marker(point: LatLng(12.9716, 77.5946), width: 44, height: 44,
      child: Icon(Icons.location_pin, size: 44, color: Colors.red)),
  ];
  final List<String> valves = ['GSM-001', 'GSM-002', 'LoRa-001'];

  void addValve() => setState(() => valves.add('GSM-${(valves.length + 1).toString().padLeft(3, '0')}'));

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('MAP', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w400)), actions: [IconButton(onPressed: addValve, icon: const Icon(Icons.add_location_alt))]),
    body: Column(children: [
      Padding(padding: const EdgeInsets.fromLTRB(20, 4, 20, 10), child: Row(children: [
        const Expanded(child: Text('Municipal Valve Map', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600))),
        FilledButton.icon(onPressed: addValve, icon: const Icon(Icons.add), label: const Text('ADD VALVE')),
      ])),
      SizedBox(height: 330, child: FlutterMap(
        mapController: map,
        options: const MapOptions(initialCenter: LatLng(12.9716, 77.5946), initialZoom: 11.5),
        children: [
          TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'com.example.muncipal_operator_apk'),
          MarkerLayer(markers: markers),
        ],
      )),
      Expanded(child: ListView(padding: const EdgeInsets.fromLTRB(20, 12, 20, 20), children: [
        const Text('Valve List', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        for (final v in valves) ListTile(leading: const Icon(Icons.location_pin, color: Colors.red, size: 34), title: Text('Valve ID: $v', style: const TextStyle(fontSize: 18)), subtitle: const Text('Latitude / Longitude'), trailing: const Icon(Icons.link)),
      ])),
    ]),
  );
}
