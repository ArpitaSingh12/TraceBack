import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/demo_banner.dart';
import '../auth/login_screen.dart';

class AdminProfileScreen extends StatelessWidget {
  final UserProfile profile;

  const AdminProfileScreen({super.key, required this.profile});

  Future<void> _logout(BuildContext context) async {
    await ApiService.clearToken();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const DemoBanner(label: 'Administrator Credentials • High Privilege Role'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 38,
                    backgroundColor: AppTheme.warmGold.withValues(alpha: 0.2),
                    child: const Icon(
                      Icons.admin_panel_settings_rounded,
                      size: 44,
                      color: AppTheme.warmGold,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(profile.name, style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 4),
                  Text(profile.email, style: const TextStyle(color: AppTheme.mutedGrey, fontSize: 13)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.forestGreen,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'LEAD VERIFIER & AUDITOR',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Verifier Privileges', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          Card(
            child: Column(
              children: const [
                ListTile(
                  leading: Icon(Icons.verified, color: AppTheme.primaryGreen),
                  title: Text('Laboratory Assay Verification'),
                  subtitle: Text('Full authority to approve or reject NABL & Agmark reports'),
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.manage_accounts, color: AppTheme.primaryGreen),
                  title: Text('Producer & User Management'),
                  subtitle: Text('Review registered farms, cooperatives, and audit trails'),
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.vpn_key_outlined, color: AppTheme.primaryGreen),
                  title: Text('Cryptographic Sealing'),
                  subtitle: Text('SHA-256 batch hash generation & QR code endorsement'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text('System Health', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.dns_outlined, color: AppTheme.forestGreen),
                  title: const Text('API Gateway'),
                  subtitle: Text(ApiService.baseUrl),
                  trailing: const Text(
                    'Operational',
                    style: TextStyle(
                      color: AppTheme.verifiedGreen,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout, color: AppTheme.rejectedRed),
                  title: const Text(
                    'Log out',
                    style: TextStyle(color: AppTheme.rejectedRed, fontWeight: FontWeight.w600),
                  ),
                  onTap: () => _logout(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
