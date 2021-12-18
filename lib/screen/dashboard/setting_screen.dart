import 'dart:typed_data';

import 'package:admin/constant/db_constant.dart';
import 'package:admin/model/staff.dart';
import 'package:admin/widget/image_taker.dart';
import 'package:admin/widget/ini_text_field.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class SettingScreen extends StatefulWidget {
  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  Staff? _director, _salesAdmin, _salesManager;
  final staff = FirebaseDatabase.instance.ref(DbConstant.staff);

  TextEditingController _directorCtrl = TextEditingController();
  TextEditingController _salesMgrCtrl = TextEditingController();
  TextEditingController _salesAdmCtrl = TextEditingController();

  Uint8List _directorSgntr = Uint8List(0);
  Uint8List _salsesMgrSgntr = Uint8List(0);
  Uint8List _salesAdmSgntr = Uint8List(0);

  @override
  void initState() {
    _getStaff();

    super.initState();
  }

  _getStaff() {
    staff.get().then((value) {
      if (value.exists) {
        debugPrint('staff: ' + value.value.toString());
        Map<dynamic, dynamic> values = value.value as Map;

        setState(() {
          _director = Staff.fromMap(values['director']);
          _salesAdmin = Staff.fromMap(values['salesAdmin']);
          _salesManager = Staff.fromMap(values['salesManager']);

          _directorCtrl.text = _director!.name;
          _salesMgrCtrl.text = _salesManager!.name;
          _salesAdmCtrl.text = _salesAdmin!.name;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: (_director ?? _salesAdmin ?? _salesManager) == null
            ? CircularProgressIndicator()
            : SingleChildScrollView(
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
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Staff Name and Signature',
                                style: TextStyle(fontSize: 30)),
                            SizedBox(height: 10),
                            Text(
                                'Edit and set staff name and signature for every forms.'),
                            SizedBox(height: 20),
                            Divider(
                                color: const Color.fromRGBO(160, 152, 128, 1)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      'Director',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(
                                      width: 200,
                                      child: IniTextField(
                                        controller: _directorCtrl,
                                        label: 'Name',
                                        hintText: 'Name',
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    ImageTaker(
                                      imageFile: _directorSgntr,
                                      imageUrl: _director!.signature,
                                    )
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text(
                                      'Sales Manager',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(
                                      width: 200,
                                      child: IniTextField(
                                        controller: _salesMgrCtrl,
                                        label: 'Name',
                                        hintText: 'Name',
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    ImageTaker(
                                      imageFile: _salsesMgrSgntr,
                                      imageUrl: _salesManager!.signature,
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text(
                                      'Sales Admin',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(
                                      width: 200,
                                      child: IniTextField(
                                        controller: _salesAdmCtrl,
                                        label: 'Name',
                                        hintText: 'Name',
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    ImageTaker(
                                      imageFile: _salesAdmSgntr,
                                      imageUrl: _salesAdmin!.signature,
                                    )
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 50),
                            Text('Admin Password',
                                style: TextStyle(fontSize: 30)),
                            SizedBox(height: 10),
                            Text(
                                'Change current password for the admin web app.'),
                            SizedBox(height: 20),
                            Divider(
                                color: const Color.fromRGBO(160, 152, 128, 1)),
                            Container(
                              width: 200,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IniTextField(
                                    obscureText: true,
                                    label: "Current password",
                                    hintText: 'Current password',
                                  ),
                                  Text('wrong',
                                      style: TextStyle(
                                          color: Colors.red, fontSize: 10)),
                                  IniTextField(
                                    obscureText: true,
                                    label: "New password",
                                    hintText: 'New password',
                                  ),
                                  IniTextField(
                                    obscureText: true,
                                    label: "Confirm password",
                                    hintText: 'Confirm password',
                                  ),
                                  Text('not match',
                                      style: TextStyle(
                                          color: Colors.red, fontSize: 10)),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 20, bottom: 100),
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        primary: const Color.fromRGBO(
                                            160, 152, 128, 1),
                                      ),
                                      onPressed: () {},
                                      child: const Text('Change password'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
