import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:biovillage/redux/state/app-state.dart';
import 'package:biovillage/models/cart-product.dart';

/// Поиск товара в массиве товаров по id:
CartProduct findCartProduct(List<CartProduct> products, int productId) {
  return products.firstWhere(
    (product) => product.id == productId,
    orElse: () => null,
  );
}

/// Преобразование массива json-строк в массив товаров корзины
List<CartProduct> jsonDecodeCartProducts(List<dynamic> jsonList) {
  jsonList = jsonList.cast<String>();
  return jsonList.map((c) => CartProduct.fromJson(jsonDecode(c))).toList().cast<CartProduct>();
}

/// Имя настроек SharedPreferences для хранения корзины
final String cartProductsPrefsName = 'cartProducts';

/// Тип операции над продуктом корзины в отношении к SharedPreferences
enum CartProductPrefsOperation { add, remove, update, clear }

/// Изменение товаров корзины в SharedPreferences
Future<bool> updatePrefsCartProducts(CartProduct cartProduct, CartProductPrefsOperation operation) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  // Получаем список json-строк товаров из SharedPreferences:
  List jsonCartProducts = prefs.get(cartProductsPrefsName) ?? [];
  // Преобразуем сисок json-строк в список нефиксированной длины:
  jsonCartProducts = new List<String>.from(jsonCartProducts);
  // Декодируем сохраненные товары:
  List<CartProduct> cartProducts = await compute(jsonDecodeCartProducts, jsonCartProducts);

  switch (operation) {
    case CartProductPrefsOperation.add:
      // Если продукт уже был добавлен, то выходим:
      if (findCartProduct(cartProducts, cartProduct.id) != null) return false;
      // Преобразуем добавляемый товар в json-строку и добавляем в общий список:
      String jsonCartProduct = await compute(cartProductToJson, cartProduct);
      jsonCartProducts.add(jsonCartProduct);
      break;

    case CartProductPrefsOperation.remove:
      // Находим продукт в корзине, если нет, то выходим:
      CartProduct productToRemove = findCartProduct(cartProducts, cartProduct.id);
      if (productToRemove == null) return false;
      // Удаляем продукт из массива json-строк:
      String productToRemoveJson = await compute(cartProductToJson, productToRemove);
      jsonCartProducts.remove(productToRemoveJson);
      break;

    case CartProductPrefsOperation.update:
      // Проверяем есть ли товар с таким id в корзине, если нет, то выходим:
      CartProduct foundProduct = findCartProduct(cartProducts, cartProduct.id);
      if (foundProduct == null) return false;
      // Определяем индекс продукта в массиве строк и заменяем новой:
      int index = cartProducts.indexOf(foundProduct);
      jsonCartProducts[index] = await compute(cartProductToJson, cartProduct);
      break;

    case CartProductPrefsOperation.clear:
      jsonCartProducts = [];
      break;
  }

  // Сохраняем новую корзину в SharedPreferences и возвращаем результат:
  bool result = await prefs.setStringList(cartProductsPrefsName, jsonCartProducts.cast<String>());
  if (!result) print('При изменении корзины в SharedPreferences возникла ошибка');
  return result;
}

/// Подсчет стоимости доставки:
int calcDeliverySum(AppState state) {
  if (state.account.currentAddress == null) return null;
  int deliveryPrice = state.account.currentAddress.deliveryPrice ?? 0;
  int freeSum = state.account.currentAddress.deliveryFreeSum ?? 0;
  int cartCost = state.cart.cost;
  if (cartCost >= freeSum) deliveryPrice = 0;
  return deliveryPrice;
}

/// Подсчет суммы, оставшейся для бесплатной доставки
int calcSumForFreeDelivery(AppState state) {
  if (state.account.currentAddress == null) return null;
  int freeSum = state.account.currentAddress.deliveryFreeSum ?? 0;
  int cartCost = state.cart.cost;
  int difference = freeSum - cartCost;
  return difference <= 0 ? 0 : difference;
}
