import 'package:imat_app/model/imat_data_handler.dart';

/// User-managed data persisted via the backend's `extras` JSON store.
/// (Backend only has a single Customer + CreditCard, so we keep our own
/// list of addresses and saved cards in extras.)

class SavedAddress {
  String label;
  String street;
  String postCode;
  String city;
  String phone;

  SavedAddress({
    required this.label,
    required this.street,
    required this.postCode,
    required this.city,
    this.phone = '',
  });

  Map<String, dynamic> toJson() => {
        'label': label,
        'street': street,
        'postCode': postCode,
        'city': city,
        'phone': phone,
      };

  factory SavedAddress.fromJson(Map json) => SavedAddress(
        label: json['label']?.toString() ?? '',
        street: json['street']?.toString() ?? '',
        postCode: json['postCode']?.toString() ?? '',
        city: json['city']?.toString() ?? '',
        phone: json['phone']?.toString() ?? '',
      );
}

class SavedCard {
  String holder;
  String number;
  int month;
  int year;

  SavedCard({
    required this.holder,
    required this.number,
    required this.month,
    required this.year,
  });

  String get last4 {
    final clean = number.replaceAll(RegExp(r'\s+'), '');
    if (clean.length < 4) return clean;
    return clean.substring(clean.length - 4);
  }

  String get expiry =>
      '${month.toString().padLeft(2, '0')}/${(year % 100).toString().padLeft(2, '0')}';

  Map<String, dynamic> toJson() => {
        'holder': holder,
        'number': number,
        'month': month,
        'year': year,
      };

  factory SavedCard.fromJson(Map json) => SavedCard(
        holder: json['holder']?.toString() ?? '',
        number: json['number']?.toString() ?? '',
        month: (json['month'] as num?)?.toInt() ?? 1,
        year: (json['year'] as num?)?.toInt() ?? DateTime.now().year,
      );
}

/// Order metadata not provided by the backend Order: delivery method and
/// payment method, keyed by order number.
class OrderMeta {
  final String delivery;
  final String payment;
  const OrderMeta({required this.delivery, required this.payment});

  Map<String, dynamic> toJson() => {
        'delivery': delivery,
        'payment': payment,
      };

  factory OrderMeta.fromJson(Map json) => OrderMeta(
        delivery: json['delivery']?.toString() ?? 'home',
        payment: json['payment']?.toString() ?? 'card',
      );
}

class AccountData {
  static const _kAddresses = 'accountAddresses';
  static const _kAddressDefault = 'accountAddressDefault';
  static const _kCards = 'accountCards';
  static const _kCardDefault = 'accountCardDefault';
  static const _kOrderMeta = 'accountOrderMeta';
  static const _kLoggedOut = 'accountLoggedOut';

  static List<SavedAddress> addresses(ImatDataHandler iMat) {
    final raw = iMat.getExtras()[_kAddresses];
    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((e) => SavedAddress.fromJson(e))
          .toList();
    }
    return [];
  }

  static int defaultAddressIndex(ImatDataHandler iMat) {
    final raw = iMat.getExtras()[_kAddressDefault];
    final list = addresses(iMat);
    if (list.isEmpty) return -1;
    if (raw is num) {
      final i = raw.toInt();
      if (i >= 0 && i < list.length) return i;
    }
    return 0;
  }

  static void addAddress(ImatDataHandler iMat, SavedAddress a) {
    final list = addresses(iMat).map((e) => e.toJson()).toList();
    list.add(a.toJson());
    iMat.addExtra(_kAddresses, list);
    // Set as default if it's the only one
    if (list.length == 1) {
      iMat.addExtra(_kAddressDefault, 0);
    }
  }

  static void updateAddress(
      ImatDataHandler iMat, int index, SavedAddress a) {
    final list = addresses(iMat).map((e) => e.toJson()).toList();
    if (index < 0 || index >= list.length) return;
    list[index] = a.toJson();
    iMat.addExtra(_kAddresses, list);
  }

  static void removeAddress(ImatDataHandler iMat, int index) {
    final list = addresses(iMat).map((e) => e.toJson()).toList();
    if (index < 0 || index >= list.length) return;
    list.removeAt(index);
    iMat.addExtra(_kAddresses, list);
    final def = defaultAddressIndex(iMat);
    if (def >= list.length) {
      iMat.addExtra(_kAddressDefault, list.isEmpty ? -1 : 0);
    }
  }

  static void setDefaultAddress(ImatDataHandler iMat, int index) {
    iMat.addExtra(_kAddressDefault, index);
  }

  static List<SavedCard> cards(ImatDataHandler iMat) {
    final raw = iMat.getExtras()[_kCards];
    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((e) => SavedCard.fromJson(e))
          .toList();
    }
    return [];
  }

  static int defaultCardIndex(ImatDataHandler iMat) {
    final raw = iMat.getExtras()[_kCardDefault];
    final list = cards(iMat);
    if (list.isEmpty) return -1;
    if (raw is num) {
      final i = raw.toInt();
      if (i >= 0 && i < list.length) return i;
    }
    return 0;
  }

  static void addCard(ImatDataHandler iMat, SavedCard c) {
    final list = cards(iMat).map((e) => e.toJson()).toList();
    list.add(c.toJson());
    iMat.addExtra(_kCards, list);
    if (list.length == 1) {
      iMat.addExtra(_kCardDefault, 0);
    }
  }

  static void updateCard(ImatDataHandler iMat, int index, SavedCard c) {
    final list = cards(iMat).map((e) => e.toJson()).toList();
    if (index < 0 || index >= list.length) return;
    list[index] = c.toJson();
    iMat.addExtra(_kCards, list);
  }

  static void removeCard(ImatDataHandler iMat, int index) {
    final list = cards(iMat).map((e) => e.toJson()).toList();
    if (index < 0 || index >= list.length) return;
    list.removeAt(index);
    iMat.addExtra(_kCards, list);
    final def = defaultCardIndex(iMat);
    if (def >= list.length) {
      iMat.addExtra(_kCardDefault, list.isEmpty ? -1 : 0);
    }
  }

  static void setDefaultCard(ImatDataHandler iMat, int index) {
    iMat.addExtra(_kCardDefault, index);
  }

  /// Order metadata: delivery + payment per order number.
  static OrderMeta? orderMeta(ImatDataHandler iMat, int orderNumber) {
    final raw = iMat.getExtras()[_kOrderMeta];
    if (raw is Map) {
      final v = raw[orderNumber.toString()];
      if (v is Map) return OrderMeta.fromJson(v);
    }
    return null;
  }

  static void setOrderMeta(
    ImatDataHandler iMat,
    int orderNumber,
    OrderMeta meta,
  ) {
    final raw = iMat.getExtras()[_kOrderMeta];
    final Map<String, dynamic> map = (raw is Map)
        ? Map<String, dynamic>.from(raw)
        : <String, dynamic>{};
    map[orderNumber.toString()] = meta.toJson();
    iMat.addExtra(_kOrderMeta, map);
  }

  static bool isLoggedIn(ImatDataHandler iMat) {
    return iMat.getExtras()[_kLoggedOut] != true;
  }

  static void setLoggedIn(ImatDataHandler iMat, bool loggedIn) {
    iMat.addExtra(_kLoggedOut, !loggedIn);
  }
}

const deliveryLabels = {
  'home': 'Hemleverans',
  'pickup': 'Hämta i butik',
  'express': 'Expressleverans',
};

const paymentLabels = {
  'card': 'Bankkort',
  'swish': 'Swish',
  'invoice': 'Faktura',
};
