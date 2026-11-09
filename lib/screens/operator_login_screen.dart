import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

const Color _loginBlue = Color(0xFF2B6F9F);
const Color _loginPage = Color(0xFFF7F7FF);

enum OperatorLoginRole { admin, agent }

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final LocalAuthentication _localAuth = LocalAuthentication();
  OperatorLoginRole _role = OperatorLoginRole.agent;
  final TextEditingController _phone = TextEditingController();
  bool _biometricBusy = false;

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _loginWithFingerprint() async {
    if (_biometricBusy) return;
    setState(() => _biometricBusy = true);
    try {
      final supported = await _localAuth.isDeviceSupported();
      if (!supported) {
        _showMessage('This device does not support biometric authentication.');
        return;
      }

      final canCheck = await _localAuth.canCheckBiometrics;
      final biometrics = canCheck
          ? await _localAuth.getAvailableBiometrics()
          : <BiometricType>[];
      if (biometrics.isEmpty) {
        _showMessage('No enrolled fingerprint or biometric is available. Set it up in Android Settings first.');
        return;
      }

      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Verify your identity to access the Municipal Operator app',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (!authenticated) {
        _showMessage('Fingerprint verification was cancelled or not successful.');
        return;
      }

      // Biometric verification alone must not create a server session.
      // A verified OTP session and secure token enrollment are required first.
      _showMessage('Fingerprint verified. First complete registered-mobile OTP login to enable secure session unlock.');
    } catch (error) {
      _showMessage('Biometric authentication unavailable: $error');
    } finally {
      if (mounted) setState(() => _biometricBusy = false);
    }
  }

  void _showOtpPending() {
    _showMessage('OTP login is waiting for the municipal server and SMS service to be available.');
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
                          onPressed: _showOtpPending,
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
                          onPressed: _biometricBusy ? null : _loginWithFingerprint,
                          icon: _biometricBusy
                              ? const SizedBox(
                                  width: 25,
                                  height: 25,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.fingerprint, size: 27),
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
