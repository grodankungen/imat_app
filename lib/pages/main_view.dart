import 'package:flutter/material.dart';
import 'package:imat_app/app_theme.dart';
import 'package:imat_app/model/imat/product.dart';
import 'package:imat_app/model/imat_data_handler.dart';
import 'package:imat_app/model/ui_state.dart';
import 'package:imat_app/util/categories.dart';
import 'package:imat_app/widgets/cart_sidebar.dart';
import 'package:imat_app/widgets/category_sidebar.dart';
import 'package:imat_app/widgets/flying_product.dart';
import 'package:imat_app/widgets/header_bar.dart';
import 'package:imat_app/widgets/product_card.dart';
import 'package:imat_app/widgets/product_detail_modal.dart';
import 'package:provider/provider.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView>
    with SingleTickerProviderStateMixin {
  final GlobalKey _cartButtonKey = GlobalKey();
  final GlobalKey _favoritesButtonKey = GlobalKey();

  late final AnimationController _cartCtrl;
  late final Animation<Offset> _cartSlide;

  // Active flying product widgets, keyed by an incrementing id.
  final Map<int, Widget> _flying = {};
  int _flyingId = 0;

  @override
  void initState() {
    super.initState();
    _cartCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _cartSlide = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _cartCtrl, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _cartCtrl.dispose();
    super.dispose();
  }

  Offset _centerOfKey(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) return Offset.zero;
    final box = ctx.findRenderObject() as RenderBox?;
    if (box == null) return Offset.zero;
    final pos = box.localToGlobal(Offset.zero);
    return pos + Offset(box.size.width / 2, box.size.height / 2);
  }

  void _flyTo(Offset start, Offset end, Product product, ImatDataHandler iMat) {
    final id = _flyingId++;
    setState(() {
      _flying[id] = FlyingProduct(
        key: ValueKey(id),
        product: product,
        iMat: iMat,
        start: start,
        end: end,
        onCompleted: () {
          if (!mounted) return;
          setState(() => _flying.remove(id));
        },
      );
    });
  }

  List<Product> _filteredProducts(ImatDataHandler iMat, UiState ui) {
    Iterable<Product> base;
    if (ui.showFavorites) {
      base = iMat.favorites;
    } else if (ui.selectedCategory == allProducts) {
      base = iMat.products;
    } else {
      base = iMat.products
          .where((p) => ui.selectedCategory.contains(p.category));
    }
    final q = ui.searchQuery.trim().toLowerCase();
    if (q.isNotEmpty) {
      base = base.where((p) => p.name.toLowerCase().contains(q));
    }
    return base.toList();
  }

  String _heading(UiState ui) {
    if (ui.showFavorites) return 'Favoriter';
    return ui.selectedCategory.label;
  }

  @override
  Widget build(BuildContext context) {
    final iMat = context.watch<ImatDataHandler>();
    final ui = context.watch<UiState>();

    if (ui.cartOpen) {
      _cartCtrl.forward();
    } else {
      _cartCtrl.reverse();
    }

    final products = _filteredProducts(iMat, ui);

    return Scaffold(
      backgroundColor: AppTheme.gray50,
      body: Stack(
        children: [
          Column(
            children: [
              HeaderBar(
                cartButtonKey: _cartButtonKey,
                favoritesButtonKey: _favoritesButtonKey,
              ),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const CategorySidebar(),
                    Expanded(
                      child: AnimatedPadding(
                        duration: const Duration(milliseconds: 300),
                        padding: EdgeInsets.only(
                          right: ui.cartOpen ? AppTheme.cartWidth : 0,
                        ),
                        child: _ProductsArea(
                          heading: _heading(ui),
                          products: products,
                          onOpenDetail: (p) => showProductDetailModal(
                            context,
                            p,
                            onAddToCart: (origin) => _flyTo(
                              origin,
                              _centerOfKey(_cartButtonKey),
                              p,
                              iMat,
                            ),
                          ),
                          onFlyToCart: (origin, p) {
                            _flyTo(
                              origin,
                              _centerOfKey(_cartButtonKey),
                              p,
                              iMat,
                            );
                          },
                          onFlyToFavorites: (origin, p) {
                            _flyTo(
                              origin,
                              _centerOfKey(_favoritesButtonKey),
                              p,
                              iMat,
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Cart slide-in panel (positioned below header)
          Positioned(
            top: AppTheme.headerHeight,
            right: 0,
            bottom: 0,
            child: SlideTransition(
              position: _cartSlide,
              child: const CartSidebar(),
            ),
          ),
          // Flying product overlay
          ..._flying.values,
        ],
      ),
    );
  }
}

class _ProductsArea extends StatelessWidget {
  final String heading;
  final List<Product> products;
  final void Function(Product) onOpenDetail;
  final void Function(Offset, Product) onFlyToCart;
  final void Function(Offset, Product) onFlyToFavorites;

  const _ProductsArea({
    required this.heading,
    required this.products,
    required this.onOpenDetail,
    required this.onFlyToCart,
    required this.onFlyToFavorites,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.paddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: AppTheme.paddingMedium),
            child: Text(
              heading,
              style: const TextStyle(
                fontSize: AppTheme.fontSize6xl,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: products.isEmpty
                ? const Center(
                    child: Text(
                      'Inga produkter hittades',
                      style:
                          TextStyle(fontSize: AppTheme.fontSizeLg, color: AppTheme.gray500),
                    ),
                  )
                : LayoutBuilder(
                    builder: (ctx, c) {
                      int columns;
                      if (c.maxWidth >= 950) {
                        columns = 4;
                      } else if (c.maxWidth >= 620) {
                        columns = 3;
                      } else if (c.maxWidth >= 400) {
                        columns = 2;
                      } else {
                        columns = 1;
                      }
                      return GridView.builder(
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          crossAxisSpacing: AppTheme.paddingMedium,
                          mainAxisSpacing: AppTheme.paddingMedium,
                          mainAxisExtent: 290,
                        ),
                        itemCount: products.length,
                        itemBuilder: (_, i) => ProductCard(
                          product: products[i],
                          onOpenDetail: onOpenDetail,
                          onFlyToCart: onFlyToCart,
                          onFlyToFavorites: onFlyToFavorites,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}