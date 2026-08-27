import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import 'worker_home_screen.dart';
import 'admin_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController(text: 'asha_anita');
  final _passwordController = TextEditingController(text: 'AshaPass2026!');
  bool _isLoading = false;
  bool _useOtp = false;
  late AuthService _authService;

  @override
  void initState() {
    super.initState();
    _authService = AuthService(api: ApiService());
  }

  void _handleLogin() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600));

    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    final success = await _authService.login(username, password);
    setState(() => _isLoading = false);

    if (success && mounted) {
      if (username == 'admin') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const WorkerHomeScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              // Brand Header
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppConstants.colorPrimary.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.water_drop_rounded,
                        size: 44,
                        color: AppConstants.colorPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      AppConstants.appName,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Frontline Health Worker Portal (ASHA / ANM)',
                      style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 36),

              // Offline Ready Banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFA7F3D0)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.offline_bolt_rounded, color: Color(0xFF059669), size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Offline Enabled: Works seamlessly without internet',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF065F46)),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Username / Worker ID Input
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Worker ID / Username',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                  helperText: 'Default: asha_anita (or "admin")',
                ),
              ),

              const SizedBox(height: 16),

              // Password / OTP Input
              TextField(
                controller: _passwordController,
                obscureText: !_useOtp,
                decoration: InputDecoration(
                  labelText: _useOtp ? '6-Digit OTP' : 'Password',
                  prefixIcon: Icon(_useOtp ? Icons.sms_outlined : Icons.lock_outline_rounded),
                  suffixIcon: TextButton(
                    onPressed: () => setState(() => _useOtp = !_useOtp),
                    child: Text(_useOtp ? 'Use Password' : 'Use OTP'),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Login Button
              ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                      )
                    : const Text('Login to RaktDrishti'),
              ),

              const SizedBox(height: 24),

              // Quick Preset Chips for Demo
              const Center(
                child: Text(
                  'Quick Hackathon Demo Profiles:',
                  style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ActionChip(
                    label: const Text('ASHA Worker (Anita)'),
                    avatar: const Icon(Icons.medical_services_outlined, size: 16),
                    onPressed: () {
                      setState(() {
                        _usernameController.text = 'asha_anita';
                        _passwordController.text = 'AshaPass2026!';
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  ActionChip(
                    label: const Text('Admin / MO'),
                    avatar: const Icon(Icons.admin_panel_settings_outlined, size: 16),
                    onPressed: () {
                      setState(() {
                        _usernameController.text = 'admin';
                        _passwordController.text = 'AdminPass2026!';
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
