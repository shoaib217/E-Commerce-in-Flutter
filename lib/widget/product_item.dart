import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecommerce/main.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce/data/products.dart';
import 'package:ecommerce/extensions.dart';
import 'package:ecommerce/screen/item_detail_screen.dart';

class ProductItem extends StatelessWidget {
  const ProductItem(this.selectedProduct, {super.key});

  final Product selectedProduct;

  // --- 1. Discount Badge Helper ---
  Widget _buildDiscountBadge(BuildContext context, double discount) {
    if (discount <= 0) return const SizedBox.shrink();
    return Positioned(
      top: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.error, // Use theme error color (usually red)
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
        ),
        child: Text(
          '-${discount.toStringAsFixed(0)}%',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.onError,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // --- 2. Bottom Info Helper (Rating & Stock) ---
  Widget _buildBottomInfo(BuildContext context, Product product) {
    return Row(
      children: [
        Icon(Icons.star_rounded, color: Colors.amber[700], size: 18), // Rounded star looks nicer
        const SizedBox(width: 4),
        Text(
          product.rating.toStringAsFixed(1),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 1,
          height: 12,
          color: Colors.grey.withValues(alpha: 0.5), // Divider
        ),
        const SizedBox(width: 8),
        Text(
          product.stock > 0 ? 'In Stock' : 'Out of Stock',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: product.stock > 0
                ? Colors.green[700]
                : Theme.of(context).colorScheme.error,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    const double imageSize = 140.0; // Slightly reduced for a tighter look

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ItemDetailScreen(product: selectedProduct),
          ),
        );
      },
      child: Card(
        elevation: 0, // Flat design is cleaner, or use 1-2 for shadow
        // ✅ THEME FIX: Use surfaceContainer (M3) or surface with a border
        color: colorScheme.surfaceContainerLow,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)), // Subtle border
        ),
        clipBehavior: Clip.antiAlias, // Ensures image doesn't bleed out corners
        child: IntrinsicHeight(
          child: Row(
            children: [
              // ---------------- IMAGE SECTION ----------------
              SizedBox(
                width: imageSize, // Force square aspect ratio for the image container
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: selectedProduct.images[0],
                      fit: BoxFit.cover,
                      progressIndicatorBuilder: (context, url, progress) =>
                          Center(
                            child: CircularProgressIndicator(
                                value: progress.progress, strokeWidth: 2),
                          ),
                      errorWidget: (context, url, error) => Container(
                        color: colorScheme.surfaceContainerHighest,
                        child: const Icon(Icons.broken_image_outlined, size: 40),
                      ),
                    ),
                    _buildDiscountBadge(context, selectedProduct.discountPercentage),
                  ],
                ),
              ),

              // ---------------- DETAILS SECTION ----------------
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    // ✅ ALIGNMENT FIX: Center vertically to remove empty gaps
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 1. Brand
                      if (selectedProduct.brand.isNotNullOrEmpty())
                        Text(
                          selectedProduct.brand.toUpperCase(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.primary,
                            letterSpacing: 0.5,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                      const SizedBox(height: 4),

                      // 2. Title
                      Text(
                        selectedProduct.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          height: 1.1,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 8), // Consistent gap

                      // 3. Price
                      Text(
                        currencyFormat.format(selectedProduct.price),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),

                      const SizedBox(height: 6),

                      // 4. Rating & Stock
                      _buildBottomInfo(context, selectedProduct),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}