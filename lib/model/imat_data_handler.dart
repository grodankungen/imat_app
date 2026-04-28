import 'dart:collection';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:imat_app/model/imat/credit_card.dart';
import 'package:imat_app/model/imat/customer.dart';
import 'package:imat_app/model/imat/order.dart';
import 'package:imat_app/model/imat/product.dart';
import 'package:imat_app/model/imat/product_detail.dart';
import 'package:imat_app/model/imat/settings.dart';
import 'package:imat_app/model/imat/shopping_cart.dart';
import 'package:imat_app/model/imat/shopping_item.dart';
import 'package:imat_app/model/imat/user.dart';
import 'package:imat_app/model/internet_handler.dart';

class ImatDataHandler extends ChangeNotifier {
  // Initializes the IMatDataHandler
  ImatDataHandler() {
    _setUp();
  }

  // Never changing, only loaded on startup
  List<Product> get products => _products;

  List<ProductDetail> get details => _details;

  // Access a list of all previous orders
  List<Order> get orders => _orders;

  //
  // Handle product selections
  //

  // Returnernar de produkter som är valda
  List<Product> get selectProducts => _selectProducts;

  // Nollställer urvalet till alla produkter.
  // Anropar notifyListeners så att GUI:t får
  // veta att urvalet ändrats.
  void selectAllProducts() {
    _selectProducts.clear();
    _selectProducts.addAll(_products);
    notifyListeners();
  }

  // Välj alla favoritmarkerade produkter.
  // Detta sätter selectProducts till de produkter
  // som markerats som favoriter och informerar GUI:t
  // om att urvalet har ändrats
  void selectFavorites() {
    _selectProducts.clear();
    _selectProducts.addAll(favorites);
    notifyListeners();
  }

  // A list of products that has been produced somehow.
  // Sätter selectProducts till innehållet i listan selection.
  // Med denna metod kan man sätta urvalet till vad som helst.
  // Meddelar GUI:t att urvalet har ändrats
  void selectSelection(List<Product> selection) {
    _selectProducts.clear();
    _selectProducts.addAll(selection);
    notifyListeners();
  }

  // Returnerar alla produkter som hör till category.
  // Med denna och setSelection kan man sätta urvalet till en viss kategori.
  // Meddelar GUI:t att urvalet har ändrats.
  List<Product> findProductsByCategory(ProductCategory category) {
    return products.where((product) => product.category == category).toList();
  }

  // Returnerar en lista med alla produkter vars namn matchar search.
  // Sökningen görs utan hänsyn till case och var i strängen search finns.
  // T ex så hittar "me" både Clementin och Lime.
  List<Product> findProducts(String search) {
    final lowerSearch = search.toLowerCase();

    return products.where((product) {
      final name = product.name.toLowerCase();
      return name.contains(lowerSearch);
    }).toList();
  }

  // Returnerar produkten med productId idNbr eller null
  // om produkten inte finns med i sortimentet.
  Product? getProduct(int idNbr) {
    for (final product in _products) {
      if (product.productId == idNbr) {
        return product;
      }
    }
    return null;
  }

  //
  // Manage favorites
  //

  // Returnerar en lista med alla favoritmarkerade produkter.
  List<Product> get favorites => _favorites.values.toList();

  // Returnerar om product är markerad som favorit.
  bool isFavorite(Product product) {
    return _favorites[product.productId] != null;
  }

  // 'Togglar' om product är favorit eller inte.
  // Dvs om produkten är favorit tas den bort annars läggs
  // läggs den till.
  // Meddelar GUI:t att data har ändrats och uppdaterar på servern
  void toggleFavorite(Product product) {
    var pid = product.productId;

    if (_favorites.containsKey(pid)) {
      _favorites.remove(pid);
      _removeFavorite(product);
    } else {
      _favorites[pid] = product;
      _addFavorite(product);
    }
  }

  CreditCard getCreditCard() => _creditCard;

  // Sparar information till servern och
  // meddelar gränssnittet att data ändrats
  void setCreditCard(CreditCard card) async {
    _creditCard.cardType = card.cardType;
    _creditCard.holdersName = card.holdersName;
    _creditCard.validMonth = card.validMonth;
    _creditCard.validYear = card.validYear;
    _creditCard.cardNumber = card.cardNumber;
    _creditCard.verificationCode = card.verificationCode;

    String _ = await InternetHandler.setCreditCard(_creditCard);
    notifyListeners();
  }

  Customer getCustomer() => _customer;

  // Sparar information till servern och
  // meddelar gränssnittet att data ändrats
  void setCustomer(Customer customer) async {
    _customer.firstName = customer.firstName;
    _customer.lastName = customer.lastName;
    _customer.phoneNumber = customer.phoneNumber;
    _customer.mobilePhoneNumber = customer.mobilePhoneNumber;
    _customer.email = customer.email;
    _customer.address = customer.address;
    _customer.postCode = customer.postCode;
    _customer.postAddress = customer.postAddress;

    String _ = await InternetHandler.setCustomer(_customer);
    notifyListeners();
  }

  // Sparar information till servern och
  // meddelar gränssnittet att data ändrats
  User getUser() => _user;

  void setUser(User user) async {
    _user.userName = user.userName;
    _user.password = user.password;

    String _ = await InternetHandler.setUser(_user);
    notifyListeners();
  }

  // Returnerar ProductDetail för produkten p
  // eller null om information saknas
  ProductDetail? getDetail(Product p) {
    return getDetailWithId(p.productId);
  }

  // Returnerar ProductDetail för produkten p
  // med idNbr eller null om information saknas
  ProductDetail? getDetailWithId(int idNbr) {
    for (ProductDetail d in _details) {
      if (d.productId == idNbr) {
        return d;
      }
    }
    return null;
  }

  // Returnerar en Map med strängar som nycklar och
  // något som kan uttryckas med json som värde.
  Map<String, dynamic> getExtras() {
    return _extras;
  }

  // Lägg till ett nytt värde för nyckeln key.
  // Om key redan finns så ersätts dess värde med jsonData.
  // jsonData ska vara en bastyp, en lista eller en map.
  // Sparar data till servern och meddelar GUI:t att data ändrats
  void addExtra(String key, dynamic jsonData) {
    _extras[key] = jsonData;
    setExtras(_extras);
  }

  // Tar bort key från extras.
  // Sparar data till servern och meddelar GUI:t att data ändrats.
  void removeExtra(String key) {
    _extras.remove(key);
    setExtras(_extras);
  }

  // Sparar extras till servern och meddelar GUI:t att data ändrats.
  // Om man ändrar mapen som returneras från getExtras direkt så
  // måste denna metod anropas för att data ska sparas och GUI:t uppdateras
  // annars behöver man inte använda den.
  void setExtras(Map<String, dynamic> extras) async {
    await InternetHandler.setExtras(extras);
    notifyListeners();
  }

  // Returnerar bilden som hör till produkten p.
  // Om bilden inte finns cachad returneras en tillfällig bild.
  // När bilden har hämtats meddelas gränssnittet och bilden visas
  // automatiskt om getImage använts i ett sammanhang som använder watch.
  // getImage använder getImageData med Boxfit.cover.
  Image getImage(Product p) {
    String url = InternetHandler.getImageUrl(p.productId);

    Image? image = _getImage(url);

    bool imageFound = image != null;

    return imageFound ? image : Image.asset('assets/images/placeholder.png');
  }

  // Can be used to create desired images using
  // Image.memory
  // final bytes = getImageData(product);
  // if (bytes != null)
  // Image img = Image.memory(bytes + other parameters)

  // Returnerar bild-data tillhörande produktbilden för p.
  // Om bilden inte är cachad returneras null.
  // När bilden har hämtats uppdateras resultatet precis som
  // för getImage. Man behöver själv hantera null. T ex något i stil med
  // var data = getImageData(p);
  // Widget image = data ?? Image.memory(data) : CircularSpinner();
  // När man använder Image.memory kan man ange ett flertal parametrar
  // t ex storlek. Kolla dokumentationen för Image.
  Uint8List? getImageData(Product p) {
    String url = InternetHandler.getImageUrl(p.productId);

    return _getImageData(url);
  }

  // Returnerar kundvagnen. Så längt det är möjligt är det att
  // fördedra att ändra kundvagnen med metoderna nedan.
  // Om man gör något annat behöver man anropa setShoppingCart för
  // att ändringarna ska sparas.
  ShoppingCart getShoppingCart() => _shoppingCart;

  // Lägger till item i kundvagnen. Om den produkt som ingår i item redan finns
  // i kundvagnen så ökas mängden på det som fanns redan.
  // Uppdaterar till servern och meddelar GUI:t att kundvagnen ändrats.
  void shoppingCartAdd(ShoppingItem item) {
    //print('Adding ${item.product.name}');
    _shoppingCart.addItem(item);

    // Update and notify listeners
    setShoppingCart();
  }

  // Uppdaterar mängden som finns av item med delta.
  // Ett positiv värde ökar mängden och ett negativ minskar.
  // Om värdet blir <= 0 så tas item bort ur kundvagnen.
  // Uppdaterar till servern och meddelar GUI:t att kundvagnen ändrats.
  void shoppingCartUpdate(ShoppingItem item, {double delta = 0.0}) {
    //print('Adding ${item.product.name}');
    _shoppingCart.updateItem(item, delta: delta);

    // Update and notify listeners
    setShoppingCart();
  }

  // Tar bort item från kundvagnen.
  // Uppdaterar till servern och meddelar GUI:t att kundvagnen ändrats.
  void shoppingCartRemove(ShoppingItem item) {
    //print('Removing ${item.product.name}');
    _shoppingCart.removeItem(item);

    // Update and notify listeners
    setShoppingCart();
  }

  // Tömmer kundvagnen.
  // Uppdaterar på servern och meddelar GUI:t.
  void shoppingCartClear() {
    _shoppingCart.clear();

    // Update and notify listeners
    setShoppingCart();
  }

  double shoppingCartTotal() {
    double total = 0;

    for (final item in _shoppingCart.items) {
      total = total + item.amount * item.product.price;
    }
    return total;
  }

  // Uppdaterar kundvagnen på servern och
  // meddelar GUI:t att kundvagnen ändrats.
  void setShoppingCart() async {
    await InternetHandler.setShoppingCart(_shoppingCart);
    notifyListeners();
  }

  void placeOrder() async {
    await InternetHandler.placeOrder();
    _shoppingCart.clear();
    notifyListeners();

    // Reload orders
    var response = await InternetHandler.getOrders();

    //print('Orders $response');
    var jsonData = jsonDecode(response) as List;

    _orders.clear();
    _orders.addAll(jsonData.map((item) => Order.fromJson(item)).toList());
    notifyListeners();
  }

  void reset() async {
    await InternetHandler.reset();

    // Clearing favorites
    _favorites.clear();

    // Fetching CreditCard, Customer & User
    var response = await InternetHandler.getCreditCard();
    var singleJson = jsonDecode(response);
    _creditCard = CreditCard.fromJson(singleJson);

    response = await InternetHandler.getCustomer();
    singleJson = jsonDecode(response);
    _customer = Customer.fromJson(singleJson);

    response = await InternetHandler.getUser();
    singleJson = jsonDecode(response);
    _user = User.fromJson(singleJson);

    // Remove orders
    _orders.clear();

    response = await InternetHandler.getShoppingCart();

    //print('Cart $response');
    singleJson = jsonDecode(response);
    _shoppingCart = ShoppingCart.fromJson(singleJson);

    response = await InternetHandler.getExtras();
    _extras = jsonDecode(response);

    notifyListeners();
  }

  ///
  // Code below this line is private and can be disregarded
  ///
  void _addFavorite(Product p) async {
    String _ = await InternetHandler.addFavorite(p.productId);

    notifyListeners();
  }

  void _removeFavorite(Product p) async {
    String _ = await InternetHandler.removeFavorite(p.productId);

    notifyListeners();
  }

  final List<Product> _products = [];

  final List<Product> _selectProducts = [];

  final List<ProductDetail> _details = [];

  final Map<int, Product> _favorites = {};

  User _user = User('', '');

  Customer _customer = Customer('', '', '', '', '', '', '', '');

  CreditCard _creditCard = CreditCard('', '', 12, 25, '', 0);

  ShoppingCart _shoppingCart = ShoppingCart([]);

  final List<Order> _orders = [];

  Map<String, dynamic> _extras = {};

  //final Map<int, Image> _imageCache = HashMap();

  /*
import 'dart:collection';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
*/

  //class ImageCacheProvider extends ChangeNotifier {
  /* import 'dart:collection';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
*/

  //class ImageCacheProvider extends ChangeNotifier {
  final Map<String, Uint8List> _imageData = {};
  final Set<String> _loadingUrls = {};
  final Queue<String> _queue = Queue();

  final int maxConcurrentRequests = 5;
  int _currentRequests = 0;

  //ImageCacheProvider({this.maxConcurrentRequests = 5});

  /// Students can use this to get raw image bytes
  Uint8List? _getImageData(String url) {
    _triggerLoadIfNeeded(url);
    return _imageData[url];
  }

  /// Students can use this to get an Image widget
  Image? _getImage(String url, {BoxFit fit = BoxFit.cover}) {
    final bytes = _getImageData(url);
    if (bytes != null) {
      return Image.memory(bytes, fit: fit);
    }
    return null;
  }

  void _triggerLoadIfNeeded(String url) {
    if (_imageData.containsKey(url) ||
        _loadingUrls.contains(url) ||
        _queue.contains(url)) {
      return;
    }

    _queue.add(url);
    _tryNext();
  }

  void _tryNext() {
    if (_currentRequests >= maxConcurrentRequests || _queue.isEmpty) return;

    final url = _queue.removeFirst();
    _loadingUrls.add(url);
    _currentRequests++;

    _fetch(url).whenComplete(() {
      _loadingUrls.remove(url);
      _currentRequests--;
      _tryNext();
    });
  }

  Future<void> _fetch(String url) async {
    //print(url);
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: InternetHandler.apiKeyHeader,
      );
      if (response.statusCode == 200) {
        _imageData[url] = response.bodyBytes;
        notifyListeners(); // So UI rebuilds if needed
      } else {
        debugPrint('Failed to load image $url: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching $url: $e');
    }
  }

  /*
  // Not working, there's no corresponding endpoint
  void setFavorites() async {
    String _ = await InternetHandler.setFavorites(favorites);
    notifyListeners();
  }
  */

  void _setUp() async {
    InternetHandler.kGroupId = Settings.groupId;

    // Fetching all products
    var response = await InternetHandler.getProducts();

    //print(response);
    List<dynamic> jsonData = jsonDecode(response);

    _products.clear();
    _products.addAll(jsonData.map((item) => Product.fromJson(item)).toList());

    _selectProducts.clear();
    _selectProducts.addAll(_products);

    // Fetching product details
    response = await InternetHandler.getDetails();
    jsonData = jsonDecode(response);

    _details.clear();
    _details.addAll(
      jsonData.map((item) => ProductDetail.fromJson(item)).toList(),
    );

    // Fetching favorites
    response = await InternetHandler.getFavorites();
    jsonData = jsonDecode(response);

    var favList = jsonData.map((item) => Product.fromJson(item)).toList();
    for (final product in favList) {
      _favorites[product.productId] = product;
    }

    notifyListeners();

    // Fetching CreditCard, Customer & User
    response = await InternetHandler.getCreditCard();
    var singleJson = jsonDecode(response);
    _creditCard = CreditCard.fromJson(singleJson);

    response = await InternetHandler.getCustomer();
    singleJson = jsonDecode(response);
    _customer = Customer.fromJson(singleJson);

    response = await InternetHandler.getUser();
    singleJson = jsonDecode(response);
    _user = User.fromJson(singleJson);

    //print('User ${singleJson}');

    response = await InternetHandler.getOrders();
    singleJson = jsonDecode(response);

    jsonData = jsonDecode(response);

    _orders.clear();
    _orders.addAll(jsonData.map((item) => Order.fromJson(item)).toList());

    response = await InternetHandler.getShoppingCart();

    //print('Cart $response');
    singleJson = jsonDecode(response);
    _shoppingCart = ShoppingCart.fromJson(singleJson);

    response = await InternetHandler.getExtras();
    _extras = jsonDecode(response);

    /* Testcode

    print('New extras $_extras');
    _extras['Brand'] = 'Findus';

    var _ = await InternetHandler.setExtras(_extras);

    response = await InternetHandler.getExtras();
    _extras = jsonDecode(response);
    // Testcode

    print('Got ${_extras}');

     Testcode 
     */

    notifyListeners();
  }
}
