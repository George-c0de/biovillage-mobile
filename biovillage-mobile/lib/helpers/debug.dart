import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Вывод сообщения в консоль со временем
void printTimeMsg(String message) {
  var n = new DateTime.now();
  String h = n.hour.toString().padLeft(2, '0');
  String m = n.minute.toString().padLeft(2, '0');
  String s = n.second.toString().padLeft(2, '0');
  String ms = n.millisecond.toString().padLeft(3, '0');
  String time = '$h:$m:$s.$ms';
  debugPrint('############# $time | $message');
}
