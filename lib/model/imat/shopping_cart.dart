import 'package:imat_app/model/imat/shopping_item.dart';

class ShoppingCart {
  List<ShoppingItem> items;

  ShoppingCart(this.items);

  factory ShoppingCart.fromJson(Map<String, dynamic> json) {
    List jsonItems = json[_items];

    List<ShoppingItem> items = [];

    for (int i = 0; i < jsonItems.length; i++) {
      ShoppingItem item = ShoppingItem.fromJson(jsonItems[i]);
      items.add(item);
    }
    return ShoppingCart(items);
  }

  /*
  Map<String, dynamic> toJson() => {
    'items': jsonEncode(items.map((item) => item.toJson()).toList()),
  };
  */

  Map<String, dynamic> toJson() {
    return {'items': items.map((item) => item.toJson()).toList()};
  }

  void addItem(ShoppingItem sci, {bool merge = true}) {
    if (merge) {
      bool found = false;
      int pId = sci.product.productId;
      double delta = sci.amount;

      for (final item in items) {
        if (pId == item.product.productId) {
          item.amount = item.amount + delta;
          found = true;
          break;
        }
      }
      if (!found) {
        items.add(sci);
      }
    } else {
      items.add(sci);
    }
  }

  // Changes the amount of sci with delta.
  // If the item does not exist the this is the same
  // as addItem.
  // If amount is <= 0 then the item is removed
  void updateItem(
    ShoppingItem sci, {
    double delta = 0.0,
    bool removeEmpty = true,
  }) {
    bool found = false;
    int pId = sci.product.productId;

    for (final item in items) {
      if (pId == item.product.productId) {
        item.amount = item.amount + delta;
        found = true;
        if (removeEmpty && item.amount <= 0.0) {
          items.remove(item);
        }
        break;
      }
    }
    if (!found) {
      items.add(sci);
    }
  }

  void removeItem(ShoppingItem sci) {
    int pId = sci.product.productId;
    List<ShoppingItem> toRemove = [];

    for (ShoppingItem item in items) {
      if (item.product.productId == pId) {
        toRemove.add(item);
      }
    }
    for (ShoppingItem item in toRemove) {
      items.remove(item);
    }
  }

  void clear() {
    items.clear();
  }

  /*
  void _removeFirst(ShoppingItem) {
    for (final item in items) {}
  }
  */

  static const _items = 'items';
}
