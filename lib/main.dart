import 'package:flutter/material.dart';

void main() => runApp(const MunicipalOperatorApp());

class MunicipalOperatorApp extends StatelessWidget {
  const MunicipalOperatorApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Smart Valve Management - Operator',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1261A0)),
          scaffoldBackgroundColor: const Color(0xFFF6FAFE),
        ),
        home: const LoginPage(),
      );
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final password = TextEditingController();

  @override
  void dispose() {
    password.dispose();
    super.dispose();
  }

  void login() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 28),
                const Icon(Icons.water_drop, size: 78, color: Colors.blue),
                const SizedBox(height: 10),
                const Text('Smart Valve Management',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF102B72))),
                const Text('Monitor  •  Control  •  Manage',
                    style: TextStyle(fontSize: 18, color: Color(0xFF49648D))),
                const SizedBox(height: 28),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Center(child: Text('Login', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF102B72)))),
                        const SizedBox(height: 6),
                        const Center(child: Text('Agent / Operator', style: TextStyle(fontSize: 18, color: Color(0xFF49648D)))),
                        const SizedBox(height: 20),
                        const Text('Password', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF102B72))),
                        const SizedBox(height: 6),
                        TextField(
                          controller: password,
                          obscureText: true,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Enter your password',
                            prefixIcon: Icon(Icons.lock),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(onPressed: () => _forgotPassword(context), child: const Text('Forgot Password?')),
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: login,
                            child: const Padding(
                              padding: EdgeInsets.all(14),
                              child: Text('LOGIN', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        const InfoBox(icon: Icons.verified_user, text: 'Authentication will be sent to your registered mobile number.'),
                        const SizedBox(height: 8),
                        const InfoBox(icon: Icons.phone_android, text: 'If app mobile number changes / phone changes, re-authentication is required.'),
                        const SizedBox(height: 8),
                        const InfoBox(icon: Icons.info, text: 'App supports the registered phone/mobile number.'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  void _forgotPassword(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reset Password'),
        content: const Text('Enter your registered mobile number to receive an authentication code.'),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
      ),
    );
  }
}

class InfoBox extends StatelessWidget {
  final IconData icon;
  final String text;
  const InfoBox({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: const Color(0xFFE5F2FD), borderRadius: BorderRadius.circular(10)),
        child: Row(children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 15, color: Color(0xFF17336E)))),
        ]),
      );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int index = 0;
  int? zone;
  int? ward;

  void go(int i) => setState(() => index = i);

  @override
  Widget build(BuildContext context) {
    if (index == 1) return const Shell(child: GsmPage(), selected: 1);
    if (index == 2) return const Shell(child: LoraPage(), selected: 2);
    if (index == 3) return const Shell(child: MapPage(), selected: 3);

    return Scaffold(
      appBar: AppBar(title: const Text('Smart Valve Management'), actions: const [Icon(Icons.more_vert)]),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Select Zone and Ward', textAlign: TextAlign.center, style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold, color: Color(0xFF102B72))),
                const SizedBox(height: 6),
                const Text('Choose zone and ward to view valve information', textAlign: TextAlign.center, style: TextStyle(fontSize: 17, color: Color(0xFF596E94))),
                const SizedBox(height: 20),
                DropdownButtonFormField<int>(
                  value: zone,
                  decoration: const InputDecoration(labelText: 'Zone No', prefixIcon: Icon(Icons.location_on), border: OutlineInputBorder()),
                  items: [1, 2, 3, 4, 5].map((v) => DropdownMenuItem(value: v, child: Text('Zone $v'))).toList(),
                  onChanged: (v) => setState(() => zone = v),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<int>(
                  value: ward,
                  decoration: const InputDecoration(labelText: 'Ward No', prefixIcon: Icon(Icons.location_city), border: OutlineInputBorder()),
                  items: [1, 2, 3, 4, 5, 6, 7, 8].map((v) => DropdownMenuItem(value: v, child: Text('Ward $v'))).toList(),
                  onChanged: (v) => setState(() => ward = v),
                ),
                const SizedBox(height: 20),
                Row(children: [
                  Expanded(child: ViewButton(label: 'GSM / LTE\nValve View', icon: Icons.cell_tower, onTap: () => go(1))),
                  const SizedBox(width: 12),
                  Expanded(child: ViewButton(label: 'LoRa\nValve View', icon: Icons.cell_tower, onTap: () => go(2))),
                ]),
                const SizedBox(height: 12),
                ViewButton(label: 'MAP View', icon: Icons.map, onTap: () => go(3)),
                const SizedBox(height: 16),
                const InfoBox(icon: Icons.info, text: 'Select Zone and Ward to navigate to GSM, LoRa or MAP view.'),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: NavBar(index: 0, onTap: go),
    );
  }
}

class Shell extends StatelessWidget {
  final Widget child;
  final int selected;
  const Shell({super.key, required this.child, required this.selected});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: child,
        bottomNavigationBar: NavBar(index: selected, onTap: (i) {
          if (i == 0) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
          if (i == 1 && selected != 1) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const GsmPage()));
          if (i == 2 && selected != 2) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoraPage()));
          if (i == 3 && selected != 3) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MapPage()));
        }),
      );
}

class ViewButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const ViewButton({super.key, required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => FilledButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(label, textAlign: TextAlign.center),
        style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 20)),
      );
}

class NavBar extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;
  const NavBar({super.key, required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) => NavigationBar(
        selectedIndex: index,
        onDestinationSelected: onTap,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.cell_tower), label: 'GSM'),
          NavigationDestination(icon: Icon(Icons.cell_tower), label: 'LoRa'),
          NavigationDestination(icon: Icon(Icons.map), label: 'MAP'),
        ],
      );
}

class GsmPage extends StatelessWidget {
  const GsmPage({super.key});
  @override
  Widget build(BuildContext context) => const ValvePage(title: 'GSM Valve Control', type: 'GSM', valveIds: ['GSM-001', 'GSM-002']);
}

class LoraPage extends StatelessWidget {
  const LoraPage({super.key});
  @override
  Widget build(BuildContext context) => const ValvePage(title: 'LoRa Valve Control', type: 'LoRa', valveIds: ['LoRa-001', 'LoRa-002']);
}

class ValvePage extends StatefulWidget {
  final String title;
  final String type;
  final List<String> valveIds;
  const ValvePage({super.key, required this.title, required this.type, required this.valveIds});

  @override
  State<ValvePage> createState() => _ValvePageState();
}

class _ValvePageState extends State<ValvePage> {
  String? selected;
  double position = 0;
  bool bypass = true;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(widget.title), leading: const BackButton()),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(10),
          child: Column(children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selected,
                      decoration: InputDecoration(labelText: 'Valve ID (${widget.type})', border: const OutlineInputBorder()),
                      items: widget.valveIds.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                      onChanged: (v) => setState(() => selected = v),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Chip(avatar: CircleAvatar(backgroundColor: Colors.green, radius: 5), label: Text('Online')),
                ]),
              ),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(children: [
                  const ListTile(leading: Icon(Icons.water), title: Text('Valve Position', style: TextStyle(fontWeight: FontWeight.bold)), subtitle: Text('Requested / Actual')),
                  Slider(value: position, divisions: 100, label: '${position.round()}%', onChanged: (v) => setState(() => position = v)),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [for (final p in [0, 25, 50, 75, 100]) OutlinedButton(onPressed: () => setState(() => position = p.toDouble()), child: Text('$p%'))]),
                  const SizedBox(height: 8),
                  FilledButton(onPressed: () {}, child: Text('SET VALVE TO ${position.round()}%')),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(child: FilledButton(onPressed: () {}, child: const Text('OPEN'))),
                    const SizedBox(width: 5),
                    Expanded(child: FilledButton(onPressed: () {}, style: FilledButton.styleFrom(backgroundColor: Colors.red), child: const Text('CLOSE'))),
                    const SizedBox(width: 5),
                    Expanded(child: FilledButton(onPressed: () {}, child: const Text('STOP'))),
                    const SizedBox(width: 5),
                    Expanded(child: FilledButton(onPressed: () {}, style: FilledButton.styleFrom(backgroundColor: Colors.red), child: const Text('E-STOP'))),
                  ]),
                ]),
              ),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(children: [
                  const ListTile(leading: Icon(Icons.tune), title: Text('Calibration', style: TextStyle(fontWeight: FontWeight.bold))),
                  Row(children: [
                    Expanded(child: FilledButton(onPressed: () {}, child: const Text('START'))),
                    const SizedBox(width: 6),
                    Expanded(child: FilledButton(onPressed: () {}, style: FilledButton.styleFrom(backgroundColor: Colors.green), child: const Text('OPEN'))),
                    const SizedBox(width: 6),
                    Expanded(child: FilledButton(onPressed: () {}, style: FilledButton.styleFrom(backgroundColor: Colors.red), child: const Text('CLOSE'))),
                    const SizedBox(width: 6),
                    Expanded(child: FilledButton(onPressed: () {}, child: const Text('COMPLETE'))),
                  ]),
                ]),
              ),
            ),
            Card(
              child: SwitchListTile(
                title: const Text('Low Voltage Bypass'),
                subtitle: const Text('Operator acknowledgement when a low-voltage bypass request is active.'),
                value: bypass,
                onChanged: (v) => setState(() => bypass = v),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.system_update),
                title: const Text('Firmware / OTA'),
                subtitle: const Text('Firmware version and operator-authorized OTA update.'),
                trailing: FilledButton(onPressed: () {}, child: const Text('OTA')),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.person_add_alt_1),
                title: const Text('OWNER REBIND'),
                onTap: () {},
              ),
            ),
          ]),
        ),
      );
}

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final List<String> valves = ['GSM-001', 'GSM-002', 'LoRa-001'];

  void addValve() {
    final id = 'GSM-${(valves.length + 1).toString().padLeft(3, '0')}';
    setState(() => valves.add(id));
    _message('Valve Added Successfully', '$id added to the existing map.');
  }

  void removeValve(String id) {
    setState(() => valves.remove(id));
    _message('Valve Removed', id);
  }

  void _message(String title, String body) => showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(title),
          content: Text(body),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
        ),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('MAP'),
          leading: const BackButton(),
          actions: [IconButton(onPressed: addValve, icon: const Icon(Icons.add_location_alt))],
        ),
        body: Column(children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              const Expanded(child: Text('Map Name\nMunicipal Valve Map', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
              FilledButton.icon(onPressed: addValve, icon: const Icon(Icons.add), label: const Text('ADD VALVE')),
            ]),
          ),
          Container(
            height: 260,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(color: const Color(0xFFD9EBD8), borderRadius: BorderRadius.circular(12)),
            child: const Center(child: Icon(Icons.map, size: 120, color: Color(0xFF2F7D4A))),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: Align(alignment: Alignment.centerLeft, child: Text('Valve List', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF102B72)))),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: valves.length,
              itemBuilder: (context, i) {
                final id = valves[i];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: ListTile(
                    leading: Icon(id.startsWith('GSM') ? Icons.cell_tower : Icons.cell_tower, color: Colors.red),
                    title: Text('Valve ID: $id'),
                    subtitle: const Text('Latitude / Longitude available'),
                    trailing: Wrap(spacing: 4, children: [
                      IconButton(onPressed: () => _message('Rebind', 'Rebind $id to the current operator ownership.'), icon: const Icon(Icons.link)),
                      IconButton(onPressed: () => removeValve(id), icon: const Icon(Icons.delete, color: Colors.red)),
                    ]),
                  ),
                );
              },
            ),
          ),
        ]),
      );
}
