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
    if (tab == 4) return const Shell(index: 4, child: Rs485Page());

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
            const SizedBox(height: 14),
            Btn('RS485 / MODBUS View', Icons.cable, () => nav(4)),
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
      if (i == 4) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Shell(index: 4, child: Rs485Page())));
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
      NavigationDestination(icon: Icon(Icons.cable), label: 'RS485'),
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

class ValveStatus {
  final bool ocTrip;
  final bool ocLocked;
  final bool lowVoltage;
  final bool lowVoltageBypass;
  final double currentA;
  final double voltageV;

  const ValveStatus({
    this.ocTrip = false,
    this.ocLocked = false,
    this.lowVoltage = false,
    this.lowVoltageBypass = false,
    this.currentA = 0.0,
    this.voltageV = 0.0,
  });

  factory ValveStatus.fromJson(Map<String, dynamic> json) {
    final faults = Map<String, dynamic>.from(json['faults'] ?? const {});
    final electrical = Map<String, dynamic>.from(json['electrical'] ?? const {});
    return ValveStatus(
      ocTrip: faults['oc_trip'] == true,
      ocLocked: faults['oc_locked'] == true,
      lowVoltage: faults['low_voltage'] == true,
      lowVoltageBypass: faults['low_voltage_bypass'] == true,
      currentA: (electrical['current_a'] as num?)?.toDouble() ?? 0.0,
      voltageV: (electrical['voltage_v'] as num?)?.toDouble() ?? 0.0,
    );
  }
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
  ValveStatus status = const ValveStatus();

  void applyStatusJson(Map<String, dynamic> json) {
    setState(() => status = ValveStatus.fromJson(json));
  }

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

          Card(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(children: [
                    statBox(
                      'Voltage',
                      status.voltageV > 0 ? '${status.voltageV.toStringAsFixed(2)} V' : '11.50 V',
                      icon: Icons.bolt,
                    ),
                    const SizedBox(width: 8),
                    statBox('Over Current', 'Trip 5.0 A / Reset 6.0 A', icon: Icons.monitor_heart),
                  ]),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: status.ocTrip ? kRed.withOpacity(0.10) : kGreen.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: status.ocTrip ? kRed : kGreen, width: 1.5),
                    ),
                    child: Row(children: [
                      Icon(Icons.circle, size: 15, color: status.ocTrip ? kRed : kGreen),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          status.ocTrip ? 'FAULT  /  OC TRIP' : 'OC STATUS  /  NORMAL',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: status.ocTrip ? kRed : kGreen,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Text(
                        '${status.currentA.toStringAsFixed(2)} A',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => setState(() => bypass = !bypass),
                      icon: Icon(status.lowVoltageBypass ? Icons.warning_amber_rounded : Icons.bolt),
                      label: Text(
                        status.lowVoltageBypass
                            ? 'LOW VOLTAGE BYPASS ACTIVE'
                            : (bypass ? 'VOLTAGE BYPASS REQUESTED' : 'VOLTAGE BYPASS'),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: status.lowVoltageBypass || bypass ? kOrange : kBlue,
                        minimumSize: const Size(0, 52),
                      ),
                    ),
                  ),
                  if (status.lowVoltageBypass || status.lowVoltage)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(children: [
                        Icon(Icons.warning_amber_rounded, color: kOrange, size: 19),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            status.lowVoltageBypass
                                ? 'LOW VOLTAGE BYPASS ACTIVE'
                                : 'LOW VOLTAGE DETECTED',
                            style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.deepOrange),
                          ),
                        ),
                      ]),
                    ),
                ],
              ),
            ),
          ),

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


// Page 5: manufacturer-independent RS485 / Modbus device view.
class Rs485Device {
  final int slot, slaveId, baud, startRegister, registerCount;
  final String make, model, parity, measurement, unit, status;
  final bool configured;
  const Rs485Device({required this.slot,this.slaveId=0,this.baud=9600,this.startRegister=0,this.registerCount=1,this.make='',this.model='',this.parity='None',this.measurement='',this.unit='',this.status='EMPTY',this.configured=false});
}

class Rs485Page extends StatefulWidget {
  const Rs485Page({super.key});
  @override State<Rs485Page> createState()=>_Rs485PageState();
}
class _Rs485PageState extends State<Rs485Page> {
  final List<Rs485Device> devices=List.generate(8,(i)=>Rs485Device(slot:i+1));

  Future<void> configure(Rs485Device d) async {
    final make=TextEditingController(text:d.make), model=TextEditingController(text:d.model);
    final slave=TextEditingController(text:d.slaveId==0?'':d.slaveId.toString());
    final baud=TextEditingController(text:d.baud.toString());
    final reg=TextEditingController(text:d.startRegister.toString());
    final count=TextEditingController(text:d.registerCount.toString());
    final measure=TextEditingController(text:d.measurement), unit=TextEditingController(text:d.unit);
    String parity=d.parity;
    final result=await showDialog<Rs485Device>(context:context,builder:(dc)=>StatefulBuilder(builder:(ctx,setD)=>AlertDialog(
      title:Text('Configure RS485 Slot '+d.slot.toString()),
      content:SizedBox(width:480,child:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,children:[
        const Info('The sensor remains sealed. Use its manufacturer Modbus manual or a verified driver profile. Never guess register addresses or scaling.'),
        const SizedBox(height:8),TextField(controller:make,decoration:const InputDecoration(labelText:'Manufacturer')),
        const SizedBox(height:8),TextField(controller:model,decoration:const InputDecoration(labelText:'Model')),
        const SizedBox(height:8),TextField(controller:slave,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'Slave ID (1–247)')),
        const SizedBox(height:8),TextField(controller:baud,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'Baud rate')),
        const SizedBox(height:8),DropdownButtonFormField<String>(value:parity,decoration:const InputDecoration(labelText:'Parity'),items:['None','Even','Odd'].map((x)=>DropdownMenuItem(value:x,child:Text(x))).toList(),onChanged:(x)=>setD(()=>parity=x??'None')),
        const SizedBox(height:8),TextField(controller:reg,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'Start register address (decimal)')),
        const SizedBox(height:8),TextField(controller:count,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'Register count')),
        const SizedBox(height:8),TextField(controller:measure,decoration:const InputDecoration(labelText:'Measurement name')),
        const SizedBox(height:8),TextField(controller:unit,decoration:const InputDecoration(labelText:'Engineering unit')),
      ]))),
      actions:[
        TextButton(onPressed:()=>Navigator.pop(dc),child:const Text('CANCEL')),
        FilledButton(onPressed:(){
          final id=int.tryParse(slave.text), b=int.tryParse(baud.text), r=int.tryParse(reg.text), n=int.tryParse(count.text);
          if(make.text.trim().isEmpty||model.text.trim().isEmpty||id==null||id<1||id>247||b==null||b<1200||r==null||r<0||r>65535||n==null||n<1||n>125){
            ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content:Text('Enter valid manufacturer, model and Modbus settings.')));return;
          }
          Navigator.pop(dc,Rs485Device(slot:d.slot,make:make.text.trim(),model:model.text.trim(),slaveId:id,baud:b,parity:parity,startRegister:r,registerCount:n,measurement:measure.text.trim(),unit:unit.text.trim(),status:'CONFIGURED',configured:true));
        },child:const Text('SAVE CONFIG')),
      ],
    )));
    if(result!=null&&mounted){setState(()=>devices[d.slot-1]=result);ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Saved as a local draft. Gateway/server sync is not connected yet.')));}
    for(final x in [make,model,slave,baud,reg,count,measure,unit]){x.dispose();}
  }

  void searchDrivers()=>showDialog<void>(context:context,builder:(ctx){
    final query=TextEditingController();
    return AlertDialog(title:const Text('Search Driver Catalogue'),content:Column(mainAxisSize:MainAxisSize.min,children:[
      TextField(controller:query,decoration:const InputDecoration(labelText:'Manufacturer / model')),
      const SizedBox(height:10),
      const Info('Only verified driver profiles should appear here. The driver catalogue API is not connected in this APK branch yet.'),
    ]),actions:[TextButton(onPressed:()=>Navigator.pop(ctx),child:const Text('CLOSE'))]);
  });

  void candidateDrivers()=>showDialog<void>(context:context,builder:(ctx)=>AlertDialog(
    title:const Text('Candidate Drivers'),
    content:const Text('No candidate driver records are currently synchronized. Add a manufacturer/model and the verified Modbus register map when available. A slave address response alone does not identify the sensor.'),
    actions:[TextButton(onPressed:()=>Navigator.pop(ctx),child:const Text('CLOSE'))],
  ));

  void scanInfo()=>showDialog<void>(context:context,builder:(ctx)=>AlertDialog(
    title:const Text('Scan RS485 Devices'),
    content:const Text('A gateway scan can discover responding Modbus slave IDs. It cannot identify manufacturer/model or infer register maps. Live scan requires gateway/server discovery integration.'),
    actions:[TextButton(onPressed:()=>Navigator.pop(ctx),child:const Text('CLOSE'))],
  ));

  Widget deviceCard(Rs485Device d){
    final color=d.status=='ONLINE'?kGreen:d.status=='OFFLINE'?kRed:Colors.blueGrey;
    return Card(color:Colors.white,child:Padding(padding:const EdgeInsets.all(12),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Row(children:[
        Container(width:40,height:40,alignment:Alignment.center,decoration:BoxDecoration(color:Colors.blueGrey.shade100,borderRadius:BorderRadius.circular(10)),child:Text(d.slot.toString(),style:const TextStyle(fontSize:18,fontWeight:FontWeight.w700))),
        const SizedBox(width:12),Expanded(child:Text(d.configured?(d.measurement.isEmpty?d.model:d.measurement):'RS485 Device Slot',style:const TextStyle(fontSize:17,fontWeight:FontWeight.w600))),
        Container(padding:const EdgeInsets.symmetric(horizontal:13,vertical:8),decoration:BoxDecoration(border:Border.all(color:color.withOpacity(.5)),borderRadius:BorderRadius.circular(9)),child:Text(d.status,style:TextStyle(color:color,fontWeight:FontWeight.w600))),
      ]),
      const SizedBox(height:12),
      Text(d.configured?'Slave ID: '+d.slaveId.toString()+'  •  '+d.make+'  •  Model: '+d.model:'Slot '+d.slot.toString()+'  •  No device configured',style:TextStyle(color:Colors.grey.shade600,fontSize:13)),
      const SizedBox(height:10),
      Row(children:[const Text('VALUE',style:TextStyle(fontSize:11,fontWeight:FontWeight.w700)),const SizedBox(width:8),const Text('--',style:TextStyle(fontSize:16,fontWeight:FontWeight.w600)),if(d.unit.isNotEmpty)Text(' '+d.unit),const Spacer(),TextButton.icon(onPressed:()=>configure(d),icon:const Icon(Icons.settings,size:18),label:Text(d.configured?'CONFIG':'ADD / CONFIG'))]),
    ])));
  }

  @override Widget build(BuildContext context)=>Scaffold(
    appBar:AppBar(centerTitle:true,leading:IconButton(icon:const Icon(Icons.arrow_back),onPressed:()=>Navigator.pushReplacement(context,MaterialPageRoute(builder:(_)=>const Home()))),title:const Text('RS485 / MODBUS',style:TextStyle(fontSize:22,fontWeight:FontWeight.w500))),
    body:ListView(padding:const EdgeInsets.fromLTRB(20,8,20,20),children:[
      const Text('RS485 Device Management',style:TextStyle(fontSize:19,fontWeight:FontWeight.w600)),
      const SizedBox(height:8),
      Wrap(spacing:8,runSpacing:8,children:[
        OutlinedButton.icon(onPressed:scanInfo,icon:const Icon(Icons.search),label:const Text('SCAN FOR DEVICES')),
        OutlinedButton.icon(onPressed:devices.any((x)=>!x.configured)?(){configure(devices.firstWhere((x)=>!x.configured));}:null,icon:const Icon(Icons.add),label:const Text('ADD MANUALLY')),
        OutlinedButton.icon(onPressed:searchDrivers,icon:const Icon(Icons.manage_search),label:const Text('SEARCH DRIVERS')),
        OutlinedButton.icon(onPressed:candidateDrivers,icon:const Icon(Icons.list_alt),label:const Text('CANDIDATE DRIVERS')),
      ]),
      const SizedBox(height:8),const Info('Eight fixed Modbus slots. Different manufacturers are supported through verified driver profiles and documented register maps.'),
      const SizedBox(height:8),for(final d in devices)deviceCard(d),
    ]),

  );
}
