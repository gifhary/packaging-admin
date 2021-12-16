import 'package:admin/constant/db_constant.dart';
import 'package:admin/model/address.dart';
import 'package:admin/model/delivery_note.dart';
import 'package:admin/model/item.dart';
import 'package:admin/model/user.dart';
import 'package:admin/utils/encrypt.dart';
import 'package:admin/widget/machine_table.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderDetailScreen extends StatefulWidget {
  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final Item _item = Get.arguments['item'] as Item;
  final User _user = Get.arguments['user'] as User;

  final order = FirebaseDatabase.instance.ref(DbConstant.order);

  late Item _editItem;

  DeliveryNote? _note;

  @override
  void initState() {
    _editItem = _item;

    super.initState();
  }

  String _getAddress(Address address) {
    String str = '-';
    debugPrint(address.toString());

    if (address.address1.isNotEmpty) {
      str = address.address1 + ', ';
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

  _approve() {
    _editItem.orderData.confirmedBySales = true;

    order
        .child('${Encrypt.heh(_user.email)}/${_item.orderId}')
        .update(_editItem.orderData.toMap())
        .then((value) {
      debugPrint('quotation completed');
      Get.back();
    });
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
              //TODO quotation order
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
                            editable: !_item.orderData.confirmedBySales,
                            machineData: _item.orderData.machineList[key]!,
                            onDataChanged: (data) {
                              _editItem.orderData.machineList[key] = data;
                            },
                          ),
                        const Divider(color: Color.fromRGBO(160, 152, 128, 1)),
                        SizedBox(height: 100),
                        Visibility(
                          visible: !_item.orderData.confirmedBySales,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary:
                                      const Color.fromRGBO(160, 152, 128, 1),
                                ),
                                onPressed: _approve,
                                child: const Text('Approve'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )),
              ),
              //TODO delivery note
              Visibility(
                visible: _note != null,
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 20),
                  padding: EdgeInsets.all(30),
                  width: _width * 0.75,
                  decoration: BoxDecoration(
                      border: Border.all(
                          color: const Color.fromRGBO(160, 152, 128, 1))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Delivery Note ',
                            style: TextStyle(
                                fontSize: 30, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Order: ${_item.orderId}',
                            style: TextStyle(fontSize: 30),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('PT KHS PACKAGING MACHINERY INDONESIA'),
                              Text('THE PRIME - Office Sunter, 3rd floor'),
                              Text('Jl. Yos Sudarso Kav. 30 Sunter Agun'),
                              Text('Jakarta Utara'),
                            ],
                          ),
                          Image.asset(
                            'assets/img/khs_logo.png',
                            width: 234,
                            height: 72,
                            fit: BoxFit.contain,
                          ),
                        ],
                      ),
                      const Divider(color: Color.fromRGBO(160, 152, 128, 1)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 250,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _user.userDetail!.company ?? '',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  _getAddress(
                                      _user.userDetail!.deliveryAddress),
                                  style: TextStyle(height: 1.5),
                                ),
                                SizedBox(height: 15),
                                Row(
                                  children: [
                                    Text('ATTENTION: '),
                                    Text(
                                      'SPAREPART DEPARTMENT',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 350,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Date',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    SizedBox(height: 5),
                                    Text('Customer Id',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    SizedBox(height: 5),
                                    Text('Ref No.',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    SizedBox(height: 5),
                                    Text('Rn No',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('12-12-21'),
                                    SizedBox(height: 5),
                                    Text(Encrypt.heh(_user.email)),
                                    SizedBox(height: 5),
                                    Text('777'),
                                    SizedBox(height: 5),
                                    Text('555')
                                  ],
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: 20),
                      for (String key in _item.orderData.machineList.keys)
                        MachineTable(
                          machineData: _item.orderData.machineList[key]!,
                          editable: false,
                          onDataChanged: (machineData) {},
                        ),
                      const Divider(color: Color.fromRGBO(160, 152, 128, 1)),
                      SizedBox(height: 15),
                      Text('Remarks,',
                          style: TextStyle(fontStyle: FontStyle.italic)),
                      SizedBox(height: 100),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              Container(
                                height: 200,
                                width: 300,
                                child: Image.network(
                                    'https://firebasestorage.googleapis.com/v0/b/packaging-machinery.appspot.com/o/companyAsset%2Fdelivery-note-stamp.png?alt=media&token=86c60e7b-94b0-46e1-b642-359681cee7e0'),
                              ),
                              Container(
                                margin: EdgeInsets.all(15),
                                width: 150,
                                height: 2,
                                color: Colors.black,
                              ),
                              Text(
                                'LEONI ANDRIYATI',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 10),
                              Text('KHS Packaging Machinery Indonesia')
                            ],
                          ),
                          Column(
                            children: [
                              Container(
                                height: 200,
                                width: 300,
                                color: Colors.grey.withOpacity(0.5),
                                child: Image.network(
                                  'https://firebasestorage.googleapis.com/v0/b/packaging-machinery.appspot.com/o/companyAsset%2Fdelivery-note-stamp.png?alt=media&token=86c60e7b-94b0-46e1-b642-359681cee7e0',
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.all(15),
                                width: 150,
                                height: 2,
                                color: Colors.black,
                              ),
                              Text(
                                _user.userDetail?.name ?? '',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
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
