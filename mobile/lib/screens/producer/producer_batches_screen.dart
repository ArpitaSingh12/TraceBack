import 'package:flutter/material.dart';
import '../../data/demo_data.dart';
import '../../theme/app_theme.dart';
import '../../widgets/demo_banner.dart';
import '../../widgets/qr_view_modal.dart';
import '../../widgets/verification_badge.dart';
import 'producer_forms.dart';

class ProducerBatchesScreen extends StatefulWidget {
  const ProducerBatchesScreen({super.key});

  @override
  State<ProducerBatchesScreen> createState() => _ProducerBatchesScreenState();
}

class _ProducerBatchesScreenState extends State<ProducerBatchesScreen> {
  @override
  Widget build(BuildContext context) {
    final batches = DemoData.getBatches();

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.forestGreen,
        foregroundColor: Colors.white,
        onPressed: () => AddBatchModal.show(context, () => setState(() {})),
        icon: const Icon(Icons.qr_code),
        label: const Text('Create Batch'),
      ),
      body: RefreshIndicator(
        onRefresh: () async => setState(() {}),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 80),
          children: [
            const DemoBanner(label: 'Production Batches & QR Registry • 10 Active Batches'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Active Batches', style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 4),
                    Text(
                      '${batches.length} QR-coded batch records linked to supply-chain events.',
                      style: const TextStyle(fontSize: 13, color: AppTheme.mutedGrey),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...batches.map((batch) {
              final product = DemoData.getProductById(batch.productId) ??
                  DemoData.getProducts().first;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.creamDark,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              batch.batchNumber,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: AppTheme.forestGreen,
                              ),
                            ),
                          ),
                          VerificationBadge(status: batch.status),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        batch.productName,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 14, color: AppTheme.mutedGrey),
                          const SizedBox(width: 6),
                          Text(
                            'Manufactured: ${batch.createdAt}',
                            style: const TextStyle(fontSize: 12, color: AppTheme.mutedGrey),
                          ),
                          const SizedBox(width: 16),
                          const Icon(Icons.timeline, size: 14, color: AppTheme.primaryGreen),
                          const SizedBox(width: 6),
                          Text(
                            '${batch.totalEvents} Journey Milestones',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.charcoal,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const Divider(),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            onPressed: () => AddJourneyEventModal.show(
                              context,
                              () => setState(() {}),
                            ),
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('Add Milestone'),
                          ),
                          const SizedBox(width: 8),
                          FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: AppTheme.forestGreen,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            ),
                            onPressed: () => QrViewModal.show(context, product),
                            icon: const Icon(Icons.qr_code, size: 16),
                            label: const Text('View QR Code'),
                          ),
                        ],
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
