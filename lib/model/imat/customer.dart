class Customer {
  String firstName;
  String lastName;
  String phoneNumber;
  String mobilePhoneNumber;
  String email;
  String address;
  String postCode;
  String postAddress;

  Customer(
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.mobilePhoneNumber,
    this.email,
    this.address,
    this.postCode,
    this.postAddress,
  );

  Customer.fromJson(Map<String, dynamic> json)
    : firstName = json[_firstName],
      lastName = json[_lastName],
      phoneNumber = json[_phone],
      mobilePhoneNumber = json[_mobile],
      email = json[_email],
      address = json[_address],
      postCode = json[_postCode],
      postAddress = json[_postAddress];

  Map<String, dynamic> toJson() => {
    _firstName: firstName,
    _lastName: lastName,
    _phone: phoneNumber,
    _mobile: mobilePhoneNumber,
    _email: email,
    _address: address,
    _postCode: postCode,
    _postAddress: postAddress,
  };

  static const _firstName = 'firstName';
  static const _lastName = 'lastName';
  static const _phone = 'phoneNumber';
  static const _mobile = 'mobilePhoneNumber';
  static const _email = 'email';
  static const _address = 'address';
  static const _postCode = 'postCode';
  static const _postAddress = 'postAddress';
}
