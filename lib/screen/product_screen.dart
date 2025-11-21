import 'package:flutter/material.dart';
import 'package:ecommerce/http_helper.dart';
import 'package:ecommerce/widget/product_list.dart';
import 'package:ecommerce/main.dart';

class ProductScreen extends StatelessWidget {
  const ProductScreen({super.key});

  void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<Object?>(
      canPop: false, // Prevents immediate pop
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) {
          return;
        }
        final bool shouldPop = await showDialog(
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
        ) ?? false; // Handle case where dialog is dismissed
        if (context.mounted && shouldPop) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        body: Center(
          child: FutureBuilder(
            future: fetchProduct(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData) {
                  var products = snapshot.data?.products ?? [];
                  return ProductList(products,
                      groupBy(products, (product) => product.category));
                } else {
                  showSnackBar(context, snapshot.error.toString());
                  return const SizedBox();
                }
              } else {
                return const CircularProgressIndicator();
              }
            },
          ),
        ),
      ),
    );
  }
}
