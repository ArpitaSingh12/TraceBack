import 'package:flutter/material.dart';

import 'models/models.dart';
import 'screens/admin/admin_shell.dart';
import 'screens/auth/login_screen.dart';
import 'screens/customer/customer_shell.dart';
import 'screens/producer/producer_shell.dart';
import 'services/api_service.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TraceBackApp());
}

class TraceBackApp extends StatelessWidget {
  const TraceBackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TraceBack',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final token = await ApiService.readToken();
    if (!mounted) return;

    final navigator = Navigator.of(context);

    if (token == null || token.isEmpty) {
      setState(() => _loading = false);
      navigator.pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }

    final profile = await ApiService.fetchMe();
    if (!mounted) return;

    if (profile == null) {
      await ApiService.clearToken();
      setState(() => _loading = false);
      navigator.pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }

    setState(() => _loading = false);

    // Route dynamically based on actual authenticated role
    final role = UserRoleHelper.normalize(profile.role);
    Widget target;

    if (role == 'admin') {
      target = AdminShell(profile: profile);
    } else if (role == 'producer') {
      target = ProducerShell(profile: profile);
    } else {
      target = CustomerShell(profile: profile);
    }

    navigator.pushReplacement(
      MaterialPageRoute(builder: (_) => target),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cream,
      body: Center(
        child: _loading
            ? const CircularProgressIndicator(color: AppTheme.primaryGreen)
            : const SizedBox.shrink(),
      ),
    );
  }
}
