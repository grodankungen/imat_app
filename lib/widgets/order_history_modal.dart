import 'package:flutter/material.dart';
import 'package:imat_app/app_theme.dart';
import 'package:imat_app/model/account_data.dart';
import 'package:imat_app/model/imat/order.dart';
import 'package:imat_app/model/imat/shopping_item.dart';
import 'package:imat_app/model/imat_data_handler.dart';
import 'package:provider/provider.dart';

Future<void> showOrderHistoryModal(BuildContext context) {
  return showDialog(
    context: context,
    barrierColor: Colors.black54,
    builder: (_) => const _OrderHistoryModal(),
  );
}

class _OrderHistoryModal extends StatelessWidget {
  const _OrderHistoryModal();

  @override
  Widget build(BuildContext context) {
    final iMat = context.watch<ImatDataHandler>();
    final orders = [...iMat.orders]
      ..sort((a, b) => b.date.compareTo(a.date));

    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.all(AppTheme.paddingHuge),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 760,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(AppTheme.paddingLarge),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Orderhistorik',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 24),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppTheme.gray200),
            // Body
            Flexible(
              child: orders.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(AppTheme.paddingHuge),
                      child: Text(
                        'Du har inga tidigare beställningar.',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppTheme.gray500,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(
                        AppTheme.paddingLarge,
                      ),
                      itemCount: orders.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppTheme.paddingMedium),
                      itemBuilder: (_, i) =>
                          _OrderCard(order: orders[i], iMat: iMat),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  final ImatDataHandler iMat;

  const _OrderCard({required this.order, required this.iMat});

  String _fmt(DateTime d) {
    const mn = [
      'jan',
      'feb',
      'mar',
      'apr',
      'maj',
      'jun',
      'jul',
      'aug',
      'sep',
      'okt',
      'nov',
      'dec',
    ];
    final time =
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    return '${d.day} ${mn[d.month - 1]} ${d.year} $time';
  }

  @override
  Widget build(BuildContext context) {
    final meta = AccountData.orderMeta(iMat, order.orderNumber);
    final deliveryLabel =
        deliveryLabels[meta?.delivery ?? 'home'] ?? 'Hemleverans';
    final paymentLabel =
        paymentLabels[meta?.payment ?? 'card'] ?? 'Bankkort';

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.gray50,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header row
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppTheme.paddingMedium,
              AppTheme.paddingMedium,
              AppTheme.paddingMedium,
              AppTheme.paddingSmall,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #${order.orderNumber}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _fmt(order.date),
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.gray600,
                        ),
                      ),
                      Text(
                        '$deliveryLabel  •  $paymentLabel',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.gray500,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${order.getTotal().toStringAsFixed(2)} kr',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.green700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.green600,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusLg),
                        ),
                      ),
                      icon: const Icon(
                        Icons.shopping_cart_outlined,
                        size: 18,
                      ),
                      label: const Text(
                        'Beställ igen',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: () {
                        for (final item in order.items) {
                          iMat.shoppingCartAdd(
                            ShoppingItem(
                              item.product,
                              amount: item.amount,
                            ),
                          );
                        }
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('Produkterna lades i kundvagnen'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Items
          for (int i = 0; i < order.items.length; i++) ...[
            if (i == 0)
              const Divider(height: 1, color: AppTheme.gray200),
            _OrderItemRow(item: order.items[i], iMat: iMat),
            if (i < order.items.length - 1)
              const Divider(height: 1, color: AppTheme.gray200),
          ],
        ],
      ),
    );
  }
}

class _OrderItemRow extends StatelessWidget {
  final ShoppingItem item;
  final ImatDataHandler iMat;

  const _OrderItemRow({required this.item, required this.iMat});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.paddingMedium,
        vertical: AppTheme.paddingMediumSmall,
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            child: SizedBox(
              width: 44,
              height: 44,
              child: iMat.getImage(item.product),
            ),
          ),
          const SizedBox(width: AppTheme.paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${item.amount.toStringAsFixed(0)} × ${item.product.price.toStringAsFixed(2)} kr',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.gray500,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${(item.product.price * item.amount).toStringAsFixed(2)} kr',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
