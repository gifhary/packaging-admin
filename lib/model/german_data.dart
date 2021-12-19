import 'dart:convert';

import 'package:admin/model/data_group.dart';

class GermanData {
  DataGroup germanOffered;
  DataGroup purchaseOrder;
  DataGroup orderConfirm;
  String dnSi;
  String invoice;
  GermanData({
    required this.germanOffered,
    required this.purchaseOrder,
    required this.orderConfirm,
    required this.dnSi,
    required this.invoice,
  });

  GermanData copyWith({
    DataGroup? germanOffered,
    DataGroup? purchaseOrder,
    DataGroup? orderConfirm,
    String? dnSi,
    String? invoice,
  }) {
    return GermanData(
      germanOffered: germanOffered ?? this.germanOffered,
      purchaseOrder: purchaseOrder ?? this.purchaseOrder,
      orderConfirm: orderConfirm ?? this.orderConfirm,
      dnSi: dnSi ?? this.dnSi,
      invoice: invoice ?? this.invoice,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'germanOffered': germanOffered.toMap(),
      'purchaseOrder': purchaseOrder.toMap(),
      'orderConfirm': orderConfirm.toMap(),
      'dnSi': dnSi,
      'invoice': invoice,
    };
  }

  factory GermanData.fromMap(Map<String, dynamic> map) {
    return GermanData(
      germanOffered: DataGroup.fromMap(map['germanOffered']),
      purchaseOrder: DataGroup.fromMap(map['purchaseOrder']),
      orderConfirm: DataGroup.fromMap(map['orderConfirm']),
      dnSi: map['dnSi'] ?? '',
      invoice: map['invoice'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory GermanData.fromJson(String source) =>
      GermanData.fromMap(json.decode(source));

  @override
  String toString() {
    return 'GermanData(germanOffered: $germanOffered, purchaseOrder: $purchaseOrder, orderConfirm: $orderConfirm, dnSi: $dnSi, invoice: $invoice)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is GermanData &&
        other.germanOffered == germanOffered &&
        other.purchaseOrder == purchaseOrder &&
        other.orderConfirm == orderConfirm &&
        other.dnSi == dnSi &&
        other.invoice == invoice;
  }

  @override
  int get hashCode {
    return germanOffered.hashCode ^
        purchaseOrder.hashCode ^
        orderConfirm.hashCode ^
        dnSi.hashCode ^
        invoice.hashCode;
  }
}
