import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:imat_app/model/imat/credit_card.dart';
import 'package:imat_app/model/imat/customer.dart';
import 'package:imat_app/model/imat/product.dart';
import 'package:imat_app/model/imat/shopping_cart.dart';
import 'package:imat_app/model/imat/user.dart';
import 'dart:convert';

import 'package:imat_app/model/imat/util/functions.dart';

// A class that handles the communication over the internet.
// All methods are static class methods which means that we can
// use them without creating an instance of this class.
class InternetHandler {
  // Some constant strings used to avoid having strings in the code.
  //static const baseURL = 'http://localhost:8080/imat2/api/';
  static const baseURL = 'https://dat216.cse.chalmers.se/imat2/api/';

  static int kGroupId = 0;

  static const kDivider = '/';

  static var apiKey =
      'a27bg892h-jgdfg6-81kwna22lmq-sidfha9361zw-jj221112abkm77';

  static var apiKeyHeader = {'X-API-Key': apiKey};
  static var apiKeyPlusJsonHeader = {
    'X-API-Key': apiKey,
    'Content-Type': 'application/json',
  };

  static String getImageUrl(int pid) {
    return '${baseURL}image/$pid';
  }

  static Future<String> getProduct(int id) async {
    var url = Uri.parse('${baseURL}products/$id');

    try {
      var response = await http.get(url, headers: apiKeyHeader);
      if (response.statusCode == 200) {
        return response.body;
      } else {
        dbugPrint('getProduct ${response.statusCode}');
      }
    } catch (e) {
      dbugPrint('getProduct $e');
    }
    return '';
  }

  static Future<String> getProducts() async {
    return getEndpoint('products');
  }

  static Future<String> getDetails() async {
    return getEndpoint('details');
  }

  static Future<String> getCreditCard() async {
    return getEndpoint('creditcard', id: kGroupId);
  }

  static Future<String> getCustomer() async {
    return getEndpoint("customer", id: kGroupId);
  }

  static Future<String> getUser() async {
    return getEndpoint("user", id: kGroupId);
  }

  static Future<String> getFavorites() async {
    return getEndpoint("favorites", id: kGroupId);
  }

  static Future<String> getOrders() async {
    return getEndpoint("orders", id: kGroupId);
  }

  static Future<String> getShoppingCart() async {
    return getEndpoint("shoppingcart", id: kGroupId);
  }

  static Future<String> getExtras() async {
    return getEndpoint("extras", id: kGroupId);
  }

  static Future<String> getEndpoint(String endPoint, {int id = 0}) async {
    var resourcePath = baseURL + endPoint;

    if (id > 0) {
      resourcePath = '$resourcePath/$id';
    }
    dbugPrint(resourcePath);

    var url = Uri.parse(resourcePath);

    try {
      var response = await http.get(url, headers: apiKeyHeader);
      if (response.statusCode == 200) {
        return response.body;
      } else {
        dbugPrint('get $endPoint ${response.statusCode}');
      }
    } catch (e) {
      dbugPrint('get $endPoint $e');
    }
    return '';
  }

  static Future<String> setCreditCard(CreditCard card) async {
    return putEndpoint("creditcard", json: jsonEncode(card), cid: kGroupId);
  }

  static Future<String> setCustomer(Customer customer) async {
    return putEndpoint("customer", json: jsonEncode(customer), cid: kGroupId);
  }

  static Future<String> setUser(User user) async {
    return putEndpoint("user", json: jsonEncode(user), cid: kGroupId);
  }

  static Future<String> setShoppingCart(ShoppingCart cart) async {
    return putEndpoint("shoppingcart", json: jsonEncode(cart), cid: kGroupId);
  }

  static Future<String> setFavorites(List<Product> favorites) {
    return putEndpoint("favorites", json: jsonEncode(favorites), cid: kGroupId);
  }

  static Future<String> setExtrasX(String extras) {
    return putEndpoint("extras", json: extras, cid: kGroupId);
  }

  static Future<String> setExtras(Map<String, dynamic> extras) {
    return putEndpoint("extras", json: jsonEncode(extras), cid: kGroupId);
  }

  static Future<String> addFavorite(int pid) {
    return putEndpoint(
      "favorites",
      json: jsonEncode(pid),
      cid: kGroupId,
      pid: pid,
    );
  }

  static Future<String> removeFavorite(int pid) {
    return deleteEndpoint("favorites", cid: kGroupId, pid: pid);
  }

  static Future<String> placeOrder() async {
    return putEndpoint("orders", json: jsonEncode([]), cid: kGroupId);
  }

  static Future<String> reset() async {
    return postEndpoint("reset", json: jsonEncode([]), cid: kGroupId);
  }

  static Future<String> putEndpoint(
    String endPoint, {
    required String json,
    int cid = 0,
    int pid = 0,
  }) async {
    var resourcePath = baseURL + endPoint;

    //print('Put ${json}');
    // Add customer identifier
    if (cid > 0) {
      resourcePath = '$resourcePath/$cid';
    }
    //print('Put ${json}');
    // Add product identifier
    if (pid > 0) {
      resourcePath = '$resourcePath/$pid';
    }

    dbugPrint(resourcePath);

    var url = Uri.parse(resourcePath);

    try {
      var response = await http.put(
        url,
        headers: apiKeyPlusJsonHeader,
        body: json,
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response.body;
      } else {
        dbugPrint('put $endPoint ${response.statusCode}');
      }
    } catch (e) {
      dbugPrint('put $endPoint $e');
    }
    return '';
  }

  static Future<String> postEndpoint(
    String endPoint, {
    required String json,
    int cid = 0,
    int pid = 0,
  }) async {
    var resourcePath = baseURL + endPoint;

    //print('Put ${json}');
    // Add customer identifier
    if (cid > 0) {
      resourcePath = '$resourcePath/$cid';
    }
    //print('Put ${json}');
    // Add product identifier
    if (pid > 0) {
      resourcePath = '$resourcePath/$pid';
    }

    dbugPrint(resourcePath);

    var url = Uri.parse(resourcePath);

    try {
      var response = await http.post(
        url,
        headers: apiKeyPlusJsonHeader,
        body: json,
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response.body;
      } else {
        dbugPrint('post $endPoint ${response.statusCode}');
      }
    } catch (e) {
      dbugPrint('put $endPoint $e');
    }
    return '';
  }

  static Future<String> deleteEndpoint(
    String endPoint, {
    int cid = 0,
    int pid = 0,
  }) async {
    var resourcePath = baseURL + endPoint;

    //print('Put ${json}');
    // Add customer identifier
    if (cid > 0) {
      resourcePath = '$resourcePath/$cid';
    }
    //print('Put ${json}');
    // Add product identifier
    if (pid > 0) {
      resourcePath = '$resourcePath/$pid';
    }

    dbugPrint(resourcePath);

    var url = Uri.parse(resourcePath);

    try {
      var response = await http.delete(url, headers: apiKeyHeader);
      if (response.statusCode == 200) {
        return response.body;
      } else {
        dbugPrint('delete $endPoint ${response.statusCode}');
      }
    } catch (e) {
      dbugPrint('delete $endPoint $e');
    }
    return '';
  }

  // Add a todo to the server.
  // The todo is a Todo object that is converted to a json string
  // before the call to the server using jsonEncode.
  /*
  static Future<String> addToDo(Todo todo) async {
    var url = Uri.parse(baseURL + '/todos?key=' + key);

    debugPrint('adding ${url.toString()}');
    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(todo),
    );
    return response.body;
  }
  */

  // This code is not in use
  static final Map<int, Image> _imageCache = HashMap();

  // pid är product id
  static Future<Image?> fetchImage(int pid) async {
    try {
      final response = await http.get(
        Uri.parse('${baseURL}image/$pid'),
        headers: apiKeyHeader,
      );
      if (response.statusCode == 200) {
        final image = Image.memory(response.bodyBytes);
        return image;
      } else {
        dbugPrint('Fel vid bildhämtning: ${response.statusCode}');
      }
    } catch (e) {
      dbugPrint('Fel vid bildhämtning: $e');
    }
    return null;
  }

  // Cacha bilder
  //static final Map<int, Image> _imageCache = HashMap();

  // pid är product id
  static Future<Image?> fetchAndCacheImage(int pid) async {
    // Returnera från cache om den redan finns
    if (_imageCache.containsKey(pid)) {
      return _imageCache[pid];
    }

    try {
      final response = await http.get(
        Uri.parse('${baseURL}image/$pid'),
        headers: apiKeyHeader,
      );
      if (response.statusCode == 200) {
        final image = Image.memory(response.bodyBytes);
        _imageCache[pid] = image;
        return image;
      } else {
        dbugPrint('Fel vid bildhämtning: ${response.statusCode}');
      }
    } catch (e) {
      dbugPrint('Fel vid bildhämtning: $e');
    }

    return null;
  }

  /*
  static Image? getCachedImage(String url) {
    dbugPrint('getCachedImage $url');
    return _imageCache[url];
  }
  */
}
