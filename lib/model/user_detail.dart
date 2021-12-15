import 'dart:convert';

import 'address.dart';

class UserDetail {
  String name;
  String? title, firstName, lastName, phone, additionalEmail, company, position;
  Address address, deliveryAddress;
  Address? invoiceBillAddress, invoiceBillingSettlementAddress;
  UserDetail({
    required this.name,
    this.title,
    this.firstName,
    this.lastName,
    this.phone,
    this.additionalEmail,
    this.company,
    this.position,
    required this.address,
    required this.deliveryAddress,
    this.invoiceBillAddress,
    this.invoiceBillingSettlementAddress,
  });

  UserDetail copyWith({
    String? name,
    String? title,
    String? firstName,
    String? lastName,
    String? phone,
    String? additionalEmail,
    String? company,
    String? position,
    Address? address,
    Address? deliveryAddress,
    Address? invoiceBillAddress,
    Address? invoiceBillingSettlementAddress,
  }) {
    return UserDetail(
      name: name ?? this.name,
      title: title ?? this.title,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      additionalEmail: additionalEmail ?? this.additionalEmail,
      company: company ?? this.company,
      position: position ?? this.position,
      address: address ?? this.address,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      invoiceBillAddress: invoiceBillAddress ?? this.invoiceBillAddress,
      invoiceBillingSettlementAddress: invoiceBillingSettlementAddress ??
          this.invoiceBillingSettlementAddress,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'title': title,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'additionalEmail': additionalEmail,
      'company': company,
      'position': position,
      'address': address.toMap(),
      'deliveryAddress': deliveryAddress.toMap(),
      'invoiceBillAddress': invoiceBillAddress?.toMap(),
      'invoiceBillingSettlementAddress':
          invoiceBillingSettlementAddress?.toMap(),
    };
  }

  factory UserDetail.fromMap(Map<String, dynamic> map) {
    return UserDetail(
      name: map['name'],
      title: map['title'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      phone: map['phone'],
      additionalEmail: map['additionalEmail'],
      company: map['company'],
      position: map['position'],
      address: Address.fromMap(map['address']),
      deliveryAddress: Address.fromMap(map['deliveryAddress']),
      invoiceBillAddress: map['invoiceBillAddress'] != null
          ? Address.fromMap(map['invoiceBillAddress'])
          : null,
      invoiceBillingSettlementAddress:
          map['invoiceBillingSettlementAddress'] != null
              ? Address.fromMap(map['invoiceBillingSettlementAddress'])
              : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserDetail.fromJson(String source) =>
      UserDetail.fromMap(json.decode(source));

  @override
  String toString() {
    return 'UserDetail(name: $name, title: $title, firstName: $firstName, lastName: $lastName, phone: $phone additionalEmail: $additionalEmail, company: $company, position: $position, address: $address, deliveryAddress: $deliveryAddress, invoiceBillAddress: $invoiceBillAddress, invoiceBillingSettlementAddress: $invoiceBillingSettlementAddress)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserDetail &&
        other.name == name &&
        other.title == title &&
        other.firstName == firstName &&
        other.lastName == lastName &&
        other.phone == phone &&
        other.additionalEmail == additionalEmail &&
        other.company == company &&
        other.position == position &&
        other.address == address &&
        other.deliveryAddress == deliveryAddress &&
        other.invoiceBillAddress == invoiceBillAddress &&
        other.invoiceBillingSettlementAddress ==
            invoiceBillingSettlementAddress;
  }

  @override
  int get hashCode {
    return name.hashCode ^
        title.hashCode ^
        firstName.hashCode ^
        lastName.hashCode ^
        phone.hashCode ^
        additionalEmail.hashCode ^
        company.hashCode ^
        position.hashCode ^
        address.hashCode ^
        deliveryAddress.hashCode ^
        invoiceBillAddress.hashCode ^
        invoiceBillingSettlementAddress.hashCode;
  }
}
