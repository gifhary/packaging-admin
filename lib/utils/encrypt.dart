import 'dart:convert';
import 'package:crypto/crypto.dart';

class Encrypt {
  static String heh(String input) {
    return md5.convert(utf8.encode(input)).toString();
  }
}
