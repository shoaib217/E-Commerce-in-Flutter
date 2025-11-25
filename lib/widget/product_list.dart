import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:ecommerce/data/products.dart';
import 'package:ecommerce/widget/product_item.dart';
import '../screen/cart_screen.dart';
import '../screen/favorites_screen.dart';
import '../state/app_state.dart';

enum ViewType { list, grid }

class ProductList extends StatefulWidget {
  final List<Product> products;
  final Map<String, List<Product>> category;

  const ProductList({
    required this.products,
    required this.category,
    super.key,
  });

  @override
  State<ProductList> createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  late List<Product> _filtered;
  String _selectedCategory = "All";

  ViewType _viewType = ViewType.list;

  @override
  void initState() {
    super.initState();
    _filtered = widget.products;
  }

  @override
  void didUpdateWidget(ProductList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.products != widget.products) {
      _applyFilter(_selectedCategory);
    }
  }

  void _applyFilter(String category) {
    setState(() {
      _selectedCategory = category;
      _filtered = category == "All"
          ? widget.products
          : widget.products.where((p) => p.category == category).toList();
    });
  }

  void _showSnack(BuildContext context, String text) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(text),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Slidable builder
  Widget _action({
    required Color color,
    required Color onColor,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return CustomSlidableAction(
      onPressed: (_) => onPressed(),
      backgroundColor: Colors.transparent,
      foregroundColor: color,
      padding: const EdgeInsets.all(4),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<AppState>(
      builder: (context, appState, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text("Products", style: theme.textTheme.titleLarge),
            actions: [
              IconButton(
                icon: Icon(
                  _viewType == ViewType.list
                      ? Icons.grid_view_rounded
                      : Icons.view_list_rounded,
                ),
                tooltip: _viewType == ViewType.list
                    ? "Show as Grid"
                    : "Show as List",
                onPressed: () {
                  setState(() {
                    _viewType = _viewType == ViewType.list
                        ? ViewType.grid
                        : ViewType.list;
                  });
                },
              ),
              IconButton(
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
              IconButton(
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
              PopupMenuButton<String>(
                icon: const Icon(Icons.filter_list),
                tooltip: "Filter by Category",
                onSelected: _applyFilter,
                itemBuilder: (_) => [
                  const PopupMenuItem(value: "All", child: Text("All")),
                  ...widget.category.keys.map(
                    (c) => PopupMenuItem(value: c, child: Text(c)),
                  ),
                ],
              ),
            ],
          ),
          body: _filtered.isEmpty
              ? Center(child: Text("No products found"))
              : _viewType == ViewType.list
              ? _buildListView()
              : _buildGridView(),
        );
      },
    );
  }

  // --- Helper method to build the ListView ---
  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _filtered.length,
      itemBuilder: (_, index) {
        final p = _filtered[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Slidable(
            key: ValueKey(p.id),
            endActionPane: ActionPane(
              motion: const ScrollMotion(),
              extentRatio: 0.45,
              children: [
                _action(
                  label: 'Favorite',
                  icon: Icons.favorite,
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  onColor: Theme.of(context).colorScheme.onSecondaryContainer,
                  onPressed: () {
                    context.read<AppState>().addToFavorites(p);
                    _showSnack(context, '${p.title} added to Favorites!');
                  },
                ),
                _action(
                  label: 'Cart',
                  icon: Icons.shopping_cart,
                  color: Theme.of(context).colorScheme.primary,
                  onColor: Theme.of(context).colorScheme.onPrimary,
                  onPressed: () {
                    context.read<AppState>().addToCart(p);
                    _showSnack(context, '${p.title} added to Cart!');
                  },
                ),
              ],
            ),
            child: ProductItem(p, _viewType),
          ),
        );
      },
    );
  }

  // --- Helper method to build the GridView ---
  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75, // Adjust this to control item height
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _filtered.length,
      itemBuilder: (context, index) {
        final p = _filtered[index];
        // Grid items usually don't have swipe actions, but you could wrap
        // this in a Slidable if you wanted. For this example, we keep it simple.
        return ProductItem(p, _viewType);
      },
    );
  }
}
