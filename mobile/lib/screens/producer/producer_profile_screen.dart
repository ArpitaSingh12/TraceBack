import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/demo_banner.dart';
import '../../widgets/verification_badge.dart';
import '../auth/login_screen.dart';

class ProducerProfileScreen extends StatefulWidget {
  final UserProfile profile;

  const ProducerProfileScreen({super.key, required this.profile});

  @override
  State<ProducerProfileScreen> createState() => _ProducerProfileScreenState();
}

class _ProducerProfileScreenState extends State<ProducerProfileScreen> {
  late String _companyName;
  late String _contactPerson;
  late String _email;
  late String _location;
  late String _description;

  @override
  void initState() {
    super.initState();
    _companyName = 'Aster Flow Organics';
    _contactPerson = widget.profile.name;
    _email = widget.profile.email;
    _location = 'Nilgiris & Kashmir Valley, India';
    _description =
        'Leading sustainable producer of pesticide-free wildflower and acacia honey. Certified by India Organic and Fair Trade Guild.';
  }

  void _showEditProfileDialog() {
    final companyCtrl = TextEditingController(text: _companyName);
    final contactCtrl = TextEditingController(text: _contactPerson);
    final locationCtrl = TextEditingController(text: _location);
    final descCtrl = TextEditingController(text: _description);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Producer Profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const DemoBanner(label: 'Updates saved for current demo session'),
              TextField(controller: companyCtrl, decoration: const InputDecoration(labelText: 'Company / Cooperative Name')),
              const SizedBox(height: 12),
              TextField(controller: contactCtrl, decoration: const InputDecoration(labelText: 'Contact Person')),
              const SizedBox(height: 12),
              TextField(controller: locationCtrl, decoration: const InputDecoration(labelText: 'Location / State')),
              const SizedBox(height: 12),
              TextField(controller: descCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Company Description')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              setState(() {
                _companyName = companyCtrl.text.trim();
                _contactPerson = contactCtrl.text.trim();
                _location = locationCtrl.text.trim();
                _description = descCtrl.text.trim();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Producer profile updated successfully.')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
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
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const DemoBanner(label: 'Producer Profile • Verified Agriculture Enterprise'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 38,
                    backgroundColor: AppTheme.sageLight,
                    child: const Icon(
                      Icons.agriculture_rounded,
                      size: 44,
                      color: AppTheme.forestGreen,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(_companyName, style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 4),
                  Text(_location, style: const TextStyle(color: AppTheme.mutedGrey, fontSize: 13)),
                  const SizedBox(height: 10),
                  const VerificationBadge(status: 'verified'),
                  const SizedBox(height: 14),
                  Text(
                    _description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13, color: AppTheme.charcoalLight, height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: _showEditProfileDialog,
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('Edit Enterprise Profile'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Enterprise Information', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person_outline, color: AppTheme.primaryGreen),
                  title: const Text('Primary Contact Person'),
                  subtitle: Text(_contactPerson),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.email_outlined, color: AppTheme.primaryGreen),
                  title: const Text('Enterprise Email'),
                  subtitle: Text(_email),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.category_outlined, color: AppTheme.primaryGreen),
                  title: const Text('Product Categories'),
                  subtitle: const Text('Wildflower Honey, Acacia Honey, Alpine Botanicals'),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.verified_outlined, color: AppTheme.primaryGreen),
                  title: const Text('Certification Registry'),
                  subtitle: const Text('NPOP India Organic (#ADITI-2024-ORG), Fairtrade Guild'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text('Account & Security', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          Card(
            child: ListTile(
              leading: const Icon(Icons.logout, color: AppTheme.rejectedRed),
              title: const Text(
                'Log out',
                style: TextStyle(color: AppTheme.rejectedRed, fontWeight: FontWeight.w600),
              ),
              onTap: _logout,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
