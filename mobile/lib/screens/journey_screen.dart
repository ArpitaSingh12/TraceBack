import 'package:flutter/material.dart';
import '../data/demo_data.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/demo_banner.dart';

class JourneyScreen extends StatefulWidget {
  final Product product;

  const JourneyScreen({super.key, required this.product});

  @override
  State<JourneyScreen> createState() => _JourneyScreenState();
}

class _JourneyScreenState extends State<JourneyScreen> {
  late Future<List<SupplyEvent>> _journeyFuture;

  @override
  void initState() {
    super.initState();
    _journeyFuture = ApiService.fetchJourney(1);
  }

  IconData _getEventIcon(String type) {
    final lower = type.toLowerCase();
    if (lower.contains('harvest')) return Icons.agriculture_rounded;
    if (lower.contains('process') || lower.contains('extract')) return Icons.factory_outlined;
    if (lower.contains('test') || lower.contains('analysis') || lower.contains('lab')) return Icons.science_outlined;
    if (lower.contains('pack')) return Icons.inventory_2_outlined;
    if (lower.contains('transit') || lower.contains('transport')) return Icons.local_shipping_outlined;
    return Icons.warehouse_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.product.name} Journey'),
      ),
      body: FutureBuilder<List<SupplyEvent>>(
        future: _journeyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final events = snapshot.data ?? DemoData.getJourneyEvents(1);

          return ListView(
            padding: const EdgeInsets.all(18),
            children: [
              const DemoBanner(
                label: 'Chronological Supply-Chain Audit Trail • Tamper-Resistant Chain',
              ),
              Card(
                color: AppTheme.creamDark,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.qr_code, color: AppTheme.forestGreen, size: 28),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Batch #${widget.product.batchNumber}',
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: AppTheme.forestGreen,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${events.length} chronological milestones logged across supply chain nodes.',
                              style: const TextStyle(fontSize: 12, color: AppTheme.charcoalLight),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ...events.asMap().entries.map((entry) {
                final index = entry.key;
                final event = entry.value;
                final isLast = index == events.length - 1;

                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Timeline indicator
                      Column(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: AppTheme.forestGreen,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.forestGreen.withValues(alpha: 0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              _getEventIcon(event.eventType),
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          if (!isLast)
                            Expanded(
                              child: Container(
                                width: 2,
                                color: AppTheme.sageGreen,
                                margin: const EdgeInsets.symmetric(vertical: 4),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 14),
                      // Card details
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppTheme.creamDark,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          event.eventType.toUpperCase(),
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: AppTheme.forestGreen,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          const Icon(Icons.calendar_today, size: 12, color: AppTheme.mutedGrey),
                                          const SizedBox(width: 4),
                                          Text(
                                            event.date,
                                            style: const TextStyle(fontSize: 12, color: AppTheme.mutedGrey),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    event.title,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.charcoal,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.place_outlined, size: 15, color: AppTheme.primaryGreen),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          event.location,
                                          style: const TextStyle(fontSize: 12, color: AppTheme.charcoalLight),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(Icons.business_outlined, size: 15, color: AppTheme.mutedGrey),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          event.organization,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: AppTheme.forestGreen,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    event.description,
                                    style: const TextStyle(fontSize: 13, height: 1.4, color: AppTheme.charcoal),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}
