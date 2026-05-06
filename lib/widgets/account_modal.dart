import 'package:flutter/material.dart';
import 'package:imat_app/app_theme.dart';
import 'package:imat_app/model/account_data.dart';
import 'package:imat_app/model/imat_data_handler.dart';
import 'package:imat_app/widgets/address_form_modal.dart';
import 'package:imat_app/widgets/card_form_modal.dart';
import 'package:provider/provider.dart';

Future<void> showAccountModal(BuildContext context) {
  return showDialog(
    context: context,
    barrierColor: Colors.black54,
    builder: (_) => const _AccountModal(),
  );
}

class _AccountModal extends StatelessWidget {
  const _AccountModal();

  @override
  Widget build(BuildContext context) {
    final iMat = context.watch<ImatDataHandler>();
    final email = iMat.getCustomer().email.isEmpty
        ? 'anna.andersson@email.se'
        : iMat.getCustomer().email;

    final addresses = AccountData.addresses(iMat);
    final defAddr = AccountData.defaultAddressIndex(iMat);
    final cards = AccountData.cards(iMat);
    final defCard = AccountData.defaultCardIndex(iMat);

    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.all(AppTheme.paddingHuge),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 720,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTheme.paddingLarge,
                AppTheme.paddingLarge,
                AppTheme.paddingLarge,
                AppTheme.paddingMedium,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Kontouppgifter',
                          style: TextStyle(
                            fontSize: AppTheme.fontSize5xl,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email,
                          style: const TextStyle(
                            fontSize: AppTheme.fontSizeSm,
                            color: AppTheme.gray500,
                          ),
                        ),
                      ],
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
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.all(AppTheme.paddingLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _SectionHeader(
                      icon: Icons.location_on_outlined,
                      title: 'Leveransadresser',
                    ),
                    const SizedBox(height: AppTheme.paddingMediumSmall),
                    if (addresses.isEmpty)
                      _EmptyHint(
                        text:
                            'Du har inga sparade adresser ännu.',
                      ),
                    for (int i = 0; i < addresses.length; i++) ...[
                      _AddressTile(
                        address: addresses[i],
                        isDefault: i == defAddr,
                        onTap: () =>
                            AccountData.setDefaultAddress(iMat, i),
                        onEdit: () async {
                          final updated = await showAddressFormModal(
                            context,
                            existing: addresses[i],
                          );
                          if (updated != null) {
                            AccountData.updateAddress(iMat, i, updated);
                          }
                        },
                        onDelete: () => _confirmDelete(
                          context,
                          'Ta bort adress?',
                          () => AccountData.removeAddress(iMat, i),
                        ),
                      ),
                      const SizedBox(height: AppTheme.paddingMediumSmall),
                    ],
                    _AddDashedButton(
                      icon: Icons.add,
                      label: 'Lägg till ny adress',
                      onTap: () async {
                        final addr =
                            await showAddressFormModal(context);
                        if (addr != null) {
                          AccountData.addAddress(iMat, addr);
                        }
                      },
                    ),
                    const SizedBox(height: AppTheme.paddingHuge),
                    _SectionHeader(
                      icon: Icons.credit_card,
                      title: 'Betalmetoder',
                    ),
                    const SizedBox(height: AppTheme.paddingMediumSmall),
                    if (cards.isEmpty)
                      _EmptyHint(
                        text: 'Du har inga sparade kort ännu.',
                      ),
                    for (int i = 0; i < cards.length; i++) ...[
                      _CardTile(
                        card: cards[i],
                        isDefault: i == defCard,
                        onTap: () =>
                            AccountData.setDefaultCard(iMat, i),
                        onEdit: () async {
                          final updated = await showCardFormModal(
                            context,
                            existing: cards[i],
                          );
                          if (updated != null) {
                            AccountData.updateCard(iMat, i, updated);
                          }
                        },
                        onDelete: () => _confirmDelete(
                          context,
                          'Ta bort kort?',
                          () => AccountData.removeCard(iMat, i),
                        ),
                      ),
                      const SizedBox(height: AppTheme.paddingMediumSmall),
                    ],
                    _AddDashedButton(
                      icon: Icons.add,
                      label: 'Lägg till nytt kort',
                      onTap: () async {
                        final c = await showCardFormModal(context);
                        if (c != null) {
                          AccountData.addCard(iMat, c);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    String title,
    VoidCallback onConfirm,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        ),
        title: Text(title),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Avbryt'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.red600),
            child: const Text('Ta bort'),
          ),
        ],
      ),
    );
    if (ok == true) onConfirm();
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 22, color: AppTheme.gray900),
        const SizedBox(width: AppTheme.paddingSmall),
        Text(
          title,
          style: const TextStyle(
            fontSize: AppTheme.fontSize3xl,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _EmptyHint extends StatelessWidget {
  final String text;
  const _EmptyHint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.paddingSmall),
      child: Text(
        text,
        style: const TextStyle(color: AppTheme.gray500, fontSize: AppTheme.fontSizeXs2),
      ),
    );
  }
}

class _StandardBadge extends StatelessWidget {
  const _StandardBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.green50,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, size: 12, color: AppTheme.green700),
          SizedBox(width: 4),
          Text(
            'Standard',
            style: TextStyle(
              fontSize: AppTheme.fontSizeXxs,
              fontWeight: FontWeight.w600,
              color: AppTheme.green700,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddressTile extends StatelessWidget {
  final SavedAddress address;
  final bool isDefault;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AddressTile({
    required this.address,
    required this.isDefault,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.gray50,
      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        onTap: onTap,
        onLongPress: onEdit,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.paddingMedium,
            vertical: AppTheme.paddingMedium,
          ),
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.gray200),
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          address.label,
                          style: const TextStyle(
                            fontSize: AppTheme.fontSizeMd,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (isDefault) ...[
                          const SizedBox(
                            width: AppTheme.paddingSmall,
                          ),
                          const _StandardBadge(),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      address.street,
                      style: const TextStyle(
                        fontSize: AppTheme.fontSizeSm,
                        color: AppTheme.gray700,
                      ),
                    ),
                    Text(
                      '${address.postCode} ${address.city}'.trim(),
                      style: const TextStyle(
                        fontSize: AppTheme.fontSizeSm,
                        color: AppTheme.gray700,
                      ),
                    ),
                    if (address.phone.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          address.phone,
                          style: const TextStyle(
                            fontSize: AppTheme.fontSizeXs2,
                            color: AppTheme.gray500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  color: AppTheme.red500,
                ),
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardTile extends StatelessWidget {
  final SavedCard card;
  final bool isDefault;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CardTile({
    required this.card,
    required this.isDefault,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.gray50,
      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        onTap: onTap,
        onLongPress: onEdit,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.paddingMedium,
            vertical: AppTheme.paddingMedium,
          ),
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.gray200),
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.credit_card,
                size: 22,
                color: AppTheme.gray700,
              ),
              const SizedBox(width: AppTheme.paddingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '•••• ${card.last4}',
                          style: const TextStyle(
                            fontSize: AppTheme.fontSizeMd,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                          ),
                        ),
                        if (isDefault) ...[
                          const SizedBox(
                            width: AppTheme.paddingSmall,
                          ),
                          const _StandardBadge(),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${card.holder.toUpperCase()}  •  ${card.expiry}',
                      style: const TextStyle(
                        fontSize: AppTheme.fontSizeXs,
                        color: AppTheme.gray600,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  color: AppTheme.red500,
                ),
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddDashedButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _AddDashedButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        onTap: onTap,
        child: DottedBorder(
          color: AppTheme.gray300,
          radius: AppTheme.radiusLg,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: AppTheme.gray700),
                const SizedBox(width: AppTheme.paddingSmall),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: AppTheme.fontSizeBase,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.gray700,
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

/// Lightweight dashed border widget (avoids extra dependency).
class DottedBorder extends StatelessWidget {
  final Widget child;
  final Color color;
  final double radius;
  const DottedBorder({
    super.key,
    required this.child,
    required this.color,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DottedRectPainter(color: color, radius: radius),
      child: child,
    );
  }
}

class _DottedRectPainter extends CustomPainter {
  final Color color;
  final double radius;
  _DottedRectPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);

    const dashLen = 6.0;
    const gapLen = 4.0;
    for (final metric in path.computeMetrics()) {
      double dist = 0;
      while (dist < metric.length) {
        final next = (dist + dashLen).clamp(0, metric.length).toDouble();
        canvas.drawPath(metric.extractPath(dist, next), paint);
        dist = next + gapLen;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DottedRectPainter old) =>
      old.color != color || old.radius != radius;
}
