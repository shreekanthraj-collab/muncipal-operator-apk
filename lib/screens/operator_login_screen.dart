import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import '../services/municipal_auth_service.dart';

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
  final MunicipalAuthService _auth = MunicipalAuthService();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _otp = TextEditingController();
  OperatorLoginRole _role = OperatorLoginRole.agent;
  bool _busy = false;
  bool _otpRequested = false;
  int _otpExpiresIn = 300;

  @override
  void dispose() {
    _phone.dispose();
    _otp.dispose();
    _auth.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  String get _normalizedPhone => _phone.text.replaceAll(RegExp(r'\D'), '');

  Future<void> _requestOtp() async {
    if (_busy) return;
    if (_normalizedPhone.length != 10) {
      _showMessage('Enter the registered 10-digit mobile number.');
      return;
    }
    if (!_auth.isConfigured) {
      _showMessage('Municipal server is not configured. The OTP has not been sent. Configure MUNICIPAL_API_BASE_URL after server deployment.');
      return;
    }
    setState(() => _busy = true);
    try {
      final expiry = await _auth.requestOtp(_normalizedPhone);
      if (!mounted) return;
      setState(() {
        _otpRequested = true;
        _otpExpiresIn = expiry;
      });
      _showMessage('OTP request accepted by server. Check your registered mobile.');
    } catch (error) {
      _showMessage('OTP request failed: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _verifyOtp() async {
    if (_busy) return;
    if (!_otpRequested) {
      _showMessage('Request an OTP first.');
      return;
    }
    if (!RegExp(r'^\d{6}$').hasMatch(_otp.text.trim())) {
      _showMessage('Enter the 6-digit OTP.');
      return;
    }
    setState(() => _busy = true);
    try {
      final session = await _auth.verifyOtp(_normalizedPhone, _otp.text.trim());
      final sessionPhone = session.phone.replaceAll(RegExp(r'\D'), '');
      if (sessionPhone.length < 10 ||
          sessionPhone.substring(sessionPhone.length - 10) != _normalizedPhone ||
          session.organizationId.isEmpty ||
          session.accessToken.isEmpty) {
        await _auth.clearSession();
        throw const MunicipalAuthException('Server identity response did not match the registered phone or organization.');
      }
      if (!mounted) return;
      _showMessage('Authenticated as ${session.role}. Secure session saved.');
      Navigator.of(context).pushReplacementNamed('/home');
    } catch (error) {
      _showMessage('OTP verification failed: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _loginWithFingerprint() async {
    if (_busy) return;
    if (!await _auth.hasValidSession()) {
      _showMessage('Complete registered-mobile OTP login first. No valid secure session is stored.');
      return;
    }
    setState(() => _busy = true);
    try {
      final supported = await _localAuth.isDeviceSupported();
      final canCheck = await _localAuth.canCheckBiometrics;
      final biometrics = canCheck ? await _localAuth.getAvailableBiometrics() : <BiometricType>[];
      if (!supported || biometrics.isEmpty) {
        _showMessage('No enrolled fingerprint or supported biometric is available.');
        return;
      }
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Verify your identity to unlock your municipal operator session',
        options: const AuthenticationOptions(biometricOnly: true, stickyAuth: true),
      );
      if (!authenticated) {
        _showMessage('Fingerprint verification was cancelled or not successful.');
        return;
      }
      if (!await _auth.hasValidSession()) {
        await _auth.clearSession();
        _showMessage('Your municipal session has expired. Sign in again using OTP.');
        return;
      }
      if (!mounted) return;
      _showMessage('Fingerprint verified. Secure session unlocked.');
      Navigator.of(context).pushReplacementNamed('/home');
    } catch (error) {
      _showMessage('Biometric authentication unavailable: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: _loginPage,
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 34, 22, 28),
        child: Column(children: [
          const Icon(Icons.water_drop, color: Colors.lightBlue, size: 92),
          const SizedBox(height: 22),
          const Text('Smart Valve\nManagement', textAlign: TextAlign.center,
            style: TextStyle(fontSize: 38, height: 1.16, fontWeight: FontWeight.w500, color: Color(0xFF171923))),
          const SizedBox(height: 10),
          const Text('Monitor  •  Control  •  Manage', textAlign: TextAlign.center, style: TextStyle(fontSize: 19, color: Color(0xFF171923))),
          const SizedBox(height: 48),
          Card(
            color: const Color(0xFFF1F1FA),
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 28, 18, 24),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                const Text('Login', textAlign: TextAlign.center, style: TextStyle(fontSize: 42, fontWeight: FontWeight.w500)),
                const SizedBox(height: 18),
                const Text('Select your role to continue', textAlign: TextAlign.center, style: TextStyle(fontSize: 20)),
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
                  onChanged: (_) { if (_otpRequested) setState(() => _otpRequested = false); },
                  decoration: const InputDecoration(
                    counterText: '', prefixIcon: Icon(Icons.phone_android),
                    hintText: 'Registered mobile number', border: OutlineInputBorder(),
                    filled: true, fillColor: _loginPage,
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  height: 58,
                  child: FilledButton.icon(
                    onPressed: _busy ? null : _requestOtp,
                    icon: _busy ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.sms),
                    label: const Text('REQUEST OTP', style: TextStyle(fontSize: 18)),
                    style: FilledButton.styleFrom(backgroundColor: _loginBlue, shape: const StadiumBorder()),
                  ),
                ),
                if (_otpRequested) ...[
                  const SizedBox(height: 16),
                  TextField(
                    controller: _otp, keyboardType: TextInputType.number, maxLength: 6,
                    decoration: InputDecoration(
                      counterText: '', prefixIcon: const Icon(Icons.lock_outline),
                      hintText: 'Enter 6-digit OTP', helperText: 'OTP expires in $_otpExpiresIn seconds',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(height: 54, child: FilledButton(
                    onPressed: _busy ? null : _verifyOtp,
                    child: const Text('VERIFY OTP', style: TextStyle(fontSize: 17)),
                  )),
                ],
                const SizedBox(height: 18),
                SizedBox(
                  height: 92,
                  child: OutlinedButton.icon(
                    onPressed: _busy ? null : _loginWithFingerprint,
                    icon: const Icon(Icons.fingerprint, size: 27),
                    label: const Text('LOGIN WITH\nFINGERPRINT', textAlign: TextAlign.left, style: TextStyle(fontSize: 18, height: 1.35)),
                    style: OutlinedButton.styleFrom(foregroundColor: _loginBlue, side: const BorderSide(color: Colors.black54), shape: const StadiumBorder()),
                  ),
                ),
                const SizedBox(height: 18),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Icon(Icons.phone_android, color: Color(0xFF424956)),
                    SizedBox(width: 14),
                    Expanded(child: Text(
                      'Phone / mobile change\nRe-authentication is required if the app mobile number or phone changes.',
                      style: TextStyle(fontSize: 18, height: 1.45),
                    )),
                  ]),
                ),
              ]),
            ),
          ),
        ]),
      ),
    ),
  );
}
