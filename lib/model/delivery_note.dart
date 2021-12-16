import 'dart:convert';

class DeliveryNote {
  String refNo;
  String rnNo;
  String date;
  String imgUrl;
  DeliveryNote({
    required this.refNo,
    required this.rnNo,
    required this.date,
    required this.imgUrl,
  });

  DeliveryNote copyWith({
    String? refNo,
    String? rnNo,
    String? date,
    String? imgUrl,
  }) {
    return DeliveryNote(
      refNo: refNo ?? this.refNo,
      rnNo: rnNo ?? this.rnNo,
      date: date ?? this.date,
      imgUrl: imgUrl ?? this.imgUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'refNo': refNo,
      'rnNo': rnNo,
      'date': date,
      'imgUrl': imgUrl,
    };
  }

  factory DeliveryNote.fromMap(Map<String, dynamic> map) {
    return DeliveryNote(
      refNo: map['refNo'] ?? '',
      rnNo: map['rnNo'] ?? '',
      date: map['date'] ?? '',
      imgUrl: map['imgUrl'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory DeliveryNote.fromJson(String source) =>
      DeliveryNote.fromMap(json.decode(source));

  @override
  String toString() {
    return 'DeliveryNote(refNo: $refNo, rnNo: $rnNo, date: $date, imgUrl: $imgUrl)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DeliveryNote &&
        other.refNo == refNo &&
        other.rnNo == rnNo &&
        other.date == date &&
        other.imgUrl == imgUrl;
  }

  @override
  int get hashCode {
    return refNo.hashCode ^ rnNo.hashCode ^ date.hashCode ^ imgUrl.hashCode;
  }
}
