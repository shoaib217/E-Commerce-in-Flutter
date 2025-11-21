import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:ecommerce/data/products.dart';

const String api = "https://dummyjson.com/products";

Future<Products> fetchProduct() async {
  var response = await http.Client().get(Uri.parse(api));
  if (kDebugMode) {
    print(jsonDecode(response.body));
  }
  return Products.fromJson(jsonDecode(response.body));
}
