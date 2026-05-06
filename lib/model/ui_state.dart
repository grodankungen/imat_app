import 'package:flutter/foundation.dart';
import 'package:imat_app/util/categories.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// UI-only state: selected category, search query, cart panel visibility,
/// favorites filter mode. Persisted with shared_preferences (replaces the
/// localStorage usage in the original web design).
class UiState extends ChangeNotifier {
  static const _kCategoryIndex = 'ui.categoryIndex';

  CategoryGroup _selectedCategory = allProducts;
  String _searchQuery = '';
  bool _cartOpen = true;
  bool _showFavorites = false;

  CategoryGroup get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  bool get cartOpen => _cartOpen;
  bool get showFavorites => _showFavorites;

  UiState() {
    _restore();
  }

  Future<void> _restore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final idx = prefs.getInt(_kCategoryIndex);
      if (idx != null && idx >= 0 && idx < categoryGroups.length) {
        _selectedCategory = categoryGroups[idx];
        notifyListeners();
      }
    } catch (_) {
      // shared_preferences not initialized in some test envs - ignore.
    }
  }

  Future<void> _persistCategory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(
        _kCategoryIndex,
        categoryGroups.indexOf(_selectedCategory),
      );
    } catch (_) {}
  }

  void selectCategory(CategoryGroup group) {
    _selectedCategory = group;
    _showFavorites = false;
    _persistCategory();
    notifyListeners();
  }

  void setSearch(String q) {
    _searchQuery = q;
    notifyListeners();
  }

  void toggleCart() {
    _cartOpen = !_cartOpen;
    notifyListeners();
  }

  void closeCart() {
    if (!_cartOpen) return;
    _cartOpen = false;
    notifyListeners();
  }

  void openCart() {
    if (_cartOpen) return;
    _cartOpen = true;
    notifyListeners();
  }

  void toggleFavoritesFilter() {
    _showFavorites = !_showFavorites;
    notifyListeners();
  }
}
