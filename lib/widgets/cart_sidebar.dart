import 'package:flutter/material.dart';
import 'package:imat_app/app_theme.dart';
import 'package:imat_app/model/account_data.dart';
import 'package:imat_app/model/imat/shopping_item.dart';
import 'package:imat_app/model/imat_data_handler.dart';
import 'package:imat_app/model/ui_state.dart';
import 'package:imat_app/pages/checkout_page.dart';
import 'package:imat_app/pages/login_page.dart';
import 'package:imat_app/widgets/clear_cart_modal.dart';
import 'package:provider/provider.dart';

class CartSidebar extends StatelessWidget {
  const CartSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final iMat = context.watch<ImatDataHandler>();
    final items = iMat.getShoppingCart().items;
    final total = iMat.shoppingCartTotal();

    return Material(
      elevation: 8,
      color: Colors.white,
      child: Container(
        width: AppTheme.cartWidth,
        decoration: const BoxDecoration(
          border: Border(left: BorderSide(color: AppTheme.gray200)),
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(AppTheme.paddingMediumLarge),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Kundvagn',
                    style: TextStyle(
                      fontSize: AppTheme.fontSize4xl,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 24),
                    onPressed: () => context.read<UiState>().closeCart(),
                  ),
                ],
              ),
            ),
            // Items
            Expanded(
              child: items.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: Text(
                          'Din kundvagn är tom',
                          style: TextStyle(
                            color: AppTheme.gray500,
                            fontSize: AppTheme.fontSizeLg,
                          ),
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.paddingMediumLarge,
                      ),
                      itemCount: items.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppTheme.paddingMedium),
                      itemBuilder: (_, i) =>
                          _CartItemTile(item: items[i], iMat: iMat),
                    ),
            ),
            // Footer
            if (items.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(AppTheme.paddingMediumLarge),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: AppTheme.gray200)),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppTheme.paddingMedium,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Totalt:',
                            style: TextStyle(fontSize: AppTheme.fontSizeXl),
                          ),
                          Text(
                            '${total.toStringAsFixed(2)} kr',
                            style: const TextStyle(
                              fontSize: AppTheme.fontSizeXl,
                              color: AppTheme.green700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppTheme.paddingMediumSmall),
                    SizedBox(
                      width: double.infinity,
                      child: Material(
                        color: AppTheme.green600,
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusLg),
                        child: InkWell(
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusLg),
                          onTap: () {
                            final iMat = context.read<ImatDataHandler>();
                            if (AccountData.isLoggedIn(iMat)) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const CheckoutPage(),
                                ),
                              );
                            } else {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const LoginPage(),
                                ),
                              );
                            }
                          },
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: Text(
                                'Gå till kassan',
                                style: TextStyle(
                                  fontSize: AppTheme.fontSizeLg,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppTheme.paddingMediumSmall),
                    SizedBox(
                      width: double.infinity,
                      child: Material(
                        color: AppTheme.red50,
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusLg),
                        child: InkWell(
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusLg),
                          onTap: () => showClearCartModal(context),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.delete,
                                  size: 20,
                                  color: AppTheme.red600,
                                ),
                                SizedBox(width: AppTheme.paddingSmall),
                                Text(
                                  'Töm kundvagn',
                                  style: TextStyle(
                                    fontSize: AppTheme.fontSizeLg,
                                    color: AppTheme.red600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  final ShoppingItem item;
  final ImatDataHandler iMat;

  const _CartItemTile({required this.item, required this.iMat});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.paddingMediumSmall),
      decoration: BoxDecoration(
        color: AppTheme.gray50,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            child: SizedBox(
              width: 64,
              height: 64,
              child: iMat.getImage(item.product),
            ),
          ),
          const SizedBox(width: AppTheme.paddingMediumSmall),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: AppTheme.fontSizeLg,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${item.product.price.toStringAsFixed(2)} ${item.product.unit}',
                  style: const TextStyle(color: AppTheme.green700, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: AppTheme.paddingSmall),
                Row(
                  children: [
                    _SmallQtyBtn(
                      icon: '-',
                      onTap: () =>
                          iMat.shoppingCartUpdate(item, delta: -1),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(item.amount.toStringAsFixed(0)),
                    ),
                    _SmallQtyBtn(
                      icon: '+',
                      onTap: () =>
                          iMat.shoppingCartUpdate(item, delta: 1),
                    ),
                  ],
                ),
              ],
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            onTap: () => iMat.shoppingCartRemove(item),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.delete_outline, color: AppTheme.red500, size: 18),
                  SizedBox(width: 4),
                  Text(
                    'Ta bort',
                    style: TextStyle(
                      fontSize: AppTheme.fontSizeXs,
                      color: AppTheme.red500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallQtyBtn extends StatelessWidget {
  final String icon;
  final VoidCallback onTap;
  const _SmallQtyBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.gray200,
      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Text(
            icon,
            style: const TextStyle(fontSize: AppTheme.fontSizeBase, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
