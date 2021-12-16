import 'package:admin/model/address.dart';
import 'package:admin/model/item.dart';
import 'package:admin/model/user.dart';
import 'package:admin/widget/machine_table.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderDetailScreen extends StatefulWidget {
  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final Item _item = Get.arguments['item'] as Item;
  final User _user = Get.arguments['user'] as User;

  late Item _editItem;

  @override
  void initState() {
    _editItem = _item;

    super.initState();
  }

  String _getAddress(Address address) {
    String str = '-';
    debugPrint(address.toString());

    if (address.address1.isNotEmpty) {
      str += address.address1 + ', ';
    }
    if (address.address2?.isNotEmpty ?? false) {
      str += address.address2! + ', ';
    }
    if (address.street?.isNotEmpty ?? false) {
      str += address.street! + ', ';
    }
    if (address.city.isNotEmpty) {
      str += address.city + ', ';
    }
    if (address.zipcode.isNotEmpty) {
      str += address.zipcode + ', ';
    }
    if (address.country.isNotEmpty) {
      str += address.country + '.';
    }
    return str;
  }

  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(40),
        child: AppBar(
          backgroundColor: const Color.fromRGBO(46, 45, 42, 1),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.symmetric(vertical: 20),
                padding: EdgeInsets.all(30),
                width: _width * 0.75,
                decoration: BoxDecoration(
                    border: Border.all(
                        color: const Color.fromRGBO(160, 152, 128, 1))),
                child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //title
                        Row(
                          children: [
                            Text(
                              _item.orderData.confirmedBySales &&
                                      _item.orderData.approvedByCustomer
                                  ? 'Purchase '
                                  : 'Quotation ',
                              style: TextStyle(
                                  fontSize: 30, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Order: ${_item.orderId} ',
                              style: TextStyle(fontSize: 30),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child:
                              Text('PO Title: ${_item.orderData.orderTitle}'),
                        ),
                        //section 1
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color:
                                      const Color.fromRGBO(160, 152, 128, 1))),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 5),
                            child: Text(
                              'Purchase Order',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(10),
                          width: double.infinity,
                          color: const Color.fromRGBO(160, 152, 128, 0.16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Invoice Bill To',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 100),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_user.userDetail?.company ?? '-'),
                                  SizedBox(
                                    width: 300,
                                    child: Text(
                                      _getAddress(_user
                                          .userDetail!.invoiceBillAddress!),
                                      style: TextStyle(height: 1.5),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Table(
                              columnWidths: const <int, TableColumnWidth>{
                                0: FixedColumnWidth(150),
                                1: FixedColumnWidth(300),
                              },
                              children: [
                                TableRow(children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text('Buyer',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                        _user.userDetail?.name.toUpperCase() ??
                                            '-'),
                                  )
                                ]),
                                TableRow(children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text('Email',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(_user.email),
                                  )
                                ]),
                                TableRow(children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text('Order Date',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(_item.orderData.orderTime),
                                  )
                                ]),
                                TableRow(children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text('Delivery Date',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      DateTime.now().toString().split(' ')[0],
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  )
                                ]),
                                TableRow(children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text('Goods Ship To',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(_getAddress(
                                        _user.userDetail!.deliveryAddress)),
                                  )
                                ]),
                              ],
                            ),
                            Table(
                              columnWidths: const <int, TableColumnWidth>{
                                0: FixedColumnWidth(150),
                                1: FixedColumnWidth(300),
                              },
                              children: [
                                TableRow(children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text('Supplier',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                        'KHS PACKAGING MACHINERY INDONESIA, PT'),
                                  )
                                ]),
                                TableRow(children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text('Address',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                        'JL YOS SUDARSO KAV 30 SUNTER THE PRIME - OFFICE'),
                                  )
                                ]),
                                TableRow(children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text('Telephone',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text('0210000'),
                                  )
                                ]),
                                TableRow(children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text('Fax No.',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text('0210000'),
                                  )
                                ]),
                                TableRow(children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text('Invoice Sent To',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                              _user.userDetail!.company ?? '-'),
                                          Text(_getAddress(_user.userDetail!
                                              .invoiceBillingSettlementAddress!)),
                                        ],
                                      ))
                                ]),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color:
                                      const Color.fromRGBO(160, 152, 128, 1))),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 5),
                            child: Text(
                              'Part Line Items',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        for (String key in _item.orderData.machineList.keys)
                          MachineTable(
                            machineData: _item.orderData.machineList[key]!,
                            onDataChanged: (data) {
                              _editItem.orderData.machineList[key] = data;
                            },
                          ),
                        const Divider(color: Color.fromRGBO(160, 152, 128, 1)),
                        SizedBox(height: 100),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: const Color.fromRGBO(160, 152, 128, 1),
                              ),
                              onPressed: () {},
                              child: const Text('Approve'),
                            ),
                          ],
                        ),
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
