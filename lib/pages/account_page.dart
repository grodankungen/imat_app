import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:imat_app/app_theme.dart';
import 'package:imat_app/model/account_data.dart';
import 'package:imat_app/model/imat_data_handler.dart';
import 'package:imat_app/widgets/address_form_modal.dart';
import 'package:imat_app/widgets/card_form_modal.dart';
import 'package:provider/provider.dart';

// ── Navigation helper ────────────────────────────────────────────────────────

Future<void> showAccountView(BuildContext context) {
  return Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const AccountPage()),
  );
}

// ── Page ─────────────────────────────────────────────────────────────────────

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    final iMat = context.watch<ImatDataHandler>();
    final email =
        iMat.getCustomer().email.isEmpty
            ? 'anna.andersson@email.se'
            : iMat.getCustomer().email;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ───────────────────────────────────────────────────
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.paddingLarge,
                vertical: AppTheme.paddingMediumSmall,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.textPrimary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      icon: const Icon(Icons.arrow_back, size: 18),
                      label: const Text(
                        'Tillbaka',
                        style: TextStyle(fontSize: AppTheme.fontSizeBase),
                      ),
                    ),
                  ),
                  const Text(
                    'iMat Konto',
                    style: TextStyle(
                      fontSize: AppTheme.fontSize3xl,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppTheme.border),
            // ── Body ─────────────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppTheme.paddingLarge),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 640),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Email info row
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 4,
                            bottom: AppTheme.paddingMedium,
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.person_outline,
                                size: 18,
                                color: AppTheme.textSecondary,
                              ),
                              const SizedBox(width: 8),
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
                        // Addresses card
                        _AddressCard(iMat: iMat),
                        const SizedBox(height: AppTheme.paddingLarge),
                        // Payment cards card
                        _PaymentCard(iMat: iMat),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── _Card container (same as checkout) ───────────────────────────────────────

class _Card extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  const _Card({required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(AppTheme.paddingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ── Section header (icon + title) ─────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionHeader({required this.icon, required this.title});

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

// ── Standard badge ────────────────────────────────────────────────────────────

class _StandardBadge extends StatelessWidget {
  const _StandardBadge();

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

// ── Delete confirmation ───────────────────────────────────────────────────────

Future<void> _confirmDelete(
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

// ── Address card with inline add form ─────────────────────────────────────────

class _AddressCard extends StatefulWidget {
  final ImatDataHandler iMat;
  const _AddressCard({required this.iMat});

  @override
  State<_AddressCard> createState() => _AddressCardState();
}

class _AddressCardState extends State<_AddressCard> {
  bool _adding = false;

  @override
  Widget build(BuildContext context) {
    final addresses = AccountData.addresses(widget.iMat);
    final defAddr = AccountData.defaultAddressIndex(widget.iMat);

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: AppTheme.paddingMedium),
            child: _SectionHeader(
              icon: Icons.location_on_outlined,
              title: 'Leveransadresser',
            ),
          ),
          if (addresses.isEmpty && !_adding)
            Padding(
              padding: const EdgeInsets.only(
                bottom: AppTheme.paddingMediumSmall,
              ),
              child: Text(
                'Du har inga sparade adresser ännu.',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: AppTheme.fontSizeXs2,
                ),
              ),
            ),
          for (int i = 0; i < addresses.length; i++) ...[
            _AddressTile(
              address: addresses[i],
              isDefault: i == defAddr,
              onTap: () => AccountData.setDefaultAddress(widget.iMat, i),
              onEdit: () async {
                final updated = await showAddressFormModal(
                  context,
                  existing: addresses[i],
                );
                if (updated != null) {
                  AccountData.updateAddress(widget.iMat, i, updated);
                }
              },
              onDelete:
                  () => _confirmDelete(
                    context,
                    'Ta bort adress?',
                    () => AccountData.removeAddress(widget.iMat, i),
                  ),
            ),
            const SizedBox(height: AppTheme.paddingMediumSmall),
          ],
          // Inline add form
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            child:
                _adding
                    ? _InlineAddressForm(
                      onSave: (addr) {
                        AccountData.addAddress(widget.iMat, addr);
                        setState(() => _adding = false);
                      },
                      onCancel: () => setState(() => _adding = false),
                    )
                    : const SizedBox.shrink(),
          ),
          if (!_adding) ...[
            const SizedBox(height: AppTheme.paddingSmall),
            _AddButton(
              label: 'Lägg till ny adress',
              onTap: () => setState(() => _adding = true),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Payment card with inline add form ─────────────────────────────────────────

class _PaymentCard extends StatefulWidget {
  final ImatDataHandler iMat;
  const _PaymentCard({required this.iMat});

  @override
  State<_PaymentCard> createState() => _PaymentCardState();
}

class _PaymentCardState extends State<_PaymentCard> {
  bool _adding = false;

  @override
  Widget build(BuildContext context) {
    final cards = AccountData.cards(widget.iMat);
    final defCard = AccountData.defaultCardIndex(widget.iMat);

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: AppTheme.paddingMedium),
            child: _SectionHeader(
              icon: Icons.credit_card,
              title: 'Betalmetoder',
            ),
          ),
          if (cards.isEmpty && !_adding)
            Padding(
              padding: const EdgeInsets.only(
                bottom: AppTheme.paddingMediumSmall,
              ),
              child: Text(
                'Du har inga sparade kort ännu.',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: AppTheme.fontSizeXs2,
                ),
              ),
            ),
          for (int i = 0; i < cards.length; i++) ...[
            _CardTile(
              card: cards[i],
              isDefault: i == defCard,
              onTap: () => AccountData.setDefaultCard(widget.iMat, i),
              onEdit: () async {
                final updated = await showCardFormModal(
                  context,
                  existing: cards[i],
                );
                if (updated != null) {
                  AccountData.updateCard(widget.iMat, i, updated);
                }
              },
              onDelete:
                  () => _confirmDelete(
                    context,
                    'Ta bort kort?',
                    () => AccountData.removeCard(widget.iMat, i),
                  ),
            ),
            const SizedBox(height: AppTheme.paddingMediumSmall),
          ],
          // Inline add form
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            child:
                _adding
                    ? _InlineCardForm(
                      onSave: (card) {
                        AccountData.addCard(widget.iMat, card);
                        setState(() => _adding = false);
                      },
                      onCancel: () => setState(() => _adding = false),
                    )
                    : const SizedBox.shrink(),
          ),
          if (!_adding) ...[
            const SizedBox(height: AppTheme.paddingSmall),
            _AddButton(
              label: 'Lägg till nytt kort',
              onTap: () => setState(() => _adding = true),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Add button (dashed, matching original style) ──────────────────────────────

class _AddButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _AddButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        onTap: onTap,
        child: _DottedBorder(
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

// ── Address tile ──────────────────────────────────────────────────────────────

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
      color: isDefault ? AppTheme.primarySurface : AppTheme.surface,
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
            border: Border.all(
              color: isDefault ? AppTheme.primary : AppTheme.border,
              width: isDefault ? 2 : 1,
            ),
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
                            fontSize: AppTheme.fontSizeBase,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (isDefault) ...[
                          const SizedBox(width: AppTheme.paddingSmall),
                          const _StandardBadge(),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      address.street,
                      style: const TextStyle(
                        fontSize: AppTheme.fontSizeXs2,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      '${address.postCode} ${address.city}'.trim(),
                      style: const TextStyle(
                        fontSize: AppTheme.fontSizeXs2,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    if (address.phone.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          address.phone,
                          style: const TextStyle(
                            fontSize: AppTheme.fontSizeXs2,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  color: AppTheme.favorite,
                  size: 20,
                ),
                onPressed: onDelete,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Card tile ─────────────────────────────────────────────────────────────────

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
      color: isDefault ? AppTheme.primarySurface : AppTheme.surface,
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
                          const _StandardBadge(),
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
              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  color: AppTheme.favorite,
                  size: 20,
                ),
                onPressed: onDelete,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Inline address form ───────────────────────────────────────────────────────

class _InlineAddressForm extends StatefulWidget {
  final ValueChanged<SavedAddress> onSave;
  final VoidCallback onCancel;
  const _InlineAddressForm({required this.onSave, required this.onCancel});

  @override
  State<_InlineAddressForm> createState() => _InlineAddressFormState();
}

class _InlineAddressFormState extends State<_InlineAddressForm> {
  final _formKey = GlobalKey<FormState>();
  final _label = TextEditingController();
  final _street = TextEditingController();
  final _postCode = TextEditingController();
  final _city = TextEditingController();
  final _phone = TextEditingController();

  @override
  void dispose() {
    for (final c in [_label, _street, _postCode, _city, _phone]) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    widget.onSave(
      SavedAddress(
        label: _label.text.trim(),
        street: _street.text.trim(),
        postCode: _postCode.text.trim(),
        city: _city.text.trim(),
        phone: _phone.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.paddingMedium),
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.border),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Ny adress',
              style: const TextStyle(
                fontSize: AppTheme.fontSizeBase,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppTheme.paddingMediumSmall),
            _InlineField(
              label: 'Namn (t.ex. Hemma, Arbete)',
              controller: _label,
              required: true,
            ),
            _InlineField(
              label: 'Gatuadress',
              controller: _street,
              required: true,
            ),
            Row(
              children: [
                Expanded(
                  child: _InlineField(
                    label: 'Postnummer',
                    controller: _postCode,
                    required: true,
                  ),
                ),
                const SizedBox(width: AppTheme.paddingMediumSmall),
                Expanded(
                  flex: 2,
                  child: _InlineField(
                    label: 'Ort',
                    controller: _city,
                    required: true,
                  ),
                ),
              ],
            ),
            _InlineField(label: 'Telefon (valfritt)', controller: _phone),
            const SizedBox(height: AppTheme.paddingSmall),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: widget.onCancel,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.textSecondary,
                      side: const BorderSide(color: AppTheme.border),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                      ),
                    ),
                    child: const Text('Avbryt'),
                  ),
                ),
                const SizedBox(width: AppTheme.paddingMediumSmall),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                      ),
                    ),
                    child: const Text(
                      'Lägg till',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Inline card form ──────────────────────────────────────────────────────────

class _InlineCardForm extends StatefulWidget {
  final ValueChanged<SavedCard> onSave;
  final VoidCallback onCancel;
  const _InlineCardForm({required this.onSave, required this.onCancel});

  @override
  State<_InlineCardForm> createState() => _InlineCardFormState();
}

class _InlineCardFormState extends State<_InlineCardForm> {
  final _formKey = GlobalKey<FormState>();
  final _holder = TextEditingController();
  final _number = TextEditingController();
  int _month = 1;
  late int _year;

  @override
  void initState() {
    super.initState();
    _year = DateTime.now().year;
  }

  @override
  void dispose() {
    _holder.dispose();
    _number.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    widget.onSave(
      SavedCard(
        holder: _holder.text.trim(),
        number: _number.text.replaceAll(RegExp(r'\s+'), ''),
        month: _month,
        year: _year,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final years = List.generate(15, (i) => DateTime.now().year + i);

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.paddingMedium),
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.border),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Nytt kort',
              style: TextStyle(
                fontSize: AppTheme.fontSizeBase,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppTheme.paddingMediumSmall),
            _InlineField(
              label: 'Korthållarens namn',
              controller: _holder,
              required: true,
              textCapitalization: TextCapitalization.characters,
            ),
            _InlineField(
              label: 'Kortnummer',
              controller: _number,
              required: true,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(19),
              ],
              validator: (v) {
                final clean = (v ?? '').replaceAll(RegExp(r'\s+'), '');
                if (clean.length < 12) return 'Minst 12 siffror';
                return null;
              },
            ),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      bottom: AppTheme.paddingMediumSmall,
                    ),
                    child: DropdownButtonFormField<int>(
                      value: _month,
                      decoration: InputDecoration(
                        labelText: 'Månad',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusLg,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                      ),
                      items:
                          List.generate(12, (i) => i + 1)
                              .map(
                                (m) => DropdownMenuItem(
                                  value: m,
                                  child: Text(m.toString().padLeft(2, '0')),
                                ),
                              )
                              .toList(),
                      onChanged: (v) => setState(() => _month = v ?? _month),
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.paddingMediumSmall),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      bottom: AppTheme.paddingMediumSmall,
                    ),
                    child: DropdownButtonFormField<int>(
                      value: _year,
                      decoration: InputDecoration(
                        labelText: 'År',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusLg,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                      ),
                      items:
                          years
                              .map(
                                (y) => DropdownMenuItem(
                                  value: y,
                                  child: Text(y.toString()),
                                ),
                              )
                              .toList(),
                      onChanged: (v) => setState(() => _year = v ?? _year),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.paddingSmall),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: widget.onCancel,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.textSecondary,
                      side: const BorderSide(color: AppTheme.border),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                      ),
                    ),
                    child: const Text('Avbryt'),
                  ),
                ),
                const SizedBox(width: AppTheme.paddingMediumSmall),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                      ),
                    ),
                    child: const Text(
                      'Lägg till',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared inline form field ───────────────────────────────────────────────────

class _InlineField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool required;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  const _InlineField({
    required this.label,
    required this.controller,
    this.required = false,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.paddingMediumSmall),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        inputFormatters: inputFormatters,
        validator:
            validator ??
            (required
                ? (v) => (v == null || v.trim().isEmpty) ? 'Krävs' : null
                : null),
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}

// ── Dotted border painter ─────────────────────────────────────────────────────

class _DottedBorder extends StatelessWidget {
  final Widget child;
  final Color color;
  final double radius;
  const _DottedBorder({
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
