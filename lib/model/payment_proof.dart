import 'dart:convert';

class PaymentProof {
  String imgUrl;
  String paymentDate;
  PaymentProof({
    required this.imgUrl,
    required this.paymentDate,
  });

  PaymentProof copyWith({
    String? imgUrl,
    String? paymentDate,
  }) {
    return PaymentProof(
      imgUrl: imgUrl ?? this.imgUrl,
      paymentDate: paymentDate ?? this.paymentDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'imgUrl': imgUrl,
      'paymentDate': paymentDate,
    };
  }

  factory PaymentProof.fromMap(Map<String, dynamic> map) {
    return PaymentProof(
      imgUrl: map['imgUrl'] ?? '',
      paymentDate: map['paymentDate'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory PaymentProof.fromJson(String source) =>
      PaymentProof.fromMap(json.decode(source));

  @override
  String toString() =>
      'PaymentProof(imgUrl: $imgUrl, paymentDate: $paymentDate)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PaymentProof &&
        other.imgUrl == imgUrl &&
        other.paymentDate == paymentDate;
  }

  @override
  int get hashCode => imgUrl.hashCode ^ paymentDate.hashCode;
}
