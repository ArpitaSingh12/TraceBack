import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/product_card.dart';
import '../scanner_screen.dart';

class CustomerDashboardScreen extends StatefulWidget {
  final UserProfile profile;
  final Function(int) onNavigateToTab;

  const CustomerDashboardScreen({
    super.key,
    required this.profile,
    required this.onNavigateToTab,
  });

  @override
  State<CustomerDashboardScreen> createState() => _CustomerDashboardScreenState();
}

class _CustomerDashboardScreenState extends State<CustomerDashboardScreen> {
  String _selectedCategory = 'All';
  final _searchController = TextEditingController();
  List<Product> _products = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final products = await ApiService.fetchProducts();
    if (!mounted) return;
    setState(() {
      _products = products;
      _loading = false;
    });
  }

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

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final products = _products;
    final filtered = _selectedCategory == 'All'
        ? products
        : products.where((p) => p.category == _selectedCategory).toList();

    final recentProducts = <Product>[];

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        children: [

          // Personalized Header Greeting
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_getGreeting()}, ${widget.profile.name.split(' ').first}',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Explore verified origins and farm-to-table traceability.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.mutedGrey,
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () => widget.onNavigateToTab(4), // Profile tab
                borderRadius: BorderRadius.circular(24),
                child: CircleAvatar(
                  radius: 22,
                  backgroundColor: AppTheme.primaryGreen,
                  child: Text(
                    widget.profile.name.isNotEmpty
                        ? widget.profile.name[0].toUpperCase()
                        : 'C',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Search Bar
          TextField(
            controller: _searchController,
            onSubmitted: (_) => widget.onNavigateToTab(1), // Explore tab
            decoration: InputDecoration(
              hintText: 'Search products, spices, origins, or batches...',
              prefixIcon: const Icon(Icons.search, color: AppTheme.primaryGreen),
              suffixIcon: IconButton(
                icon: const Icon(Icons.tune, color: AppTheme.mutedGrey),
                onPressed: () => widget.onNavigateToTab(1),
              ),
            ),
          ),

          const SizedBox(height: 18),

          // QR Scanner Hero Card
          InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ScannerScreen()),
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.forestGreen, AppTheme.primaryGreen],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.forestGreen.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.qr_code_scanner_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Scan Product QR Code',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Instant audit trail, harvest location & purity certificates.',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // How TraceBack Works Explainer Card
          Card(
            color: AppTheme.creamDark,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.verified_user_outlined, size: 20, color: AppTheme.forestGreen),
                      const SizedBox(width: 8),
                      Text(
                        'How TraceBack Works',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Every product has an unalterable digital footprint. From harvest coordinates to processing logs and independent lab verification certificates, our transparency score reflects documented integrity.',
                    style: TextStyle(fontSize: 12, color: AppTheme.charcoalLight, height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStepPill('1. Scan QR', Icons.qr_code),
                      const Icon(Icons.arrow_right_alt, color: AppTheme.mutedGrey),
                      _buildStepPill('2. Verify Farm', Icons.place_outlined),
                      const Icon(Icons.arrow_right_alt, color: AppTheme.mutedGrey),
                      _buildStepPill('3. Check Labs', Icons.science_outlined),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Categories Filter
          Text(
            'Explore Categories',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = cat;
                      });
                    },
                    selectedColor: AppTheme.primaryGreen,
                    checkmarkColor: Colors.white,
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 24),

          // Featured Products Carousel / Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Featured Products',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              TextButton(
                onPressed: () => widget.onNavigateToTab(1),
                child: const Text('See All (12)'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 280,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                return ProductCard(
                  product: filtered[index],
                  horizontal: true,
                  onFavoriteToggled: () => setState(() {}),
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          const SizedBox(height: 24),

          // Recently Viewed Section
          if (recentProducts.isNotEmpty) ...[
            Text(
              'Recently Viewed',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            ...recentProducts.map(
              (p) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ProductCard(
                  product: p,
                  onFavoriteToggled: () => setState(() {}),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStepPill(String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.borderGrey),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppTheme.primaryGreen),
          const SizedBox(width: 4),
          Text(
            title,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
