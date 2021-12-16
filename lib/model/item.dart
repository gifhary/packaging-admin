import 'dart:convert';

import 'package:admin/model/order_list.dart';

class Item {
  String orderId;
  OrderData orderData;
  Item({
    required this.orderId,
    required this.orderData,
  });

  Item copyWith({
    String? orderId,
    OrderData? orderData,
  }) {
    return Item(
      orderId: orderId ?? this.orderId,
      orderData: orderData ?? this.orderData,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'orderData': orderData.toMap(),
    };
  }

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      orderId: map['orderId'],
      orderData: OrderData.fromMap(map['orderData']),
    );
  }

  String toJson() => json.encode(toMap());

  factory Item.fromJson(String source) => Item.fromMap(json.decode(source));

  @override
  String toString() => 'Item(orderId: $orderId, orderData: $orderData)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Item &&
        other.orderId == orderId &&
        other.orderData == orderData;
  }

  @override
  int get hashCode => orderId.hashCode ^ orderData.hashCode;
}
