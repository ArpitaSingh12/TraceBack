import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traceback/widgets/product_image.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const products = {
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

  test('every demo product batch has a matching explicit local image', () {
    for (final entry in products.entries) {
      expect(
        ProductImage.assetForProduct(
          productKey: entry.key,
          productName: '',
        ),
        entry.value,
        reason: 'Missing image mapping for ${entry.key}',
      );
    }
  });

  test('every mapped product photo is bundled as a Flutter asset', () async {
    for (final asset in products.values.toSet()) {
      final data = await rootBundle.load(asset);
      expect(data.lengthInBytes, greaterThan(0), reason: 'Empty asset: $asset');
    }
  });

  test('uses the product batch identifier instead of a mismatched stored asset', () {
    expect(
      ProductImage.resolveSource(
        imageUrl: 'assets/images/organic_apples.jpg',
        productKey: 'FRU-MNG-009',
        productName: 'Alphonso Mango',
      ),
      'assets/images/alphonso_mango.jpg',
    );
  });

  test('uploaded product images override the bundled product image', () {
    expect(
      ProductImage.resolveSource(
        imageUrl: '/uploads/products/0123456789abcdef0123456789abcdef.jpg',
        productKey: 'SPC-TUR-004',
        productName: 'Turmeric',
      ),
      '/uploads/products/0123456789abcdef0123456789abcdef.jpg',
    );
  });

  test('does not use unrelated external URLs or generic photos as a fallback', () {
    expect(
      ProductImage.resolveSource(
        imageUrl: 'https://example.invalid/unrelated.jpg',
        productKey: 'unknown-batch',
        productName: 'Unknown product',
      ),
      isEmpty,
    );
    expect(
      ProductImage.resolveSource(
        imageUrl: '',
        productKey: '',
        productName: 'Watermelon',
      ),
      'assets/images/watermelon.jpg',
    );
  });
}
