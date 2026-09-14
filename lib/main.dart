import 'package:flutter/material.dart';

void main() {
  runApp(const MunicipalOperatorApp());
}

class MunicipalOperatorApp extends StatelessWidget {
  const MunicipalOperatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final password = TextEditingController();
  bool admin = false;

  @override
  void dispose() {
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 28),
              const Icon(Icons.water_drop, size: 78, color: Colors.blue),
              const SizedBox(height: 10),
              const Text('Smart Valve Management', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF102B72))),
              const Text('Monitor  •  Control  •  Manage', style: TextStyle(fontSize: 18, color: Color(0xFF49648D))),
              const SizedBox(height: 28),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Center(child: Text('Login', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF102B72)))),
                    const SizedBox(height: 6),
                    const Center(child: Text('Select your role to continue', style: TextStyle(fontSize: 18, color: Color(0xFF49648D)))),
                    const SizedBox(height: 20),
                    SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment(value: false, label: Text('Agent / Operator'), icon: Icon(Icons.groups)),
                        ButtonSegment(value: true, label: Text('Admin'), icon: Icon(Icons.admin_panel_settings)),
                      ],
                      selected: {admin},
                      onSelectionChanged: (s) => setState(() => admin = s.first),
                    ),
                    const SizedBox(height: 18),
                    const Text('Password', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF102B72))),
                    const SizedBox(height: 6),
                    TextField(controller: password, obscureText: true, decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Enter your password', prefixIcon: Icon(Icons.lock))),
                    const SizedBox(height: 14),
                    SizedBox(width: double.infinity, child: FilledButton(onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage())), child: const Padding(padding: EdgeInsets.all(14), child: Text('LOGIN', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))))),
                    const SizedBox(height: 14),
                    const InfoBox(icon: Icons.verified_user, text: 'Authentication will be sent to your registered mobile number.'),
                    const SizedBox(height: 8),
                    const InfoBox(icon: Icons.phone_android, text: 'If app mobile number changes / phone changes, re-authentication is required.'),
                  ]),
                ),
              ),
            ],
          ),
        ),
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
    child: Row(children: [Icon(icon, color: Colors.blue), const SizedBox(width: 12), Expanded(child: Text(text, style: const TextStyle(fontSize: 15, color: Color(0xFF17336E))))]),
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

  final pages = const [GsmPage(), LoraPage(), MapPage(), Rs485Page()];

  void go(int i) => setState(() => index = i);

  @override
  Widget build(BuildContext context) {
    if (index > 0) {
      return Scaffold(
        body: pages[index - 1],
        bottomNavigationBar: NavBar(index: index, onTap: go),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Smart Valve Management'), actions: const [Icon(Icons.more_vert)]),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              const Text('Select Zone and Ward', textAlign: TextAlign.center, style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold, color: Color(0xFF102B72))),
              const SizedBox(height: 6),
              const Text('Choose zone and ward to view valve information', textAlign: TextAlign.center, style: TextStyle(fontSize: 17, color: Color(0xFF596E94))),
              const SizedBox(height: 20),
              DropdownButtonFormField<int>(value: zone, decoration: const InputDecoration(labelText: 'Zone No', prefixIcon: Icon(Icons.location_on), border: OutlineInputBorder()), items: [1,2,3,4,5].map((v) => DropdownMenuItem(value: v, child: Text('Zone $v'))).toList(), onChanged: (v) => setState(() => zone = v)),
              const SizedBox(height: 14),
              DropdownButtonFormField<int>(value: ward, decoration: const InputDecoration(labelText: 'Ward No', prefixIcon: Icon(Icons.location_city), border: OutlineInputBorder()), items: [1,2,3,4,5,6,7,8].map((v) => DropdownMenuItem(value: v, child: Text('Ward $v'))).toList(), onChanged: (v) => setState(() => ward = v)),
              const SizedBox(height: 20),
              Row(children: [Expanded(child: ViewButton(label: 'GSM / LTE\nValve View', icon: Icons.cell_tower, onTap: () => go(1))), const SizedBox(width: 12), Expanded(child: ViewButton(label: 'LoRa\nValve View', icon: Icons.cell_tower, onTap: () => go(2)))]),
              const SizedBox(height: 12),
              Row(children: [Expanded(child: ViewButton(label: 'MAP View', icon: Icons.map, onTap: () => go(3))), const SizedBox(width: 12), Expanded(child: ViewButton(label: 'RS485 View', icon: Icons.account_tree, onTap: () => go(4)))]),
              const SizedBox(height: 16),
              const InfoBox(icon: Icons.info, text: 'Select Zone and Ward to navigate to GSM, LoRa, MAP or RS485 view.'),
            ]),
          ),
        ),
      ),
      bottomNavigationBar: NavBar(index: 0, onTap: go),
    );
  }
}

class ViewButton extends StatelessWidget {
  final String label; final IconData icon; final VoidCallback onTap;
  const ViewButton({super.key, required this.label, required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) => FilledButton.icon(onPressed: onTap, icon: Icon(icon), label: Text(label, textAlign: TextAlign.center), style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 20)));
}

class NavBar extends StatelessWidget {
  final int index; final ValueChanged<int> onTap;
  const NavBar({super.key, required this.index, required this.onTap});
  @override
  Widget build(BuildContext context) => NavigationBar(selectedIndex: index, onDestinationSelected: onTap, destinations: const [
    NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
    NavigationDestination(icon: Icon(Icons.cell_tower), label: 'GSM'),
    NavigationDestination(icon: Icon(Icons.cell_tower), label: 'LoRa'),
    NavigationDestination(icon: Icon(Icons.map), label: 'MAP'),
    NavigationDestination(icon: Icon(Icons.account_tree), label: 'RS485'),
  ]);
}

class GsmPage extends StatelessWidget {
  const GsmPage({super.key});
  @override
  Widget build(BuildContext context) => ValvePage(title: 'GSM Valve Control', type: 'GSM', valveIds: const ['GSM-001','GSM-002']);
}
class LoraPage extends StatelessWidget {
  const LoraPage({super.key});
  @override
  Widget build(BuildContext context) => ValvePage(title: 'LoRa Valve Control', type: 'LoRa', valveIds: const ['LoRa-001','LoRa-002']);
}

class ValvePage extends StatefulWidget {
  final String title, type; final List<String> valveIds;
  const ValvePage({super.key, required this.title, required this.type, required this.valveIds});
  @override State<ValvePage> createState() => _ValvePageState();
}
class _ValvePageState extends State<ValvePage> {
  String? selected;
  double position = 0;
  bool bypass = true;
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text(widget.title), leading: const BackButton()), body: SingleChildScrollView(padding: const EdgeInsets.all(10), child: Column(children: [
    Card(child: Padding(padding: const EdgeInsets.all(10), child: Row(children: [Expanded(child: DropdownButtonFormField<String>(value: selected, decoration: const InputDecoration(labelText: 'Valve ID', border: OutlineInputBorder()), items: widget.valveIds.map((v)=>DropdownMenuItem(value:v, child: Text(v))).toList(), onChanged:(v)=>setState(()=>selected=v))), const SizedBox(width:8), const Chip(avatar: CircleAvatar(backgroundColor: Colors.green, radius:5), label: Text('Online'))])),
    Card(child: Column(children: [const ListTile(leading: Icon(Icons.water), title: Text('Valve Position', style: TextStyle(fontWeight: FontWeight.bold)), subtitle: Text('Requested / Actual')), Slider(value: position, divisions: 100, label: '${position.round()}%', onChanged:(v)=>setState(()=>position=v)), Padding(padding: const EdgeInsets.all(8), child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [for (final p in [0,25,50,75,100]) OutlinedButton(onPressed:()=>setState(()=>position=p.toDouble()), child: Text('$p%'))])), FilledButton(onPressed:()=>setState(()=>position=position), child: Text('SET VALVE TO ${position.round()}%')), const SizedBox(height:8), Row(children: [Expanded(child: FilledButton(onPressed:(){}, child:const Text('OPEN'))), const SizedBox(width:5), Expanded(child: FilledButton(onPressed:(){}, style:FilledButton.styleFrom(backgroundColor:Colors.red), child:const Text('CLOSE'))), const SizedBox(width:5), Expanded(child: FilledButton(onPressed:(){}, child:const Text('STOP'))), const SizedBox(width:5), Expanded(child: FilledButton(onPressed:(){}, style:FilledButton.styleFrom(backgroundColor:Colors.red), child:const Text('E-STOP')))]), const SizedBox(height:10)])),
    Card(child: SwitchListTile(title: const Text('Sleep Bypass'), value:bypass, onChanged:(v)=>setState(()=>bypass=v))),
    Card(child: ListTile(leading: const Icon(Icons.schedule), title: const Text('Scheduling / Clock'), subtitle: const Text('View Schedule   •   Start   •   Set Schedule   •   Cancel All   •   Clock View'))),
  ]));
}

class MapPage extends StatelessWidget {
  const MapPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('MAP'), leading: const BackButton()), body: Column(children: [
    const Padding(padding: EdgeInsets.all(12), child: Row(children: [Expanded(child: Text('Map Name\nMunicipal Valve Map', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))), Icon(Icons.gps_fixed)])),
    Expanded(child: Container(margin: const EdgeInsets.symmetric(horizontal:12), decoration: BoxDecoration(color: const Color(0xFFD9EBD8), borderRadius: BorderRadius.circular(12)), child: const Center(child: Icon(Icons.map, size:120, color: Color(0xFF2F7D4A))))),
    const Padding(padding: EdgeInsets.fromLTRB(12,12,12,4), child: Align(alignment:Alignment.centerLeft, child:Text('Valve List', style:TextStyle(fontSize:20,fontWeight:FontWeight.bold,color:Color(0xFF102B72))))),
    Expanded(child: ListView.builder(itemCount:6, itemBuilder:(context,i)=>Card(margin:const EdgeInsets.symmetric(horizontal:12,vertical:4), child: ListTile(leading:const Icon(Icons.water,color:Colors.red), title:Text(i%2==0?'GSM-${i+1}':'LoRa-${i+1}'), subtitle:const Text('Latitude / Longitude available'), trailing:const Icon(Icons.chevron_right))))),
  ]));
}

class Rs485Page extends StatelessWidget {
  const Rs485Page({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('RS485 / MODBUS'), leading: const BackButton()), body: SingleChildScrollView(padding:const EdgeInsets.all(12), child: Column(children:[
    DropdownButtonFormField<String>(decoration:const InputDecoration(labelText:'Valve ID (GSM + LoRa)',border:OutlineInputBorder()), items:const ['GSM-001','GSM-002','LoRa-001','LoRa-002'].map((v)=>DropdownMenuItem(value:v,child:Text(v))).toList(), onChanged:(_){ }),
    const SizedBox(height:12),
    const Card(child: Column(children:[ListTile(leading:Icon(Icons.sensors),title:Text('Sensor Readings',style:TextStyle(fontWeight:FontWeight.bold))), ListTile(title:Text('Flow Sensor 1'),trailing:Text('12.5 FL/sec')), ListTile(title:Text('Flow Sensor 2'),trailing:Text('10.8 FL/sec')), ListTile(title:Text('Overflow Tank'),trailing:Text('EMPTY')), ListTile(title:Text('Water Quality Sensor'),trailing:Text('78%'))])),
    const Card(child: ListTile(leading:Icon(Icons.download),title:Text('Device Drivers'),subtitle:Text('Operator access is limited; admin driver-management remains separate.'))),
  ]));
}
