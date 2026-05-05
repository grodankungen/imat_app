import 'package:flutter/material.dart';
import '../widgets/category_panel.dart';
import '../widgets/product_grid.dart';
import '../widgets/shopping_cart_panel.dart';

class MainView extends StatelessWidget {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SizedBox(width: 200, child: CategoryPanel()),
          VerticalDivider(width: 1),
          Expanded(child: ProductGrid()),
          VerticalDivider(width: 1),
          SizedBox(width: 250, child: ShoppingCartPanel()),
        ],
      ),
    );
  }
}