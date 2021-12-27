import 'package:admin/constant/db_constant.dart';
import 'package:admin/model/item.dart';
import 'package:admin/model/order_list.dart';
import 'package:admin/model/staff.dart';
import 'package:admin/model/user.dart';
import 'package:admin/route/route_constant.dart';
import 'package:admin/utils/encrypt.dart';
import 'package:admin/widget/order_item.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class OrderScreen extends StatefulWidget {
  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final order = FirebaseDatabase.instance.ref(DbConstant.order);
  final user = FirebaseDatabase.instance.ref(DbConstant.user);
  final staff = FirebaseDatabase.instance.ref(DbConstant.staff);

  Map<String, OrderList> _list = Map();
  Map<String, User> _users = Map();

  late Staff _director, _salesAdmin, _salesManager;

  @override
  void initState() {
    _getOrderList();
    _getStaff();
    super.initState();
  }

  _getStaff() {
    staff.get().then((value) {
      if (value.exists) {
        debugPrint('staff: ' + value.value.toString());
        Map<dynamic, dynamic> values = value.value as Map;

        _director = Staff.fromMap(values['director']);
        _salesAdmin = Staff.fromMap(values['salesAdmin']);
        _salesManager = Staff.fromMap(values['salesManager']);
      }
    });
  }

  _getUsers() {
    user.get().then((value) {
      debugPrint(value.value.toString());
      Map<dynamic, dynamic> values = value.value as Map;

      setState(() {
        values.forEach(
            (key, val) => _users.putIfAbsent(key, () => User.fromMap(val)));
      });
    });
  }

  _getOrderList() {
    order.get().then((value) {
      if (value.exists) {
        debugPrint(value.value.toString());
        Map<dynamic, dynamic> values = value.value as Map;

        values.forEach(
            (key, val) => _list.putIfAbsent(key, () => OrderList.fromMap(val)));
        _getUsers();
        debugPrint('Hahaha ' + _list.length.toString());
      }
    });
  }

  String _getStatus(bool delivered, salesConfirm, customerApprove) {
    String _status = '';
    if (!delivered) {
      if (salesConfirm && customerApprove) {
        _status = 'Purchased order';
      } else if (salesConfirm && !customerApprove) {
        _status = 'Quotation completed';
      } else if (!salesConfirm && !customerApprove) {
        _status = 'Quotation request';
      }
    } else {
      _status = 'Delivered';
    }
    return _status;
  }

  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height),
                margin: EdgeInsets.symmetric(vertical: 20),
                padding: EdgeInsets.all(20),
                width: _width * 0.75,
                decoration: BoxDecoration(
                    border: Border.all(
                        color: const Color.fromRGBO(160, 152, 128, 1))),
                child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Customer Orders', style: TextStyle(fontSize: 30)),
                        SizedBox(height: 10),
                        Text(
                            'View, complete or manage your customer bookings.'),
                        SizedBox(height: 5),
                        Text('Time Zone: Western Indonesia Time (GMT+7)'),
                        SizedBox(height: 20),
                        Divider(color: const Color.fromRGBO(160, 152, 128, 1)),
                        for (String i in _list.keys)
                          for (String j in _list[i]!.orderData.keys)
                            OrderItem(
                              orderId: j,
                              status: _getStatus(
                                  _list[i]!.orderData[j]!.delivered,
                                  _list[i]!.orderData[j]!.confirmedBySales,
                                  _list[i]!.orderData[j]!.approvedByCustomer),
                              company: _users[i]!.userDetail!.company ?? '-',
                              userId: Encrypt.heh(_users[i]!.email),
                              onTap: () => Get.toNamed(
                                      RouteConstant.orderDetail,
                                      arguments: {
                                    'item': Item(
                                        orderId: j,
                                        orderData: _list[i]!.orderData[j]!),
                                    'user': _users[i]!,
                                    'director': _director,
                                    'salesAdmin': _salesAdmin,
                                    'salesManager': _salesManager,
                                  })!
                                  .then((value) {
                                setState(() {});
                              }),
                            )
                      ],
                    )),
              ),
              Container(
                color: const Color.fromRGBO(117, 111, 99, 1),
                width: double.infinity,
                height: 43,
                child: const Center(
                  child: Text(
                    '©2022 by Samantha Tiara W. Master\'s Thesis Project - EM.',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
