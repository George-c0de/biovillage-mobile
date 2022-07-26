import 'package:flutter/foundation.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:biovillage/redux/state/app-state.dart';
import 'package:biovillage/api-client/catalog.dart';
import 'package:biovillage/models/filter-tag.dart';
import 'package:biovillage/models/prod-category.dart';
import 'package:biovillage/models/product.dart';
import 'package:biovillage/models/gift.dart';
import 'package:biovillage/helpers/catalog.dart';
// import 'package:biovillage/helpers/debug.dart';

class SetFilterTags {
  final List<FilterTag> tags;
  SetFilterTags(this.tags);
}

/// Переключение статуса активности для фильтр-тега
ThunkAction<AppState> toggleFilterTag(int id, bool active) {
  return (Store<AppState> store) async {
    store.dispatch(SetFilterTagActive(id, active));
    setPrefsActiveTags(store.state.catalog.tags);
  };
}

class SetFilterTagActive {
  final int id;
  final bool active;
  SetFilterTagActive(this.id, this.active);
}

class SetCategories {
  final List<ProdCategory> categories;
  SetCategories(this.categories);
}

/// Получение списка товаров с сервера по id категории
ThunkAction<AppState> getProducts(int id, {Function onFailed}) {
  return (Store<AppState> store) async {
    // Если товары загружены ранее, то выходим:
    if (store.state.catalog.products[id] != null) return;
    // Если запрашиваются промо товары, то используем другой экшен:
    if (id == -1) {
      await store.dispatch(getPromoProducts(onFailed: onFailed));
      return;
    }
    var result = await ApiClientCatalog.getProducts(id);
    if (result == null || !result['success']) {
      if (onFailed != null) onFailed();
    } else {
      List<Product> products = await compute(parseAndSortJsonProducts, result['result']['products']);
      await store.dispatch(SetProducts(id, products));
      // printTimeMsg('GET PRODUCTS ($id) - данные распаршены');
    }
    // TODO: Временно прячем промотовары со страниц категорий
    // Проверим загружены ли промотовары:
    // if (id != -1 && store.state.catalog.products[-1] == null) {
    //   await store.dispatch(getPromoProducts(onFailed: onFailed));
    // }
  };
}

/// Получение списка промо товаров с сервера
ThunkAction<AppState> getPromoProducts({Function onFailed}) {
  return (Store<AppState> store) async {
    if (store.state.catalog.products[-1] != null) return;
    var result = await ApiClientCatalog.getPromoProducts();
    if (result == null || !result['success']) {
      if (onFailed != null) onFailed();
    } else {
      List<Product> products = await compute(parseJsonProducts, result['result']['products']);
      await store.dispatch(SetProducts(-1, products));
      // printTimeMsg('GET PROMO PRODUCTS - данные распаршены');
    }
  };
}

class SetProducts {
  final int categoryId;
  final List<Product> products;
  SetProducts(this.categoryId, this.products);
}

/// Получение списка подарков
ThunkAction<AppState> getGifts({Function onFailed}) {
  return (Store<AppState> store) async {
    if (store.state.catalog.gifts != null) return;
    var result = await ApiClientCatalog.getGifts();
    if (result == null || !result['success']) {
      if (onFailed != null) onFailed();
    } else {
      List<Gift> gifts = await compute(parseAndSortJsonGifts, result['result']);
      store.dispatch(SetGifts(gifts));
    }
  };
}

class SetGifts {
  final List<Gift> gifts;
  SetGifts(this.gifts);
}
