import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import 'verification_badge.dart';

class QrViewModal extends StatelessWidget {
  final Product product;

  const QrViewModal({super.key, required this.product});

  static void show(BuildContext context, Product product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => QrViewModal(product: product),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.borderGrey,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Icon(Icons.qr_code_2_rounded, size: 36, color: AppTheme.forestGreen),
          const SizedBox(height: 8),
          Text(
            'Batch Traceability QR',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 4),
          Text(
            product.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.mutedGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          // QR Box
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.borderGrey, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildQrVisual(),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.creamDark,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        product.batchNumber,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: AppTheme.charcoal,
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: product.batchNumber));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              duration: Duration(seconds: 1),
                              content: Text('Batch code copied to clipboard'),
                            ),
                          );
                        },
                        child: const Icon(Icons.copy, size: 14, color: AppTheme.primaryGreen),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          VerificationBadge(status: product.status),
          const SizedBox(height: 14),
          const Text(
            'Customers scan this QR code in supermarkets and retail stores to verify farm origin, harvesting dates, processing checkpoints, and laboratory test certificates.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppTheme.mutedGrey, height: 1.4),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQrVisual() {
    return Container(
      width: 180,
      height: 180,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: CustomPaint(
        painter: _SimulatedQrPainter(seed: product.id * 17 + product.batchNumber.hashCode),
      ),
    );
  }
}

class _SimulatedQrPainter extends CustomPainter {
  final int seed;

  _SimulatedQrPainter({required this.seed});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF123B2C)
      ..style = PaintingStyle.fill;

    const int grid = 21;
    final double cellSize = size.width / grid;

    // Draw finder patterns (top-left, top-right, bottom-left)
    _drawFinderPattern(canvas, 0, 0, cellSize, paint);
    _drawFinderPattern(canvas, grid - 7, 0, cellSize, paint);
    _drawFinderPattern(canvas, 0, grid - 7, cellSize, paint);

    // Pseudorandom grid data for realistic QR visual
    int currentSeed = seed;
    for (int r = 0; r < grid; r++) {
      for (int c = 0; c < grid; c++) {
        // Skip finder pattern zones
        final inTL = r < 8 && c < 8;
        final inTR = r < 8 && c >= grid - 8;
        final inBL = r >= grid - 8 && c < 8;
        if (inTL || inTR || inBL) continue;

        currentSeed = (currentSeed * 1103515245 + 12345) & 0x7FFFFFFF;
        if (currentSeed % 2 == 0) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(c * cellSize, r * cellSize, cellSize * 0.9, cellSize * 0.9),
              const Radius.circular(1),
            ),
            paint,
          );
        }
      }
    }
  }

  void _drawFinderPattern(Canvas canvas, int col, int row, double cell, Paint paint) {
    // Outer 7x7 square
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(col * cell, row * cell, 7 * cell, 7 * cell),
        const Radius.circular(4),
      ),
      paint,
    );
    // Inner white 5x5 square
    final whitePaint = Paint()..color = Colors.white;
    canvas.drawRect(
      Rect.fromLTWH((col + 1) * cell, (row + 1) * cell, 5 * cell, 5 * cell),
      whitePaint,
    );
    // Center 3x3 square
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH((col + 2) * cell, (row + 2) * cell, 3 * cell, 3 * cell),
        const Radius.circular(2),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
