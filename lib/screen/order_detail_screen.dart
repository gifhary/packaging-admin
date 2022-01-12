import 'package:admin/constant/db_constant.dart';
import 'package:admin/model/address.dart';
import 'package:admin/model/data_group.dart';
import 'package:admin/model/delivery_note.dart';
import 'package:admin/model/german_data.dart';
import 'package:admin/model/item.dart';
import 'package:admin/model/payment_proof.dart';
import 'package:admin/model/staff.dart';
import 'package:admin/model/user.dart';
import 'package:admin/utils/encrypt.dart';
import 'package:admin/widget/another_text_field.dart';
import 'package:admin/widget/ini_text_field.dart';
import 'package:admin/widget/machine_table.dart';
import 'package:admin/widget/machine_table_invoice.dart';
import 'package:admin/widget/machine_table_note.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'dart:html' as html; //ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js; // ignore: avoid_web_libraries_in_flutter

import 'package:screenshot/screenshot.dart';

class OrderDetailScreen extends StatefulWidget {
  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final Item _item = Get.arguments['item'] as Item;
  final User _user = Get.arguments['user'] as User;

  final Staff _director = Get.arguments['director'] as Staff;
  final Staff _salesAdmin = Get.arguments['salesAdmin'] as Staff;
  final Staff _salesManager = Get.arguments['salesManager'] as Staff;

  final order = FirebaseDatabase.instance.ref(DbConstant.order);
  final _deliveryNote = FirebaseDatabase.instance.ref(DbConstant.deliveryNote);
  final _paymentProof = FirebaseDatabase.instance.ref(DbConstant.paymentProof);

  late Item _editItem;

  DeliveryNote? _note;
  PaymentProof? _proof;

  double _total = 0;
  double _eurTotal = 0;

  final cur = NumberFormat("#,##0.00", "en_US");

  ScreenshotController _quotationCtrl = ScreenshotController();
  ScreenshotController _deliveryCtrl = ScreenshotController();
  ScreenshotController _invoiceCtrl = ScreenshotController();
  ScreenshotController _paymentCtrl = ScreenshotController();

  TextEditingController _germanOffer = TextEditingController();
  TextEditingController _purchaseOrder = TextEditingController();
  TextEditingController _orderConfirm = TextEditingController();
  TextEditingController _dnSi = TextEditingController();
  TextEditingController _invoice = TextEditingController();

  TextEditingController _trackingId = TextEditingController();
  TextEditingController _trackingUrl = TextEditingController();
  TextEditingController _deliveryDate = TextEditingController();

  bool userForm = false;

  @override
  void initState() {
    _editItem = _item;
    debugPrint(_item.orderData.delivered.toString());
    if (_item.orderData.delivered) _getDeliveryNote();

    if (_item.orderData.confirmedBySales) {
      _calculateTotal();

      _germanOffer.text = _item.orderData.germanData?.germanOffered.text ?? '';
      _purchaseOrder.text =
          _item.orderData.germanData?.purchaseOrder.text ?? '';
      _orderConfirm.text = _item.orderData.germanData?.orderConfirm.text ?? '';
      _dnSi.text = _item.orderData.germanData?.dnSi.text ?? '';
      _invoice.text = _item.orderData.germanData?.invoice.text ?? '';
    }

    if (_item.orderData.trackingNumber != null ||
        _item.orderData.deliveryDate != null ||
        _item.orderData.trackingUrl != null) {
      _trackingUrl.text = _item.orderData.trackingUrl ?? '';
      _trackingId.text = _item.orderData.trackingNumber ?? '';
      _deliveryDate.text = _item.orderData.deliveryDate ?? '';
    }

    super.initState();
  }

  _calculateTotal() {
    for (String i in _item.orderData.machineList.keys) {
      for (String j in _item.orderData.machineList[i]!.partRequest.keys) {
        _total += (_item.orderData.machineList[i]!.partRequest[j]!.quantity *
            (_item.orderData.machineList[i]!.partRequest[j]!.price ?? 0));
        _eurTotal += (_item.orderData.machineList[i]!.partRequest[j]!.quantity *
            (_item.orderData.machineList[i]!.partRequest[j]!.eurPrice ?? 0));
      }
    }
  }

  _getDeliveryNote() {
    _deliveryNote
        .child('${Encrypt.heh(_user.email)}/${_item.orderId}')
        .get()
        .then((value) {
      if (value.exists) {
        debugPrint('note exists');
        Map<String, dynamic> values = value.value as Map<String, dynamic>;

        setState(() {
          _note = DeliveryNote.fromMap(values);
        });
        _getPaymentProof();
      }
    });
  }

  _getPaymentProof() {
    _paymentProof
        .child('${Encrypt.heh(_user.email)}/${_item.orderId}')
        .get()
        .then((val) {
      if (val.exists) {
        Map<String, dynamic> values = val.value as Map<String, dynamic>;
        setState(() {
          _proof = PaymentProof.fromMap(values);
        });
      }
    });
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
    _editItem.orderData.dateSalesConfirm = DateTime.now().toString();

    order
        .child('${Encrypt.heh(_user.email)}/${_item.orderId}')
        .update(_editItem.orderData.toMap())
        .then((value) {
      Get.defaultDialog(
          titleStyle: const TextStyle(color: Color.fromRGBO(117, 111, 99, 1)),
          title: "Success",
          middleText: "Quotation completed",
          onConfirm: () {
            Get.back();
            Get.back();
          },
          buttonColor: const Color.fromRGBO(117, 111, 99, 1),
          confirmTextColor: Colors.white,
          textConfirm: 'OK');
    });
  }

  _saveCompanyData() {
    var data = GermanData(
        germanOffered: DataGroup(
            text: _germanOffer.text,
            date: _germanOffer.text.isNotEmpty
                ? _item.orderData.germanData?.germanOffered.date ??
                    DateTime.now().toString()
                : null),
        purchaseOrder: DataGroup(
            text: _purchaseOrder.text,
            date: _purchaseOrder.text.isNotEmpty
                ? _item.orderData.germanData?.purchaseOrder.date ??
                    DateTime.now().toString()
                : null),
        orderConfirm: DataGroup(
            text: _orderConfirm.text,
            date: _orderConfirm.text.isNotEmpty
                ? _item.orderData.germanData?.orderConfirm.date ??
                    DateTime.now().toString()
                : null),
        dnSi: DataGroup(
            text: _dnSi.text,
            date: _dnSi.text.isNotEmpty
                ? _item.orderData.germanData?.dnSi.date ??
                    DateTime.now().toString()
                : null),
        invoice: DataGroup(
            text: _invoice.text,
            date: _invoice.text.isNotEmpty
                ? _item.orderData.germanData?.invoice.date ??
                    DateTime.now().toString()
                : null));

    order
        .child('${Encrypt.heh(_user.email)}/${_item.orderId}')
        .update({'germanData': data.toMap()}).then((value) {
      Get.defaultDialog(
          titleStyle: const TextStyle(color: Color.fromRGBO(117, 111, 99, 1)),
          title: "Success",
          middleText: _item.orderData.germanData != null
              ? 'Data updated'
              : 'Data saved',
          onConfirm: Get.back,
          buttonColor: const Color.fromRGBO(117, 111, 99, 1),
          confirmTextColor: Colors.white,
          textConfirm: 'OK');
    });
  }

  _submitDeliveryInfo() {
    if (_trackingId.text.isEmpty) return;
    if (_deliveryDate.text.isEmpty) return;
    if (_trackingUrl.text.isEmpty) return;

    if (!_trackingUrl.text.contains('http'))
      _trackingUrl.text = 'http://' + _trackingUrl.text;

    order.child('${Encrypt.heh(_user.email)}/${_item.orderId}').update({
      'trackingUrl': _trackingUrl.text,
      'trackingNumber': _trackingId.text,
      'deliveryDate': _deliveryDate.text,
    }).then((value) {
      Get.defaultDialog(
          titleStyle: const TextStyle(color: Color.fromRGBO(117, 111, 99, 1)),
          title: "Success",
          middleText: "Delivery info submitted",
          onConfirm: () {
            Get.back();
            Get.back();
          },
          buttonColor: const Color.fromRGBO(117, 111, 99, 1),
          confirmTextColor: Colors.white,
          textConfirm: 'OK');
    });
  }

  _announceDeliveryNote() {
    order.child('${Encrypt.heh(_user.email)}/${_item.orderId}').update({
      'delivered': true,
      'deliveryInputDateTime': DateTime.now().toString(),
    }).then((value) {
      Get.defaultDialog(
          titleStyle: const TextStyle(color: Color.fromRGBO(117, 111, 99, 1)),
          title: "Success",
          middleText: "Delivery note announced",
          onConfirm: () {
            Get.back();
            Get.back();
          },
          buttonColor: const Color.fromRGBO(117, 111, 99, 1),
          confirmTextColor: Colors.white,
          textConfirm: 'OK');
    });
  }

  _downloadProofForm(ScreenshotController controller, String name) async {
    return await controller
        .capture(delay: const Duration(milliseconds: 10))
        .then((image) async {
      if (image != null) {
        js.context.callMethod("saveAs", [
          html.Blob([image]),
          '$name${_item.orderId}.png'
        ]);
      }
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
              Screenshot(
                controller: _quotationCtrl,
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 20),
                  padding: EdgeInsets.all(30),
                  width: _width * 0.75,
                  decoration: BoxDecoration(
                      color: Colors.white,
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
                                _item.orderData.confirmedBySales &&
                                        _item.orderData.approvedByCustomer
                                    ? 'Order: KHS${_item.orderId} '
                                    : 'Order: QO${_item.orderId} ',
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
                                    color: const Color.fromRGBO(
                                        160, 152, 128, 1))),
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
                                      child: Text(_user.userDetail?.name
                                              .toUpperCase() ??
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
                                        padding:
                                            const EdgeInsets.only(top: 8.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(_user.userDetail!.company ??
                                                '-'),
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
                                    color: const Color.fromRGBO(
                                        160, 152, 128, 1))),
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
                              userForm: userForm,
                              editable: !_item.orderData.confirmedBySales,
                              machineData: _item.orderData.machineList[key]!,
                              onDataChanged: (data) {
                                _editItem.orderData.machineList[key] = data;
                              },
                            ),
                          const Divider(
                              color: Color.fromRGBO(160, 152, 128, 1)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Visibility(
                                visible: _item.orderData.approvedByCustomer,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'Approving customer:',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(width: 50),
                                        Text(_item.orderData.approver ?? ''),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          'Date of Approval:',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(width: 70),
                                        Text(_item.orderData
                                                .dateCustomerApprove ??
                                            ''),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    'Total',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(width: 50),
                                  Text('IDR ' + cur.format(_total)),
                                ],
                              ),
                            ],
                          ),
                          userForm
                              ? Container()
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Total',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue),
                                    ),
                                    SizedBox(width: 50),
                                    Text(
                                      'EUR ' + cur.format(_eurTotal),
                                      style: TextStyle(color: Colors.blue),
                                    ),
                                  ],
                                ),
                          SizedBox(height: 20),
                          userForm
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Payment Terms',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(width: 60),
                                    Text('YI45'),
                                  ],
                                )
                              : _item.orderData.confirmedBySales
                                  ? Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          'Disc. ${_item.orderData.hsDiscount ?? 0}%',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue),
                                        ),
                                        SizedBox(width: 50),
                                        Text(
                                          'EUR ' +
                                              cur.format(_eurTotal *
                                                  ((_item.orderData
                                                              .hsDiscount ??
                                                          0) /
                                                      100)),
                                          style: TextStyle(color: Colors.blue),
                                        ),
                                      ],
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          'Disc. ',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue),
                                        ),
                                        SizedBox(
                                          width: 50,
                                          child: AnotherTextField(
                                            numberOnly: true,
                                            onChanged: (val) {
                                              setState(() {
                                                _editItem.orderData.hsDiscount =
                                                    double.tryParse(val)!;
                                              });
                                            },
                                          ),
                                        ),
                                        Text('%',
                                            style:
                                                TextStyle(color: Colors.blue)),
                                      ],
                                    ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              SizedBox(
                                  width: 200,
                                  child: Divider(
                                      color: Color.fromRGBO(160, 152, 128, 1))),
                            ],
                          ),
                          userForm
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text('45 days from Invoice Receipt')
                                  ],
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Total',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue),
                                    ),
                                    SizedBox(width: 50),
                                    Text(
                                      'EUR ' +
                                          cur.format(_eurTotal -
                                              (_eurTotal *
                                                  ((_item.orderData
                                                              .hsDiscount ??
                                                          0) /
                                                      100))),
                                      style: TextStyle(color: Colors.blue),
                                    ),
                                  ],
                                ),
                          SizedBox(height: 80),
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
                          SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              InkWell(
                                onTap: () async {
                                  setState(() {
                                    userForm = true;
                                  });
                                  await _downloadProofForm(
                                      _quotationCtrl,
                                      _item.orderData.confirmedBySales &&
                                              _item.orderData.approvedByCustomer
                                          ? 'customer-purchase'
                                          : 'customer-quotation');
                                  setState(() {
                                    userForm = false;
                                  });
                                },
                                child: Text(
                                  'Download Customer Form',
                                  style: TextStyle(
                                      color: Colors.grey,
                                      decoration: TextDecoration.underline),
                                ),
                              ),
                              SizedBox(width: 20),
                              InkWell(
                                onTap: () => _downloadProofForm(
                                    _quotationCtrl,
                                    _item.orderData.confirmedBySales &&
                                            _item.orderData.approvedByCustomer
                                        ? 'purchase'
                                        : 'quotation'),
                                child: Text(
                                  'Download',
                                  style: TextStyle(
                                      color: Colors.grey,
                                      decoration: TextDecoration.underline),
                                ),
                              ),
                            ],
                          ),
                        ],
                      )),
                ),
              ),
              //TODO company data
              Container(
                margin: EdgeInsets.symmetric(vertical: 20),
                padding: EdgeInsets.all(30),
                width: _width * 0.75,
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                        color: const Color.fromRGBO(160, 152, 128, 1))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      width: double.infinity,
                      color: const Color.fromRGBO(160, 152, 128, 0.16),
                      child: Center(
                        child: Text(
                          'KHS ID - KHS Germany',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: const Color.fromRGBO(117, 111, 99, 1),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 500,
                            child: IniTextField(
                              controller: _germanOffer,
                              label: "German Offered",
                              hintText: 'Enter German Offered',
                            ),
                          ),
                          SizedBox(
                            width: 500,
                            child: IniTextField(
                              controller: _purchaseOrder,
                              label: "Purchased Order",
                              hintText: 'Enter PO',
                            ),
                          ),
                          SizedBox(
                            width: 500,
                            child: IniTextField(
                              controller: _orderConfirm,
                              label: "Order Confirmation",
                              hintText: 'Enter OC',
                            ),
                          ),
                          SizedBox(
                            width: 500,
                            child: IniTextField(
                              controller: _dnSi,
                              label: "DN-SI",
                              hintText: 'Enter Delivery Note issued by HQ',
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              SizedBox(
                                width: 500,
                                child: IniTextField(
                                  controller: _invoice,
                                  label: "Invoice",
                                  hintText: 'Enter KHS Invoice',
                                ),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary:
                                      const Color.fromRGBO(160, 152, 128, 1),
                                ),
                                onPressed: _saveCompanyData,
                                child: Text(_item.orderData.germanData != null
                                    ? 'Update'
                                    : 'Save'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              //TODO tracking id input
              Visibility(
                visible: _item.orderData.approvedByCustomer &&
                    _item.orderData.confirmedBySales,
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 20),
                  padding: EdgeInsets.all(30),
                  width: _width * 0.75,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                          color: const Color.fromRGBO(160, 152, 128, 1))),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IniTextField(
                        readOnly: _item.orderData.trackingNumber != null,
                        controller: _trackingId,
                        label: 'Tracking ID:',
                        hintText: 'Enter tracking number',
                      ),
                      IniTextField(
                        readOnly: _item.orderData.trackingUrl != null,
                        controller: _trackingUrl,
                        label: 'Tracking website:',
                        hintText: 'Enter tracking website',
                      ),
                      IniTextField(
                        readOnly: _item.orderData.deliveryDate != null,
                        controller: _deliveryDate,
                        label: 'Delivery Date:',
                        hintText: 'DD-MM-YYY',
                      ),
                      SizedBox(height: 20),
                      Visibility(
                        visible: _item.orderData.trackingNumber == null ||
                            _item.orderData.deliveryDate == null ||
                            _item.orderData.trackingUrl == null,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: const Color.fromRGBO(160, 152, 128, 1),
                          ),
                          onPressed: _submitDeliveryInfo,
                          child: const Text('Submit'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: const Color.fromRGBO(160, 152, 128, 1),
                ),
                onPressed: _item.orderData.trackingNumber != null &&
                        !_item.orderData.delivered
                    ? _announceDeliveryNote
                    : null,
                child: Text('Announce delivery note'),
              ),
              //TODO delivery note
              Visibility(
                visible: _note != null,
                child: Screenshot(
                  controller: _deliveryCtrl,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 20),
                    padding: EdgeInsets.all(30),
                    width: _width * 0.75,
                    decoration: BoxDecoration(
                        color: Colors.white,
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
                              'Order: DN${_item.orderId}',
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
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(_note?.date ?? '-'),
                                      SizedBox(height: 5),
                                      Text(Encrypt.heh(_user.email)),
                                      SizedBox(height: 5),
                                      Text(_note?.refNo ?? '-'),
                                      SizedBox(height: 5),
                                      Text(_note?.rnNo ?? '-')
                                    ],
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: 20),
                        for (String key in _item.orderData.machineList.keys)
                          MachineTableNote(
                            machineData: _item.orderData.machineList[key]!,
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
                                CachedNetworkImage(
                                  fit: BoxFit.contain,
                                  imageUrl: _salesAdmin.signature,
                                  height: 100,
                                  placeholder: (context, url) => Center(
                                      child: CircularProgressIndicator()),
                                  errorWidget: (context, url, error) =>
                                      Icon(Icons.error),
                                ),
                                Container(
                                  margin: EdgeInsets.all(15),
                                  width: 150,
                                  height: 2,
                                  color: Colors.black,
                                ),
                                Text(
                                  _salesAdmin.name,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 10),
                                Text('KHS Packaging Machinery Indonesia')
                              ],
                            ),
                            Column(
                              children: [
                                Image.network(
                                  _note?.imgUrl ?? '',
                                  height: 100,
                                  fit: BoxFit.contain,
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
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            InkWell(
                              onTap: () => _downloadProofForm(
                                  _deliveryCtrl, 'delivery-note'),
                              child: Text(
                                'Download',
                                style: TextStyle(
                                    color: Colors.grey,
                                    decoration: TextDecoration.underline),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              //TODO invoice
              Visibility(
                visible: _note != null,
                child: Screenshot(
                  controller: _invoiceCtrl,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 20),
                    padding: EdgeInsets.all(30),
                    width: _width * 0.75,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                            color: const Color.fromRGBO(160, 152, 128, 1))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Invoice ',
                              style: TextStyle(
                                  fontSize: 30, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Order: IN${_item.orderId}',
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
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
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
                                        'BILLING STATEMENT',
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                      Text('RN No',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(_note?.date ?? '-'),
                                      SizedBox(height: 5),
                                      Text(Encrypt.heh(_user.email)),
                                      SizedBox(height: 5),
                                      Text(_note?.refNo ?? '-'),
                                      SizedBox(height: 5),
                                      Text(_note?.rnNo ?? '-')
                                    ],
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: 20),
                        for (String key in _item.orderData.machineList.keys)
                          MachineTableInvoice(
                            machineData: _item.orderData.machineList[key]!,
                          ),
                        const Divider(color: Color.fromRGBO(160, 152, 128, 1)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Total',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'PPN 10%',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            SizedBox(width: 20),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(cur.format(_total)),
                                SizedBox(height: 10),
                                Text(cur.format(_total * 0.1)),
                              ],
                            )
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            SizedBox(
                                width: 200,
                                child: Divider(
                                    color: Color.fromRGBO(160, 152, 128, 1))),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              'BALANCE DUE',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(width: 20),
                            Text(
                              cur.format((_total * 0.1) + _total),
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const Divider(color: Color.fromRGBO(160, 152, 128, 1)),
                        SizedBox(height: 15),
                        Text('Remarks,',
                            style: TextStyle(fontStyle: FontStyle.italic)),
                        SizedBox(height: 100),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            SizedBox(
                              width: 600,
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        children: [
                                          CachedNetworkImage(
                                            fit: BoxFit.contain,
                                            imageUrl: _director.signature,
                                            height: 100,
                                            placeholder: (context, url) => Center(
                                                child:
                                                    CircularProgressIndicator()),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Icon(Icons.error),
                                          ),
                                          Container(
                                            margin: EdgeInsets.all(15),
                                            width: 150,
                                            height: 2,
                                            color: Colors.black,
                                          ),
                                          Text(
                                            _director.name,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          CachedNetworkImage(
                                            fit: BoxFit.contain,
                                            imageUrl: _salesManager.signature,
                                            height: 100,
                                            placeholder: (context, url) => Center(
                                                child:
                                                    CircularProgressIndicator()),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Icon(Icons.error),
                                          ),
                                          Container(
                                            margin: EdgeInsets.all(15),
                                            width: 150,
                                            height: 2,
                                            color: Colors.black,
                                          ),
                                          Text(
                                            _salesManager.name,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 20),
                                  Text('KHS Packaging Machinery Indonesia')
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'To be paid to',
                                  style: TextStyle(color: Colors.blue),
                                ),
                                Text(
                                  'PT KHS Packaging Machinery Indonesia',
                                  style: TextStyle(color: Colors.blue),
                                ),
                                Text(
                                  'DEUTSCHE BANK AG, Jakarta Branch',
                                  style: TextStyle(color: Colors.blue),
                                ),
                                Text(
                                  'IDR Account No: 0024869.00.0',
                                  style: TextStyle(color: Colors.blue),
                                ),
                                Text(
                                  'EUR Account No: 0024869.01.0',
                                  style: TextStyle(color: Colors.blue),
                                ),
                                Text(
                                  'USD Account No: 0024869.05.0',
                                  style: TextStyle(color: Colors.blue),
                                ),
                                Text(
                                  'Swift code: DEUTIDJA',
                                  style: TextStyle(color: Colors.blue),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 25),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              InkWell(
                                onTap: () =>
                                    _downloadProofForm(_invoiceCtrl, 'invoice'),
                                child: Text(
                                  'Download',
                                  style: TextStyle(
                                      color: Colors.grey,
                                      decoration: TextDecoration.underline),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              //TODO payment
              Visibility(
                visible: _proof != null,
                child: Screenshot(
                  controller: _paymentCtrl,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 20),
                    padding: EdgeInsets.all(30),
                    width: _width * 0.75,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                            color: const Color.fromRGBO(160, 152, 128, 1))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Payment ',
                              style: TextStyle(
                                  fontSize: 30, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Order: PP${_item.orderId}',
                              style: TextStyle(fontSize: 30),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Text(_user.userDetail!.company ?? ''),
                        SizedBox(
                            width: 250,
                            child:
                                Text(_getAddress(_user.userDetail!.address))),
                        Divider(color: Color.fromRGBO(160, 152, 128, 1)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Customer Id',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    SizedBox(height: 5),
                                    Text('Ref No.',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    SizedBox(height: 5),
                                    Text('RN No',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                SizedBox(width: 20),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(Encrypt.heh(_user.email)),
                                    SizedBox(height: 5),
                                    Text(_note?.refNo ?? '-'),
                                    SizedBox(height: 5),
                                    Text(_note?.rnNo ?? '-')
                                  ],
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          'Total',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: 10),
                                        Text(
                                          'PPN 10%',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    SizedBox(width: 20),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(cur.format(_total)),
                                        SizedBox(height: 10),
                                        Text(cur.format(_total * 0.1)),
                                      ],
                                    )
                                  ],
                                ),
                                SizedBox(
                                    width: 200,
                                    child: Divider(
                                        color:
                                            Color.fromRGBO(160, 152, 128, 1))),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      'BALANCE DUE',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(width: 20),
                                    Text(
                                      cur.format((_total * 0.1) + _total),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          ],
                        ),
                        SizedBox(height: 50),
                        Container(
                            height: 400,
                            width: double.infinity,
                            color: Colors.grey.withOpacity(0.5),
                            child: Image.network(
                              _proof?.imgUrl ?? '',
                              fit: BoxFit.contain,
                            )),
                        SizedBox(height: 50),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 350,
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Text('Date of Payment: '),
                                      SizedBox(width: 10),
                                      Text(
                                        _proof?.paymentDate ?? '-',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      )
                                    ],
                                  ),
                                  SizedBox(height: 20),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'To be paid to',
                                  style: TextStyle(color: Colors.blue),
                                ),
                                Text(
                                  'PT KHS Packaging Machinery Indonesia',
                                  style: TextStyle(color: Colors.blue),
                                ),
                                Text(
                                  'DEUTSCHE BANK AG, Jakarta Branch',
                                  style: TextStyle(color: Colors.blue),
                                ),
                                Text(
                                  'IDR Account No: 0024869.00.0',
                                  style: TextStyle(color: Colors.blue),
                                ),
                                Text(
                                  'EUR Account No: 0024869.01.0',
                                  style: TextStyle(color: Colors.blue),
                                ),
                                Text(
                                  'USD Account No: 0024869.05.0',
                                  style: TextStyle(color: Colors.blue),
                                ),
                                Text(
                                  'Swift code: DEUTIDJA',
                                  style: TextStyle(color: Colors.blue),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            InkWell(
                              onTap: () =>
                                  _downloadProofForm(_paymentCtrl, 'payment'),
                              child: Text(
                                'Download',
                                style: TextStyle(
                                    color: Colors.grey,
                                    decoration: TextDecoration.underline),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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
