import 'dart:async';
import 'package:biovillage/api-client/_api-client.dart';
// import 'package:biovillage/helpers/debug.dart';

class ApiClientGeneral {
  /// Запрос основных настроек приложения
  static Future<Map<String, dynamic>> getSettings() async {
    // printTimeMsg('GET APP SETTINGS - запрос отправлен');
    var result = await ApiClient().getRequest(
      url: 'settings',
    );
    // printTimeMsg('GET APP SETTINGS - ответ получен');
    return result;
  }
}
