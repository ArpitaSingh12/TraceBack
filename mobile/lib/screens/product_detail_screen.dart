import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/demo_data.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/demo_banner.dart';
import '../widgets/product_card.dart';
import '../widgets/product_image.dart';
import '../widgets/qr_view_modal.dart';
import '../widgets/transparency_badge.dart';
import '../widgets/verification_badge.dart';
import 'journey_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late bool _isSaved;
  late Future<List<DocumentItem>> _documentsFuture;
  late Future<List<SupplyEvent>> _journeyFuture;

  @override
  void initState() {
    super.initState();
    _isSaved = DemoData.isProductSaved(widget.product.id);
    _documentsFuture = ApiService.fetchDocuments(widget.product.id);
    _journeyFuture = ApiService.fetchJourney(1);
  }

  void _toggleSaved() {
    setState(() {
      DemoData.toggleSavedProduct(widget.product.id);
      _isSaved = DemoData.isProductSaved(widget.product.id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 1),
        content: Text(_isSaved ? 'Saved to bookmarks' : 'Removed from bookmarks'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final relatedProducts = DemoData.getProducts()
        .where((p) => p.id != widget.product.id && p.category == widget.product.category)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name),
        actions: [
          IconButton(
            icon: Icon(
              _isSaved ? Icons.bookmark : Icons.bookmark_border,
              color: Colors.white,
            ),
            tooltip: 'Bookmark product',
            onPressed: _toggleSaved,
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_2_rounded, color: Colors.white),
            tooltip: 'View QR',
            onPressed: () => QrViewModal.show(context, widget.product),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Image
            Stack(
              children: [
                Hero(
                  tag: 'product-img-${widget.product.id}',
                  child: ProductImage(
                    imageUrl: widget.product.imageUrl,
                    productKey: widget.product.batchNumber,
                    productName: widget.product.name,
                    height: 260,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: TransparencyBadge(score: widget.product.transparencyScore),
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppTheme.forestGreen.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.product.category.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const DemoBanner(label: 'Verified Product Dossier • TraceBack Blockchain Manifest'),

                  // Title & Brand
                  Text(
                    widget.product.name,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.agriculture, size: 16, color: AppTheme.primaryGreen),
                      const SizedBox(width: 6),
                      Text(
                        widget.product.brand,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.charcoal,
                        ),
                      ),
                      const SizedBox(width: 10),
                      VerificationBadge(status: widget.product.status),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Origin & Batch Quick Card
                  Card(
                    color: AppTheme.creamDark,
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined, size: 18, color: AppTheme.primaryGreen),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Origin: ${widget.product.origin}',
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          const Divider(height: 1),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.qr_code, size: 18, color: AppTheme.forestGreen),
                                  const SizedBox(width: 8),
                                  Text(
                                    widget.product.batchNumber,
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              InkWell(
                                onTap: () {
                                  Clipboard.setData(ClipboardData(text: widget.product.batchNumber));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Batch code copied to clipboard')),
                                  );
                                },
                                child: const Row(
                                  children: [
                                    Text('Copy', style: TextStyle(fontSize: 12, color: AppTheme.primaryGreen, fontWeight: FontWeight.w600)),
                                    SizedBox(width: 4),
                                    Icon(Icons.copy, size: 13, color: AppTheme.primaryGreen),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          const Divider(height: 1),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Mfg: ${widget.product.manufacturingDate}', style: const TextStyle(fontSize: 12, color: AppTheme.mutedGrey)),
                              Text('Exp: ${widget.product.expiryDate}', style: const TextStyle(fontSize: 12, color: AppTheme.mutedGrey)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Transparency Score Deep Dive Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Transparency Index', style: Theme.of(context).textTheme.titleLarge),
                                  const SizedBox(height: 2),
                                  const Text('Documentation Completeness Metric', style: TextStyle(fontSize: 12, color: AppTheme.mutedGrey)),
                                ],
                              ),
                              TransparencyBadge(score: widget.product.transparencyScore),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildScoreBar('Geographic Farm Origin (GPS)', 20, 20),
                          const SizedBox(height: 8),
                          _buildScoreBar('Producer Credentials & Registration', 15, 15),
                          const SizedBox(height: 8),
                          _buildScoreBar('Processing & Extraction Timestamps', 20, 20),
                          const SizedBox(height: 8),
                          _buildScoreBar('Induction Packaging & Laser Batch Coding', 15, 15),
                          const SizedBox(height: 8),
                          _buildScoreBar('Supporting Assays & Lab Reports', 20, 20),
                          const SizedBox(height: 8),
                          _buildScoreBar('Third-Party Verifier Endorsement', widget.product.transparencyScore >= 90 ? 10 : 5, 10),
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.creamDark,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'NOTE: The transparency score represents documentation completeness and audit availability, not an unconditional chemical guarantee of food safety or authenticity.',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppTheme.charcoalLight,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Data Provenance Distinction
                  Card(
                    color: AppTheme.sageLight.withValues(alpha: 0.6),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: const [
                          Icon(Icons.gavel_rounded, color: AppTheme.forestGreen, size: 24),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Dual-Tier Audit Model',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    color: AppTheme.forestGreen,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Farm harvests are logged by the producer; laboratory purity tests & GI tags are independently vetted by accredited verifiers.',
                                  style: TextStyle(fontSize: 11, color: AppTheme.charcoal, height: 1.3),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Description
                  Text('Product Narrative', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(
                    widget.product.description,
                    style: const TextStyle(fontSize: 14, height: 1.5, color: AppTheme.charcoal),
                  ),

                  if (widget.product.ingredients.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text('Verified Ingredients', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.product.ingredients.map((ing) {
                        return Chip(
                          label: Text(ing),
                          backgroundColor: AppTheme.creamDark,
                        );
                      }).toList(),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Supply Chain Preview
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Supply-Chain Journey', style: Theme.of(context).textTheme.titleLarge),
                      TextButton.icon(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => JourneyScreen(product: widget.product),
                          ),
                        ),
                        icon: const Icon(Icons.arrow_forward, size: 16),
                        label: const Text('View All Events'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  FutureBuilder<List<SupplyEvent>>(
                    future: _journeyFuture,
                    builder: (context, snapshot) {
                      final events = snapshot.data ?? DemoData.getJourneyEvents(1);
                      return Column(
                        children: events.take(3).map((event) {
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppTheme.sageLight,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.timeline, color: AppTheme.forestGreen, size: 20),
                              ),
                              title: Text(event.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                              subtitle: Text('${event.location} • ${event.date}', style: const TextStyle(fontSize: 12)),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Certificates & Supporting Documents
                  Text('Certificates & Lab Assays', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 10),
                  FutureBuilder<List<DocumentItem>>(
                    future: _documentsFuture,
                    builder: (context, snapshot) {
                      final docs = snapshot.data ?? DemoData.getDocumentsForProduct(widget.product.id);
                      if (docs.isEmpty) {
                        return const Card(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Text('No supporting certificates uploaded for this item yet.'),
                          ),
                        );
                      }
                      return Column(
                        children: docs.map((doc) {
                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          doc.documentType,
                                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                                        ),
                                      ),
                                      VerificationBadge(status: doc.status),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(doc.name, style: const TextStyle(fontFamily: 'monospace', fontSize: 12, color: AppTheme.mutedGrey)),
                                  const SizedBox(height: 4),
                                  Text(doc.notes, style: const TextStyle(fontSize: 12, color: AppTheme.charcoalLight)),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Related Products
                  if (relatedProducts.isNotEmpty) ...[
                    Text('Related ${widget.product.category} Products', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 280,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: relatedProducts.length,
                        itemBuilder: (context, index) {
                          return ProductCard(
                            product: relatedProducts[index],
                            horizontal: true,
                            onFavoriteToggled: () => setState(() {}),
                          );
                        },
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.forestGreen,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () => QrViewModal.show(context, widget.product),
                      icon: const Icon(Icons.qr_code_2_rounded),
                      label: const Text('View Batch QR Code & Provenance'),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreBar(String label, int earned, int max) {
    final pct = earned / max;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.charcoal)),
            Text('$earned / $max', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct,
            backgroundColor: AppTheme.creamDark,
            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
            minHeight: 5,
          ),
        ),
      ],
    );
  }
}
