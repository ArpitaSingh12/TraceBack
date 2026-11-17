import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import 'producer_forms.dart';

class ProducerDashboardScreen extends StatefulWidget {
  final UserProfile profile;
  final Function(int) onNavigateToTab;

  const ProducerDashboardScreen({
    super.key,
    required this.profile,
    required this.onNavigateToTab,
  });

  @override
  State<ProducerDashboardScreen> createState() => _ProducerDashboardScreenState();
}

class _ProducerDashboardScreenState extends State<ProducerDashboardScreen> {
  List<Product> _products = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final products = await ApiService.fetchMyProducts();
    if (!mounted) return;
    setState(() {
      _products = products;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final products = _products;
    final batches = <dynamic>[];
    final pendingDocs = 0;
    final verifiedProducts = products.where((p) => p.isVerified).length;
    final activities = <ActivityRecord>[];

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [

          // Company Welcome Card
          Card(
            color: AppTheme.forestGreen,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.agriculture_rounded, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.profile.organization.isNotEmpty
                                  ? widget.profile.organization
                                  : widget.profile.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Logged in as ${widget.profile.name} (Producer Admin)',
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
                  const SizedBox(height: 14),
                  const Divider(color: Colors.white24),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.verified, size: 14, color: AppTheme.sageGreen),
                      const SizedBox(width: 6),
                      Text(
                        'Authenticated Producer ID: #${widget.profile.id}',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Overview Statistics Grid
          Text('Producer Performance Overview', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.45,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: [
              _buildStatCard(
                title: 'Total Products',
                value: '${products.length}',
                subtitle: 'Active in catalog',
                icon: Icons.inventory_2_outlined,
                color: AppTheme.primaryGreen,
                onTap: () => widget.onNavigateToTab(1),
              ),
              _buildStatCard(
                title: 'Active Batches',
                value: '${batches.length}',
                subtitle: 'QR tracked',
                icon: Icons.qr_code_2_rounded,
                color: AppTheme.forestGreen,
                onTap: () => widget.onNavigateToTab(2),
              ),
              _buildStatCard(
                title: 'Pending Verifications',
                value: '$pendingDocs',
                subtitle: 'In verifier queue',
                icon: Icons.pending_actions_rounded,
                color: AppTheme.warmGold,
                onTap: () => widget.onNavigateToTab(3),
              ),
              _buildStatCard(
                title: 'Verified Products',
                value: '$verifiedProducts',
                subtitle: 'High score (>=80)',
                icon: Icons.verified_rounded,
                color: AppTheme.verifiedGreen,
                onTap: () => widget.onNavigateToTab(1),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Quick Actions
          Text('Quick Management Actions', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildActionBtn(
                  context,
                  icon: Icons.add_box_outlined,
                  label: 'Add Product',
                  onTap: () => AddProductModal.show(context, () => setState(() {})),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildActionBtn(
                  context,
                  icon: Icons.qr_code_rounded,
                  label: 'New Batch',
                  onTap: () => AddBatchModal.show(context, () => setState(() {})),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildActionBtn(
                  context,
                  icon: Icons.timeline_rounded,
                  label: 'Log Milestone',
                  onTap: () => AddJourneyEventModal.show(context, () => setState(() {})),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildActionBtn(
                  context,
                  icon: Icons.upload_file_rounded,
                  label: 'Upload Doc',
                  onTap: () => UploadDocumentModal.show(context, () => setState(() {})),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Product Quality Distribution
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Transparency Score Health',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.sageLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Avg 91.5 / 100',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.forestGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _buildProgressBar('Verified Certificates', 0.94, AppTheme.forestGreen),
                  const SizedBox(height: 8),
                  _buildProgressBar('GPS Farm Coordinates', 1.0, AppTheme.primaryGreen),
                  const SizedBox(height: 8),
                  _buildProgressBar('Processing Event Logs', 0.88, AppTheme.sageGreen),
                  const SizedBox(height: 8),
                  _buildProgressBar('Third-Party Lab Assays', 0.85, AppTheme.warmGold),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Recent Activity Stream
          Text('Recent Supply-Chain Activity', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          ...activities.take(4).map(
            (act) => Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.sageLight,
                  child: Icon(
                    act.type == 'verify'
                        ? Icons.check_circle_outline
                        : act.type == 'create'
                            ? Icons.add_circle_outline
                            : Icons.update,
                    color: AppTheme.forestGreen,
                    size: 20,
                  ),
                ),
                title: Text(
                  act.title,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
                subtitle: Text(
                  act.subtitle,
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: Text(
                  act.timestamp,
                  style: const TextStyle(fontSize: 11, color: AppTheme.mutedGrey),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
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

  Widget _buildActionBtn(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        side: const BorderSide(color: AppTheme.primaryGreen),
      ),
      onPressed: onTap,
      icon: Icon(icon, size: 18, color: AppTheme.primaryGreen),
      label: Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.forestGreen)),
    );
  }

  Widget _buildProgressBar(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.charcoalLight)),
            Text('${(value * 100).toInt()}%',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value,
            backgroundColor: AppTheme.creamDark,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}
