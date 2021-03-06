import 'package:admin/model/order_list.dart';
import 'package:admin/widget/another_text_field.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MachineTable extends StatefulWidget {
  final bool userForm;
  final bool editable;
  final MachineData machineData;
  final Function(MachineData) onDataChanged;

  const MachineTable(
      {Key? key,
      required this.machineData,
      required this.onDataChanged,
      required this.editable,
      this.userForm = false})
      : super(key: key);

  @override
  State<MachineTable> createState() => _MachineTableState();
}

class _MachineTableState extends State<MachineTable> {
  late MachineData _editData;
  final cur = NumberFormat("#,##0.00", "en_US");

  @override
  void initState() {
    _editData = widget.machineData;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            width: double.infinity,
            color: const Color.fromRGBO(160, 152, 128, 0.16),
            child: Column(
              children: [
                Text(
                  'Machine Type: ${widget.machineData.machineType}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: const Color.fromRGBO(117, 111, 99, 1),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  height: 3,
                  width: 500,
                  color: Colors.white,
                )
              ],
            ),
          ),
          DataTable(dataRowHeight: 75, columns: [
            DataColumn(
              label: Text(
                'Item',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Part Number',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'QTY',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Contract\nDiscount %',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Unit Price\nTotal Tax Amount\nTotal Extra Charges',
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            DataColumn(
              label: Text(
                'Total',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ], rows: [
            for (String key in widget.machineData.partRequest.keys)
              DataRow(
                cells: <DataCell>[
                  DataCell(Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(widget.machineData.partRequest[key]!.itemName),
                      SizedBox(height: 5),
                      widget.editable
                          ? SizedBox(
                              width: 200,
                              height: 22,
                              child: AnotherTextField(
                                hintText: 'Enter time',
                                onChanged: (val) {
                                  _editData.partRequest[key]?.availability =
                                      val;
                                },
                              ),
                            )
                          : SizedBox(
                              width: 150,
                              height: 22,
                              child: Text(
                                '*estimated arrival: ' +
                                    (widget.machineData.partRequest[key]!
                                            .availability ??
                                        ''),
                                style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 10,
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.w100,
                                    letterSpacing: 0.5),
                              ),
                            ),
                    ],
                  )),
                  DataCell(Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                          width: 130,
                          child: Text(
                              widget.machineData.partRequest[key]!.partNumber)),
                      widget.userForm
                          ? Container()
                          : widget.editable
                              ? SizedBox(
                                  width: 130,
                                  height: 22,
                                  child: AnotherTextField(
                                    hintText: 'HS code',
                                    onChanged: (val) {
                                      _editData.partRequest[key]!.hsPartNumber =
                                          val;
                                    },
                                  ),
                                )
                              : Text(
                                  widget.machineData.partRequest[key]!
                                          .hsPartNumber ??
                                      '',
                                  style: TextStyle(color: Colors.blue),
                                ),
                    ],
                  )),
                  DataCell(Text(widget.machineData.partRequest[key]!.quantity
                      .toString())),
                  DataCell(SizedBox(width: 70, child: Text('0.00'))),
                  DataCell(
                    widget.editable
                        ? SizedBox(
                            width: 140,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AnotherTextField(
                                  numberOnly: true,
                                  hintText: 'IDR price',
                                  onChanged: (val) {
                                    setState(() {
                                      _editData.partRequest[key]?.price =
                                          double.tryParse(val);
                                    });

                                    widget.onDataChanged(_editData);
                                  },
                                ),
                                SizedBox(height: 10),
                                widget.userForm
                                    ? Container()
                                    : AnotherTextField(
                                        numberOnly: true,
                                        hintText: 'EUR price',
                                        onChanged: (val) {
                                          setState(() {
                                            _editData.partRequest[key]
                                                    ?.eurPrice =
                                                double.tryParse(val);
                                          });
                                          widget.onDataChanged(_editData);
                                        },
                                      ),
                              ],
                            ),
                          )
                        : SizedBox(
                            width: 140,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('IDR ' +
                                    cur.format((widget.machineData
                                            .partRequest[key]?.price ??
                                        0))),
                                widget.userForm
                                    ? Container()
                                    : Text(
                                        'EUR ' +
                                            cur.format((widget
                                                    .machineData
                                                    .partRequest[key]
                                                    ?.eurPrice ??
                                                0)),
                                        style: TextStyle(color: Colors.blue),
                                      ),
                              ],
                            ),
                          ),
                  ),
                  DataCell(SizedBox(
                    width: 150,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('IDR ' +
                            cur.format(
                                ((_editData.partRequest[key]?.price ?? 0) *
                                    _editData.partRequest[key]!.quantity))),
                        widget.userForm
                            ? Container()
                            : Text(
                                'EUR ' +
                                    cur.format(((_editData
                                                .partRequest[key]?.eurPrice ??
                                            0) *
                                        _editData.partRequest[key]!.quantity)),
                                style: TextStyle(color: Colors.blue),
                              ),
                      ],
                    ),
                  )),
                ],
              ),
          ]),
        ],
      ),
    );
  }
}
