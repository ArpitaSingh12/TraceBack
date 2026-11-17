import 'package:flutter/material.dart';
import '../../data/demo_data.dart';
import '../../models/models.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/demo_banner.dart';
import '../auth/login_screen.dart';

class CustomerProfileScreen extends StatefulWidget {
  final UserProfile profile;
  final ValueChanged<UserProfile>? onProfileUpdated;

  const CustomerProfileScreen({
    super.key,
    required this.profile,
    this.onProfileUpdated,
  });

  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  late UserProfile _currentProfile;
  bool _pushNotifications = true;
  bool _batchAlerts = true;
  bool _verificationUpdates = true;

  @override
  void initState() {
    super.initState();
    _currentProfile = widget.profile;
  }

  void _showEditProfileDialog() {
    final nameCtrl = TextEditingController(text: _currentProfile.name);
    final phoneCtrl = TextEditingController(text: _currentProfile.phone);
    final locationCtrl = TextEditingController(text: _currentProfile.location);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Profile'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const DemoBanner(label: 'Profile changes are saved to local session state.'),
                const SizedBox(height: 8),
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Full Name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneCtrl,
                  decoration: const InputDecoration(labelText: 'Phone Number'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: locationCtrl,
                  decoration: const InputDecoration(labelText: 'City / Region'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final updated = _currentProfile.copyWith(
                  name: nameCtrl.text.trim(),
                  phone: phoneCtrl.text.trim(),
                  location: locationCtrl.text.trim(),
                );
                setState(() => _currentProfile = updated);
                widget.onProfileUpdated?.call(updated);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile updated successfully (local session).')),
                );
              },
              child: const Text('Save Changes'),
            ),
          ],
        );
      },
    );
  }

  void _showChangePasswordDialog() {
    final currentPass = TextEditingController();
    final newPass = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Change Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentPass,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Current Password'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: newPass,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'New Password'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password updated successfully for demo session.'),
                  ),
                );
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log out'),
        content: const Text('Are you sure you want to end your current session?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ApiService.clearToken();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final savedCount = DemoData.getSavedProducts().length;
    final recentCount = DemoData.getRecentProducts().length;

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const DemoBanner(label: 'Customer Account • Authenticated via /auth/me'),

          // Profile Header Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 38,
                    backgroundColor: AppTheme.sageGreen,
                    child: Text(
                      _currentProfile.name.isNotEmpty
                          ? _currentProfile.name[0].toUpperCase()
                          : 'C',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.forestGreen,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    _currentProfile.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _currentProfile.email,
                    style: const TextStyle(color: AppTheme.mutedGrey, fontSize: 13),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.forestGreen,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'CUSTOMER MEMBER',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMetricItem('$savedCount', 'Saved Items'),
                      Container(height: 30, width: 1, color: AppTheme.borderGrey),
                      _buildMetricItem('$recentCount', 'Recent Views'),
                      Container(height: 30, width: 1, color: AppTheme.borderGrey),
                      _buildMetricItem(_currentProfile.memberSince, 'Member Since'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Personal Information Section
          Text('Personal Information', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.badge_outlined, color: AppTheme.primaryGreen),
                  title: const Text('Full Name'),
                  subtitle: Text(_currentProfile.name),
                  trailing: TextButton(
                    onPressed: _showEditProfileDialog,
                    child: const Text('Edit'),
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.email_outlined, color: AppTheme.primaryGreen),
                  title: const Text('Email Address'),
                  subtitle: Text(_currentProfile.email),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.phone_outlined, color: AppTheme.primaryGreen),
                  title: const Text('Phone Number'),
                  subtitle: Text(_currentProfile.phone),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.place_outlined, color: AppTheme.primaryGreen),
                  title: const Text('Location'),
                  subtitle: Text(_currentProfile.location),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Notification Preferences
          Text('Notification Preferences', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  activeColor: AppTheme.primaryGreen,
                  title: const Text('Push Notifications'),
                  subtitle: const Text('Receive notifications for new batch releases.'),
                  value: _pushNotifications,
                  onChanged: (val) => setState(() => _pushNotifications = val),
                ),
                const Divider(),
                SwitchListTile(
                  activeColor: AppTheme.primaryGreen,
                  title: const Text('Batch Traceability Updates'),
                  subtitle: const Text('Alerts when saved products update journey milestones.'),
                  value: _batchAlerts,
                  onChanged: (val) => setState(() => _batchAlerts = val),
                ),
                const Divider(),
                SwitchListTile(
                  activeColor: AppTheme.primaryGreen,
                  title: const Text('Verification Alerts'),
                  subtitle: const Text('Notices when lab certificates or GI tags are approved.'),
                  value: _verificationUpdates,
                  onChanged: (val) => setState(() => _verificationUpdates = val),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Security & Account Actions
          Text('Security & Account', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.lock_outline, color: AppTheme.primaryGreen),
                  title: const Text('Change Password'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  onTap: _showChangePasswordDialog,
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout, color: AppTheme.rejectedRed),
                  title: const Text(
                    'Log out',
                    style: TextStyle(color: AppTheme.rejectedRed, fontWeight: FontWeight.w600),
                  ),
                  onTap: _logout,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String val, String label) {
    return Column(
      children: [
        Text(
          val,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppTheme.forestGreen,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppTheme.mutedGrey),
        ),
      ],
    );
  }
}
