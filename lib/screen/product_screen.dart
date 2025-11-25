import 'package:flutter/material.dart';
import 'package:ecommerce/http_helper.dart';
import 'package:ecommerce/widget/product_list.dart';
import 'package:ecommerce/main.dart';
import 'package:ecommerce/data/products.dart';

// 1. Converted to a StatefulWidget
class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  // 2. Hold the Future in a state variable
  late Future<Products> _productsFuture;

  @override
  void initState() {
    super.initState();
    // 3. Fetch data only once when the widget is created
    _productsFuture = fetchProducts();
  }

  // 4. Create a method to re-run the fetch operation
  void _retryFetch() {
    setState(() {
      // Assigning a new Future will cause the FutureBuilder to re-evaluate
      _productsFuture = fetchProducts();
    });
  }

  // Helper to show a snack bar for errors/messages
  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  // Dialog shown when the user tries to exit
  Future<bool> _showExitConfirmationDialog() async {
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
    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) return;
        final bool shouldPop = await _showExitConfirmationDialog();
        if (context.mounted && shouldPop) {
          Navigator.pop(context);
        }
      },
      child: Center(
        child: FutureBuilder<Products>(
          // 5. Use the state variable for the future
          future: _productsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            // --- IMPROVEMENT WITH RETRY BUTTON ---
            if (snapshot.hasError) {
              // Return a user-friendly error UI with a retry button
              return Scaffold(
                body: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        "Failed to load products: ${snapshot.error}",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _retryFetch,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            // --- END OF IMPROVEMENT ---

            if (snapshot.hasData) {
              var products = snapshot.data?.products ?? [];
              if (products.isEmpty) {
                return const Text("No products found");
              }
              // Return the main content widget which contains the Scaffold
              return ProductList(
                products: products,
                category: groupBy(products, (product) => product.category),
              );
            }

            return const Text("No products found");
          },
        ),
      ),
    );
  }
}
