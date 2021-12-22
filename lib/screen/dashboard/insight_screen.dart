import 'package:admin/constant/db_constant.dart';
import 'package:admin/model/item.dart';
import 'package:admin/model/order_list.dart';
import 'package:admin/model/payment_proof.dart';
import 'package:excel/excel.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class InsightScreen extends StatefulWidget {
  @override
  State<InsightScreen> createState() => _InsightScreenState();
}

class _InsightScreenState extends State<InsightScreen> {
  final order = FirebaseDatabase.instance.ref(DbConstant.order);
  final paymentProof = FirebaseDatabase.instance.ref(DbConstant.paymentProof);

  Map<String, OrderList> _orderList = Map();
  Map<String, PaymentProofList> _proofList = Map();

  List<Item> _orderItems = [];

  bool _loading = false;

  _download() async {
    setState(() {
      _loading = true;
    });
    var ord = await _getOrderList();
    Map<dynamic, dynamic> orders = ord.value as Map;
    orders.forEach((key, val) =>
        _orderList.putIfAbsent(key, () => OrderList.fromMap(val)));

    var prf = await _getPaymentList();
    Map<dynamic, dynamic> proofs = prf.value as Map;
    proofs.forEach((key, value) =>
        _proofList.putIfAbsent(key, () => PaymentProofList.fromMap(value)));

    _orderItems = _getCompletedOnly(_orderList, _proofList);
    _writeToExcel(_orderItems);
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
      'SENT',
      'GERMAN OFFERED',
      'Amount per pc EUR',
      'Total Amount EUR',
      'Disc. 15%',
      'Total Amount EUR',
      'PO',
      'OC',
      'DN SI',
      'KHS Invoice',
      'Shipping'
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
            'QTNS.',
            'APPRX.  02 - 04 WEEKS',
            part.hsPartNumber ?? '-',
            part.price,
            (part.price ?? 0) * part.quantity,
            item.orderId,
            'DN',
            'SENT',
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
            item.orderData.trackingNumber
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
