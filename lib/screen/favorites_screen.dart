import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecommerce/state/app_state.dart';
import 'package:ecommerce/widget/product_item.dart'; // Reuse your ProductItem

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Favorites"),
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          if (appState.favoriteItems.isEmpty) {
            return const Center(
              child: Text("You haven't added any favorites yet."),
            );
          }

          return ListView.builder(
            itemCount: appState.favoriteItems.length,
            itemBuilder: (context, index) {
              final product = appState.favoriteItems[index];

              // 1. Wrap the ProductItem with the Dismissible widget
              return Dismissible(
                // 2. Provide a unique key. This is crucial for Flutter to manage the list.
                key: ValueKey(product.id),
                direction: .endToStart,

                // 3. Define the action to take when the item is dismissed.
                onDismissed: (direction) {

                  final removedProduct = product;
                  final removedIndex = index;

                  // Call the method from your AppState to remove the item
                  appState.removeFromFavorites(product);

                  // Show a confirmation SnackBar
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${product.title} removed from favorites.'),
                      duration: const Duration(seconds: 4),
                        action: SnackBarAction(
                          label: "UNDO",
                          onPressed: () {
                            // 4. When "Undo" is pressed, add the item back at its original position.
                            appState.insertIntoFavorites(removedIndex, removedProduct);
                          },
                        ),
                    ),
                  );
                },

                // 4. Define the background that appears behind the item during the swipe.
                background: Padding(
                  // Match the margin of the ProductItem's Card
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.0), // Use the same radius as your card
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


                // 5. The child is your original ProductItem widget.
                child: ProductItem(product),
              );
            },
          );
        },
      ),
    );
  }
}
