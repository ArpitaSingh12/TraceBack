import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../models/models.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/product_image.dart';
import '../../widgets/transparency_badge.dart';
import '../../widgets/verification_badge.dart';
import '../product_detail_screen.dart';
import 'producer_forms.dart';

class ProducerProductsScreen extends StatefulWidget {
  const ProducerProductsScreen({super.key});

  @override
  State<ProducerProductsScreen> createState() => _ProducerProductsScreenState();
}

class _ProducerProductsScreenState extends State<ProducerProductsScreen> {
  final _searchCtrl = TextEditingController();
  String _selectedCategory = 'All';
  List<Product> _products = [];
  bool _loading = true;
  String? _error;

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
    final products = await ApiService.fetchMyProducts();
    if (!mounted) return;
    setState(() {
      _products = products;
      _loading = false;
      if (products.isEmpty) _error = 'No managed products are available.';
    });
  }

  void _showEditProductDialog(Product product) {
    final nameCtrl = TextEditingController(text: product.name);
    final originCtrl = TextEditingController(text: product.origin);
    final statusCtrl = TextEditingController(text: product.status);
    PlatformFile? selectedImage;
    var removeImage = false;
    var busy = false;
    double? uploadProgress;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Edit ${product.name}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (selectedImage != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(
                      selectedImage!.bytes!,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  )
                else if (removeImage)
                  Container(
                    height: 150,
                    width: double.infinity,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppTheme.creamDark,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.image_not_supported_outlined, size: 36),
                  )
                else
                  ProductImage(
                    imageUrl: product.imageUrl,
                    productKey: product.batchNumber,
                    productName: product.name,
                    height: 150,
                    width: double.infinity,
                    borderRadius: BorderRadius.circular(12),
                  ),
                const SizedBox(height: 8),
                if (selectedImage != null)
                  Text(
                    selectedImage!.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: AppTheme.mutedGrey),
                  ),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: busy
                            ? null
                            : () async {
                                final result = await FilePicker.platform.pickFiles(
                                  type: FileType.custom,
                                  allowedExtensions: const ['jpg', 'jpeg', 'png', 'webp'],
                                  allowMultiple: false,
                                  withData: true,
                                );
                                if (!context.mounted || result == null || result.files.isEmpty) return;
                                final file = result.files.single;
                                if (file.size > 10 * 1024 * 1024 || file.bytes == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Choose a readable image smaller than 10 MB.')),
                                  );
                                  return;
                                }
                                setDialogState(() {
                                  selectedImage = file;
                                  removeImage = false;
                                });
                              },
                        icon: const Icon(Icons.add_photo_alternate_outlined, size: 18),
                        label: Text(selectedImage == null ? 'Replace Photo' : 'Choose Another'),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Remove product photo',
                      onPressed: busy
                          ? null
                          : () => setDialogState(() {
                                selectedImage = null;
                                removeImage = true;
                              }),
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ],
                ),
                if (uploadProgress != null) ...[
                  LinearProgressIndicator(value: uploadProgress),
                  const SizedBox(height: 4),
                  Text(
                    'Uploading photo: ${(uploadProgress! * 100).round()}%',
                    style: const TextStyle(fontSize: 12, color: AppTheme.mutedGrey),
                  ),
                ],
                const SizedBox(height: 12),
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
                const SizedBox(height: 12),
                TextField(controller: originCtrl, decoration: const InputDecoration(labelText: 'Origin')),
                const SizedBox(height: 12),
                TextField(controller: statusCtrl, decoration: const InputDecoration(labelText: 'Status')),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: busy ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: busy
                  ? null
                  : () async {
                      setDialogState(() {
                        busy = true;
                        uploadProgress = selectedImage == null ? null : 0;
                      });
                      final updated = product.copyWith(
                        name: nameCtrl.text.trim(),
                        origin: originCtrl.text.trim(),
                        status: statusCtrl.text.trim(),
                      );
                      final detailsSaved = await ApiService.updateProduct(updated);
                      if (!context.mounted) return;
                      if (!detailsSaved) {
                        setDialogState(() => busy = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Unable to update product details.')),
                        );
                        return;
                      }

                      var imageSaved = true;
                      if (selectedImage != null) {
                        imageSaved = await ApiService.uploadProductImage(
                          productId: product.id,
                          image: selectedImage!,
                          onProgress: (progress) {
                            if (context.mounted) {
                              setDialogState(() => uploadProgress = progress);
                            }
                          },
                        );
                      } else if (removeImage) {
                        imageSaved = await ApiService.deleteProductImage(product.id);
                      }
                      if (!context.mounted) return;
                      if (!imageSaved) {
                        setDialogState(() => busy = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Product details were saved, but the photo change failed. Retry the photo action.'),
                          ),
                        );
                        await _loadProducts();
                        return;
                      }

                      Navigator.pop(context);
                      await _loadProducts();
                      if (!mounted) return;
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        const SnackBar(content: Text('Product updated successfully.')),
                      );
                    },
              child: busy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null && _products.isEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!),
              const SizedBox(height: 12),
              FilledButton(onPressed: _loadProducts, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }
    var products = List<Product>.from(_products);

    final query = _searchCtrl.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      products = products
          .where((p) =>
              p.name.toLowerCase().contains(query) ||
              p.batchNumber.toLowerCase().contains(query) ||
              p.category.toLowerCase().contains(query))
          .toList();
    }

    if (_selectedCategory != 'All') {
      products = products.where((p) => p.category == _selectedCategory).toList();
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        onPressed: () => AddProductModal.show(context, _loadProducts),
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadProducts,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 80),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Managed Products', style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 4),
                    Text(
                      '${products.length} products listed under your producer account.',
                      style: const TextStyle(fontSize: 13, color: AppTheme.mutedGrey),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchCtrl,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: 'Search products by name, category, batch...',
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ProductImage(
                        imageUrl: product.imageUrl,
                        productKey: product.batchNumber,
                        productName: product.name,
                        width: 80,
                        height: 80,
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
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                TransparencyBadge(score: product.transparencyScore, compact: true),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${product.category} • Batch: ${product.batchNumber}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.mutedGrey,
                                fontFamily: 'monospace',
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                VerificationBadge(status: product.status),
                                const Spacer(),
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, size: 18),
                                  tooltip: 'Edit Product',
                                  onPressed: () => _showEditProductDialog(product),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.visibility_outlined, size: 18),
                                  tooltip: 'View Details',
                                  onPressed: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => ProductDetailScreen(product: product),
                                    ),
                                  ),
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
