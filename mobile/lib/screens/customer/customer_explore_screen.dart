import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../services/api_service.dart';
import '../../widgets/product_card.dart';

class CustomerExploreScreen extends StatefulWidget {
  const CustomerExploreScreen({super.key});

  @override
  State<CustomerExploreScreen> createState() => _CustomerExploreScreenState();
}

class _CustomerExploreScreenState extends State<CustomerExploreScreen> {
  final _searchController = TextEditingController();
  List<Product> _products = [];
  bool _loading = true;
  String? _error;
  String _selectedCategory = 'All';
  String _sortBy = 'Score (Highest)';
  int _minScore = 0;

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
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final products = await ApiService.fetchProducts();
    if (!mounted) return;
    setState(() {
      _products = products;
      _loading = false;
      if (products.isEmpty) _error = 'No products are available or the server could not be reached.';
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null && _products.isEmpty) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off_outlined, size: 48),
                const SizedBox(height: 12),
                Text(_error!, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                FilledButton(onPressed: _loadProducts, child: const Text('Retry')),
              ],
            ),
          ),
        ),
      );
    }
    var products = List<Product>.from(_products);

    // Filter by search query
    final query = _searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      products = products.where((p) {
        return p.name.toLowerCase().contains(query) ||
            p.brand.toLowerCase().contains(query) ||
            p.origin.toLowerCase().contains(query) ||
            p.batchNumber.toLowerCase().contains(query) ||
            p.category.toLowerCase().contains(query);
      }).toList();
    }

    // Filter by category
    if (_selectedCategory != 'All') {
      products = products.where((p) => p.category == _selectedCategory).toList();
    }

    // Filter by min score
    if (_minScore > 0) {
      products = products.where((p) => p.transparencyScore >= _minScore).toList();
    }

    // Sorting
    if (_sortBy == 'Score (Highest)') {
      products.sort((a, b) => b.transparencyScore.compareTo(a.transparencyScore));
    } else if (_sortBy == 'Score (Lowest)') {
      products.sort((a, b) => a.transparencyScore.compareTo(b.transparencyScore));
    } else if (_sortBy == 'Name A-Z') {
      products.sort((a, b) => a.name.compareTo(b.name));
    }

    final isDesktop = AppTheme.isDesktop(context);
    final isTablet = AppTheme.isTablet(context);

    int crossAxisCount = 1;
    if (isDesktop) {
      crossAxisCount = 3;
    } else if (isTablet) {
      crossAxisCount = 2;
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadProducts,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Explore Products',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Filter by category, transparency rating, and traceable origin.',
                      style: TextStyle(fontSize: 13, color: AppTheme.mutedGrey),
                    ),
                    const SizedBox(height: 16),

                    // Search Bar
                    TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Search 12 products, origins, or batches...',
                        prefixIcon: const Icon(Icons.search, color: AppTheme.primaryGreen),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {});
                                },
                              )
                            : null,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Category Filter Chips
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
                              onSelected: (_) {
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

                    const SizedBox(height: 12),

                    // Controls Row (Sort + Min Score Filter)
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _sortBy,
                            decoration: const InputDecoration(
                              labelText: 'Sort by',
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'Score (Highest)',
                                child: Text('Score (Highest)'),
                              ),
                              DropdownMenuItem(
                                value: 'Score (Lowest)',
                                child: Text('Score (Lowest)'),
                              ),
                              DropdownMenuItem(
                                value: 'Name A-Z',
                                child: Text('Name A-Z'),
                              ),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _sortBy = val);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        ActionChip(
                          avatar: Icon(
                            Icons.tune,
                            size: 16,
                            color: _minScore > 0 ? Colors.white : AppTheme.charcoal,
                          ),
                          label: Text(_minScore > 0 ? 'Score >= $_minScore' : 'Filter Score'),
                          backgroundColor: _minScore > 0 ? AppTheme.forestGreen : AppTheme.creamDark,
                          labelStyle: TextStyle(
                            color: _minScore > 0 ? Colors.white : AppTheme.charcoal,
                            fontWeight: FontWeight.w600,
                          ),
                          onPressed: () {
                            _showScoreFilterDialog();
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Result Count Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Showing ${products.length} products',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.mutedGrey,
                          ),
                        ),
                        if (_selectedCategory != 'All' || _searchController.text.isNotEmpty || _minScore > 0)
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _selectedCategory = 'All';
                                _searchController.clear();
                                _minScore = 0;
                              });
                            },
                            child: const Text('Reset filters'),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            if (products.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.search_off_rounded,
                          size: 64,
                          color: AppTheme.subtleGrey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No matching products found',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Try adjusting your search criteria or resetting filters.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppTheme.mutedGrey),
                        ),
                        const SizedBox(height: 20),
                        FilledButton(
                          onPressed: () {
                            setState(() {
                              _selectedCategory = 'All';
                              _searchController.clear();
                              _minScore = 0;
                            });
                          },
                          child: const Text('Reset All Filters'),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else if (crossAxisCount == 1)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: ProductCard(
                          product: products[index],
                          onFavoriteToggled: () => setState(() {}),
                        ),
                      );
                    },
                    childCount: products.length,
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return ProductCard(
                        product: products[index],
                        onFavoriteToggled: () => setState(() {}),
                      );
                    },
                    childCount: products.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showScoreFilterDialog() {
    int tempScore = _minScore;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Minimum Transparency Score'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    tempScore == 0 ? 'Any score' : '$tempScore / 100 or higher',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  Slider(
                    value: tempScore.toDouble(),
                    min: 0,
                    max: 95,
                    divisions: 19,
                    label: tempScore == 0 ? 'Any' : '$tempScore',
                    onChanged: (val) {
                      setDialogState(() {
                        tempScore = val.round();
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() => _minScore = 0);
                    Navigator.pop(context);
                  },
                  child: const Text('Clear'),
                ),
                FilledButton(
                  onPressed: () {
                    setState(() => _minScore = tempScore);
                    Navigator.pop(context);
                  },
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
