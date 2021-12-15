import 'dart:convert';

import 'package:admin/constant/db_constant.dart';
import 'package:admin/model/order_list.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class OrderScreen extends StatefulWidget {
  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final order = FirebaseDatabase.instance.ref(DbConstant.order);
  Map<String, OrderList> _list = Map();

  @override
  void initState() {
    _getOrderList();
    super.initState();
  }

  _getOrderList() {
    order.get().then((value) {
      debugPrint(value.value.toString());
      Map<dynamic, dynamic> values = value.value as Map;

      values.forEach(
          (key, val) => _list.putIfAbsent(key, () => OrderList.fromMap(val)));

      debugPrint('Hahaha ' + _list.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          width: _width * 0.75,
          decoration: BoxDecoration(
              border:
                  Border.all(color: const Color.fromRGBO(160, 152, 128, 1))),
          child: Padding(
              padding: EdgeInsets.symmetric(vertical: 5),
              child: Column(
                children: [],
              )),
        ),
      ),
    );
  }
}
