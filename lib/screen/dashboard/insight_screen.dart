import 'package:admin/constant/db_constant.dart';
import 'package:admin/model/delivery_note.dart';
import 'package:admin/model/item.dart';
import 'package:admin/model/order_list.dart';
import 'package:admin/model/payment_proof.dart';
import 'package:excel/excel.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class InsightScreen extends StatefulWidget {
  @override
  State<InsightScreen> createState() => _InsightScreenState();
}

class _InsightScreenState extends State<InsightScreen> {
  final order = FirebaseDatabase.instance.ref(DbConstant.order);
  final paymentProof = FirebaseDatabase.instance.ref(DbConstant.paymentProof);
  final note = FirebaseDatabase.instance.ref(DbConstant.deliveryNote);

  Map<String, OrderList> _orderList = Map();
  Map<String, PaymentProofList> _proofList = Map();
  Map<String, DeliveryNote> _note = Map();

  List<Item> _orderItems = [];

  bool _loading = false;

  String _daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round().toString();
  }

  _download() async {
    debugPrint('loading download');
    setState(() {
      _loading = true;
    });
    var ord = await _getOrderList();
    if (ord.exists) {
      Map<dynamic, dynamic> orders = ord.value as Map;
      orders.forEach((key, val) =>
          _orderList.putIfAbsent(key, () => OrderList.fromMap(val)));

      _note = await _getDNList();
      if (_note.isEmpty) {
        _noData();
        return;
      }

      var prf = await _getPaymentList();
      if (prf.exists) {
        debugPrint('exists');
        Map<dynamic, dynamic> proofs = prf.value as Map;
        proofs.forEach((key, value) =>
            _proofList.putIfAbsent(key, () => PaymentProofList.fromMap(value)));

        _orderItems = _getCompletedOnly(_orderList, _proofList);
        if (_orderItems.isEmpty) {
          _noData();
          return;
        }
        _writeToExcel(_orderItems);
      } else {
        _noData();
      }
    } else {
      _noData();
    }
  }

  _noData() {
    setState(() {
      _loading = false;
    });
    Get.defaultDialog(
        titleStyle: const TextStyle(color: Color.fromRGBO(117, 111, 99, 1)),
        title: "No Data",
        middleText: "Currently there's no completed data, check again later",
        onConfirm: Get.back,
        buttonColor: const Color.fromRGBO(117, 111, 99, 1),
        confirmTextColor: Colors.white,
        textConfirm: 'OK');
  }

  _writeToExcel(List<Item> nyeh) {
    var excel = Excel.createExcel();
    var sheetObject = excel['Sheet1'];

    List<String> columnName = [
      'QTY',
      'NAME PARTS',
      'PN',
      'MACHINE DETAILS',
      'QTNS.',
      'DEL. TIME',
      'HS CODE',
      'Amount per pc IDR',
      'Total Amount IDR',
      'PO',
      'DN',
      'GERMAN OFFERED',
      'Amount per pc EUR',
      'Total Amount EUR',
      'Disc. 15%',
      'Total Amount EUR',
      'PO',
      'OC',
      'DN SI',
      'KHS Invoice',
      'Shipping',
      'Lead Time to Indonesia (DAYS)',
      'Lead Time to Customer (DAYS)'
    ];
    sheetObject.insertRowIterables(columnName, 0);

    for (Item item in nyeh) {
      item.orderData.machineList.forEach((key, machine) {
        machine.partRequest.forEach((key, part) {
          List dataRow = [
            part.quantity,
            part.itemName,
            part.partNumber,
            machine.machineType,
            'QO' + item.orderId,
            part.availability ?? '-',
            part.hsPartNumber ?? '-',
            part.price,
            (part.price ?? 0) * part.quantity,
            'KHS' + item.orderId,
            'DN' + item.orderId,
            item.orderData.germanData?.germanOffered.text ?? '-',
            part.eurPrice,
            (part.eurPrice ?? 0) * part.quantity,
            ((part.eurPrice ?? 0) * part.quantity) * 0.15,
            ((part.eurPrice ?? 0) * part.quantity) -
                (((part.eurPrice ?? 0) * part.quantity) * 0.15),
            item.orderData.germanData?.purchaseOrder.text ?? '-',
            item.orderData.germanData?.orderConfirm.text ?? '-',
            item.orderData.germanData?.dnSi ?? '-',
            item.orderData.germanData?.invoice ?? '-',
            item.orderData.trackingNumber ?? '-',
            _daysBetween(
                DateTime.parse(
                    item.orderData.germanData?.germanOffered.date ?? ''),
                DateTime.parse(item.orderData.deliveryInputDateTime ?? '')),
            _daysBetween(
                DateTime.parse(
                    item.orderData.germanData?.germanOffered.date ?? ''),
                DateTime.parse(_note[item.orderId]!.date))
          ];

          sheetObject.appendRow(dataRow);
        });
      });
    }

    excel.save(
        fileName:
            "List_spare_parts_order_${DateFormat('dd-MM-yyyy').format(DateTime.now())}.xlsx");
    setState(() {
      _loading = false;
    });
  }

  List<Item> _getCompletedOnly(
      Map<String, OrderList> orders, Map<String, PaymentProofList> proofs) {
    List<Item> nyeh = [];
    proofs.forEach((user, val) {
      val.paymentProof.forEach((orderId, v) {
        if (orders[user]!.orderData[orderId]!.germanData != null)
          nyeh.add(Item(
              orderId: orderId, orderData: orders[user]!.orderData[orderId]!));
      });
    });
    return nyeh;
  }

  Future<DataSnapshot> _getOrderList() async {
    return await order.get();
  }

  Future<DataSnapshot> _getPaymentList() async {
    return await paymentProof.get();
  }

  Future<Map<String, DeliveryNote>> _getDNList() async {
    Map<String, DeliveryNote> data = Map();

    var vallueueue = await note.get();
    if (vallueueue.exists) {
      Map<dynamic, dynamic> notes = vallueueue.value as Map;
      notes.forEach((key, val) {
        Map<dynamic, dynamic> ha = val as Map;
        ha.forEach((k, v) {
          debugPrint(k);
          data.putIfAbsent(k, () => DeliveryNote.fromMap(v));
          debugPrint('data written');
        });
      });
    }

    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: const Color.fromRGBO(160, 152, 128, 1),
              ),
              onPressed: _download,
              child: const Text('Download Completed Order'),
            ),
          ),
          Visibility(
            visible: _loading,
            child: Container(
              height: double.infinity,
              width: double.infinity,
              color: Colors.black.withOpacity(0.1),
              child: Center(
                child: CircularProgressIndicator(
                  semanticsValue: 'ss',
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
