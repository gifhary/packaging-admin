import 'dart:convert';
import 'package:flutter/foundation.dart';

class OrderList {
  Map<String, OrderData> orderData;
  OrderList({
    required this.orderData,
  });
//TODO here
  factory OrderList.fromMap(Map<String, dynamic> map) {
    return OrderList(
      orderData: Map<String, OrderData>.from(map),
    );
  }

  factory OrderList.fromJson(String source) =>
      OrderList.fromMap(json.decode(source));

  @override
  String toString() => 'OrderList(orderData: $orderData)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is OrderList && mapEquals(other.orderData, orderData);
  }

  @override
  int get hashCode => orderData.hashCode;
}

class OrderData {
  String orderTitle;
  bool approvedByCustomer;
  bool confirmedBySales;
  bool delivered;
  String orderTime;
  String? deliveryNoteConfirmedDate;
  Map<String, MachineData> machineList;

  OrderData({
    required this.orderTitle,
    required this.approvedByCustomer,
    required this.confirmedBySales,
    required this.delivered,
    required this.orderTime,
    this.deliveryNoteConfirmedDate,
    required this.machineList,
  });

  factory OrderData.fromMap(Map<String, dynamic> json) => OrderData(
          delivered: json['delivered'],
          approvedByCustomer: json['approvedByCustomer'],
          orderTitle: json['orderTitle'],
          confirmedBySales: json['confirmedBySales'],
          orderTime: json['orderTime'],
          deliveryNoteConfirmedDate: json['deliveryNoteConfirmedDate'],
          machineList: {
            for (String machineKey in json['machineList'].keys)
              machineKey: MachineData(
                machineType: json['machineList'][machineKey]['machineType'],
                partRequest: {
                  for (String key
                      in json['machineList'][machineKey]['partRequest'].keys)
                    key: PartData(
                      partNumber: json['machineList'][machineKey]['partRequest']
                          [key]['partNumber'],
                      itemName: json['machineList'][machineKey]['partRequest']
                          [key]['itemName'],
                      quantity: json['machineList'][machineKey]['partRequest']
                          [key]['quantity'],
                    )
                },
              )
          });

  Map<String, dynamic> toMap() => {
        'delivered': delivered,
        "orderTitle": orderTitle,
        'approvedByCustomer': approvedByCustomer,
        "orderTime": orderTime,
        'confirmedBySales': confirmedBySales,
        'deliveryNoteConfirmedDate': deliveryNoteConfirmedDate,
        "machineList": {
          for (String machineKey in machineList.keys)
            machineKey: {
              'machineType': machineList[machineKey]!.machineType,
              'partRequest': {
                for (String partKey
                    in machineList[machineKey]!.partRequest.keys)
                  partKey: {
                    'partNumber': machineList[machineKey]!
                        .partRequest[partKey]!
                        .partNumber,
                    'itemName':
                        machineList[machineKey]!.partRequest[partKey]!.itemName,
                    'quantity':
                        machineList[machineKey]!.partRequest[partKey]!.quantity
                  }
              }
            },
        },
      };

  String toJson() => json.encode(toMap());
}

class MachineData {
  String machineType;
  Map<String, PartData> partRequest;

  MachineData({required this.machineType, required this.partRequest});
}

class PartData {
  String partNumber;
  String itemName;
  int quantity;

  PartData({
    required this.partNumber,
    required this.itemName,
    required this.quantity,
  });
}
