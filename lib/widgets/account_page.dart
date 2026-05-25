import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:imat_app/app_theme.dart';
import 'package:imat_app/model/account_data.dart';
import 'package:imat_app/model/imat_data_handler.dart';
import 'package:imat_app/widgets/account_widgets.dart';
import 'package:imat_app/widgets/address_form_modal.dart';
import 'package:imat_app/widgets/card_form_modal.dart';
import 'package:provider/provider.dart';

// ── Navigation-helper ─────────────────────────────────────────────────────────

Future<void> showAccountView(BuildContext context) {
  return Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const AccountPage()),
  );
}

// ── Sida ──────────────────────────────────────────────────────────────────────

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
                        // E-postrad
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
                        // Adresskort med inline-formulär
                        _AddressCard(iMat: iMat),
                        const SizedBox(height: AppTheme.paddingLarge),
                        // Betalkortkort med inline-formulär
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

// ── Kortbehållare ─────────────────────────────────────────────────────────────

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

// ── Adresskort med inline-lägg-till-formulär ──────────────────────────────────

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
            child: AccountSectionHeader(
              icon: Icons.location_on_outlined,
              title: 'Leveransadresser',
            ),
          ),
          if (addresses.isEmpty && !_adding)
            const AccountEmptyHint(text: 'Du har inga sparade adresser ännu.'),
          for (int i = 0; i < addresses.length; i++) ...[
            AccountAddressTile(
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
                  () => accountConfirmDelete(
                    context,
                    'Ta bort adress?',
                    () => AccountData.removeAddress(widget.iMat, i),
                  ),
            ),
            const SizedBox(height: AppTheme.paddingMediumSmall),
          ],
          // Inline-formulär för ny adress (animerat)
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
            AccountAddButton(
              label: 'Lägg till ny adress',
              onTap: () => setState(() => _adding = true),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Betalkortkort med inline-lägg-till-formulär ───────────────────────────────

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
            child: AccountSectionHeader(
              icon: Icons.credit_card,
              title: 'Betalmetoder',
            ),
          ),
          if (cards.isEmpty && !_adding)
            const AccountEmptyHint(text: 'Du har inga sparade kort ännu.'),
          for (int i = 0; i < cards.length; i++) ...[
            AccountCardTile(
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
                  () => accountConfirmDelete(
                    context,
                    'Ta bort kort?',
                    () => AccountData.removeCard(widget.iMat, i),
                  ),
            ),
            const SizedBox(height: AppTheme.paddingMediumSmall),
          ],
          // Inline-formulär för nytt kort (animerat)
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
            AccountAddButton(
              label: 'Lägg till nytt kort',
              onTap: () => setState(() => _adding = true),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Inline-adressformulär ─────────────────────────────────────────────────────

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
            const Text(
              'Ny adress',
              style: TextStyle(
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
            _InlineFormButtons(onCancel: widget.onCancel, onSave: _save),
          ],
        ),
      ),
    );
  }
}

// ── Inline-kortformulär ───────────────────────────────────────────────────────

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
                          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
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
                          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
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
            _InlineFormButtons(onCancel: widget.onCancel, onSave: _save),
          ],
        ),
      ),
    );
  }
}

// ── Delade knappar för inline-formulär (Avbryt / Lägg till) ──────────────────

class _InlineFormButtons extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onSave;
  const _InlineFormButtons({required this.onCancel, required this.onSave});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onCancel,
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
            onPressed: onSave,
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
    );
  }
}

// ── Delat inline-formulärfält ─────────────────────────────────────────────────

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
