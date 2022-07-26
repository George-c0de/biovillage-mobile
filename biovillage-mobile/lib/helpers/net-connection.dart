import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:biovillage/widgets/notifications.dart';

/// Проверка интернет соедения с возможностью вывода тост-уведомления
Future<bool> checkConnect(BuildContext context, {bool toast = true}) async {
  bool connect;
  try {
    final result = await InternetAddress.lookup('google.com');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      connect = true;
    }
  } on SocketException catch (_) {
    if (context != null && toast) showToast(FlutterI18n.translate(context, 'common.no_internet'), isError: true);
    connect = false;
  }
  return connect;
}
