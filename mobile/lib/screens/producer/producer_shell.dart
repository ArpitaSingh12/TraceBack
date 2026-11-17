import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/api_service.dart';
import '../../widgets/responsive_layout.dart';
import '../auth/login_screen.dart';
import 'producer_batches_screen.dart';
import 'producer_dashboard_screen.dart';
import 'producer_documents_screen.dart';
import 'producer_products_screen.dart';
import 'producer_profile_screen.dart';

class ProducerShell extends StatefulWidget {
  final UserProfile profile;

  const ProducerShell({super.key, required this.profile});

  @override
  State<ProducerShell> createState() => _ProducerShellState();
}

class _ProducerShellState extends State<ProducerShell> {
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
      ProducerDashboardScreen(
        profile: _currentProfile,
        onNavigateToTab: _onTabSelected,
      ),
      const ProducerProductsScreen(),
      const ProducerBatchesScreen(),
      const ProducerDocumentsScreen(),
      ProducerProfileScreen(profile: _currentProfile),
    ];

    final titles = [
      'Producer Portal',
      'My Products',
      'Batches & QR Codes',
      'Certificates & Documents',
      'Producer Profile',
    ];

    const navItems = [
      NavigationItem(
        icon: Icons.dashboard_outlined,
        selectedIcon: Icons.dashboard_rounded,
        label: 'Dashboard',
      ),
      NavigationItem(
        icon: Icons.inventory_2_outlined,
        selectedIcon: Icons.inventory_2_rounded,
        label: 'Products',
      ),
      NavigationItem(
        icon: Icons.qr_code_2_outlined,
        selectedIcon: Icons.qr_code_2_rounded,
        label: 'Batches',
      ),
      NavigationItem(
        icon: Icons.folder_outlined,
        selectedIcon: Icons.folder_rounded,
        label: 'Documents',
      ),
      NavigationItem(
        icon: Icons.business_outlined,
        selectedIcon: Icons.business_rounded,
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
