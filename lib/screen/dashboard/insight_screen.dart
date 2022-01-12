import 'package:admin/constant/db_constant.dart';
import 'package:admin/model/delivery_note.dart';
import 'package:admin/model/item.dart';
import 'package:admin/model/order_list.dart';
import 'package:admin/model/payment_proof.dart';
import 'package:admin/model/user.dart';
import 'package:excel/excel.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class InsightScreen extends StatefulWidget {
  final VoidCallback logOut;

  const InsightScreen({Key? key, required this.logOut}) : super(key: key);

  @override
  State<InsightScreen> createState() => _InsightScreenState();
}

class _InsightScreenState extends State<InsightScreen> {
  final order = FirebaseDatabase.instance.ref(DbConstant.order);
  final paymentProof = FirebaseDatabase.instance.ref(DbConstant.paymentProof);
  final note = FirebaseDatabase.instance.ref(DbConstant.deliveryNote);
  final user = FirebaseDatabase.instance.ref(DbConstant.user);

  Map<String, OrderList> _orderList = Map();
  Map<String, PaymentProofList> _proofList = Map();
  Map<String, DeliveryNote> _note = Map();
  Map<String, User> _users = Map();

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

      var usrs = await _getUsers();
      if (usrs.exists) {
        debugPrint('user exists ${usrs.value}');
        Map<dynamic, dynamic> usrsmap = usrs.value as Map;
        usrsmap.forEach((key, value) {
          _users.putIfAbsent(key, () => User.fromMap(value));
        });
        debugPrint('user length ${_users.length}');
      } else {
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
        title: "Error",
        middleText: "Error downloading data or there's no completed order",
        onConfirm: Get.back,
        buttonColor: const Color.fromRGBO(117, 111, 99, 1),
        confirmTextColor: Colors.white,
        textConfirm: 'OK');
  }

  _writeToExcel(List<Item> nyeh) {
    var excel = Excel.createExcel();
    excel.rename('Sheet1', 'KHS ID - Customer');

    var sheetObject = excel['KHS ID - Customer'];
    var sheet2 = excel['KHS ID - German'];

    List<String> sheet1Column = [
      'Customer',
      'QTY',
      'Spare Part Name',
      'Spare Part Number',
      'Machine Type',
      'HS Code',
//
      'Code',
      'Date Received',
      'Date Completed',
      'Delivery estimation',
//
      'Code',
      'Date',
//
      'Code',
      'Date Sent',
      'Date Confirmed',
//
      'Lead Time',
      'Amount per pc (IDR)',
      'Total Amount (IDR)'
    ];
    List<String> sheet2Column = [
      'QTY',
      'Spare Part Name',
      'Spare Part Number',
      'Machine Type',
      'HS Code',
//
      'Code',
      'Date',
      'German Offered',
      'Date',
//
      'Code',
      'Date',
//
      'Code',
      'Date',
//
      'Arrival Date',
      'Lead Time',
      'Invoice',
      'Shipping',
      'Disc. 15%',
      'Amount per pc (EUR)',
      'Total Amount (EUR)',
    ];

    sheetObject.insertRowIterables(sheet1Column, 1);
    sheet2.insertRowIterables(sheet2Column, 1);

//sheet1
    for (int i = 97; i <= 102; i++) {
      sheetObject.merge(CellIndex.indexByString(String.fromCharCode(i) + '1'),
          CellIndex.indexByString(String.fromCharCode(i) + '2'),
          customValue: sheet1Column[i - 97]);
    }
    sheetObject.merge(
        CellIndex.indexByString('G1'), CellIndex.indexByString('J1'),
        customValue: 'Quotation');
    sheetObject.merge(
        CellIndex.indexByString('K1'), CellIndex.indexByString('L1'),
        customValue: 'PO');
    sheetObject.merge(
        CellIndex.indexByString('M1'), CellIndex.indexByString('O1'),
        customValue: 'Delivery Note');
    for (int i = 112; i <= 114; i++) {
      sheetObject.merge(CellIndex.indexByString(String.fromCharCode(i) + '1'),
          CellIndex.indexByString(String.fromCharCode(i) + '2'),
          customValue: sheet1Column[i - 97]);
    }

    //sheet2
    for (int i = 97; i <= 101; i++) {
      sheet2.merge(CellIndex.indexByString(String.fromCharCode(i) + '1'),
          CellIndex.indexByString(String.fromCharCode(i) + '2'),
          customValue: sheet2Column[i - 97]);
    }
    sheet2.merge(CellIndex.indexByString('F1'), CellIndex.indexByString('I1'),
        customValue: 'PO');
    sheet2.merge(CellIndex.indexByString('J1'), CellIndex.indexByString('K1'),
        customValue: 'Order Confirmation');
    sheet2.merge(CellIndex.indexByString('L1'), CellIndex.indexByString('M1'),
        customValue: 'DN-SI');
    for (int i = 110; i <= 116; i++) {
      sheet2.merge(CellIndex.indexByString(String.fromCharCode(i) + '1'),
          CellIndex.indexByString(String.fromCharCode(i) + '2'),
          customValue: sheet2Column[i - 97]);
    }

    for (Item item in nyeh) {
      item.orderData.machineList.forEach((key, machine) {
        machine.partRequest.forEach((key, part) {
          var userId = _orderList.keys.firstWhere(
              (k) => _orderList[k]!.toJson().contains(item.orderId));

          List dataRowSheet1 = [
            _users[userId]?.userDetail?.company ?? '-',
            part.quantity,
            part.itemName,
            part.partNumber,
            machine.machineType,
            part.hsPartNumber,
            //QO
            'QO' + item.orderId,
            item.orderData.orderTime,
            item.orderData.dateSalesConfirm ?? '-',
            part.availability ?? '-',
            //PO
            'KHS' + item.orderId,
            item.orderData.dateCustomerApprove,
            //DN
            'DN' + item.orderId,
            item.orderData.deliveryInputDateTime,
            _note[item.orderId]?.date ?? '-',
            //
            _daysBetween(
                DateTime.parse(item.orderData.dateCustomerApprove ?? ''),
                DateTime.parse(item.orderData.deliveryInputDateTime ?? '')),
            part.price,
            (part.price ?? 0) * part.quantity
          ];

          List dataRowSheet2 = [
            part.quantity,
            part.itemName,
            part.partNumber,
            machine.machineType,
            part.hsPartNumber,
            //PO
            item.orderData.germanData?.purchaseOrder.text ?? '-',
            item.orderData.germanData?.purchaseOrder.date ?? '-',
            item.orderData.germanData?.germanOffered.text ?? '-',
            item.orderData.germanData?.germanOffered.date ?? '-',
            //OC
            item.orderData.germanData?.orderConfirm.text ?? '-',
            item.orderData.germanData?.orderConfirm.date ?? '-',
            //DN
            item.orderData.germanData?.dnSi.text,
            item.orderData.germanData?.dnSi.date,
            //
            item.orderData.deliveryInputDateTime ?? '-',
            _daysBetween(
                DateTime.parse(
                    item.orderData.germanData?.orderConfirm.date ?? ''),
                DateTime.parse(item.orderData.deliveryInputDateTime ?? '')),
            item.orderData.germanData?.invoice ?? '-',
            item.orderData.trackingNumber,
            ((part.eurPrice ?? 0) * part.quantity) * 0.15,
            part.eurPrice,
            (part.eurPrice ?? 0) * part.quantity
          ];

          sheetObject.appendRow(dataRowSheet1);
          sheet2.appendRow(dataRowSheet2);
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

  Future<DataSnapshot> _getUsers() async {
    return await user.get();
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
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: const Color.fromRGBO(160, 152, 128, 1),
                  ),
                  onPressed: _download,
                  child: const Text('Download Completed Order'),
                ),
                SizedBox(height: 20),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                      primary: const Color.fromRGBO(160, 152, 128, 1)),
                  onPressed: widget.logOut,
                  child: const Text('Log Out'),
                )
              ],
            ),
          ),
          Visibility(
            visible: _loading,
            child: Container(
              height: double.infinity,
              width: double.infinity,
              color: Colors.black.withOpacity(0.1),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          )
        ],
      ),
    );
  }
}
