import 'package:flutter/material.dart';
import '../data/demo_data.dart';
import '../models/models.dart';
import '../screens/product_detail_screen.dart';
import '../theme/app_theme.dart';
import 'product_image.dart';
import 'transparency_badge.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final VoidCallback? onFavoriteToggled;
  final bool horizontal;

  const ProductCard({
    super.key,
    required this.product,
    this.onFavoriteToggled,
    this.horizontal = false,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  late bool _isSaved;

  @override
  void initState() {
    super.initState();
    _isSaved = DemoData.isProductSaved(widget.product.id);
  }

  void _toggleSave() {
    setState(() {
      DemoData.toggleSavedProduct(widget.product.id);
      _isSaved = DemoData.isProductSaved(widget.product.id);
    });
    widget.onFavoriteToggled?.call();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        content: Text(
          _isSaved ? 'Saved to bookmarks' : 'Removed from bookmarks',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.horizontal) {
      return Container(
        width: 260,
        margin: const EdgeInsets.only(right: 14),
        child: _buildCardContent(context),
      );
    }

    return _buildCardContent(context);
  }

  Widget _buildCardContent(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          DemoData.recordProductView(widget.product.id);
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ProductDetailScreen(product: widget.product),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                Hero(
                  tag: 'product-img-${widget.product.id}',
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: ProductImage(
                      imageUrl: widget.product.imageUrl,
                      productKey: widget.product.batchNumber,
                      productName: widget.product.name,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Material(
                    color: Colors.white.withValues(alpha: 0.9),
                    shape: const CircleBorder(),
                    elevation: 1,
                    child: IconButton(
                      iconSize: 18,
                      constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        _isSaved ? Icons.bookmark : Icons.bookmark_border,
                        color: _isSaved ? AppTheme.primaryGreen : AppTheme.charcoal,
                      ),
                      onPressed: _toggleSave,
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.forestGreen.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      widget.product.category,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  left: 10,
                  child: TransparencyBadge(
                    score: widget.product.transparencyScore,
                    compact: true,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.charcoal,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    widget.product.brand,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.mutedGrey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: AppTheme.primaryGreen,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.product.origin,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.charcoalLight,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.creamDark,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Batch: ${widget.product.batchNumber}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10,
                        fontFamily: 'monospace',
                        color: AppTheme.mutedGrey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
