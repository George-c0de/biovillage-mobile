import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:biovillage/api-client/_api-client.dart';
import 'package:biovillage/models/address.dart';
import 'package:biovillage/models/order.dart';
import 'package:biovillage/helpers/data-formating.dart';
// import 'package:biovillage/helpers/debug.dart';

class ApiClientAccount {
  /// Запрос аутентификации
  static Future<Map<String, dynamic>> authRequest({@required String phone, String refCode}) async {
    Map<String, String> body = {};
    body['phone'] = numsFromString(phone);
    if (refCode != '') body['referral'] = refCode;
    var result = await ApiClient().postRequest(
      url: 'client/register/request',
      body: body,
    );
    return result;
  }

  /// Запрос подтверждения аутентификации
  static Future<Map<String, dynamic>> authVerify({
    @required String phone,
    @required String smsCode,
    @required String platform,
  }) async {
    var result = await ApiClient().postRequest(
      url: 'client/register/verify',
      body: {
        'phone': numsFromString(phone),
        'code': smsCode,
        'platform': platform,
      },
    );
    return result;
  }

  /// Запрос информации о пользователе
  static Future<Map<String, dynamic>> getUserInfo(String userToken) async {
    // printTimeMsg('GET USER INFO - запрос отправлен');
    var result = await ApiClient().getRequest(
      url: 'client',
      userToken: userToken,
    );
    // printTimeMsg('GET USER INFO - ответ получен');
    return result;
  }

  /// Обновление информации о пользователе
  static Future<Map<String, dynamic>> updateUserInfo(
    String userToken, {
    @required String name,
    @required String email,
    String birthday,
  }) async {
    var result = await ApiClient().postRequest(
      url: 'client',
      userToken: userToken,
      body: {
        'name': name,
        'birthday': birthday,
        'email': email,
      },
    );
    return result;
  }

  /// Запрос на обновления даты рождения пользователя
  static Future<Map<String, dynamic>> updateUserBirthday(
    String userToken, {
    @required String birthday,
  }) async {
    var result = await ApiClient().postRequest(
      url: 'client/birthday',
      userToken: userToken,
      body: {
        'birthday': birthday,
      },
    );
    return result;
  }

  /// Добавление адреса
  static Future addAddress(String userToken, Address address) async {
    var result = await ApiClient().postRequest(
      url: 'client/addresses',
      userToken: userToken,
      body: {
        'name': address.name,
        'street': address.address,
        'city': address.city ?? '',
        'lat': address.coords.latitude.toString(),
        'lon': address.coords.longitude.toString(),
        'appt': address.appt ?? '',
        'entrance': address.entrance ?? '',
        'doorphone': address.doorphone ?? '',
        'floor': address.floor ?? '',
        'comment': address.comment ?? '',
      },
    );
    return result;
  }

  /// Удаление адреса
  static Future removeAddress(String userToken, int addressId) async {
    var result = await ApiClient().deleteRequest(
      url: 'client/addresses/$addressId',
      userToken: userToken,
    );
    return result;
  }

  /// Создание заказа
  static Future createOrder(String userToken, Order order) async {
    var result = await ApiClient().postRequest(
      url: 'client/orders',
      userToken: userToken,
      body: order.toMap(),
    );
    return result;
  }

  /// Запрос истории зкаказов
  static Future<Map<String, dynamic>> getOrdersHistory(String userToken) async {
    var result = await ApiClient().getRequest(
      url: 'client/orders',
      params: {
        'perPage': '15',
      },
      userToken: userToken,
    );
    return result;
  }
}
