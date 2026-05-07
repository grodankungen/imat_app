import 'package:flutter/material.dart';
import 'package:imat_app/model/imat/product.dart';

/// A user-facing category group, mapping one or more backend [ProductCategory]
/// enum values to a single label and icon shown in the sidebar.
class CategoryGroup {
  final String label;
  final IconData icon;
  final List<ProductCategory> categories;

  const CategoryGroup(this.label, this.icon, this.categories);

  bool contains(ProductCategory c) => categories.contains(c);
}

const CategoryGroup allProducts = CategoryGroup(
  'Alla Varor',
  Icons.inventory_2_outlined,
  [],
);

const List<CategoryGroup> categoryGroups = [
  allProducts,
  CategoryGroup('Frukt & bär', Icons.apple, [
    ProductCategory.FRUIT,
    ProductCategory.BERRY,
    ProductCategory.CITRUS_FRUIT,
    ProductCategory.EXOTIC_FRUIT,
    ProductCategory.MELONS,
  ]),
  CategoryGroup('Grönsaker & rotfrukter', Icons.eco_outlined, [
    ProductCategory.VEGETABLE_FRUIT,
    ProductCategory.CABBAGE,
    ProductCategory.ROOT_VEGETABLE,
    ProductCategory.POD,
    ProductCategory.HERB
  ]),
  CategoryGroup('Mejeri & Ägg', Icons.local_drink_outlined, [
    ProductCategory.DAIRIES,
  ]),
  CategoryGroup('Kött & Fisk', Icons.set_meal_outlined, [
    ProductCategory.MEAT,
    ProductCategory.FISH,
  ]),
  CategoryGroup('Bröd & Bageri', Icons.bakery_dining_outlined, [
    ProductCategory.BREAD,
  ]),
  CategoryGroup('Drycker', Icons.local_cafe_outlined, [
    ProductCategory.HOT_DRINKS,
    ProductCategory.COLD_DRINKS,
  ]),
  CategoryGroup('Nötter och frön', Icons.circle_outlined, [
    ProductCategory.NUTS_AND_SEEDS
  ]),
  CategoryGroup('Skafferi', Icons.kitchen_outlined, [
    ProductCategory.PASTA,
    ProductCategory.POTATO_RICE,
    ProductCategory.FLOUR_SUGAR_SALT,
    ProductCategory.SWEET,
  ]),
];
