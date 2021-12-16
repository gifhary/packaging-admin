import 'dart:convert';

class OrderList {
  Map<String, OrderData> orderData;
  OrderList({
    required this.orderData,
  });

  factory OrderList.fromMap(Map<String, dynamic> map) => OrderList(orderData: {
        for (String key in map.keys) key: OrderData.fromMap(map[key])
      });

  Map<String, dynamic> toMap() {
    return {for (String key in orderData.keys) key: orderData[key]!.toMap()};
  }

  String toJson() => json.encode(toMap());
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
                      availability: json['machineList'][machineKey]
                          ['partRequest'][key]['availability'],
                      price: json['machineList'][machineKey]['partRequest'][key]
                          ['price'],
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
                    'availability': machineList[machineKey]!
                            .partRequest[partKey]!
                            .availability ??
                        null,
                    'price':
                        machineList[machineKey]!.partRequest[partKey]!.price ??
                            null,
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
  double? price;
  int quantity;
  String? availability;

  PartData({
    this.availability,
    required this.partNumber,
    required this.itemName,
    this.price,
    required this.quantity,
  });
}
