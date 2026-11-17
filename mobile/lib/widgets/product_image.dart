import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class ProductImage extends StatelessWidget {
  static const Map<String, String> _assetsByProductKey = {
    'FBH-2024-089-A': 'assets/images/wildflower_honey.jpg',
    'CO-ARB-2024-041': 'assets/images/coorg_arabica_coffee.jpg',
    'HTP-8823-C': 'assets/images/himalayan_turmeric.jpg',
    'WBP-TGSEB-2024-19': 'assets/images/wayanad_black_pepper.jpg',
    'DJ-FF-2024-EX01': 'assets/images/darjeeling_tea.jpg',
    'KSH-MGR-2024-07': 'assets/images/kashmiri_saffron.jpg',
    'GVO-GN-2024-118': 'assets/images/groundnut_oil.jpg',
    'AFO-ACA-2024-03': 'assets/images/acacia_honey.jpg',
    'CMP-ROB-2024-52': 'assets/images/robusta_coffee.jpg',
    'WGN-CIN-2024-78': 'assets/images/ceylon_cinnamon.jpg',
    'GVC-GHEE-2024-209': 'assets/images/desi_ghee.jpg',
    'HHF-SALT-2024-601': 'assets/images/himalayan_pink_salt.jpg',
    'HNY-WLD-001': 'assets/images/wildflower_honey.jpg',
    'CAF-ARB-002': 'assets/images/coorg_arabica_coffee.jpg',
    'TEA-GRN-003': 'assets/images/darjeeling_tea.jpg',
    'SPC-TUR-004': 'assets/images/himalayan_turmeric.jpg',
    'SPC-CIN-005': 'assets/images/ceylon_cinnamon.jpg',
    'SPC-CAR-006': 'assets/images/cardamom_pods.jpg',
    'SPC-PEP-007': 'assets/images/wayanad_black_pepper.jpg',
    'RIC-PON-008': 'assets/images/basmati_rice.jpg',
    'FRU-MNG-009': 'assets/images/alphonso_mango.jpg',
    'FRU-ORG-010': 'assets/images/nagpur_oranges.jpg',
    'ORG-GHE-011': 'assets/images/desi_ghee.jpg',
    'RIC-BAS-012': 'assets/images/basmati_rice.jpg',
    'SPC-SAF-013': 'assets/images/kashmiri_saffron.jpg',
    'ORG-CAS-014': 'assets/images/cashew_nuts.jpg',
  };

  static String? assetForProduct({
    required String productKey,
    required String productName,
  }) {
    final fromKey = _assetsByProductKey[productKey.trim().toUpperCase()];
    if (fromKey != null) return fromKey;
    if (productName.trim().toLowerCase() == 'watermelon' ||
        productName.trim().toLowerCase() == 'watermelon fruit') {
      return 'assets/images/watermelon.jpg';
    }
    return null;
  }

  static String resolveSource({
    required String imageUrl,
    required String productKey,
    required String productName,
  }) {
    if (imageUrl.startsWith('/uploads/products/')) return imageUrl;
    final mappedAsset = assetForProduct(
      productKey: productKey,
      productName: productName,
    );
    if (mappedAsset != null) return mappedAsset;
    if (imageUrl.startsWith('assets/')) return imageUrl;
    return '';
  }

  final String imageUrl;
  final String productKey;
  final String productName;
  final double? height;
  final double? width;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const ProductImage({
    super.key,
    required this.imageUrl,
    this.productKey = '',
    this.productName = '',
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  String get _resolvedSource => resolveSource(
        imageUrl: imageUrl,
        productKey: productKey,
        productName: productName,
      );

  bool get _isAsset => _resolvedSource.startsWith('assets/');

  Widget _buildImage() {
    final source = _resolvedSource;
    if (source.isEmpty) return _placeholder();

    if (_isAsset) {
      return Image.asset(
        source,
        height: height,
        width: width,
        fit: fit,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }

    return Image.network(
      '${ApiService.baseUrl}$source',
      height: height,
      width: width,
      fit: fit,
      loadingBuilder: (ctx, child, progress) {
        if (progress == null) return child;
        return _loading();
      },
      errorBuilder: (_, __, ___) => _placeholder(),
    );
  }

  Widget _placeholder() => Container(
        height: height,
        width: width,
        color: const Color(0xFFE8F0E8),
        child: const Center(
          child: Icon(
            Icons.eco_rounded,
            size: 48,
            color: AppTheme.primaryGreen,
          ),
        ),
      );

  Widget _loading() => Container(
        height: height,
        width: width,
        color: const Color(0xFFF0EDE6),
        child: const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppTheme.primaryGreen,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: _buildImage());
    }
    return _buildImage();
  }
}
