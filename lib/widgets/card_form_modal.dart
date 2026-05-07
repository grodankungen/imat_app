import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:imat_app/app_theme.dart';
import 'package:imat_app/model/account_data.dart';

Future<SavedCard?> showCardFormModal(
  BuildContext context, {
  SavedCard? existing,
}) {
  return showDialog<SavedCard>(
    context: context,
    barrierColor: Colors.black54,
    builder: (_) => _CardForm(existing: existing),
  );
}

class _CardForm extends StatefulWidget {
  final SavedCard? existing;
  const _CardForm({this.existing});

  @override
  State<_CardForm> createState() => _CardFormState();
}

class _CardFormState extends State<_CardForm> {
  late final TextEditingController _holder;
  late final TextEditingController _number;
  late int _month;
  late int _year;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _holder = TextEditingController(text: e?.holder ?? '');
    _number = TextEditingController(text: e?.number ?? '');
    _month = e?.month ?? 1;
    final nowYear = DateTime.now().year;
    _year = e?.year ?? nowYear;
    if (_year < nowYear) _year = nowYear;
  }

  @override
  void dispose() {
    _holder.dispose();
    _number.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
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
    final isNew = widget.existing == null;
    final years = List.generate(15, (i) => DateTime.now().year + i);

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
                        isNew ? 'Nytt kort' : 'Redigera kort',
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
                TextFormField(
                  controller: _holder,
                  textCapitalization: TextCapitalization.characters,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Krävs' : null,
                  decoration: InputDecoration(
                    labelText: 'Korthållarens namn',
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusLg),
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.paddingMediumSmall),
                TextFormField(
                  controller: _number,
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
                  decoration: InputDecoration(
                    labelText: 'Kortnummer',
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusLg),
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.paddingMediumSmall),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        initialValue: _month,
                        decoration: InputDecoration(
                          labelText: 'Månad',
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusLg),
                          ),
                        ),
                        items: List.generate(12, (i) => i + 1)
                            .map((m) => DropdownMenuItem(
                                  value: m,
                                  child:
                                      Text(m.toString().padLeft(2, '0')),
                                ))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _month = v ?? _month),
                      ),
                    ),
                    const SizedBox(width: AppTheme.paddingMediumSmall),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        initialValue: _year,
                        decoration: InputDecoration(
                          labelText: 'År',
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusLg),
                          ),
                        ),
                        items: years
                            .map((y) => DropdownMenuItem(
                                  value: y,
                                  child: Text(y.toString()),
                                ))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _year = v ?? _year),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.paddingMedium),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
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
