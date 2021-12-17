import 'dart:convert';

class Staff {
  String name;
  String signature;
  Staff({
    required this.name,
    required this.signature,
  });

  Staff copyWith({
    String? name,
    String? signature,
  }) {
    return Staff(
      name: name ?? this.name,
      signature: signature ?? this.signature,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'signature': signature,
    };
  }

  factory Staff.fromMap(Map<String, dynamic> map) {
    return Staff(
      name: map['name'] ?? '',
      signature: map['signature'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Staff.fromJson(String source) => Staff.fromMap(json.decode(source));

  @override
  String toString() => 'Staff(name: $name, signature: $signature)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Staff && other.name == name && other.signature == signature;
  }

  @override
  int get hashCode => name.hashCode ^ signature.hashCode;
}
