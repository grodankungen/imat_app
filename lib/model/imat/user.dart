class User {
  String userName;
  String password;

  User(this.userName, this.password);

  User.fromJson(Map<String, dynamic> json)
    : userName = json[_userName],
      password = json[_password];

  Map<String, dynamic> toJson() => {_userName: userName, _password: password};

  static const _userName = 'userName';
  static const _password = 'password';
}
