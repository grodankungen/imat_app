import 'package:flutter/material.dart';
import 'package:imat_app/app_theme.dart';
import 'package:imat_app/model/account_data.dart';

/// Returns the entered/edited [SavedAddress] or null if cancelled.
Future<SavedAddress?> showAddressFormModal(
  BuildContext context, {
  SavedAddress? existing,
}) {
  return showDialog<SavedAddress>(
    context: context,
    barrierColor: Colors.black54,
    builder: (_) => _AddressForm(existing: existing),
  );
}

class _AddressForm extends StatefulWidget {
  final SavedAddress? existing;
  const _AddressForm({this.existing});

  @override
  State<_AddressForm> createState() => _AddressFormState();
}

class _AddressFormState extends State<_AddressForm> {
  late final TextEditingController _label;
  late final TextEditingController _street;
  late final TextEditingController _postCode;
  late final TextEditingController _city;
  late final TextEditingController _phone;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _label = TextEditingController(text: e?.label ?? '');
    _street = TextEditingController(text: e?.street ?? '');
    _postCode = TextEditingController(text: e?.postCode ?? '');
    _city = TextEditingController(text: e?.city ?? '');
    _phone = TextEditingController(text: e?.phone ?? '');
  }

  @override
  void dispose() {
    for (final c in [_label, _street, _postCode, _city, _phone]) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
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
    final isNew = widget.existing == null;
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.paddingHuge),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        isNew ? 'Ny adress' : 'Redigera adress',
                        style: const TextStyle(
                          fontSize: AppTheme.fontSize3xl,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.paddingMedium),
                _Field(
                  label: 'Namn (t.ex. Hemma, Arbete)',
                  controller: _label,
                  required: true,
                ),
                _Field(
                  label: 'Gatuadress',
                  controller: _street,
                  required: true,
                ),
                Row(
                  children: [
                    Expanded(
                      child: _Field(
                        label: 'Postnummer',
                        controller: _postCode,
                        required: true,
                      ),
                    ),
                    const SizedBox(width: AppTheme.paddingMediumSmall),
                    Expanded(
                      flex: 2,
                      child: _Field(
                        label: 'Ort',
                        controller: _city,
                        required: true,
                      ),
                    ),
                  ],
                ),
                _Field(label: 'Telefon (valfritt)', controller: _phone),
                const SizedBox(height: AppTheme.paddingMedium),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.green600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusLg),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      isNew ? 'Lägg till' : 'Spara',
                      style: const TextStyle(
                        fontSize: AppTheme.fontSizeBase,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool required;

  const _Field({
    required this.label,
    required this.controller,
    this.required = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.paddingMediumSmall),
      child: TextFormField(
        controller: controller,
        validator: required
            ? (v) => (v == null || v.trim().isEmpty) ? 'Krävs' : null
            : null,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          ),
        ),
      ),
    );
  }
}
