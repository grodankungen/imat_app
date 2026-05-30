import 'package:flutter/material.dart';
import 'package:imat_app/app_theme.dart';
import 'package:imat_app/model/account_data.dart';
import 'package:imat_app/model/imat/order.dart';
import 'package:imat_app/model/imat_data_handler.dart';
import 'package:imat_app/model/ui_state.dart';
import 'package:imat_app/widgets/account_modal.dart';
import 'package:provider/provider.dart';

// ---------- Leveranstidsfönster (för hemleverans) ----------

// Ett valbart tidsfönster för hemleverans. 'id' sparas på ordern,
// 'label' visas i listan och 'range' är klockslagen.
class _DeliveryWindow {
  final String id;
  final String label;
  final String range;
  const _DeliveryWindow(this.id, this.label, this.range);

  // Hur fönstret visas på en rad, t.ex. "Förmiddag (8:00–12:00)".
  String get display => '$label ($range)';
}

const _deliveryWindows = [
  _DeliveryWindow('morning', 'Förmiddag', '8:00–12:00'),
  _DeliveryWindow('afternoon', 'Eftermiddag', '12:00–16:00'),
  _DeliveryWindow('evening', 'Kväll', '16:00–22:00'),
];

// Formaterar ett datum till "ÅÅÅÅ-MM-DD". Null om inget datum valt.
String? _formatDate(DateTime? d) {
  if (d == null) return null;
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return '${d.year}-$m-$day';
}

// Slår upp ett tidsfönster på dess id (för visning i granska/bekräftelse).
_DeliveryWindow? _windowById(String? id) {
  if (id == null) return null;
  for (final w in _deliveryWindows) {
    if (w.id == id) return w;
  }
  return null;
}

// ---------- Models for delivery / payment selection ----------

class _DeliveryOption {
  final String id;
  final IconData icon;
  final String title;
  final String subtitle;
  final double price;
  const _DeliveryOption(
    this.id,
    this.icon,
    this.title,
    this.subtitle,
    this.price,
  );
}

const _deliveryOptions = [
  _DeliveryOption(
    'home',
    Icons.home_outlined,
    'Hemleverans',
    'Leverans till din dörr inom 1-3 dagar',
    49,
  ),
  _DeliveryOption(
    'pickup',
    Icons.location_on_outlined,
    'Hämta i butik',
    'Hämta på valfri butik samma dag',
    0,
  ),
  _DeliveryOption(
    'express',
    Icons.inventory_2_outlined,
    'Expressleverans',
    'Leverans inom 2 timmar',
    99,
  ),
];

class _PaymentOption {
  final String id;
  final IconData icon;
  final String title;
  final String subtitle;
  const _PaymentOption(this.id, this.icon, this.title, this.subtitle);
}

const _paymentOptions = [
  _PaymentOption(
    'card',
    Icons.credit_card,
    'Bankkort',
    'Betala med Visa, Mastercard eller AmEx',
  ),
  _PaymentOption(
    'swish',
    Icons.account_balance_wallet_outlined,
    'Swish',
    'Snabb och säker mobilbetalning',
  ),
  _PaymentOption(
    'invoice',
    Icons.receipt_long_outlined,
    'Faktura',
    'Betala inom 30 dagar',
  ),
];

// ---------- Page ----------

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  /// 0 = Leverans, 1 = Betalning, 2 = Granska, 3 = Bekräftelse
  int _step = 0;

  String _deliveryId = 'home';
  // Hemleverans kräver datum + tidsfönster. Inget förvalt.
  DateTime? _selectedDate;
  String? _windowId;
  // Sätts till true när användaren försökt fortsätta utan att ha valt
  // allt som krävs – då (och först då) visas felmeddelandet.
  bool _showDeliveryError = false;
  int _addressIndex = -1;
  String _paymentId = 'card';
  int _cardIndex = -1;
  bool _initialized = false;

  Order? _placedOrder;
  double _placedDeliveryCost = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final iMat = context.read<ImatDataHandler>();
      _addressIndex = AccountData.defaultAddressIndex(iMat);
      _cardIndex = AccountData.defaultCardIndex(iMat);
      _initialized = true;
    }
  }

  void _go(int step) {
    setState(() => _step = step);
  }

  Future<void> _placeOrder() async {
    final iMat = context.read<ImatDataHandler>();
    final delivery = _deliveryOptions.firstWhere((d) => d.id == _deliveryId);

    // Capture pre-place orderNumbers so we can identify the new one.
    final beforeIds = iMat.orders.map((o) => o.orderNumber).toSet();

    iMat.placeOrder();
    // Give the async placeOrder a moment to populate orders list
    await Future.delayed(const Duration(milliseconds: 600));

    Order? newOrder;
    final orders = [...iMat.orders]..sort((a, b) => b.date.compareTo(a.date));
    for (final o in orders) {
      if (!beforeIds.contains(o.orderNumber)) {
        newOrder = o;
        break;
      }
    }
    newOrder ??= orders.isNotEmpty ? orders.first : null;

    if (newOrder != null) {
      // Skicka bara med datum/tid om det är hemleverans (enda sättet som
      // har schemaläggning). scheduledTime sparas som fönstrets visningstext.
      final isHome = _deliveryId == 'home';
      final window = _windowById(_windowId);
      AccountData.setOrderMeta(
        iMat,
        newOrder.orderNumber,
        OrderMeta(
          delivery: _deliveryId,
          payment: _paymentId,
          scheduledDate: isHome ? _formatDate(_selectedDate) : null,
          scheduledTime: isHome ? window?.display : null,
        ),
      );
    }

    setState(() {
      _placedOrder = newOrder;
      _placedDeliveryCost = delivery.price;
      _step = 3;
    });
    if (mounted) context.read<UiState>().closeCart();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            _CheckoutTopBar(onBack: _onBack),
            if (_step < 3)
              _CheckoutStepper(activeStep: _step)
            else
              _CheckoutStepperDone(),
            const Divider(height: 1, color: AppTheme.border),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  void _onBack() {
    if (_step == 0 || _step == 3) {
      Navigator.of(context).maybePop();
    } else {
      _go(_step - 1);
    }
  }

  Widget _buildBody() {
    switch (_step) {
      case 0:
        return _DeliveryStep(
          deliveryId: _deliveryId,
          onDelivery:
              (id) => setState(() {
                _deliveryId = id;
                // Byter man bort från hemleverans försvinner felet.
                if (id != 'home') _showDeliveryError = false;
              }),
          addressIndex: _addressIndex,
          onAddress: (i) => setState(() => _addressIndex = i),
          selectedDate: _selectedDate,
          windowId: _windowId,
          showDeliveryError: _showDeliveryError,
          onDate:
              (d) => setState(() {
                _selectedDate = d;
                // När båda fälten är ifyllda tar vi bort ev. felmeddelande.
                if (_selectedDate != null && _windowId != null) {
                  _showDeliveryError = false;
                }
              }),
          onWindow:
              (id) => setState(() {
                _windowId = id;
                if (_selectedDate != null && _windowId != null) {
                  _showDeliveryError = false;
                }
              }),
          onContinue: _tryContinueFromDelivery,
        );
      case 1:
        return _PaymentStep(
          deliveryId: _deliveryId,
          paymentId: _paymentId,
          onPayment: (id) => setState(() => _paymentId = id),
          cardIndex: _cardIndex,
          onCard: (i) => setState(() => _cardIndex = i),
          onContinue: () => _go(2),
        );
      case 2:
        return _ReviewStep(
          deliveryId: _deliveryId,
          addressIndex: _addressIndex,
          paymentId: _paymentId,
          cardIndex: _cardIndex,
          selectedDate: _selectedDate,
          windowId: _windowId,
          onConfirm: _placeOrder,
        );
      case 3:
      default:
        return _DoneStep(
          order: _placedOrder,
          deliveryCost: _placedDeliveryCost,
          deliveryId: _deliveryId,
          selectedDate: _selectedDate,
          windowId: _windowId,
        );
    }
  }

  // Anropas när man trycker "Fortsätt" i leveranssteget. Kräver datum +
  // tidsfönster om hemleverans är valt; annars visas felet och vi stannar.
  void _tryContinueFromDelivery() {
    final needsSchedule = _deliveryId == 'home';
    final scheduleOk =
        !needsSchedule || (_selectedDate != null && _windowId != null);
    if (!scheduleOk) {
      setState(() => _showDeliveryError = true);
      return;
    }
    _go(1);
  }
}

// ---------- Top bar ----------

class _CheckoutTopBar extends StatelessWidget {
  final VoidCallback onBack;
  const _CheckoutTopBar({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
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
              onPressed: onBack,
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
            'iMat Kassa',
            style: TextStyle(
              fontSize: AppTheme.fontSize3xl,
              fontWeight: FontWeight.w600,
              color: AppTheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- Stepper ----------

class _CheckoutStepper extends StatelessWidget {
  final int activeStep;
  const _CheckoutStepper({required this.activeStep});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.paddingHuge,
        vertical: AppTheme.paddingMedium,
      ),
      child: _StepperRow(active: activeStep, completedAll: false),
    );
  }
}

class _CheckoutStepperDone extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.paddingHuge,
        vertical: AppTheme.paddingMedium,
      ),
      child: const _StepperRow(active: 2, completedAll: true),
    );
  }
}

class _StepperRow extends StatelessWidget {
  final int active;
  final bool completedAll;
  const _StepperRow({required this.active, required this.completedAll});

  @override
  Widget build(BuildContext context) {
    const labels = ['Leverans', 'Betalning', 'Granska'];
    return Row(
      children: [
        for (int i = 0; i < 3; i++) ...[
          Expanded(
            child: Column(
              children: [
                _StepCircle(
                  index: i,
                  isActive: i == active && !completedAll,
                  isCompleted: i < active || completedAll,
                ),
                const SizedBox(height: 6),
                Text(
                  labels[i],
                  style: TextStyle(
                    fontSize: AppTheme.fontSizeXs2,
                    fontWeight: FontWeight.w500,
                    color:
                        (i == active && !completedAll) ||
                                (i < active || completedAll)
                            ? AppTheme.black
                            : AppTheme.hint,
                  ),
                ),
              ],
            ),
          ),
          if (i < 2)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Container(
                  height: 2,
                  color:
                      (i < active || completedAll)
                          ? AppTheme.primary
                          : AppTheme.border,
                ),
              ),
            ),
        ],
      ],
    );
  }
}

class _StepCircle extends StatelessWidget {
  final int index;
  final bool isActive;
  final bool isCompleted;
  const _StepCircle({
    required this.index,
    required this.isActive,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Widget child;
    if (isCompleted) {
      bg = AppTheme.primary;
      child = const Icon(Icons.check, color: Colors.white, size: 18);
    } else if (isActive) {
      bg = AppTheme.primary;
      child = Text(
        '${index + 1}',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: AppTheme.fontSizeBase,
        ),
      );
    } else {
      bg = AppTheme.border;
      child = Text(
        '${index + 1}',
        style: const TextStyle(
          color: AppTheme.textSecondary,
          fontWeight: FontWeight.w600,
          fontSize: AppTheme.fontSizeBase,
        ),
      );
    }
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: child,
    );
  }
}

// ---------- Order summary panel (right side) ----------

class _OrderSummary extends StatelessWidget {
  final String deliveryId;
  const _OrderSummary({required this.deliveryId});

  @override
  Widget build(BuildContext context) {
    final iMat = context.watch<ImatDataHandler>();
    final items = iMat.getShoppingCart().items;
    final subtotal = iMat.shoppingCartTotal();
    final delivery =
        _deliveryOptions.firstWhere((d) => d.id == deliveryId).price;
    final total = subtotal + delivery;

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: AppTheme.paddingMedium),
            child: Text(
              'Ordersammanställning',
              style: TextStyle(
                fontSize: AppTheme.fontSizeXl,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(
                bottom: AppTheme.paddingMediumSmall,
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    child: SizedBox(
                      width: 40,
                      height: 40,
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
                            fontSize: AppTheme.fontSizeXl,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${item.amount.toStringAsFixed(0)} × ${item.product.price.toStringAsFixed(1)} kr',
                          style: const TextStyle(
                            fontSize: AppTheme.fontSizeBase,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${(item.product.price * item.amount).toStringAsFixed(2)} kr',
                    style: const TextStyle(
                      fontSize: AppTheme.fontSizeSm,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppTheme.paddingSmall),
            child: Divider(color: AppTheme.border, height: 1),
          ),
          _SummaryLine(
            label: 'Delsumma:',
            value: '${subtotal.toStringAsFixed(2)} kr',
          ),
          _SummaryLine(
            label: 'Leverans:',
            value: '${delivery.toStringAsFixed(2)} kr',
          ),
          const SizedBox(height: 4),
          _SummaryLine(
            label: 'Totalt:',
            value: '${total.toStringAsFixed(2)} kr',
            bold: true,
            highlight: true,
          ),
        ],
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  final bool highlight;
  const _SummaryLine({
    required this.label,
    required this.value,
    this.bold = false,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: bold ? AppTheme.fontSizeMd : AppTheme.fontSizeSm,
              fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
              color: AppTheme.black,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: bold ? AppTheme.fontSizeLg : AppTheme.fontSizeSm,
              fontWeight: bold ? FontWeight.w600 : FontWeight.w500,
              color: highlight ? AppTheme.primary : AppTheme.black,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- Generic card container ----------

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

// ---------- Selectable option tile (used for delivery, payment, address, card) ----------

class _OptionTile extends StatelessWidget {
  final bool selected;
  final VoidCallback onTap;
  final Widget child;
  const _OptionTile({
    required this.selected,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppTheme.primarySurface : Colors.white,
      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.paddingMedium,
            vertical: AppTheme.paddingMediumSmall,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              color: selected ? AppTheme.primary : AppTheme.border,
              width: selected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          ),
          child: child,
        ),
      ),
    );
  }
}

// ---------- Step layout (two-column with summary on right) ----------

class _StepLayout extends StatelessWidget {
  final Widget left;
  final String deliveryId;
  const _StepLayout({required this.left, required this.deliveryId});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.paddingLarge),
      child: LayoutBuilder(
        builder: (ctx, c) {
          final wide = c.maxWidth > 900;
          if (wide) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: left),
                    const SizedBox(width: AppTheme.paddingLarge),
                    Expanded(
                      flex: 2,
                      child: _OrderSummary(deliveryId: deliveryId),
                    ),
                  ],
                ),
              ),
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              left,
              const SizedBox(height: AppTheme.paddingLarge),
              _OrderSummary(deliveryId: deliveryId),
            ],
          );
        },
      ),
    );
  }
}

// ---------- Step 1: Leverans ----------

class _DeliveryStep extends StatelessWidget {
  final String deliveryId;
  final ValueChanged<String> onDelivery;
  final int addressIndex;
  final ValueChanged<int> onAddress;
  // Datum/tid för hemleverans + callbacks och felflagga.
  final DateTime? selectedDate;
  final String? windowId;
  final bool showDeliveryError;
  final ValueChanged<DateTime> onDate;
  final ValueChanged<String> onWindow;
  final VoidCallback onContinue;

  const _DeliveryStep({
    required this.deliveryId,
    required this.onDelivery,
    required this.addressIndex,
    required this.onAddress,
    required this.selectedDate,
    required this.windowId,
    required this.showDeliveryError,
    required this.onDate,
    required this.onWindow,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final iMat = context.watch<ImatDataHandler>();
    final addresses = AccountData.addresses(iMat);
    final defaultIndex = AccountData.defaultAddressIndex(iMat);
    final canContinue = addresses.isNotEmpty && addressIndex >= 0;

    return _StepLayout(
      deliveryId: deliveryId,
      left: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Leveranssätt
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: AppTheme.paddingMedium),
                  child: Text(
                    'Leveranssätt',
                    style: TextStyle(
                      fontSize: AppTheme.fontSizeXl,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                for (int i = 0; i < _deliveryOptions.length; i++) ...[
                  _OptionTile(
                    selected: deliveryId == _deliveryOptions[i].id,
                    onTap: () => onDelivery(_deliveryOptions[i].id),
                    child: _DeliveryRow(opt: _deliveryOptions[i]),
                  ),
                  // Under hemleverans visar vi datum + tidsfönster när
                  // det alternativet är valt.
                  if (_deliveryOptions[i].id == 'home' && deliveryId == 'home')
                    Padding(
                      padding: const EdgeInsets.only(
                        top: AppTheme.paddingMediumSmall,
                      ),
                      child: _HomeDeliveryScheduler(
                        selectedDate: selectedDate,
                        windowId: windowId,
                        showError: showDeliveryError,
                        onDate: onDate,
                        onWindow: onWindow,
                      ),
                    ),
                  if (i < _deliveryOptions.length - 1)
                    const SizedBox(height: AppTheme.paddingMediumSmall),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppTheme.paddingLarge),
          // Leveransadress
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: AppTheme.paddingMedium),
                  child: Text(
                    'Leveransadress',
                    style: TextStyle(
                      fontSize: AppTheme.fontSizeXl,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (addresses.isEmpty)
                  _EmptyAccountHint(
                    text: 'Du har inga sparade adresser ännu.',
                    actionLabel: 'Lägg till adress',
                    onAction: () => showAccountModal(context),
                  )
                else
                  for (int i = 0; i < addresses.length; i++) ...[
                    _OptionTile(
                      selected: addressIndex == i,
                      onTap: () => onAddress(i),
                      child: _AddressRow(
                        address: addresses[i],
                        isDefault: i == defaultIndex,
                      ),
                    ),
                    if (i < addresses.length - 1)
                      const SizedBox(height: AppTheme.paddingMediumSmall),
                  ],
                const SizedBox(height: AppTheme.paddingMediumSmall),
                Align(
                  alignment: Alignment.centerLeft,
                  child: _SecondaryButton(
                    label: 'Hantera adresser',
                    onPressed: () => showAccountModal(context),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.paddingLarge),
          _PrimaryButton(
            label: 'Fortsätt till betalning',
            onPressed: canContinue ? onContinue : null,
          ),
        ],
      ),
    );
  }
}

// Datum- och tidsfönster-väljare som visas under hemleverans.
// Visar ett rött felmeddelande när showError är true och något saknas.
class _HomeDeliveryScheduler extends StatelessWidget {
  final DateTime? selectedDate;
  final String? windowId;
  final bool showError;
  final ValueChanged<DateTime> onDate;
  final ValueChanged<String> onWindow;

  const _HomeDeliveryScheduler({
    required this.selectedDate,
    required this.windowId,
    required this.showError,
    required this.onDate,
    required this.onWindow,
  });

  Future<void> _pickDate(BuildContext context) async {
    // Tidigast imorgon (idag + 1 dag), upp till 60 dagar framåt.
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final first = DateTime(tomorrow.year, tomorrow.month, tomorrow.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? first,
      firstDate: first,
      lastDate: first.add(const Duration(days: 60)),
      helpText: 'Välj leveransdatum',
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            dialogTheme: const DialogThemeData(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
            ),
            datePickerTheme: const DatePickerThemeData(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              dayStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              weekdayStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
              yearStyle: TextStyle(fontSize: 18),
            ),
          ),
          child: MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(1.15)),
            child: child!,
          ),
        );
      },
    );
    if (picked != null) onDate(picked);
  }

  @override
  Widget build(BuildContext context) {
    // Visa fel bara om användaren försökt fortsätta OCH något saknas.
    final dateMissing = showError && selectedDate == null;
    final windowMissing = showError && windowId == null;
    final dateText = _formatDate(selectedDate) ?? 'Välj datum';

    return Container(
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ----- Datum -----
          const Text(
            'Leveransdatum',
            style: TextStyle(
              fontSize: AppTheme.fontSizeSm,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppTheme.paddingSmall),
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              onTap: () => _pickDate(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.paddingMedium,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: dateMissing ? AppTheme.favorite : AppTheme.border,
                  ),
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 18,
                      color:
                          selectedDate != null
                              ? AppTheme.primary
                              : AppTheme.textSecondary,
                    ),
                    const SizedBox(width: AppTheme.paddingSmall),
                    Text(
                      dateText,
                      style: TextStyle(
                        fontSize: AppTheme.fontSizeBase,
                        fontWeight:
                            selectedDate != null
                                ? FontWeight.w600
                                : FontWeight.w500,
                        color:
                            selectedDate != null
                                ? AppTheme.black
                                : AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (dateMissing)
            const Padding(
              padding: EdgeInsets.only(top: 6),
              child: Text(
                'Välj ett leveransdatum',
                style: TextStyle(
                  fontSize: AppTheme.fontSizeXs2,
                  color: AppTheme.favorite,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          const SizedBox(height: AppTheme.paddingMedium),
          // ----- Tidsfönster (dropdown) -----
          const Text(
            'Leveranstid',
            style: TextStyle(
              fontSize: AppTheme.fontSizeSm,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppTheme.paddingSmall),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.paddingMedium,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: windowMissing ? AppTheme.favorite : AppTheme.border,
              ),
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: windowId,
                isExpanded: true,
                hint: const Text(
                  'Välj leveranstid',
                  style: TextStyle(
                    fontSize: AppTheme.fontSizeBase,
                    color: AppTheme.textSecondary,
                  ),
                ),
                icon: const Icon(Icons.keyboard_arrow_down),
                items: [
                  for (final w in _deliveryWindows)
                    DropdownMenuItem<String>(
                      value: w.id,
                      child: Text(
                        w.display,
                        style: const TextStyle(
                          fontSize: AppTheme.fontSizeBase,
                          color: AppTheme.black,
                        ),
                      ),
                    ),
                ],
                onChanged: (v) {
                  if (v != null) onWindow(v);
                },
              ),
            ),
          ),
          if (windowMissing)
            const Padding(
              padding: EdgeInsets.only(top: 6),
              child: Text(
                'Välj en leveranstid',
                style: TextStyle(
                  fontSize: AppTheme.fontSizeXs2,
                  color: AppTheme.favorite,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Widget som ritar EN leveransrad (titel, undertext och pris).
// Här sätter vi egna, lite större textstorlekar direkt istället för
// temats konstanter — så att ändringen bara gäller leveransraderna
// och inte resten av appen.
class _DeliveryRow extends StatelessWidget {
  final _DeliveryOption opt;
  const _DeliveryRow({required this.opt});

  @override
  Widget build(BuildContext context) {
    final priceText =
        opt.price == 0 ? 'Gratis' : '${opt.price.toStringAsFixed(0)} kr';
    return Row(
      children: [
        // Ikonen görs också lite större så den matchar den större texten
        Icon(opt.icon, size: 26, color: AppTheme.textPrimary),
        const SizedBox(width: AppTheme.paddingMedium),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                opt.title,
                style: const TextStyle(
                  fontSize:
                      AppTheme
                          .fontSize2xl, // Titel, t.ex. "Hemleverans" (var fontSizeBase)
                  fontWeight: FontWeight.w600,
                  color: AppTheme.black,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                opt.subtitle,
                style: const TextStyle(
                  fontSize: 15, // Undertext (var fontSizeXs2)
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Text(
          priceText,
          style: const TextStyle(
            fontSize: 20, // Pris, t.ex. "49 kr" (var fontSizeSm)
            fontWeight: FontWeight.w600,
            color: AppTheme.primary,
          ),
        ),
      ],
    );
  }
}

class _AddressRow extends StatelessWidget {
  final SavedAddress address;
  final bool isDefault;
  const _AddressRow({required this.address, required this.isDefault});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                address.label,
                style: const TextStyle(
                  fontSize: AppTheme.fontSizeXl,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (isDefault) ...[
                const SizedBox(width: AppTheme.paddingSmall),
                _StdBadge(),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            address.street,
            style: const TextStyle(
              fontSize: AppTheme.fontSizeLg,
              color: AppTheme.textPrimary,
            ),
          ),
          Text(
            '${address.postCode} ${address.city}'.trim(),
            style: const TextStyle(
              fontSize: AppTheme.fontSizeLg,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _StdBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.primarySurface,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: const Text(
        'Standard',
        style: TextStyle(
          fontSize: AppTheme.fontSizeXxs,
          fontWeight: FontWeight.w500,
          color: AppTheme.primary,
        ),
      ),
    );
  }
}

class _EmptyAccountHint extends StatelessWidget {
  final String text;
  final String actionLabel;
  final VoidCallback onAction;
  const _EmptyAccountHint({
    required this.text,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: const TextStyle(
              fontSize: AppTheme.fontSizeBase,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: AppTheme.paddingSmall),
          ElevatedButton.icon(
            onPressed: onAction,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              ),
            ),
            icon: const Icon(Icons.add, size: 18),
            label: Text(
              actionLabel,
              style: const TextStyle(
                fontSize: AppTheme.fontSizeBase,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- Step 2: Betalning ----------

class _PaymentStep extends StatelessWidget {
  final String deliveryId;
  final String paymentId;
  final ValueChanged<String> onPayment;
  final int cardIndex;
  final ValueChanged<int> onCard;
  final VoidCallback onContinue;

  const _PaymentStep({
    required this.deliveryId,
    required this.paymentId,
    required this.onPayment,
    required this.cardIndex,
    required this.onCard,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final iMat = context.watch<ImatDataHandler>();
    final cards = AccountData.cards(iMat);
    final defCard = AccountData.defaultCardIndex(iMat);
    final canContinue =
        paymentId != 'card' || (cards.isNotEmpty && cardIndex >= 0);

    return _StepLayout(
      deliveryId: deliveryId,
      left: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: AppTheme.paddingMedium),
                  child: Text(
                    'Betalmetod',
                    style: TextStyle(
                      fontSize: AppTheme.fontSizeXl,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                for (int i = 0; i < _paymentOptions.length; i++) ...[
                  _OptionTile(
                    selected: paymentId == _paymentOptions[i].id,
                    onTap: () => onPayment(_paymentOptions[i].id),
                    child: _PaymentRow(opt: _paymentOptions[i]),
                  ),
                  if (i < _paymentOptions.length - 1)
                    const SizedBox(height: AppTheme.paddingMediumSmall),
                ],
              ],
            ),
          ),
          // "Sparade kort" ligger nu i ett eget kort med mellanrum ovanför,
          // på samma sätt som "Leveransadress" är skilt från "Leveranssätt".
          if (paymentId == 'card') ...[
            const SizedBox(height: AppTheme.paddingLarge),
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: AppTheme.paddingMedium),
                    child: Text(
                      'Sparade kort',
                      style: TextStyle(
                        fontSize: AppTheme.fontSizeXl,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (cards.isEmpty)
                    _EmptyAccountHint(
                      text: 'Du har inga sparade kort ännu.',
                      actionLabel: 'Lägg till kort',
                      onAction: () => showAccountModal(context),
                    )
                  else
                    for (int i = 0; i < cards.length; i++) ...[
                      _OptionTile(
                        selected: cardIndex == i,
                        onTap: () => onCard(i),
                        child: _CardRow(
                          card: cards[i],
                          isDefault: i == defCard,
                        ),
                      ),
                      if (i < cards.length - 1)
                        const SizedBox(height: AppTheme.paddingMediumSmall),
                    ],
                  const SizedBox(height: AppTheme.paddingMediumSmall),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _SecondaryButton(
                      label: 'Hantera kort',
                      onPressed: () => showAccountModal(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppTheme.paddingLarge),
          _PrimaryButton(
            label: 'Granska beställning',
            onPressed: canContinue ? onContinue : null,
          ),
        ],
      ),
    );
  }
}

// Widget som ritar EN betalmetodsrad (titel + undertext).
// Samma som leveransraderna: vi sätter egna, större textstorlekar
// direkt här så att bara betalraderna påverkas.
class _PaymentRow extends StatelessWidget {
  final _PaymentOption opt;
  const _PaymentRow({required this.opt});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Ikonen görs lite större så den matchar den större texten
        Icon(opt.icon, size: 26, color: AppTheme.textPrimary),
        const SizedBox(width: AppTheme.paddingMedium),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                opt.title,
                style: const TextStyle(
                  fontSize: 20, // Titel, t.ex. "Bankkort" (var fontSizeBase)
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                opt.subtitle,
                style: const TextStyle(
                  fontSize: 15, // Undertext (var fontSizeXs2)
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CardRow extends StatelessWidget {
  final SavedCard card;
  final bool isDefault;
  const _CardRow({required this.card, required this.isDefault});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.credit_card, size: 20, color: AppTheme.textPrimary),
        const SizedBox(width: AppTheme.paddingMediumSmall),
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
                    _StdBadge(),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Text(
                '${card.holder.toUpperCase()}  •  ${card.expiry}',
                style: const TextStyle(
                  fontSize: AppTheme.fontSizeXs,
                  color: AppTheme.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------- Step 3: Granska ----------

class _ReviewStep extends StatelessWidget {
  final String deliveryId;
  final int addressIndex;
  final String paymentId;
  final int cardIndex;
  final DateTime? selectedDate;
  final String? windowId;
  final VoidCallback onConfirm;

  const _ReviewStep({
    required this.deliveryId,
    required this.addressIndex,
    required this.paymentId,
    required this.cardIndex,
    required this.selectedDate,
    required this.windowId,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final iMat = context.watch<ImatDataHandler>();
    final addresses = AccountData.addresses(iMat);
    final cards = AccountData.cards(iMat);
    final items = iMat.getShoppingCart().items;
    final subtotal = iMat.shoppingCartTotal();
    final delivery =
        _deliveryOptions.firstWhere((d) => d.id == deliveryId).price;
    final total = subtotal + delivery;
    final paymentLabel =
        _paymentOptions.firstWhere((p) => p.id == paymentId).title;

    final SavedAddress? addr =
        (addressIndex >= 0 && addressIndex < addresses.length)
            ? addresses[addressIndex]
            : null;
    final SavedCard? card =
        (paymentId == 'card' && cardIndex >= 0 && cardIndex < cards.length)
            ? cards[cardIndex]
            : null;

    final addressLines =
        addr == null
            ? ['(ingen adress vald)']
            : [addr.street, '${addr.postCode} ${addr.city}'.trim()];

    final deliveryTitle =
        _deliveryOptions.firstWhere((d) => d.id == deliveryId).title;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.paddingLarge),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: _Card(
            padding: const EdgeInsets.all(AppTheme.paddingHuge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        color: AppTheme.primarySurface,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.shopping_cart_outlined,
                        color: AppTheme.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: AppTheme.paddingMedium),
                    const Expanded(
                      child: Text(
                        'Granska din beställning',
                        style: TextStyle(
                          fontSize: AppTheme.fontSize4xl,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.paddingLarge),
                _ReviewSection(
                  title: 'Leverans',
                  children: [
                    Text(
                      deliveryTitle,
                      style: const TextStyle(
                        fontSize: AppTheme.fontSizeBase,
                        color: AppTheme.black,
                      ),
                    ),
                    // Visa valt datum/tidsfönster vid hemleverans.
                    if (deliveryId == 'home' &&
                        selectedDate != null &&
                        windowId != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${_formatDate(selectedDate)} · ${_windowById(windowId)?.display ?? ''}',
                        style: const TextStyle(
                          fontSize: AppTheme.fontSizeBase,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    for (final l in addressLines)
                      Text(
                        l,
                        style: const TextStyle(
                          fontSize: AppTheme.fontSizeBase,
                          color: AppTheme.black,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppTheme.paddingLarge),
                _ReviewSection(
                  title: 'Betalmetod',
                  children: [
                    Text(
                      paymentLabel,
                      style: const TextStyle(
                        fontSize: AppTheme.fontSizeBase,
                        color: AppTheme.black,
                      ),
                    ),
                    if (paymentId == 'card' && card != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '•••• ${card.last4}',
                        style: const TextStyle(
                          fontSize: AppTheme.fontSizeBase,
                          color: AppTheme.black,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: AppTheme.paddingLarge),
                _ReviewSection(
                  title: 'Produkter',
                  children: [
                    for (final item in items)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${item.amount.toStringAsFixed(0)}x ${item.product.name}',
                                style: const TextStyle(
                                  fontSize: AppTheme.fontSizeBase,
                                ),
                              ),
                            ),
                            Text(
                              '${(item.product.price * item.amount).toStringAsFixed(2)} kr',
                              style: const TextStyle(
                                fontSize: AppTheme.fontSizeBase,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppTheme.paddingMedium),
                const Divider(color: AppTheme.border, height: 1),
                const SizedBox(height: AppTheme.paddingMedium),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Totalt att betala:',
                      style: TextStyle(
                        fontSize: AppTheme.fontSizeXl,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${total.toStringAsFixed(2)} kr',
                      style: const TextStyle(
                        fontSize: AppTheme.fontSize3xl,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.paddingLarge),
                _PrimaryButton(
                  label: 'Genomför beställning',
                  icon: Icons.check,
                  onPressed: onConfirm,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ReviewSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _ReviewSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: AppTheme.fontSizeXs2,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
        ...children,
      ],
    );
  }
}

// ---------- Step 4: Bekräftelse ----------

class _DoneStep extends StatelessWidget {
  final Order? order;
  final double deliveryCost;
  final String deliveryId;
  final DateTime? selectedDate;
  final String? windowId;
  const _DoneStep({
    required this.order,
    required this.deliveryCost,
    required this.deliveryId,
    required this.selectedDate,
    required this.windowId,
  });

  @override
  Widget build(BuildContext context) {
    final iMat = context.watch<ImatDataHandler>();
    final email =
        iMat.getCustomer().email.isEmpty
            ? 'din e-post'
            : iMat.getCustomer().email;
    final orderNumber = order?.orderNumber.toString() ?? '—';
    final total =
        order != null ? order!.getTotal() + deliveryCost : deliveryCost;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.paddingLarge),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: _Card(
            padding: const EdgeInsets.all(AppTheme.paddingHuge),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: AppTheme.primarySurface,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.check,
                    color: AppTheme.primary,
                    size: 44,
                  ),
                ),
                const SizedBox(height: AppTheme.paddingLarge),
                const Text(
                  'Beställning lagd!',
                  style: TextStyle(
                    fontSize: AppTheme.fontSize5xl,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppTheme.paddingMediumSmall),
                Text(
                  'Tack för din beställning. Du får en bekräftelse på\n$email',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: AppTheme.fontSizeBase,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: AppTheme.paddingLarge),
                Container(
                  padding: const EdgeInsets.all(AppTheme.paddingMedium),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Ordernummer:',
                            style: TextStyle(fontSize: AppTheme.fontSizeBase),
                          ),
                          Text(
                            '#$orderNumber',
                            style: const TextStyle(
                              fontSize: AppTheme.fontSizeBase,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Visa vald leveranstid vid hemleverans.
                      if (deliveryId == 'home' &&
                          selectedDate != null &&
                          windowId != null) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Leverans:',
                              style: TextStyle(fontSize: AppTheme.fontSizeBase),
                            ),
                            Flexible(
                              child: Text(
                                '${_formatDate(selectedDate)} · ${_windowById(windowId)?.display ?? ''}',
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  fontSize: AppTheme.fontSizeBase,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Totalt:',
                            style: TextStyle(
                              fontSize: AppTheme.fontSizeLg,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primary,
                            ),
                          ),
                          Text(
                            '${total.toStringAsFixed(2)} kr',
                            style: const TextStyle(
                              fontSize: AppTheme.fontSizeXl,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppTheme.paddingLarge),
                _PrimaryButton(
                  label: 'Tillbaka till butiken',
                  fullWidth: false,
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------- Primary button ----------

class _PrimaryButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool fullWidth;
  // Storlek på knapptexten. Standard matchar övriga primärknappar (fontSizeMd),
  // men kan höjas för enstaka knappar.
  final double labelSize;
  const _PrimaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.fullWidth = true,
    this.labelSize = AppTheme.fontSizeMd,
  });

  @override
  Widget build(BuildContext context) {
    final btn = ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        disabledBackgroundColor: AppTheme.border,
        disabledForegroundColor: AppTheme.textSecondary,
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.paddingHuge,
          vertical: 18,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        ),
        elevation: 0,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20),
            const SizedBox(width: AppTheme.paddingSmall),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: labelSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
    return fullWidth ? SizedBox(width: double.infinity, child: btn) : btn;
  }
}

// ---------- Secondary (manage) button ----------

// Mindre, mindre framträdande knapp för "Hantera"-åtgärder.
// Använder en grön bakgrund med låg opacitet och grön text, så att den
// tydligt skiljer sig från den prominenta _PrimaryButton (Fortsätt-knappen).
class _SecondaryButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  const _SecondaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        // Grön bakgrund med låg opacitet + grön text/ikon.
        backgroundColor: AppTheme.primary.withValues(alpha: 0.12),
        foregroundColor: AppTheme.primary,
        // Mindre inre marginaler => mindre knapp än Fortsätt-knappen.
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.paddingMedium,
          vertical: AppTheme.paddingMediumSmall,
        ),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18),
            const SizedBox(width: AppTheme.paddingSmall),
          ],
          Text(
            label,
            style: const TextStyle(
              fontSize: AppTheme.fontSizeSm,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}