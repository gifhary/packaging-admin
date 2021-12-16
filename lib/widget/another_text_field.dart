import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AnotherTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final Function(String)? onChanged;

  const AnotherTextField(
      {Key? key, this.controller, this.hintText, this.onChanged})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
      onChanged: onChanged,
      controller: controller,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.all(8),
        isDense: true,
        focusedBorder: const OutlineInputBorder(
          borderSide:
              BorderSide(color: Color.fromRGBO(117, 111, 99, 1), width: 1),
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide:
              BorderSide(color: Color.fromRGBO(117, 111, 99, 1), width: 1),
        ),
        hintText: hintText,
      ),
    );
  }
}
