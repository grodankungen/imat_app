import 'package:flutter/material.dart';
import 'package:imat_app/app_theme.dart';
import 'package:imat_app/model/account_data.dart';

// ── Sektionsrubrik (ikon + titel) ─────────────────────────────────────────────

class AccountSectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  const AccountSectionHeader({
    super.key,
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 22, color: AppTheme.black),
        const SizedBox(width: AppTheme.paddingSmall),
        Text(
          title,
          style: const TextStyle(
            fontSize: AppTheme.fontSizeXl,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ── "Standard"-badge ──────────────────────────────────────────────────────────

class AccountStandardBadge extends StatelessWidget {
  const AccountStandardBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.primarySurface,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, size: 11, color: AppTheme.primary),
          SizedBox(width: 3),
          Text(
            'Standard',
            style: TextStyle(
              fontSize: AppTheme.fontSizeXxs,
              fontWeight: FontWeight.w600,
              color: AppTheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tom-lista-hint ────────────────────────────────────────────────────────────

class AccountEmptyHint extends StatelessWidget {
  final String text;
  const AccountEmptyHint({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.paddingMediumSmall),
      child: Text(
        text,
        style: const TextStyle(
          color: AppTheme.textSecondary,
          fontSize: AppTheme.fontSizeBase,
        ),
      ),
    );
  }
}

// ── Bekräftelsedialog för borttagning ─────────────────────────────────────────

Future<void> accountConfirmDelete(
  BuildContext context,
  String title,
  VoidCallback onConfirm,
) async {
  final ok = await showDialog<bool>(
    context: context,
    builder:
        (ctx) => AlertDialog(
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
              style: TextButton.styleFrom(foregroundColor: AppTheme.favorite),
              child: const Text('Ta bort'),
            ),
          ],
        ),
  );
  if (ok == true) onConfirm();
}

// ── Adresstile ────────────────────────────────────────────────────────────────

class AccountAddressTile extends StatelessWidget {
  final SavedAddress address;
  final bool isDefault;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AccountAddressTile({
    super.key,
    required this.address,
    required this.isDefault,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDefault ? AppTheme.primarySurface : AppTheme.surface,
      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.paddingMedium,
            vertical: AppTheme.paddingMedium,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              color: isDefault ? AppTheme.primary : AppTheme.border,
              width: isDefault ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Adressinfo
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          address.label,
                          style: const TextStyle(
                            fontSize: AppTheme.fontSizeBase,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (isDefault) ...[
                          const SizedBox(width: AppTheme.paddingSmall),
                          const AccountStandardBadge(),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      address.street,
                      style: const TextStyle(
                        fontSize: AppTheme.fontSizeBase,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      '${address.postCode} ${address.city}'.trim(),
                      style: const TextStyle(
                        fontSize: AppTheme.fontSizeBase,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    if (address.phone.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          address.phone,
                          style: const TextStyle(
                            fontSize: AppTheme.fontSizeBase,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Ändra-knapp + Ta bort-knapp på rad
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton.icon(
                    onPressed: onEdit,
                    label: const Text(
                      'Ändra',
                      style: TextStyle(
                        fontSize: AppTheme.fontSizeBase,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    icon: const Icon(Icons.edit_outlined, size: 16),
                  ),
                  const SizedBox(width: 4),
                  ElevatedButton.icon(
                    onPressed: onDelete,
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.favorite,
                    ),
                    label: const Text(
                      'Ta bort',
                      style: TextStyle(
                        fontSize: AppTheme.fontSizeBase,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    icon: const Icon(Icons.delete_outline, size: 16),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Korttile ──────────────────────────────────────────────────────────────────

class AccountCardTile extends StatelessWidget {
  final SavedCard card;
  final bool isDefault;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AccountCardTile({
    super.key,
    required this.card,
    required this.isDefault,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDefault ? AppTheme.primarySurface : AppTheme.surface,
      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.paddingMedium,
            vertical: AppTheme.paddingMedium,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              color: isDefault ? AppTheme.primary : AppTheme.border,
              width: isDefault ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.credit_card,
                size: 22,
                color: AppTheme.textPrimary,
              ),
              const SizedBox(width: AppTheme.paddingMedium),
              // Kortinfo
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '•••• ${card.last4}',
                          style: const TextStyle(
                            fontSize: AppTheme.fontSizeBase,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.5,
                          ),
                        ),
                        if (isDefault) ...[
                          const SizedBox(width: AppTheme.paddingSmall),
                          const AccountStandardBadge(),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${card.holder.toUpperCase()}  •  ${card.expiry}',
                      style: const TextStyle(
                        fontSize: AppTheme.fontSizeXs,
                        color: AppTheme.textSecondary,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
              // Ändra-knapp + Ta bort-knapp på rad
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton.icon(
                    onPressed: onEdit,
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.primary,
                    ),
                    label: const Text(
                      'Ändra',
                      style: TextStyle(
                        fontSize: AppTheme.fontSizeBase,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    icon: const Icon(Icons.edit_outlined, size: 16),
                  ),
                  const SizedBox(width: 4),
                  ElevatedButton.icon(
                    onPressed: onDelete,
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.favorite,
                    ),
                    label: const Text(
                      'Ta bort',
                      style: TextStyle(
                        fontSize: AppTheme.fontSizeBase,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    icon: const Icon(Icons.delete_outline, size: 16),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Streckad "Lägg till"-knapp ────────────────────────────────────────────────

class AccountAddButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const AccountAddButton({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        onTap: onTap,
        child: AccountDottedBorder(
          color: AppTheme.border,
          radius: AppTheme.radiusLg,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.add, color: AppTheme.textPrimary, size: 20),
                const SizedBox(width: AppTheme.paddingSmall),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: AppTheme.fontSizeBase,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
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

// ── Streckad ram (CustomPaint) ────────────────────────────────────────────────

class AccountDottedBorder extends StatelessWidget {
  final Widget child;
  final Color color;
  final double radius;
  const AccountDottedBorder({
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
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke;

    final path =
        Path()..addRRect(
          RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
        );

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
