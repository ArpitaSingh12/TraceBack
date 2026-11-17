import 'package:flutter/material.dart';
import '../../data/demo_data.dart';
import '../../theme/app_theme.dart';
import '../../widgets/demo_banner.dart';
import '../../widgets/product_card.dart';

class CustomerSavedScreen extends StatefulWidget {
  final VoidCallback onExploreTapped;

  const CustomerSavedScreen({super.key, required this.onExploreTapped});

  @override
  State<CustomerSavedScreen> createState() => _CustomerSavedScreenState();
}

class _CustomerSavedScreenState extends State<CustomerSavedScreen> {
  @override
  Widget build(BuildContext context) {
    final savedProducts = DemoData.getSavedProducts();

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            const DemoBanner(label: 'Saved Bookmarks • Stored for quick batch access'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Saved Products',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${savedProducts.length} items bookmarked for quick review.',
                      style: const TextStyle(fontSize: 13, color: AppTheme.mutedGrey),
                    ),
                  ],
                ),
                if (savedProducts.isNotEmpty)
                  const Icon(Icons.bookmark_added_rounded, color: AppTheme.primaryGreen, size: 28),
              ],
            ),
            const SizedBox(height: 16),
            if (savedProducts.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.bookmark_border_rounded,
                      size: 64,
                      color: AppTheme.subtleGrey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No saved products yet',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Bookmark organic honey, coffees, and spices while browsing to track updates or review farm documentation.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.mutedGrey),
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: widget.onExploreTapped,
                      icon: const Icon(Icons.search),
                      label: const Text('Explore Catalog'),
                    ),
                  ],
                ),
              )
            else
              ...savedProducts.map(
                (product) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: ProductCard(
                    product: product,
                    onFavoriteToggled: () => setState(() {}),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
