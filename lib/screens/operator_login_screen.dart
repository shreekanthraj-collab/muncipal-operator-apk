import 'package:flutter/material.dart';

const Color _loginBlue = Color(0xFF2B6F9F);
const Color _loginPage = Color(0xFFF7F7FF);

enum OperatorLoginRole { admin, agent }

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  OperatorLoginRole _role = OperatorLoginRole.agent;
  final TextEditingController _phone = TextEditingController();

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  void _showPending(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature is not connected yet. No login request was sent.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _loginPage,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 34, 22, 28),
          child: Column(
            children: [
              const Icon(Icons.water_drop, color: Colors.lightBlue, size: 92),
              const SizedBox(height: 22),
              const Text(
                'Smart Valve\nManagement',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 38, height: 1.16, fontWeight: FontWeight.w500, color: Color(0xFF171923)),
              ),
              const SizedBox(height: 10),
              const Text('Monitor  •  Control  •  Manage', textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 19, color: Color(0xFF171923))),
              const SizedBox(height: 48),
              Card(
                color: const Color(0xFFF1F1FA),
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 28, 18, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('Login', textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 42, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 18),
                      const Text('Select your role to continue', textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 20)),
                      const SizedBox(height: 28),
                      SegmentedButton<OperatorLoginRole>(
                        segments: const [
                          ButtonSegment(value: OperatorLoginRole.admin, label: Text('Admin'), icon: Icon(Icons.admin_panel_settings)),
                          ButtonSegment(value: OperatorLoginRole.agent, label: Text('Agent / Operator'), icon: Icon(Icons.check)),
                        ],
                        selected: {_role},
                        onSelectionChanged: (value) => setState(() => _role = value.first),
                        showSelectedIcon: false,
                        style: SegmentedButton.styleFrom(
                          foregroundColor: const Color(0xFF252936),
                          selectedForegroundColor: const Color(0xFF252936),
                          selectedBackgroundColor: const Color(0xFFD6E7FA),
                          side: const BorderSide(color: Colors.black54),
                          textStyle: const TextStyle(fontSize: 17),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 13),
                        ),
                      ),
                      const SizedBox(height: 28),
                      TextField(
                        controller: _phone,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        decoration: const InputDecoration(
                          counterText: '',
                          prefixIcon: Icon(Icons.phone_android),
                          hintText: 'Registered mobile number',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: _loginPage,
                        ),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        height: 58,
                        child: FilledButton.icon(
                          onPressed: () => _showPending('OTP authentication'),
                          icon: const Icon(Icons.sms),
                          label: const Text('REQUEST OTP', style: TextStyle(fontSize: 18)),
                          style: FilledButton.styleFrom(
                            backgroundColor: _loginBlue,
                            shape: const StadiumBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        height: 92,
                        child: OutlinedButton.icon(
                          onPressed: () => _showPending('Fingerprint authentication'),
                          icon: const Icon(Icons.fingerprint, size: 27),
                          label: const Text('LOGIN WITH\nFINGERPRINT', textAlign: TextAlign.left,
                              style: TextStyle(fontSize: 18, height: 1.35)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _loginBlue,
                            side: const BorderSide(color: Colors.black54),
                            shape: const StadiumBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 18),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.phone_android, color: Color(0xFF424956)),
                            SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                'Phone / mobile change\nRe-authentication is required if the app mobile number or phone changes.',
                                style: TextStyle(fontSize: 18, height: 1.45),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
