import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/api_service.dart';
import '../../widgets/responsive_layout.dart';
import '../auth/login_screen.dart';
import '../scanner_screen.dart';
import 'customer_dashboard_screen.dart';
import 'customer_explore_screen.dart';
import 'customer_profile_screen.dart';
import 'customer_saved_screen.dart';

class CustomerShell extends StatefulWidget {
  final UserProfile profile;

  const CustomerShell({super.key, required this.profile});

  @override
  State<CustomerShell> createState() => _CustomerShellState();
}

class _CustomerShellState extends State<CustomerShell> {
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
      CustomerDashboardScreen(
        profile: _currentProfile,
        onNavigateToTab: _onTabSelected,
      ),
      const CustomerExploreScreen(),
      const ScannerScreen(),
      CustomerSavedScreen(
        onExploreTapped: () => _onTabSelected(1),
      ),
      CustomerProfileScreen(
        profile: _currentProfile,
        onProfileUpdated: (updated) => setState(() => _currentProfile = updated),
      ),
    ];

    final titles = [
      'TraceBack Discover',
      'Explore Products',
      'Batch QR Scanner',
      'Saved Items',
      'Customer Profile',
    ];

    const navItems = [
      NavigationItem(
        icon: Icons.home_outlined,
        selectedIcon: Icons.home_rounded,
        label: 'Home',
      ),
      NavigationItem(
        icon: Icons.explore_outlined,
        selectedIcon: Icons.explore_rounded,
        label: 'Explore',
      ),
      NavigationItem(
        icon: Icons.qr_code_scanner_outlined,
        selectedIcon: Icons.qr_code_scanner_rounded,
        label: 'Scan QR',
      ),
      NavigationItem(
        icon: Icons.bookmark_border_rounded,
        selectedIcon: Icons.bookmark_rounded,
        label: 'Saved',
      ),
      NavigationItem(
        icon: Icons.person_outline_rounded,
        selectedIcon: Icons.person_rounded,
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
