import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:ecommerce/data/products.dart';

// Using a private, more descriptive constant name.
const String _productsApiUrl = "https://dummyjson.com/products";

/// Fetches a list of products from the API.
///
/// Throws an [Exception] if the network call fails for any reason
/// (e.g., network error, server error, or malformed JSON).
Future<Products> fetchProducts() async {
  // Use a provided client or create a new one. This aids in testing.
  final httpClient = http.Client();

  try {
    final response = await httpClient.get(Uri.parse(_productsApiUrl));

    if (response.statusCode == 200) {
      // Decode JSON only once.
      final decodedJson = jsonDecode(response.body);
      return Products.fromJson(decodedJson);
    } else {
      // Handle non-200 status codes.
      throw Exception('Failed to load products. Status Code: ${response.statusCode}');
    }
  } on SocketException {
    throw Exception('No Internet Connection');
  } on FormatException {
    throw Exception('Bad response format');
  } catch (e) {
    if (kDebugMode) {
      print("An unexpected error in fetchProducts: $e");
    }
    // Re-throw to be handled by the caller.
    rethrow;
  } finally {
    httpClient.close();
  }
}
