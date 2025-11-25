import 'package:flutter/material.dart';
import 'package:ecommerce/http_helper.dart';
import 'package:ecommerce/widget/product_list.dart';
import 'package:ecommerce/main.dart';

class ProductScreen extends StatelessWidget {
  const ProductScreen({super.key});

  // Helper to show a snack bar for errors/messages
  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  // Dialog shown when the user tries to exit via the system back button
  Future<bool> _showExitConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Alert!"),
            content: const Text("Are you sure you want to exit?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("No"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text("Yes"),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    // PopScope handles the system back button press
    return PopScope<Object?>(
      canPop: false,
      // Prevents immediate pop
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) return;

        final bool shouldPop = await _showExitConfirmationDialog(context);

        // Only pop the screen if the dialog returned true AND the context is still valid.
        if (context.mounted && shouldPop) {
          Navigator.pop(context);
        }
      },
      // Removed Scaffold here. The content will be wrapped in a Scaffold by _ProductListContent.
      child: Center(
        child: FutureBuilder(
          future: fetchProduct(),
          // Assuming this fetches an object with a 'products' list
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData) {
                var products = snapshot.data?.products ?? [];
                // Return the main content widget which contains the Scaffold
                return ProductList(
                  products: products,
                  category: groupBy(products, (product) => product.category),
                );
              } else {
                // Show error message and a fallback widget if fetching failed
                _showSnackBar(context, snapshot.error.toString());
                return const SizedBox();
              }
            } else {
              // Show a loading indicator while fetching
              return const CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }
}
