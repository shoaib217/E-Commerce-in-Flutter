import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
// Assuming the path to your Product class is correct
import 'package:ecommerce/data/products.dart';
// Assuming the path to your custom extension is correct
import 'package:ecommerce/extensions.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../state/app_state.dart';

class ItemDetailScreen extends StatelessWidget {
  final Product product;

  const ItemDetailScreen({required this.product, super.key}); // Use named required parameter

  // --- Helper Widgets for Layout ---

  /// A refined helper function to display a label and its value.
  Widget _buildDetailRow(BuildContext context, String label, String value) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label is bolded and takes fixed space
          Text(
            "$label:",
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          // Value takes the remaining space and can wrap
          Expanded(
            child: Text(
              value,
              style: textTheme.titleMedium,
              // Allows value text to break line if needed
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the main image carousel section.
  Widget _buildImageCarousel(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return CarouselSlider(
      options: CarouselOptions(
        enableInfiniteScroll: false,
        viewportFraction: 1.0, // Ensures one image takes up the whole space
        height: MediaQuery.of(context).size.height * 0.4, // Set a dynamic height
      ),
      items: product.images.map((url) {
        return GestureDetector(
          onTap: () => _openImageFullScreen(context, url),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0), // Rounded corners for aesthetics
              child: CachedNetworkImage( // Use CachedNetworkImage here as well
                imageUrl: url,
                fit: BoxFit.cover,
                placeholder: (context, url) => Center(child: CircularProgressIndicator(color:  colorScheme.primary)),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // --- Dialogue/Navigation Logic ---

  /// Function to show the full-screen image carousel in a dialog.
  Future<void> _openImageFullScreen(BuildContext context, String initialUrl) {
    final int initialIndex = product.images.indexWhere((element) => element == initialUrl);

    return showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: SizedBox(
            height: MediaQuery.of(context).size.height / 2, // Slightly larger dialog
            child: CarouselSlider(
              options: CarouselOptions(
                initialPage: initialIndex.clamp(0, product.images.length - 1), // Clamp for safety
                height: double.infinity, // Fill dialog height
                viewportFraction: 1.0,
              ),
              items: product.images.map((url) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: CachedNetworkImage(
                    imageUrl: url,
                    fit: BoxFit.contain, // Use contain for full screen view
                    placeholder: (context, url) => const Center(child: CircularProgressIndicator(color: Colors.white)),
                    errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.white),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(product.title),
        elevation: 0, // AppBar without shadow often looks cleaner
      ),
      // Use SingleChildScrollView to prevent overflow on small screens/landscape
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Consistent padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Image Carousel
              _buildImageCarousel(context),
              const SizedBox(height: 16),

              // 2. Price and Rating (Highlighted)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Price
                  Text(
                    currencyFormat.format(product.price),
                    style: textTheme.headlineLarge?.copyWith(
                      // 4. Use the theme's primary color for the price to make it pop.
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  // Rating
                  Row(
                    children: [
                      RatingBarIndicator(
                        rating: product.rating,
                        itemBuilder: (context, index) => const Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        itemCount: 5,
                        itemSize: 25,
                        direction: Axis.horizontal,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${product.rating.toStringAsFixed(1)})', // Display numeric rating
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(height: 24),

              const SizedBox(height: 24),

// --- ADD BUTTONS HERE ---
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.add_shopping_cart),
                      label: const Text("Add to Cart"),
                      onPressed: () {
                        // Use Provider to add to cart
                        Provider.of<AppState>(context, listen: false).addToCart(product);
                        // Show a confirmation
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${product.title} added to cart!'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        textStyle: textTheme.titleMedium,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Favorite Button
                  Consumer<AppState>(
                    builder: (context, appState, child) {
                      final isFavorite = appState.isFavorite(product);
                      return IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? colorScheme.error : colorScheme.onSurface,
                          size: 30,
                        ),
                        onPressed: () {
                          if (isFavorite) {
                            appState.removeFromFavorites(product);
                          } else {
                            appState.addToFavorites(product);
                          }
                        },
                      );
                    },
                  )
                ],
              ),
              const SizedBox(height: 24),


              // 3. Category & Brand Details
              _buildDetailRow(context, "Category", product.category),
              if (product.brand.isNotNullOrEmpty())
                _buildDetailRow(context, "Brand", product.brand),

              const SizedBox(height: 16),

              // 4. Description Title
              Text(
                "Product Details",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // 5. Description Content
              Text(
                product.description,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}