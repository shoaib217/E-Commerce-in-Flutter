import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:ecommerce/data/products.dart';
import 'package:ecommerce/widget/product_item.dart';
import '../screen/cart_screen.dart';
import '../screen/favorites_screen.dart';
import '../state/app_state.dart';

class ProductList extends StatefulWidget {
  // 1. Widgets should be immutable. Fields must be final.
  final List<Product> products;
  final Map<String, List<Product>> category;

  const ProductList(this.products, this.category, {super.key});

  @override
  State<ProductList> createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  // 2. Store the mutable filtered list in the State, not the Widget.
  late List<Product> _filteredProducts;
  String _selectedCategory = "All";

  @override
  void initState() {
    super.initState();
    _filteredProducts = widget.products;
  }

  // Update state if the parent widget passes new data
  @override
  void didUpdateWidget(covariant ProductList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.products != widget.products) {
      _filterProducts(_selectedCategory);
    }
  }

  void _filterProducts(String categoryName) {
    setState(() {
      _selectedCategory = categoryName;
      if (categoryName == "All") {
        _filteredProducts = widget.products;
      } else {
        _filteredProducts = widget.products
            .where((product) => product.category == categoryName)
            .toList();
      }
    });
  }

  void _showConfirmationSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating, // Floating looks more modern
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer<AppState>(
      builder: (context, appState, child) => Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          title: Text("Products", style: textTheme.titleLarge),
          centerTitle: false,
          elevation: 0, // Cleaner look
          scrolledUnderElevation: 4,
          actions: [
            // --- FAVORITES ACTION ---
            IconButton(
              tooltip: 'Favorites',
              icon: Badge(
                isLabelVisible: appState.favoriteItems.isNotEmpty,
                label: Text('${appState.favoriteItems.length}'),
                child: const Icon(Icons.favorite_border),
              ),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FavoritesScreen()),
              ),
            ),
            // --- CART ACTION ---
            IconButton(
              tooltip: 'Cart',
              icon: Badge(
                isLabelVisible: appState.cartItems.isNotEmpty,
                label: Text('${appState.cartItems.length}'),
                child: const Icon(Icons.shopping_cart_outlined),
              ),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartScreen()),
              ),
            ),
            // --- FILTER MENU ---
            _buildFilterMenu(textTheme),
          ],
        ),
        body: _filteredProducts.isEmpty
            ? Center(
          child: Text("No products found", style: textTheme.bodyLarge),
        )
            : ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: _filteredProducts.length,
          itemBuilder: (context, index) {
            final product = _filteredProducts[index];

            // 3. Slidable logic
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Slidable(
                key: ValueKey(product.id),
                endActionPane: ActionPane(
                  motion: const ScrollMotion(), // ScrollMotion feels smoother than Stretch
                  extentRatio: 0.5, // Takes up 50% of width
                  children: [
                    _buildSlidableAction(
                      context: context,
                      label: 'Favorite',
                      icon: Icons.favorite,
                      color: colorScheme.secondaryContainer,
                      onColor: colorScheme.onSecondaryContainer,
                      onPressed: () {
                        appState.addToFavorites(product);
                        _showConfirmationSnackBar(
                            context, '${product.title} added to Favorites!');
                      },
                    ),
                    const SizedBox(width: 4), // Real spacing
                    _buildSlidableAction(
                      context: context,
                      label: 'Cart',
                      icon: Icons.shopping_cart,
                      color: colorScheme.primary,
                      onColor: colorScheme.onPrimary,
                      onPressed: () {
                        appState.addToCart(product);
                        _showConfirmationSnackBar(
                            context, '${product.title} added to Cart!');
                      },
                    ),
                  ],
                ),
                child: ProductItem(product),
              ),
            );
          },
        ),
      ),
    );
  }

  // --- HELPER WIDGETS ---

  PopupMenuButton<String> _buildFilterMenu(TextTheme textTheme) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.filter_list),
      tooltip: "Filter by Category",
      onSelected: _filterProducts,
      itemBuilder: (context) {
        return [
          PopupMenuItem(
            value: "All",
            child: Text("All", style: textTheme.bodyMedium),
          ),
          ...widget.category.keys.map((categoryName) {
            return PopupMenuItem(
              value: categoryName,
              child: Text(categoryName, style: textTheme.bodyMedium),
            );
          }),
        ];
      },
    );
  }

  Widget _buildSlidableAction({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Color color,
    required Color onColor,
    required VoidCallback onPressed,
  }) {
    // Using CustomSlidableAction allows for precise styling (gaps, radius)
    return CustomSlidableAction(
      onPressed: (_) => onPressed(),
      backgroundColor: Colors.transparent, // Transparent background
      foregroundColor: color,
      padding: const EdgeInsets.all(4), // Padding around the internal button
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: onColor, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: onColor,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}