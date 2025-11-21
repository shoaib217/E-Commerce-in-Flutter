import 'package:ecommerce/screen/product_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import './theme/app_theme.dart';
import 'package:ecommerce/state/app_state.dart';

Map<T, List<S>> groupBy<S, T>(Iterable<S> values, T Function(S) key) {
  var map = <T, List<S>>{};
  for (var element in values) {
    (map[key(element)] ??= []).add(element);
  }
  return map;
}

final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final AppTheme appTheme = AppTheme(ThemeData.light().textTheme);
    return ChangeNotifierProvider(
        create: (context) => AppState(),
        child: MaterialApp(
          title: 'E-commerce App',
          theme: appTheme.light(),
          darkTheme: appTheme.dark(),
          themeMode: ThemeMode.system,
          home: const ProductScreen(),
        )
    );
  }
}

