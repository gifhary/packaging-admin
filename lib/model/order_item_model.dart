import 'package:flutter/material.dart';

class OrderItemModel {
  String orderId;
  String status;
  String company;
  String userId;
  VoidCallback? onTap;
  DateTime date;

  OrderItemModel({
    required this.orderId,
    required this.status,
    required this.company,
    required this.userId,
    this.onTap,
    required this.date,
  });
}
