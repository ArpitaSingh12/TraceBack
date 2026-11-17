import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../admin/admin_shell.dart';
import '../customer/customer_shell.dart';
import '../producer/producer_shell.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _busy = false;

  void _fillAccount(String email, String password) {
    setState(() {
      _emailController.text = email;
      _passwordController.text = password;
    });
  }

  void _routeByRole(UserProfile profile) {
    final role = UserRoleHelper.normalize(profile.role);
    Widget target;

    if (role == 'admin') {
      target = AdminShell(profile: profile);
    } else if (role == 'producer') {
      target = ProducerShell(profile: profile);
    } else {
      target = CustomerShell(profile: profile);
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => target),
      (_) => false,
    );
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both email and password.')),
      );
      return;
    }

    setState(() => _busy = true);

    final messenger = ScaffoldMessenger.maybeOf(context);

    final result = await ApiService.login(email, password);

    if (!mounted) return;

    if (result['status'] == 'ok') {
      final profile = await ApiService.fetchMe();
      if (!mounted) return;
      setState(() => _busy = false);

      if (profile != null) {
        _routeByRole(profile);
        return;
      }
    }

    setState(() => _busy = false);

    messenger?.showSnackBar(
      SnackBar(
        content: Text(
          result['message']?.toString() ??
              'Invalid credentials. Tap a demo account chip below to test instantly.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cream,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo & Brand Header
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.forestGreen,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.forestGreen.withValues(alpha: 0.25),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.eco_rounded,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'TraceBack',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Know the journey behind every product.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.primaryGreen,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Login Form Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Sign In',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 18),
                          TextField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: 'Email Address',
                              prefixIcon: Icon(Icons.email_outlined, color: AppTheme.primaryGreen),
                            ),
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.primaryGreen),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                  color: AppTheme.mutedGrey,
                                ),
                                onPressed: () {
                                  setState(() => _obscurePassword = !_obscurePassword);
                                },
                              ),
                            ),
                            obscureText: _obscurePassword,
                          ),
                          const SizedBox(height: 22),
                          FilledButton(
                            onPressed: _busy ? null : _login,
                            child: _busy
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Log In'),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Quick Demo Account Switcher
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.creamDark,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.borderGrey),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.touch_app, size: 16, color: AppTheme.forestGreen),
                            SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Quick Test Demo Accounts (1-Tap Fill):',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.forestGreen,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            ActionChip(
                              avatar: const Icon(Icons.person, size: 14, color: AppTheme.primaryGreen),
                              label: const Text('Customer', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                              backgroundColor: Colors.white,
                              onPressed: () => _fillAccount('customer@traceback.app', 'customer123'),
                            ),
                            ActionChip(
                              avatar: const Icon(Icons.agriculture, size: 14, color: AppTheme.primaryGreen),
                              label: const Text('Producer', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                              backgroundColor: Colors.white,
                              onPressed: () => _fillAccount('producer@traceback.app', 'producer123'),
                            ),
                            ActionChip(
                              avatar: const Icon(Icons.security, size: 14, color: AppTheme.warmGold),
                              label: const Text('Verifier / Admin', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                              backgroundColor: Colors.white,
                              onPressed: () => _fillAccount('admin@traceback.app', 'admin123'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
                    ),
                    child: const Text('New to TraceBack? Create an account'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
