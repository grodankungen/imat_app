import 'package:flutter/material.dart';
import 'package:imat_app/app_theme.dart';
import 'package:imat_app/model/imat/product.dart';
import 'package:imat_app/model/imat/shopping_item.dart';
import 'package:imat_app/model/imat_data_handler.dart';
import 'package:imat_app/util/categories.dart';
import 'package:provider/provider.dart';

/// Card for a single product. Tapping the card opens the detail modal via
/// [onOpenDetail]; the action buttons stop propagation so they only fire
/// their own handlers.
class ProductCard extends StatefulWidget {
  final Product product;
  final void Function(Product) onOpenDetail;
  final void Function(Offset origin, Product product) onFlyToCart;
  final void Function(Offset origin, Product product) onFlyToFavorites;

  const ProductCard({
    super.key,
    required this.product,
    required this.onOpenDetail,
    required this.onFlyToCart,
    required this.onFlyToFavorites,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _hovering = false;

  String _categoryLabel(Product p) {
    for (final g in categoryGroups) {
      if (g.contains(p.category)) return g.label;
    }
    return 'Övrigt';
  }

  ShoppingItem? _itemInCart(ImatDataHandler iMat) {
    for (final i in iMat.getShoppingCart().items) {
      if (i.product.productId == widget.product.productId) return i;
    }
    return null;
  }

  Offset _centerOf(BuildContext c) {
    final box = c.findRenderObject() as RenderBox?;
    if (box == null) return Offset.zero;
    final pos = box.localToGlobal(Offset.zero);
    return pos + Offset(box.size.width / 2, box.size.height / 2);
  }

  @override
  Widget build(BuildContext context) {
    final iMat = context.watch<ImatDataHandler>();
    final p = widget.product;
    final isFav = iMat.isFavorite(p);
    final cartItem = _itemInCart(iMat);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedScale(
        scale: _hovering ? 1.02 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppTheme.border),
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: _hovering ? 0.10 : 0.05),
                blurRadius: _hovering ? 6 : 2,
                offset: Offset(0, _hovering ? 4 : 1),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => widget.onOpenDetail(p),
                splashColor: AppTheme.primarySurface,
                highlightColor: AppTheme.primarySurface,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: iMat.getImage(p),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: AppTheme.fontSizeMd,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _categoryLabel(p),
                            style: const TextStyle(
                              fontSize: AppTheme.fontSizeSm,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: AppTheme.paddingSmall),
                          Text(
                            '${p.price.toStringAsFixed(2)} ${p.unit}',
                            style: const TextStyle(
                              fontSize: AppTheme.fontSizeXl,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primary,
                            ),
                          ),
                          const SizedBox(height: AppTheme.paddingMediumSmall),
                          Row(
                            children: [
                              _FavoriteButton(
                                isFavorite: isFav,
                                onTap: (ctx) {
                                  final origin = _centerOf(ctx);
                                  iMat.toggleFavorite(p);
                                  if (!isFav) {
                                    widget.onFlyToFavorites(origin, p);
                                  }
                                },
                              ),
                              const SizedBox(width: AppTheme.paddingSmall),
                              Expanded(
                                child: cartItem == null
                                    ? _AddToCartButton(
                                        onTap: (ctx) {
                                          final origin = _centerOf(ctx);
                                          iMat.shoppingCartAdd(
                                            ShoppingItem(p, amount: 1),
                                          );
                                          widget.onFlyToCart(origin, p);
                                        },
                                      )
                                    : _QuantityControl(
                                        item: cartItem,
                                        iMat: iMat,
                                      ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  final bool isFavorite;
  final void Function(BuildContext) onTap;

  const _FavoriteButton({required this.isFavorite, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = isFavorite ? AppTheme.favorite : AppTheme.textSecondary;
    final border = isFavorite ? AppTheme.favorite : AppTheme.border;
    final bg = isFavorite ? AppTheme.favoriteSurface : Colors.transparent;
    return Builder(
      builder: (ctx) => Material(
        color: bg,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          onTap: () => onTap(ctx),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: border, width: 2),
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            ),
            child: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              size: 18,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}

class _AddToCartButton extends StatelessWidget {
  final void Function(BuildContext) onTap;
  const _AddToCartButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (ctx) => Material(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          onTap: () => onTap(ctx),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_cart, size: 18, color: Colors.white),
                SizedBox(width: AppTheme.paddingSmall),
                Text(
                  'Lägg till',
                  style: TextStyle(
                    fontSize: AppTheme.fontSizeSm,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuantityControl extends StatelessWidget {
  final ShoppingItem item;
  final ImatDataHandler iMat;
  const _QuantityControl({required this.item, required this.iMat});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border.all(color: AppTheme.border, width: 2),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _QtyBtn(
            icon: '-',
            onTap: () => iMat.shoppingCartUpdate(item, delta: -1),
          ),
          Text(
            item.amount.toStringAsFixed(0),
            style: const TextStyle(
              fontSize: AppTheme.fontSizeSm,
              fontWeight: FontWeight.w500,
            ),
          ),
          _QtyBtn(
            icon: '+',
            onTap: () => iMat.shoppingCartUpdate(item, delta: 1),
          ),
        ],
      ),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final String icon;
  final VoidCallback onTap;
  const _QtyBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.primary,
      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Text(
            icon,
            style: const TextStyle(
              fontSize: AppTheme.fontSize2xl,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
