class CreditCard {
  String cardType;
  String holdersName;
  int validMonth;
  int validYear;
  String cardNumber;
  int verificationCode;

  CreditCard(
    this.cardType,
    this.holdersName,
    this.validMonth,
    this.validYear,
    this.cardNumber,
    this.verificationCode,
  );

  CreditCard.fromJson(Map<String, dynamic> json)
    : cardType = json[_typeKey],
      holdersName = json[_nameKey],
      validMonth = json[_monthKey],
      validYear = json[_yearKey],
      cardNumber = json[_numberKey],
      verificationCode = json[_verificationKey];

  Map<String, dynamic> toJson() => {
    _typeKey: cardType,
    _nameKey: holdersName,
    _monthKey: validMonth,
    _yearKey: validYear,
    _numberKey: cardNumber,
    _verificationKey: verificationCode,
  };

  static const _typeKey = 'cardType';
  static const _nameKey = 'holdersName';
  static const _monthKey = 'validMonth';
  static const _yearKey = 'validYear';
  static const _numberKey = 'cardNumber';
  static const _verificationKey = 'verificationCode';
}
