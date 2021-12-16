import 'package:admin/constant/db_constant.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class OrderItem extends StatefulWidget {
  final String userId;
  final String orderId;
  final String status;
  final String company;
  final VoidCallback? onTap;

  const OrderItem(
      {Key? key,
      required this.orderId,
      required this.status,
      required this.company,
      this.onTap,
      required this.userId})
      : super(key: key);

  @override
  State<OrderItem> createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {
  final deliveryNote = FirebaseDatabase.instance.ref(DbConstant.deliveryNote);
  final paymentProof = FirebaseDatabase.instance.ref(DbConstant.paymentProof);

  String _status = '';

  @override
  void initState() {
    _checkIfCompleted();
    super.initState();
  }

  _checkIfCompleted() {
    deliveryNote
        .child('${widget.userId}/${widget.orderId}')
        .get()
        .then((value) {
      if (value.exists)
        paymentProof
            .child('${widget.userId}/${widget.orderId}')
            .get()
            .then((val) {
          if (val.exists) {
            setState(() {
              _status = 'Completed';
            });
          } else {
            setState(() {
              _status = 'Waiting for payment';
            });
          }
        });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: _status == 'Completed'
              ? Color.fromRGBO(255, 228, 134, 0.2)
              : null,
          child: InkWell(
            onTap: widget.onTap,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order Id: ${widget.orderId}',
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Status: ${_status.isEmpty ? widget.status : _status}',
                        style: TextStyle(
                            color: const Color.fromRGBO(160, 152, 128, 1)),
                      ),
                    ],
                  ),
                  Text(
                    widget.company,
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
          ),
        ),
        Divider(color: const Color.fromRGBO(160, 152, 128, 1)),
      ],
    );
  }
}
