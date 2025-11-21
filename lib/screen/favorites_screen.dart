import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecommerce/state/app_state.dart';
import 'package:ecommerce/widget/product_item.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Favorites"),
      ),
      // 1. IMPROVEMENT: Move Consumer closer to the widget that needs the state.
      // This prevents the AppBar and Scaffold from rebuilding unnecessarily.
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          // Show a placeholder if the list is empty.
          if (appState.favoriteItems.isEmpty) {
            // The `child` argument here is the const widget defined below,
            // which is more performant as it's not rebuilt.
            return child!;
          }

          // Build the list of favorite items.
          return ListView.builder(
            padding: const EdgeInsets.only(top: 8.0), // Add padding to the list itself
            itemCount: appState.favoriteItems.length,
            itemBuilder: (context, index) {
              final product = appState.favoriteItems[index];

              return Dismissible(
                // 2. CRITICAL FIX: Use ObjectKey to uniquely identify the widget
                // by its data object, preventing state conflicts during rebuilds.
                key: ObjectKey(product),

                direction: DismissDirection.endToStart,
                onDismissed: (direction) {
                  // The logic inside onDismissed is already excellent.
                  final messenger = ScaffoldMessenger.of(context);
                  final removedProduct = product;
                  final removedIndex = index;

                  appState.removeFromFavorites(product);

                  messenger.hideCurrentSnackBar();
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('${product.title} removed from favorites.'),
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                      action: SnackBarAction(
                        label: "UNDO",
                        onPressed: () {
                          appState.insertIntoFavorites(
                              removedIndex, removedProduct);
                          messenger.hideCurrentSnackBar();
                        },
                      ),
                    ),
                  );
                },
                background: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.0),
                    child: Container(
                      color: colorScheme.errorContainer,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Icon(
                        Icons.delete_sweep,
                        color: colorScheme.onErrorContainer,
                        size: 30,
                      ),
                    ),
                  ),
                ),
                child: ProductItem(product),
              );
            },
          );
        },
        // 3. PERFORMANCE: Pass the non-changing "empty" widget as the child
        // to the Consumer. This ensures it's created only once.
        child: const Center(
          child: Text("You haven't added any favorites yet."),
        ),
      ),
    );
  }
}
