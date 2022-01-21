import 'package:admin/constant/db_constant.dart';
import 'package:admin/route/route_constant.dart';
import 'package:admin/utils/encrypt.dart';
import 'package:admin/widget/ini_text_field.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'dashboard_screen.dart';

class AuthScreen extends StatefulWidget {
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _passCtr = TextEditingController();

  final db = FirebaseDatabase.instance.ref(DbConstant.adminPass);

  _verify() {
    if (_passCtr.text.isEmpty) return;

    db.get().then((value) {
      debugPrint(value.value.toString());
      if (value.value == Encrypt.heh(_passCtr.text)) {
        Get.offAllNamed(RouteConstant.dashboard);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 200,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IniTextField(
                obscureText: true,
                label: "Password",
                hintText: 'Password',
                controller: _passCtr,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 100),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: const Color.fromRGBO(160, 152, 128, 1),
                  ),
                  onPressed: _verify,
                  child: const Text('Verify'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
