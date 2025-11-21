import 'package:flutter/material.dart';
import 'package:ecommerce/data/products.dart';

class AppState extends ChangeNotifier {
  final List<Product> _favoriteItems = [];
  final List<Product> _cartItems = [];

  List<Product> get favoriteItems => _favoriteItems;
  List<Product> get cartItems => _cartItems;

  // Favorite Methods
  void addToFavorites(Product product) {
    if (!_favoriteItems.contains(product)) {
      _favoriteItems.add(product);
      notifyListeners();
    }
  }

  void removeFromFavorites(Product product) {
    _favoriteItems.remove(product);
    notifyListeners();
  }

  bool isFavorite(Product product) {
    return _favoriteItems.contains(product);
  }

  // Cart Methods
  void addToCart(Product product) {
    // For simplicity, we add the product. A real app would handle quantity.
    if (!_cartItems.contains(product)) {
      _cartItems.add(product);
      notifyListeners();
    }
  }

  void removeFromCart(Product product) {
    _cartItems.remove(product);
    notifyListeners();
  }

  void insertIntoFavorites(int index, Product product) {
    // Check to prevent re-inserting if it's already there
    if (!_favoriteItems.contains(product)) {
      _favoriteItems.insert(index, product);
      notifyListeners();
    }
  }

}
