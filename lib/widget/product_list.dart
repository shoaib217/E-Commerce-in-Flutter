import 'package:flutter/material.dart';
import 'package:ecommerce/data/products.dart';
import 'package:ecommerce/widget/product_item.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

import '../screen/cart_screen.dart';
import '../screen/favorites_screen.dart';
import '../state/app_state.dart';

// ignore: must_be_immutable
class ProductList extends StatefulWidget {
  ProductList(this.products, this.category, {super.key});

  List<Product> products;
  final Map<String, List<Product>> category;

  @override
  State<ProductList> createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  late List<Product> tempProducts;
  late List<String> categoryList;

  @override
  void initState() {
    tempProducts = widget.products;
    categoryList = widget.category.keys.toList();
    super.initState();
  }

  void _showConfirmationSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
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
          elevation: 4,
          actions: [
            IconButton(
              icon: Badge(
                // 2. Show the badge only if there are items
                isLabelVisible: appState.favoriteItems.isNotEmpty,
                // 3. Display the number of favorite items
                label: Text(appState.favoriteItems.length.toString()),
                child: const Icon(Icons.favorite_border),
              ),
              tooltip: 'Favorites',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const FavoritesScreen(),
                  ),
                );
              },
            ),
            // --- CART ICON WITH BADGE ---
            IconButton(
              icon: Badge(
                isLabelVisible: appState.cartItems.isNotEmpty,
                label: Text(appState.cartItems.length.toString()),
                child: const Icon(Icons.shopping_cart_outlined),
              ),
              tooltip: 'Cart',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const CartScreen()),
                );
              },
            ),
            PopupMenuButton(
              itemBuilder: (context) {
                List<PopupMenuItem> listOfMenuItem = [
                  PopupMenuItem(
                    child: Text("All", style: textTheme.bodyMedium),
                    onTap: () {
                      setState(() {
                        widget.products = tempProducts;
                      });
                    },
                  ),
                ];
                for (var categoryName in categoryList) {
                  listOfMenuItem.add(
                    PopupMenuItem(
                      child: Text(categoryName, style: textTheme.bodyMedium),
                      onTap: () {
                        setState(() {
                          widget.products = tempProducts
                              .where(
                                (product) => product.category == categoryName,
                              )
                              .toList();
                        });
                      },
                    ),
                  );
                }
                return listOfMenuItem;
              },
            ),
          ],
        ),
        body: ListView.builder(
          addAutomaticKeepAlives: true,
          itemCount: widget.products.length,
          itemBuilder: (context, index) {
            final product = widget.products[index];

            return Slidable(
              key: ValueKey(product.id),

              // 1. REMOVED the `startActionPane` to disable left-to-right swipe
              // startActionPane: ...,

              // 2. CONFIGURE the `endActionPane` for right-to-left swipe
              endActionPane: ActionPane(
                motion: const StretchMotion(),
                extentRatio: 0.6,

                // 3. REMOVED the `dismissible` property to disable full-swipe action
                // dismissible: DismissiblePane(...),

                // 4. ADDED both SlidableActions here
                children: [
                  _buildSlideableAction(
                    context,
                    appState: appState,
                    product: product,
                    label: 'Favorite',
                    icon: Icons.favorite,
                    color: colorScheme.secondaryContainer,
                    onColor: colorScheme.onSecondaryContainer,
                    onPressed: () => appState.addToFavorites(product),
                  ),

                  SizedBox(width: 10),

                  _buildSlideableAction(
                    context,
                    appState: appState,
                    product: product,
                    label: 'Cart',
                    icon: Icons.shopping_cart,
                    color: colorScheme.primaryContainer,
                    onColor: colorScheme.onPrimaryContainer,
                    onPressed: () => appState.addToCart(product),
                  ),
                  SizedBox(width: 12),

                ],
              ),

              child: ProductItem(product),
            );
          },
        ),
        /* floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) {
                return AddNewProduct();
              },
            ));
          },
          backgroundColor:
              Theme.of(context).buttonTheme.colorScheme?.onPrimaryContainer,
          child: Icon(
            Icons.add,
            color: Theme.of(context).buttonTheme.colorScheme?.onPrimary,
          ),
        ), */
      ),
    );
  }

  Widget _buildSlideableAction(
      BuildContext context, {
        required AppState appState,
        required Product product,
        required String label,
        required IconData icon,
        required Color color,
        required Color onColor,
        required VoidCallback onPressed,
      }) {
    return SlidableAction(
      onPressed: (context) {
        onPressed();
        _showConfirmationSnackBar(context, '${product.title} added to $label!');
      },
      backgroundColor: color,
      foregroundColor: onColor,
      icon: icon,
      label: label,
      borderRadius: BorderRadius.circular(12),
    );
  }
}
