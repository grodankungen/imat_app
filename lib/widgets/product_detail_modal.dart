import 'package:flutter/material.dart';
import 'package:imat_app/app_theme.dart';
import 'package:imat_app/model/imat/product.dart';
import 'package:imat_app/model/imat/shopping_item.dart';
import 'package:imat_app/model/imat_data_handler.dart';
import 'package:imat_app/util/categories.dart';
import 'package:provider/provider.dart';

Future<void> showProductDetailModal(
  BuildContext context,
  Product product, {
  void Function(Offset origin)? onAddToCart,
}) {
  return showDialog(
    context: context,
    barrierColor: Colors.black12,
    builder: (ctx) => _ProductDetail(product: product, onAddToCart: onAddToCart),
  );
}

class _ProductDetail extends StatelessWidget {
  final Product product;
  final void Function(Offset origin)? onAddToCart;
  const _ProductDetail({required this.product, this.onAddToCart});

  String _categoryLabel(Product p) {
    for (final g in categoryGroups) {
      if (g.contains(p.category)) return g.label;
    }
    return 'Övrigt';
  }

  @override
  Widget build(BuildContext context) {
    final iMat = context.watch<ImatDataHandler>();
    final detail = iMat.getDetail(product);
    final isFav = iMat.isFavorite(product);

    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.all(AppTheme.paddingHuge),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 896,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(AppTheme.paddingLarge),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppTheme.gray200)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppTheme.paddingLarge),
                child: LayoutBuilder(
                  builder: (ctx, c) {
                    final wide = c.maxWidth > 640;
                    final left = ClipRRect(
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusLg),
                      child: SizedBox(
                        height: 384,
                        width: double.infinity,
                        child: iMat.getImage(product),
                      ),
                    );
                    final right = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _categoryLabel(product),
                          style: const TextStyle(
                            fontSize: 20,
                            color: AppTheme.gray600,
                          ),
                        ),
                        const SizedBox(height: AppTheme.paddingMedium),
                        Text(
                          '${product.price.toStringAsFixed(2)} ${product.unit}',
                          style: const TextStyle(
                            fontSize: 36,
                            color: AppTheme.green700,
                          ),
                        ),
                        const SizedBox(height: AppTheme.paddingLarge),
                        Text(
                          detail?.description.isNotEmpty == true
                              ? detail!.description
                              : 'Ingen beskrivning tillgänglig.',
                          style: const TextStyle(
                            fontSize: 18,
                            height: 1.625,
                          ),
                        ),
                        if (detail != null && detail.origin.isNotEmpty) ...[
                          const SizedBox(height: AppTheme.paddingMediumSmall),
                          Text(
                            'Ursprung: ${detail.origin}',
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppTheme.gray600,
                            ),
                          ),
                        ],
                        const SizedBox(height: AppTheme.paddingHuge),
                        _DetailFavButton(
                          isFavorite: isFav,
                          onTap: () => iMat.toggleFavorite(product),
                        ),
                        const SizedBox(height: AppTheme.paddingMediumSmall),
                        _DetailAddCartButton(
                          onTap: (origin) {
                            iMat.shoppingCartAdd(
                              ShoppingItem(product, amount: 1),
                            );
                            onAddToCart?.call(origin);
                          },
                        ),
                      ],
                    );

                    if (wide) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: left),
                          const SizedBox(width: AppTheme.paddingHuge),
                          Expanded(child: right),
                        ],
                      );
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        left,
                        const SizedBox(height: AppTheme.paddingLarge),
                        right,
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailFavButton extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback onTap;
  const _DetailFavButton({required this.isFavorite, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = isFavorite ? AppTheme.red600 : AppTheme.gray700;
    final border = isFavorite ? AppTheme.red500 : AppTheme.gray300;
    final bg = isFavorite ? AppTheme.red50 : Colors.transparent;
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          onTap: onTap,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: border, width: 2),
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  size: 24,
                  color: color,
                ),
                const SizedBox(width: AppTheme.paddingSmall),
                Text(
                  isFavorite ? 'I favoriter' : 'Lägg till favoriter',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: color,
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

class _DetailAddCartButton extends StatelessWidget {
  final void Function(Offset origin) onTap;
  const _DetailAddCartButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Builder(
        builder: (ctx) {
          Offset center() {
            final box = ctx.findRenderObject() as RenderBox?;
            if (box == null) return Offset.zero;
            final pos = box.localToGlobal(Offset.zero);
            return pos + Offset(box.size.width / 2, box.size.height / 2);
          }

          return Material(
            color: AppTheme.green600,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              onTap: () => onTap(center()),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_cart, size: 24, color: Colors.white),
                    SizedBox(width: AppTheme.paddingSmall),
                    Text(
                      'Lägg till i kundvagn',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
