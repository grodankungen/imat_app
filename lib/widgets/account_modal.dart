import 'package:flutter/material.dart';
import 'package:imat_app/app_theme.dart';
import 'package:imat_app/model/account_data.dart';
import 'package:imat_app/model/imat_data_handler.dart';
import 'package:imat_app/widgets/account_widgets.dart';
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
    final email =
        iMat.getCustomer().email.isEmpty
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
            // ── Header ───────────────────────────────────────────────────
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
                            color: AppTheme.textSecondary,
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
            const Divider(height: 1, color: AppTheme.border),
            // ── Body ─────────────────────────────────────────────────────
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppTheme.paddingLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Adresser
                    const AccountSectionHeader(
                      icon: Icons.location_on_outlined,
                      title: 'Leveransadresser',
                    ),
                    const SizedBox(height: AppTheme.paddingMediumSmall),
                    if (addresses.isEmpty)
                      const AccountEmptyHint(
                        text: 'Du har inga sparade adresser ännu.',
                      ),
                    for (int i = 0; i < addresses.length; i++) ...[
                      AccountAddressTile(
                        address: addresses[i],
                        isDefault: i == defAddr,
                        onTap: () => AccountData.setDefaultAddress(iMat, i),
                        onEdit: () async {
                          final updated = await showAddressFormModal(
                            context,
                            existing: addresses[i],
                          );
                          if (updated != null) {
                            AccountData.updateAddress(iMat, i, updated);
                          }
                        },
                        onDelete:
                            () => accountConfirmDelete(
                              context,
                              'Ta bort adress?',
                              () => AccountData.removeAddress(iMat, i),
                            ),
                      ),
                      const SizedBox(height: AppTheme.paddingMediumSmall),
                    ],
                    AccountAddButton(
                      label: 'Lägg till ny adress',
                      onTap: () async {
                        final addr = await showAddressFormModal(context);
                        if (addr != null) {
                          AccountData.addAddress(iMat, addr);
                        }
                      },
                    ),
                    const SizedBox(height: AppTheme.paddingHuge),
                    // Betalmetoder
                    const AccountSectionHeader(
                      icon: Icons.credit_card,
                      title: 'Betalmetoder',
                    ),
                    const SizedBox(height: AppTheme.paddingMediumSmall),
                    if (cards.isEmpty)
                      const AccountEmptyHint(
                        text: 'Du har inga sparade kort ännu.',
                      ),
                    for (int i = 0; i < cards.length; i++) ...[
                      AccountCardTile(
                        card: cards[i],
                        isDefault: i == defCard,
                        onTap: () => AccountData.setDefaultCard(iMat, i),
                        onEdit: () async {
                          final updated = await showCardFormModal(
                            context,
                            existing: cards[i],
                          );
                          if (updated != null) {
                            AccountData.updateCard(iMat, i, updated);
                          }
                        },
                        onDelete:
                            () => accountConfirmDelete(
                              context,
                              'Ta bort kort?',
                              () => AccountData.removeCard(iMat, i),
                            ),
                      ),
                      const SizedBox(height: AppTheme.paddingMediumSmall),
                    ],
                    AccountAddButton(
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
}
