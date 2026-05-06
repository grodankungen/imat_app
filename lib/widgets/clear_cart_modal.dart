import 'package:flutter/material.dart';
import 'package:imat_app/app_theme.dart';
import 'package:imat_app/model/imat_data_handler.dart';
import 'package:provider/provider.dart';

Future<void> showClearCartModal(BuildContext context) {
  return showDialog(
    context: context,
    barrierColor: Colors.black54,
    builder: (ctx) => Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 448),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.paddingHuge),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Töm kundvagn?',
                style: TextStyle(fontSize: AppTheme.fontSize4xl, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: AppTheme.paddingMedium),
              const Text(
                'Är du säker på att du vill ta bort alla produkter från kundvagnen?',
                style: TextStyle(fontSize: AppTheme.fontSizeLg, color: AppTheme.gray600),
              ),
              const SizedBox(height: AppTheme.paddingLarge),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: AppTheme.gray300,
                          width: 2,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusLg),
                        ),
                      ),
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text(
                        'Avbryt',
                        style: TextStyle(
                          fontSize: AppTheme.fontSizeLg,
                          color: AppTheme.gray900,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppTheme.paddingMediumSmall),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.red600,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusLg),
                        ),
                      ),
                      onPressed: () {
                        ctx.read<ImatDataHandler>().shoppingCartClear();
                        Navigator.pop(ctx);
                      },
                      child: const Text(
                        'Töm vagn',
                        style: TextStyle(
                          fontSize: AppTheme.fontSizeLg,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
