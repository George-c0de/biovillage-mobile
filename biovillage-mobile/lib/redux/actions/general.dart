import 'package:flutter/foundation.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:biovillage/redux/state/app-state.dart';
import 'package:biovillage/redux/actions/catalog.dart';
import 'package:biovillage/api-client/general.dart';
import 'package:biovillage/models/slide.dart';
import 'package:biovillage/models/filter-tag.dart';
import 'package:biovillage/models/prod-category.dart';
import 'package:biovillage/models/delivery-area.dart';
import 'package:biovillage/models/payment-delivery-info.dart';
import 'package:biovillage/models/company-info.dart';
import 'package:biovillage/models/delivery-interval.dart';
import 'package:biovillage/helpers/catalog.dart';
// import 'package:biovillage/helpers/debug.dart';
import 'package:biovillage/helpers/system-elements.dart';
import 'package:biovillage/widgets/map.dart';

/// Получение основных настроек приложения
ThunkAction<AppState> getSettings({Function onFailed}) {
  return (Store<AppState> store) async {
    if (store.state.general.homeSlider != null) return;
    var result = await ApiClientGeneral.getSettings();
    if (result == null || result['success'] != true) {
      if (onFailed != null) onFailed();
      return;
    }
    result = result['result'];

    // Слайдер:
    if (result['mainSlider'] != null) {
      List<Slide> slides = await compute(parseJsonSlides, result['mainSlider']);
      store.dispatch(SetSlides(slides));
    }

    // Теги для фильтрации каталога:
    if (result['tags'] != null) {
      List<FilterTag> tags = await compute(parseJsonFilterTags, result['tags']);
      List<int> activeTagsIds = await getPrefsActiveTags();
      if (tags.isNotEmpty && activeTagsIds.isNotEmpty) {
        tags.forEach((tag) {
          if (activeTagsIds.contains(tag.id)) tag.active = true;
        });
      }
      store.dispatch(SetFilterTags(tags));
    }

    // Категории товаров:
    if (result['groups'] != null) {
      List<ProdCategory> categories = await compute(parseAndSortJsonCategories, result['groups']);
      // Также создаем виртуальную категорию товаров по акции:
      categories.insert(
        0,
        ProdCategory(
          id: -1,
          name: result['promoProdsName'],
          imageSrc: result['promoProdsImg'],
          bgColor: result['promoProdsBgColor'],
        ),
      );
      store.dispatch(SetCategories(categories));
      // printTimeMsg('GET APP SETTINGS - категории распаршены');
    }

    // Интервалы времени доставки:
    if (result['di'] != null) {
      Map<int, List<DeliveryInterval>> deliveryIntervals = await compute(parseJsonDeliveryIntervals, result['di']);
      store.dispatch(SetDeliveryIntervals(deliveryIntervals));
      // printTimeMsg('GET APP SETTINGS - интервалы доставки распаршены');
    }

    // Ключ гугл-карт:
    if (result['mapsToken'] != null) {
      store.dispatch(SetGoogleMapsKey(result['mapsToken']));
    }

    // Зоны доставки и координаты центра:
    if (result['da'] != null) {
      List<DeliveryArea> deliveryAreas = await compute(parseJsonDeliveryAreas, result['da']);
      store.dispatch(SetDilveryAreas(
        deliveryAreas,
        deliveryMapCenter: Point(latitude: result['mapsCenterLat'], longitude: result['mapsCenterLon']),
        deliveryMapZoom: result['mapsZoom'] != null ? double.parse(result['mapsZoom'].toString()) : null,
        deliveryMapSearchRadius:
            result['mapSearchRadius'] != null ? double.parse(result['mapSearchRadius'].toString()) : null,
      ));
      // printTimeMsg('GET APP SETTINGS - зоны доставки распаршены');
    }

    // Общая информация по оплате и доставке:
    PaymentDeliveryInfo paymentDeliveryInfo = await compute(parseJsonPaymentDeliveryInfo, result);
    store.dispatch(SetPaymentDeliveryInfo(paymentDeliveryInfo));
    // printTimeMsg('GET APP SETTINGS - инфо о оплате и доставке распаршены');

    // Информация о компании:
    CompanyInfo companyInfo = await compute(parseJsonCompanyInfo, result);
    store.dispatch(SetCompanyInfo(companyInfo));
    // printTimeMsg('GET APP SETTINGS - инфо о компании распаршена');
  };
}

class SetSlides {
  final List<Slide> slides;
  SetSlides(this.slides);
}

class SetDeliveryIntervals {
  final Map<int, List<DeliveryInterval>> deliveryIntervals;
  SetDeliveryIntervals(this.deliveryIntervals);
}

class SetGoogleMapsKey {
  final String key;
  SetGoogleMapsKey(this.key);
}

class SetDilveryAreas {
  final List<DeliveryArea> deliveryAreas;
  final Point deliveryMapCenter;
  final double deliveryMapZoom;
  final double deliveryMapSearchRadius;
  SetDilveryAreas(this.deliveryAreas, {this.deliveryMapCenter, this.deliveryMapZoom, this.deliveryMapSearchRadius});
}

class SetPaymentDeliveryInfo {
  final PaymentDeliveryInfo paymentDeliveryInfo;
  SetPaymentDeliveryInfo(this.paymentDeliveryInfo);
}

class SetCompanyInfo {
  final CompanyInfo companyInfo;
  SetCompanyInfo(this.companyInfo);
}

class SetNavBarTheme {
  final NavBarTheme navBarTheme;
  SetNavBarTheme(this.navBarTheme);
}
