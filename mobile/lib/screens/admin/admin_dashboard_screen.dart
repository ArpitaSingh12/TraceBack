import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

class AdminDashboardScreen extends StatefulWidget {
  final UserProfile profile;
  final Function(int) onNavigateToTab;

  const AdminDashboardScreen({
    super.key,
    required this.profile,
    required this.onNavigateToTab,
  });

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  Map<String, dynamic> _stats = {};
  List<ActivityRecord> _activities = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final stats = await ApiService.fetchAdminStats();
    final activities = await ApiService.fetchAuditLogs();
    if (!mounted) return;
    setState(() {
      _stats = stats;
      _activities = activities;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final users = (_stats['total_users'] ?? 0) as int;
    final producers = (_stats['producers'] ?? 0) as int;
    final products = (_stats['products'] ?? 0) as int;
    final batches = (_stats['batches'] ?? 0) as int;
    final documents = (_stats['documents'] ?? 0) as int;
    final pendingCount = (_stats['pending_documents'] ?? 0) as int;
    final verifiedDocCount = (_stats['verified_documents'] ?? 0) as int;
    final rejectedDocCount = (_stats['rejected_documents'] ?? 0) as int;

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [

          // Admin Header Banner
          Card(
            color: AppTheme.forestGreen,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.warmGold.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.security_rounded, color: AppTheme.warmGold, size: 30),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'TraceBack Compliance & Audit Hub',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 17,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Lead Verifier: ${widget.profile.name} • Active Session',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Overview Statistics Grid (6 Metrics)
          Text('Platform Audit Overview', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.4,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: [
              _buildMetricCard(
                title: 'Total Users',
                value: '$users',
                subtitle: 'Active across roles',
                icon: Icons.people_outline,
                color: AppTheme.charcoal,
                onTap: () => widget.onNavigateToTab(1),
              ),
              _buildMetricCard(
                title: 'Producers',
                value: '$producers',
                subtitle: 'Registered farms',
                icon: Icons.agriculture_outlined,
                color: AppTheme.primaryGreen,
                onTap: () => widget.onNavigateToTab(1),
              ),
              _buildMetricCard(
                title: 'Active SKUs',
                value: '$products',
                subtitle: 'Food & agricultural',
                icon: Icons.inventory_2_outlined,
                color: AppTheme.forestGreen,
                onTap: () => widget.onNavigateToTab(2),
              ),
              _buildMetricCard(
                title: 'Trace Batches',
                value: '$batches',
                subtitle: 'Laser QR tagged',
                icon: Icons.qr_code_2_rounded,
                color: AppTheme.charcoalLight,
                onTap: () => widget.onNavigateToTab(2),
              ),
              _buildMetricCard(
                title: 'Pending Verifications',
                value: '$pendingCount',
                subtitle: 'Requires audit review',
                icon: Icons.pending_actions_rounded,
                color: AppTheme.warmGold,
                highlight: true,
                onTap: () => widget.onNavigateToTab(3),
              ),
              _buildMetricCard(
                title: 'Verified Documents',
                value: '$verifiedDocCount',
                subtitle: 'Cleared compliance',
                icon: Icons.verified_user_rounded,
                color: AppTheme.verifiedGreen,
                onTap: () => widget.onNavigateToTab(3),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Verification Status Distribution Visualization
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Document Verification Distribution',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        '$documents Total Assays',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.mutedGrey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildStatusRow(
                    label: 'Verified & Accepted',
                    count: verifiedDocCount,
                    total: documents,
                    color: AppTheme.verifiedGreen,
                  ),
                  const SizedBox(height: 10),
                  _buildStatusRow(
                    label: 'Pending Review',
                    count: pendingCount,
                    total: documents,
                    color: AppTheme.warmGold,
                  ),
                  const SizedBox(height: 10),
                  _buildStatusRow(
                    label: 'Rejected / Incomplete',
                    count: rejectedDocCount,
                    total: documents,
                    color: AppTheme.rejectedRed,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Product Category Distribution Visualization
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Product Category Distribution',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 14),
                  _buildCategoryBar('Spices (Turmeric, Pepper, Saffron, Cinnamon)', 4, 12, AppTheme.forestGreen),
                  const SizedBox(height: 8),
                  _buildCategoryBar('Honey (Wildflower, Acacia)', 2, 12, AppTheme.warmGold),
                  const SizedBox(height: 8),
                  _buildCategoryBar('Coffee (Arabica, Robusta)', 2, 12, AppTheme.primaryGreen),
                  const SizedBox(height: 8),
                  _buildCategoryBar('Tea (Darjeeling First Flush)', 1, 12, AppTheme.sageGreen),
                  const SizedBox(height: 8),
                  _buildCategoryBar('Oils, Dairy & Minerals', 3, 12, AppTheme.charcoalLight),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Recent Audit Logs / System Activity
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Live Platform Audit Log', style: Theme.of(context).textTheme.titleLarge),
              TextButton(
                onPressed: () => widget.onNavigateToTab(3),
                child: const Text('Review Queue'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._activities.map(
            (act) => Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: act.type == 'verify'
                      ? AppTheme.sageLight
                      : AppTheme.creamDark,
                  child: Icon(
                    act.type == 'verify' ? Icons.verified : Icons.history_rounded,
                    color: act.type == 'verify' ? AppTheme.forestGreen : AppTheme.charcoal,
                    size: 20,
                  ),
                ),
                title: Text(act.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                subtitle: Text(act.subtitle, style: const TextStyle(fontSize: 12)),
                trailing: Text(act.timestamp, style: const TextStyle(fontSize: 11, color: AppTheme.mutedGrey)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool highlight = false,
  }) {
    return Card(
      color: highlight ? AppTheme.warmGoldLight : Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.mutedGrey,
                    ),
                  ),
                  Icon(icon, size: 18, color: color),
                ],
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 11, color: AppTheme.charcoalLight),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusRow({
    required String label,
    required int count,
    required int total,
    required Color color,
  }) {
    final pct = total > 0 ? (count / total) : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
            Text(
              '$count (${(pct * 100).toInt()}%)',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct,
            backgroundColor: AppTheme.creamDark,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryBar(String label, int count, int total, Color color) {
    final pct = total > 0 ? (count / total) : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 12, color: AppTheme.charcoalLight),
              ),
            ),
            Text(
              '$count items',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct,
            backgroundColor: AppTheme.creamDark,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}
