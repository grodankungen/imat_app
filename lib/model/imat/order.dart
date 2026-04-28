import 'dart:convert';

import 'package:imat_app/model/imat/shopping_item.dart';

class Order {
  int orderNumber;
  DateTime date;
  List<ShoppingItem> items;

  Order(this.orderNumber, this.date, this.items);

  factory Order.fromJson(Map<String, dynamic> json) {
    int orderNumber = json[_orderNumber] as int;
    int timeStamp = json[_date] as int;
    List jsonItems = json[_items];

    List<ShoppingItem> items = [];

    for (int i = 0; i < jsonItems.length; i++) {
      ShoppingItem item = ShoppingItem.fromJson(jsonItems[i]);
      items.add(item);
    }
    return Order(
      orderNumber,
      DateTime.fromMillisecondsSinceEpoch(timeStamp),
      items,
    );
  }

  Map<String, dynamic> toJson() => {
    _orderNumber: orderNumber,
    _date: date.millisecondsSinceEpoch,
    _items: jsonEncode(items.map((item) => item.toJson()).toList()),
  };

  double getTotal() {
    var total = 0.0;

    for (final item in items) {
      total = total + item.product.price * item.amount;
    }
    return total;
  }

  static const _orderNumber = 'orderNumber';
  static const _date = 'date';
  static const _items = 'items';
}
