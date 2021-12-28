import 'dart:typed_data';

import 'package:admin/constant/db_constant.dart';
import 'package:admin/model/staff.dart';
import 'package:admin/utils/encrypt.dart';
import 'package:admin/widget/image_taker.dart';
import 'package:admin/widget/ini_text_field.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingScreen extends StatefulWidget {
  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  Staff? _director, _salesAdmin, _salesManager;
  final staff = FirebaseDatabase.instance.ref(DbConstant.staff);
  final db = FirebaseDatabase.instance.ref(DbConstant.adminPass);

  TextEditingController _directorCtrl = TextEditingController();
  TextEditingController _salesMgrCtrl = TextEditingController();
  TextEditingController _salesAdmCtrl = TextEditingController();

  TextEditingController _currentPass = TextEditingController();
  TextEditingController _newPass = TextEditingController();
  TextEditingController _confirmPass = TextEditingController();

  Uint8List _directorSgntr = Uint8List(0);
  Uint8List _salsesMgrSgntr = Uint8List(0);
  Uint8List _salesAdmSgntr = Uint8List(0);

  String _currentPassMsg = '';
  String _confirmPassMsg = '';

  @override
  void initState() {
    _getStaff();

    super.initState();
  }

  _updateNameAndSignature(String position, String name, Uint8List image) async {
    if (image.isNotEmpty) {
      final storage = FirebaseStorage.instance
          .ref('companyAsset/$position-${name.replaceAll(' ', '-')}.png');

      TaskSnapshot uploadTask = await storage.putData(
          image, SettableMetadata(contentType: 'image/png'));

      uploadTask.ref.getDownloadURL().then((url) {
        staff
            .child(position)
            .update(Staff(name: name, signature: url).toMap())
            .then((value) {
          Get.defaultDialog(
              titleStyle:
                  const TextStyle(color: Color.fromRGBO(117, 111, 99, 1)),
              title: "Success",
              middleText: "Data updated successfuly",
              onConfirm: Get.back,
              buttonColor: const Color.fromRGBO(117, 111, 99, 1),
              confirmTextColor: Colors.white,
              textConfirm: 'OK');
        });
      });
    } else {
      debugPrint('image is empty');
    }
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

  _changPassword() {
    if (_currentPass.text.isEmpty) return;
    if (_newPass.text.isEmpty) return;
    if (_confirmPass.text.isEmpty) return;
    if (_newPass.text != _confirmPass.text) {
      setState(() {
        _confirmPassMsg = 'password does not match';
      });
      return;
    }

    db.get().then((value) {
      debugPrint(value.value.toString());
      if (value.value == Encrypt.heh(_currentPass.text)) {
        db.set(Encrypt.heh(_newPass.text)).then((value) {
          Get.defaultDialog(
              titleStyle:
                  const TextStyle(color: Color.fromRGBO(117, 111, 99, 1)),
              title: "Success",
              middleText: "Password changed successfuly",
              onConfirm: () {
                Get.back();
                setState(() {
                  _currentPassMsg = '';
                  _confirmPassMsg = '';
                  _currentPass.text = '';
                  _newPass.text = '';
                  _confirmPass.text = '';
                });
              },
              buttonColor: const Color.fromRGBO(117, 111, 99, 1),
              confirmTextColor: Colors.white,
              textConfirm: 'OK');
        });
      } else {
        setState(() {
          _currentPassMsg = 'current password is wrong';
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
                                    SizedBox(height: 20),
                                    ImageTaker(
                                      onImagePicked: (img) {
                                        setState(() {
                                          _directorSgntr = img;
                                        });
                                      },
                                      imageFile: _directorSgntr,
                                      imageUrl: _director!.signature,
                                    ),
                                    SizedBox(height: 10),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        primary: const Color.fromRGBO(
                                            160, 152, 128, 1),
                                      ),
                                      onPressed: () => _updateNameAndSignature(
                                          'director',
                                          _directorCtrl.text,
                                          _directorSgntr),
                                      child: const Text('Update'),
                                    ),
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
                                    SizedBox(height: 20),
                                    ImageTaker(
                                      onImagePicked: (img) {
                                        setState(() {
                                          _salsesMgrSgntr = img;
                                        });
                                      },
                                      imageFile: _salsesMgrSgntr,
                                      imageUrl: _salesManager!.signature,
                                    ),
                                    SizedBox(height: 10),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        primary: const Color.fromRGBO(
                                            160, 152, 128, 1),
                                      ),
                                      onPressed: () => _updateNameAndSignature(
                                          'salesManager',
                                          _salesMgrCtrl.text,
                                          _salsesMgrSgntr),
                                      child: const Text('Update'),
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
                                    SizedBox(height: 20),
                                    ImageTaker(
                                      onImagePicked: (img) {
                                        setState(() {
                                          _salesAdmSgntr = img;
                                        });
                                      },
                                      imageFile: _salesAdmSgntr,
                                      imageUrl: _salesAdmin!.signature,
                                    ),
                                    SizedBox(height: 10),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        primary: const Color.fromRGBO(
                                            160, 152, 128, 1),
                                      ),
                                      onPressed: () => _updateNameAndSignature(
                                          'salesAdmin',
                                          _salesAdmCtrl.text,
                                          _salesAdmSgntr),
                                      child: const Text('Update'),
                                    ),
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
                                    controller: _currentPass,
                                    obscureText: true,
                                    label: "Current password",
                                    hintText: 'Current password',
                                  ),
                                  Text(_currentPassMsg,
                                      style: TextStyle(
                                          color: Colors.red, fontSize: 10)),
                                  IniTextField(
                                    controller: _newPass,
                                    obscureText: true,
                                    label: "New password",
                                    hintText: 'New password',
                                  ),
                                  IniTextField(
                                    controller: _confirmPass,
                                    obscureText: true,
                                    label: "Confirm password",
                                    hintText: 'Confirm password',
                                  ),
                                  Text(_confirmPassMsg,
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
                                      onPressed: _changPassword,
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
