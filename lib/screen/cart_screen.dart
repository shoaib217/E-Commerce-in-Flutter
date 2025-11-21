import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecommerce/state/app_state.dart';
import 'package:ecommerce/main.dart'; // for currencyFormat

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Cart"),
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          if (appState.cartItems.isEmpty) {
            return const Center(
              child: Text("Your cart is empty."),
            );
          }

          // Calculate total
          final double total = appState.cartItems.fold(0, (sum, item) => sum + item.price);

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: appState.cartItems.length,
                  itemBuilder: (context, index) {
                    final product = appState.cartItems[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(product.images.first),
                      ),
                      title: Text(product.title),
                      subtitle: Text(currencyFormat.format(product.price)),
                      trailing: IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () {
                          appState.removeFromCart(product);
                        },
                      ),
                    );
                  },
                ),
              ),
              // Total and Checkout Button
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total: ${currencyFormat.format(total)}',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    ElevatedButton(
                      onPressed: () { /* Checkout logic here */ },
                      child: const Text('Checkout'),
                    ),
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }
}

