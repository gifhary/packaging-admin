import 'dart:convert';

import 'package:admin/model/user_detail.dart';

class User {
  String email;
  String password;
  UserDetail? userDetail;
  User({
    required this.email,
    required this.password,
    this.userDetail,
  });

  User copyWith({
    String? email,
    String? password,
    UserDetail? userDetail,
  }) {
    return User(
      email: email ?? this.email,
      password: password ?? this.password,
      userDetail: userDetail ?? this.userDetail,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'password': password,
      'userDetail': userDetail?.toMap(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      email: map['email'],
      password: map['password'],
      userDetail: map['userDetail'] != null
          ? UserDetail.fromMap(map['userDetail'])
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) => User.fromMap(json.decode(source));

  @override
  String toString() =>
      'User(email: $email, password: $password, userDetail: $userDetail)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is User &&
        other.email == email &&
        other.password == password &&
        other.userDetail == userDetail;
  }

  @override
  int get hashCode => email.hashCode ^ password.hashCode ^ userDetail.hashCode;
}
