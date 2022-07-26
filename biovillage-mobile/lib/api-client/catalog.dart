import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:biovillage/api-client/_api-client.dart';
import 'package:biovillage/models/prod-category.dart';
import 'package:biovillage/models/product.dart';
// import 'package:biovillage/helpers/debug.dart';

class ApiClientCatalog {
  /// Запрос продуктов по id категории
  static Future<Map<String, dynamic>> getProducts(int id) async {
    // printTimeMsg('GET PRODUCTS ($id) - запрос отправлен');
    var result = await ApiClient().getRequest(
      url: 'catalog',
      params: {
        'page': '1',
        'perPage': '1000',
        'groupId': '$id',
      },
    );
    // printTimeMsg('GET PRODUCTS ($id) - ответ получен');
    return result;
  }

  /// Запрос товаров по акции
  static Future<Map<String, dynamic>> getPromoProducts() async {
    // printTimeMsg('GET PROMO PRODUCTS - запрос отправлен');
    var result = await ApiClient().getRequest(
      url: 'catalog/promo',
      params: {
        'page': '1',
        'perPage': '1000',
      },
    );
    // printTimeMsg('GET PROMO PRODUCTS - ответ получен');
    return result;
  }

  /// Поиск по каталогу
  static Future<Map<String, List>> catalogSearch(String q) async {
    var result = await ApiClient().getRequest(
      url: 'catalog',
      params: {
        'name': q,
        'perPage': '1000',
      },
    );
    if (result == null || !result['success']) return null;
    return {
      'categories': await compute(parseJsonCategories, result['result']['groups']),
      'products': await compute(parseJsonProducts, result['result']['products']),
    };
  }

  /// Запрос списка подарков
  static Future<Map<String, dynamic>> getGifts() async {
    var result = await ApiClient().getRequest(
      url: 'gifts',
    );
    return result;
  }
}
