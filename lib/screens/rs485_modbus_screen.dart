import 'package:flutter/material.dart';

const Color _rsPage = Color(0xFFF7F7FF);

class Rs485ModbusScreen extends StatelessWidget {
  const Rs485ModbusScreen({super.key});

  static const List<_DeviceSlot> _slots = [
    _DeviceSlot(1, 'Flow Sensor 1', Icons.water_drop_outlined),
    _DeviceSlot(2, 'Flow Sensor 2', Icons.water_drop_outlined),
    _DeviceSlot(3, 'Overflow Tank', Icons.home_outlined),
    _DeviceSlot(4, 'Water Quality Sensor', Icons.science_outlined),
    _DeviceSlot(5, 'Unassigned Device', Icons.device_hub_outlined),
    _DeviceSlot(6, 'Unassigned Device', Icons.device_hub_outlined),
    _DeviceSlot(7, 'Temperature', Icons.thermostat_outlined),
    _DeviceSlot(8, 'Custom Device', Icons.devices_other_outlined),
  ];

  void _unavailable(BuildContext context, String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$action is unavailable: no RS485 device connection/API is configured.')),
    );
  }

  Widget _contextField(String label, String value) => Expanded(
    child: InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFE5E6EA),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(7)),
      ),
      child: Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
    ),
  );

  Widget _metric(IconData icon, String label, String value, {bool divider = true}) => Column(
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Row(children: [
          Icon(icon, size: 34, color: Colors.black87),
          const SizedBox(width: 22),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 3),
            Text(value, style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w600)),
          ])),
        ]),
      ),
      if (divider) const Divider(height: 1, color: Color(0xFFCDD0D8)),
    ],
  );

  Widget _deviceCard(BuildContext context, _DeviceSlot slot) => Card(
    color: const Color(0xFFF1F1FA),
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
      side: const BorderSide(color: Color(0xFFD5D6DE)),
    ),
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 48, height: 48, alignment: Alignment.center,
            decoration: BoxDecoration(color: const Color(0xFFE1E2E9), borderRadius: BorderRadius.circular(12)),
            child: Text('${slot.number}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 14),
          Icon(slot.icon, size: 27, color: Colors.black87),
          const SizedBox(width: 12),
          Expanded(child: Text(slot.name, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w600))),
        ]),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFC7C9D2)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text('NOT CONNECTED', style: TextStyle(fontSize: 14, color: Color(0xFF626672))),
          ),
        ),
        const SizedBox(height: 10),
        Text('Slave ID: --   •   Model: --', style: TextStyle(fontSize: 15, color: Colors.grey.shade600)),
        const SizedBox(height: 16),
        Row(children: [
          const Text('VALUE', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(width: 12),
          const Expanded(child: Text('--', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600))),
          TextButton.icon(
            onPressed: () => _unavailable(context, 'Device configuration'),
            icon: const Icon(Icons.settings_outlined, size: 20),
            label: const Text('CONFIG'),
          ),
        ]),
      ]),
    ),
  );

  Widget _driverTile(BuildContext context, IconData icon, String title, String subtitle) => Card(
    color: const Color(0xFFF1F1FA),
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
      side: const BorderSide(color: Color(0xFFD5D6DE)),
    ),
    child: ListTile(
      leading: Icon(icon, size: 30),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _unavailable(context, title),
    ),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: _rsPage,
    appBar: AppBar(
      backgroundColor: const Color(0xFFE1E5EF),
      title: const Text('RS485 / MODBUS', style: TextStyle(fontSize: 25)),
    ),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        Card(
          color: const Color(0xFFF1F1FA),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(children: [
              Row(children: [
                _contextField('ZONE NO', '--'),
                const SizedBox(width: 10),
                _contextField('WARD NO', '--'),
              ]),
              const SizedBox(height: 14),
              const InputDecorator(
                decoration: InputDecoration(labelText: 'VALVE ID (MAP SAVED)', border: OutlineInputBorder()),
                child: Text('No valve selected', style: TextStyle(fontSize: 20)),
              ),
            ]),
          ),
        ),
        const SizedBox(height: 14),
        Card(
          color: const Color(0xFFF1F1FA),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('RS485 BUS STATUS', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              const Chip(
                label: Text('NOT CONNECTED'),
                side: BorderSide(color: Color(0xFFC7C9D2)),
                backgroundColor: Color(0xFFF7F7FF),
              ),
              _metric(Icons.speed, 'BAUD RATE', '9600 (configured target)'),
              _metric(Icons.hub_outlined, 'DEVICES FOUND', '-- / 8'),
              _metric(Icons.access_time, 'LAST SCAN', '--', divider: false),
            ]),
          ),
        ),
        const SizedBox(height: 14),
        Card(
          color: const Color(0xFFF1F1FA),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('DEVICE SLOTS (8)', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              const Chip(
                label: Text('Modbus RTU'),
                side: BorderSide(color: Color(0xFFC7C9D2)),
                backgroundColor: Color(0xFFF7F7FF),
              ),
              const SizedBox(height: 8),
              for (final slot in _slots) _deviceCard(context, slot),
            ]),
          ),
        ),
        const SizedBox(height: 8),
        FilledButton.icon(
          onPressed: () => _unavailable(context, 'Scan for devices'),
          icon: const Icon(Icons.search),
          label: const Text('SCAN FOR DEVICES'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => _unavailable(context, 'Add device manually'),
          icon: const Icon(Icons.add),
          label: const Text('ADD DEVICE MANUALLY'),
        ),
        const SizedBox(height: 18),
        Card(
          color: const Color(0xFFF1F1FA),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('DRIVER MANAGEMENT', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              _driverTile(context, Icons.manage_search, 'SEARCH DRIVERS', 'Open Chrome / default browser'),
              _driverTile(context, Icons.list_alt, 'CANDIDATE DRIVERS', 'Driver catalog is not connected'),
            ]),
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Hardware contract: UART2 • DE GPIO19 • TX GPIO15 • RX GPIO16 • 8 Modbus slots',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ],
    ),
  );
}

class _DeviceSlot {
  final int number;
  final String name;
  final IconData icon;
  const _DeviceSlot(this.number, this.name, this.icon);
}
