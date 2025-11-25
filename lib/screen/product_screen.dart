import 'package:flutter/material.dart';
import 'package:ecommerce/http_helper.dart';
import 'package:ecommerce/widget/product_list.dart';
import 'package:ecommerce/data/products.dart';

import '../main.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  late Future<Products> _productsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = fetchProducts();
  }

  void _retryFetch() {
    setState(() {
      _productsFuture = fetchProducts();
    });
  }

  Future<bool> _showExitDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Alert!"),
        content: const Text("Are you sure you want to exit?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Yes"),
          ),
        ],
      ),
    ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _showExitDialog();
        if (context.mounted && shouldPop) Navigator.pop(context);
      },
      child: FutureBuilder<Products>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasError) {
            return Scaffold(
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Failed to load products:\n${snapshot.error}",
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _retryFetch,
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          final products = snapshot.data?.products ?? [];
          if (products.isEmpty) {
            return const Scaffold(
              body: Center(child: Text("No products found")),
            );
          }

          return ProductList(
            products: products,
            category: groupBy(
              products,
                  (product) => product.category,
            ),
          );
        },
      ),
    );
  }
}
