import 'package:flutter/material.dart';

class IniTextField extends StatelessWidget {
  final bool? readOnly;
  final String? label;
  final TextEditingController? controller;
  final String? hintText;
  final bool? obscureText;

  const IniTextField(
      {Key? key,
      this.label,
      this.controller,
      this.hintText,
      this.obscureText,
      this.readOnly})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 9),
          child: Text(label ?? ""),
        ),
        TextField(
          readOnly: readOnly ?? false,
          obscureText: obscureText ?? false,
          controller: controller,
          decoration: InputDecoration(
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
        ),
      ],
    );
  }
}
