import 'dart:convert';

class Address {
  String address1, city, zipcode, country;
  String? address2, street;
  Address({
    required this.address1,
    this.address2,
    this.street,
    required this.city,
    required this.zipcode,
    required this.country,
  });

  Address copyWith({
    String? address1,
    String? address2,
    String? street,
    String? city,
    String? zipcode,
    String? country,
  }) {
    return Address(
      address1: address1 ?? this.address1,
      address2: address2 ?? this.address2,
      street: street ?? this.street,
      city: city ?? this.city,
      zipcode: zipcode ?? this.zipcode,
      country: country ?? this.country,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'address1': address1,
      'address2': address2,
      'street': street,
      'city': city,
      'zipcode': zipcode,
      'country': country,
    };
  }

  factory Address.fromMap(Map<String, dynamic> map) {
    return Address(
      address1: map['address1'],
      address2: map['address2'],
      street: map['street'],
      city: map['city'],
      zipcode: map['zipcode'],
      country: map['country'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Address.fromJson(String source) =>
      Address.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Address(address1: $address1, address2: $address2, street: $street, city: $city, zipcode: $zipcode, country: $country)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Address &&
        other.address1 == address1 &&
        other.address2 == address2 &&
        other.street == street &&
        other.city == city &&
        other.zipcode == zipcode &&
        other.country == country;
  }

  @override
  int get hashCode {
    return address1.hashCode ^
        address2.hashCode ^
        street.hashCode ^
        city.hashCode ^
        zipcode.hashCode ^
        country.hashCode;
  }
}
