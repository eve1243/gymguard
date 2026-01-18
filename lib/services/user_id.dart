import 'dart:convert';
import 'package:crypto/crypto.dart';

String userIdFromName(String name) {
  return sha256.convert(utf8.encode(name.trim().toLowerCase())).toString();
}
