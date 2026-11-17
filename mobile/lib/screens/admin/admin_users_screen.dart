import 'package:flutter/material.dart';
import '../../data/demo_data.dart';
import '../../models/models.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/demo_banner.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final _searchCtrl = TextEditingController();
  String _selectedRole = 'All';
  List<UserRecord> _users = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _loading = true);
    final users = await ApiService.fetchAdminUsers();
    if (!mounted) return;
    setState(() {
      _users = users;
      _loading = false;
    });
  }

  void _showUserProfile(UserRecord user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(user.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppTheme.sageLight,
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                    style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.forestGreen),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.email, style: const TextStyle(fontSize: 13, color: AppTheme.mutedGrey)),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.forestGreen,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          UserRoleHelper.displayName(user.role).toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            _buildDetailRow('Organization', user.organization),
            const SizedBox(height: 6),
            _buildDetailRow('Account Status', user.status),
            const SizedBox(height: 6),
            _buildDetailRow('Registered On', user.createdAt),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.mutedGrey)),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var filtered = _users.isEmpty ? DemoData.users : _users;

    final query = _searchCtrl.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      filtered = filtered
          .where((u) =>
              u.name.toLowerCase().contains(query) ||
              u.email.toLowerCase().contains(query) ||
              u.organization.toLowerCase().contains(query))
          .toList();
    }

    if (_selectedRole != 'All') {
      filtered = filtered
          .where((u) => u.role.toLowerCase() == _selectedRole.toLowerCase())
          .toList();
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadUsers,
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            const DemoBanner(label: 'User Directory • Role-Based Access Control Audit'),
            Text('User Management', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 4),
            Text(
              '${filtered.length} authenticated users across Customer, Producer, and Verifier roles.',
              style: const TextStyle(fontSize: 13, color: AppTheme.mutedGrey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchCtrl,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: 'Search users by name, email, or organization...',
                prefixIcon: Icon(Icons.search, color: AppTheme.primaryGreen),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: ['All', 'customer', 'producer', 'admin'].map((r) {
                final isSelected = _selectedRole == r;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(r == 'All' ? 'All Roles' : UserRoleHelper.displayName(r)),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _selectedRole = r),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            if (_loading)
              const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
            else
              ...filtered.map((user) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: user.role == 'admin'
                          ? AppTheme.warmGold.withValues(alpha: 0.2)
                          : user.role == 'producer'
                              ? AppTheme.sageLight
                              : AppTheme.creamDark,
                      child: Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                        style: TextStyle(
                          color: user.role == 'admin'
                              ? AppTheme.warmGold
                              : user.role == 'producer'
                                  ? AppTheme.primaryGreen
                                  : AppTheme.charcoal,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    title: Text(
                      user.name,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                    subtitle: Text(
                      '${user.email} • ${user.organization}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: user.role == 'admin'
                                ? AppTheme.warmGold.withValues(alpha: 0.15)
                                : user.role == 'producer'
                                    ? AppTheme.sageLight
                                    : AppTheme.creamDark,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            user.role.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: user.role == 'admin'
                                  ? AppTheme.warmGold
                                  : user.role == 'producer'
                                      ? AppTheme.forestGreen
                                      : AppTheme.charcoalLight,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.info_outline, size: 18),
                          onPressed: () => _showUserProfile(user),
                        ),
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
