import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:biovillage/models/address.dart';

/// Имя настроек SharedPreferences для хранения текущего адреса
final String currentAddressPrefsName = 'currentAddress';

/// Установка текущего адреса
Future<bool> setPrefsCurrentAddress(Address address) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (address == null) {
    return prefs.remove(currentAddressPrefsName);
  } else {
    String jsonAddress = await compute(addressToJson, address);
    return prefs.setString(currentAddressPrefsName, jsonAddress);
  }
}

/// Получение текущего адреса
Future<Address> getPrefsCurrentAddress() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String addressJson = prefs.getString(currentAddressPrefsName);
  if (addressJson == null) return null;
  return await compute(addressFromJson, addressJson);
}

/// Укорачивание адреса с помощью удаления первых слов (улица, переулок и т.п.)
String shortenAddress(BuildContext context, String address) {
  final List<String> removingWords = FlutterI18n.translate(context, 'common.shorten_address_removing_words').split('|');
  removingWords.forEach((word) {
    if (address.indexOf(word) == 0) address = address.replaceAll('$word ', '');
  });
  return address;
}
