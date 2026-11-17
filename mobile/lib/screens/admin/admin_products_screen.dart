import 'package:flutter/material.dart';
import '../../data/demo_data.dart';
import '../../theme/app_theme.dart';
import '../../widgets/demo_banner.dart';
import '../../widgets/product_image.dart';
import '../../widgets/transparency_badge.dart';
import '../../widgets/verification_badge.dart';
import '../product_detail_screen.dart';

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  final _searchCtrl = TextEditingController();
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Honey',
    'Coffee',
    'Spices',
    'Tea',
    'Oils',
    'Dairy & Ghee',
    'Salt & Minerals',
  ];

  @override
  Widget build(BuildContext context) {
    var products = DemoData.getProducts();

    final query = _searchCtrl.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      products = products
          .where((p) =>
              p.name.toLowerCase().contains(query) ||
              p.brand.toLowerCase().contains(query) ||
              p.batchNumber.toLowerCase().contains(query) ||
              p.origin.toLowerCase().contains(query))
          .toList();
    }

    if (_selectedCategory != 'All') {
      products = products.where((p) => p.category == _selectedCategory).toList();
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async => setState(() {}),
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            const DemoBanner(label: 'Platform Product Directory • 12 Registered Supply Chains'),
            Text('Product Registry', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 4),
            Text(
              '${products.length} products with traceable origin certificates and transparency scores.',
              style: const TextStyle(fontSize: 13, color: AppTheme.mutedGrey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchCtrl,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: 'Search products by name, producer, origin, or batch...',
                prefixIcon: Icon(Icons.search, color: AppTheme.primaryGreen),
              ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _categories.map((c) {
                  final isSelected = _selectedCategory == c;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(c),
                      selected: isSelected,
                      onSelected: (_) => setState(() => _selectedCategory = c),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            ...products.map((product) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      ProductImage(
                        imageUrl: product.imageUrl,
                        productKey: product.batchNumber,
                        productName: product.name,
                        width: 75,
                        height: 75,
                        fit: BoxFit.cover,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    product.name,
                                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                                  ),
                                ),
                                TransparencyBadge(score: product.transparencyScore, compact: true),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${product.brand} • ${product.origin}',
                              style: const TextStyle(fontSize: 12, color: AppTheme.mutedGrey),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                VerificationBadge(status: product.status),
                                const Spacer(),
                                OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  ),
                                  onPressed: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => ProductDetailScreen(product: product),
                                    ),
                                  ),
                                  icon: const Icon(Icons.open_in_new, size: 14),
                                  label: const Text('Audit Trail', style: TextStyle(fontSize: 11)),
                                ),
                              ],
                            ),
                          ],
                        ),
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
