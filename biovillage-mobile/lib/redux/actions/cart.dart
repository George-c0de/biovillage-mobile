import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:biovillage/redux/state/app-state.dart';
import 'package:biovillage/models/product.dart';
import 'package:biovillage/models/cart-product.dart';
import 'package:biovillage/models/delivery-interval.dart';
import 'package:biovillage/helpers/cart.dart';

/// Инициализация продуктов корзины (перенос из SharedPreferences в state)
ThunkAction<AppState> initCartProducts() {
  return (Store<AppState> store) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List jsonCartProducts = prefs.get(cartProductsPrefsName) ?? [];
    List<CartProduct> cartProducts = await compute(jsonDecodeCartProducts, jsonCartProducts);
    await store.dispatch(SetCart(cartProducts));
    await store.dispatch(countCartTotal());
  };
}

class SetCart {
  final List<CartProduct> products;
  SetCart(this.products);
}

/// Добавление товара в корзину
ThunkAction<AppState> addToCart(Product product) {
  return (Store<AppState> store) async {
    // Проверяем, есть ли товар в корзине:
    if (findCartProduct(store.state.cart.products, product.id) != null) return;
    // Создаем продукт корзины:
    CartProduct cartProduct = CartProduct.fromProduct(product);
    // Добавляем продукт в корзину (state & SharedPreferences):
    await store.dispatch(AddProduct(cartProduct));
    await store.dispatch(countCartTotal());

    // Отправляем событие добавления в корзину в Facebook:
    FacebookAppEvents().logAddToCart(
      content: {'name': cartProduct.name},
      id: cartProduct.id.toString(),
      type: 'product',
      currency: 'RUB',
      price: cartProduct.price.toDouble(),
    );

    updatePrefsCartProducts(cartProduct, CartProductPrefsOperation.add);
  };
}

class AddProduct {
  final CartProduct product;
  AddProduct(this.product);
}

/// Удаление товара из корзины
ThunkAction<AppState> removeFromCart(int productId) {
  return (Store<AppState> store) async {
    // Проверяем, есть ли товар в корзине:
    CartProduct cartProduct = findCartProduct(store.state.cart.products, productId);
    if (cartProduct == null) return;
    // Удаляем продукт из корзины (state & SharedPreferences):
    await store.dispatch(RemoveProduct(cartProduct));
    await store.dispatch(countCartTotal());
    updatePrefsCartProducts(cartProduct, CartProductPrefsOperation.remove);
  };
}

class RemoveProduct {
  final CartProduct product;
  RemoveProduct(this.product);
}

/// Изменение кол-ва продукта в корзине
ThunkAction<AppState> changeCartProductAmount(Product product, int diffAmount) {
  return (Store<AppState> store) async {
    // Проверяем, есть ли товар в корзине, если нет, то просто добавляем:
    CartProduct cartProduct = findCartProduct(store.state.cart.products, product.id);
    if (cartProduct == null) return await store.dispatch(addToCart(product));
    // Изменяем кол-во товара:
    cartProduct.amount += diffAmount;
    cartProduct.cost = cartProduct.amount * cartProduct.price;
    // Если кол-во товара < 1, то просто удаляем товар:
    if (cartProduct.amount < 1) return await store.dispatch(removeFromCart(product.id));
    // Сохраняем изменненный товар:
    await store.dispatch(UpdateProduct(cartProduct));
    await store.dispatch(countCartTotal());
    updatePrefsCartProducts(cartProduct, CartProductPrefsOperation.update);
  };
}

class UpdateProduct {
  final CartProduct product;
  UpdateProduct(this.product);
}

/// Подсчет кол-ва итогов корзины
ThunkAction<AppState> countCartTotal() {
  return (Store<AppState> store) async {
    List<CartProduct> cartProducts = store.state.cart.products;
    int amount = cartProducts.fold(0, (acc, product) => acc + product.amount);
    int cost = cartProducts.fold(0, (acc, product) => acc + product.cost);
    await store.dispatch(SetCartTotal(amount, cost));
  };
}

class SetCartTotal {
  final int amount;
  final int cost;
  SetCartTotal(this.amount, this.cost);
}

/// Сброс корзины
ThunkAction<AppState> clearCart() {
  return (Store<AppState> store) async {
    await store.dispatch(ClearCart());
    await store.dispatch(countCartTotal());
    updatePrefsCartProducts(null, CartProductPrefsOperation.clear);
  };
}

class ClearCart {
  ClearCart();
}

/// Установка выбранного интервала доставки
ThunkAction<AppState> selectDeliveryInterval(DeliveryInterval deliveryInterval) {
  return (Store<AppState> store) async {
    store.dispatch(SetDeliveryInterval(deliveryInterval));
  };
}

class SetDeliveryInterval {
  final DeliveryInterval deliveryInterval;
  SetDeliveryInterval(this.deliveryInterval);
}
