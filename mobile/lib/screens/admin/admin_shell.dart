import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/api_service.dart';
import '../../widgets/responsive_layout.dart';
import '../auth/login_screen.dart';
import 'admin_dashboard_screen.dart';
import 'admin_products_screen.dart';
import 'admin_profile_screen.dart';
import 'admin_users_screen.dart';
import 'admin_verification_screen.dart';

class AdminShell extends StatefulWidget {
  final UserProfile profile;

  const AdminShell({super.key, required this.profile});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _currentIndex = 0;
  late UserProfile _currentProfile;

  @override
  void initState() {
    super.initState();
    _currentProfile = widget.profile;
  }

  void _onTabSelected(int index) {
    setState(() => _currentIndex = index);
  }

  Future<void> _logout() async {
    await ApiService.clearToken();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      AdminDashboardScreen(
        profile: _currentProfile,
        onNavigateToTab: _onTabSelected,
      ),
      const AdminUsersScreen(),
      const AdminProductsScreen(),
      const AdminVerificationScreen(),
      AdminProfileScreen(profile: _currentProfile),
    ];

    final titles = [
      'Verifier Hub',
      'User Management',
      'Product Directory',
      'Verification Queue',
      'Admin Profile',
    ];

    const navItems = [
      NavigationItem(
        icon: Icons.dashboard_outlined,
        selectedIcon: Icons.dashboard_rounded,
        label: 'Dashboard',
      ),
      NavigationItem(
        icon: Icons.people_outline,
        selectedIcon: Icons.people_rounded,
        label: 'Users',
      ),
      NavigationItem(
        icon: Icons.inventory_2_outlined,
        selectedIcon: Icons.inventory_2_rounded,
        label: 'Products',
      ),
      NavigationItem(
        icon: Icons.fact_check_outlined,
        selectedIcon: Icons.fact_check_rounded,
        label: 'Verification',
      ),
      NavigationItem(
        icon: Icons.shield_outlined,
        selectedIcon: Icons.shield_rounded,
        label: 'Profile',
      ),
    ];

    return ResponsiveLayoutShell(
      selectedIndex: _currentIndex,
      onDestinationSelected: _onTabSelected,
      items: navItems,
      body: screens[_currentIndex],
      title: titles[_currentIndex],
      profile: _currentProfile,
      onLogout: _logout,
    );
  }
}
