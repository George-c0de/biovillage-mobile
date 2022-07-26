import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:biovillage/redux/state/app-state.dart';
import 'package:biovillage/redux/actions/cart.dart';
import 'package:biovillage/api-client/account.dart';
import 'package:biovillage/models/user-info.dart';
import 'package:biovillage/models/address.dart';
import 'package:biovillage/models/history-order.dart';
import 'package:biovillage/models/order.dart';
import 'package:biovillage/models/payment-type.dart';
import 'package:biovillage/models/delivery-interval.dart';
import 'package:biovillage/helpers/address.dart';
import 'package:biovillage/helpers/account.dart';
import 'package:biovillage/helpers/data-formating.dart';
import 'package:biovillage/helpers/delivery-intervals.dart';
import 'package:biovillage/widgets/notifications.dart';
import 'package:biovillage/helpers/apps-flyer.dart';
// import 'package:biovillage/helpers/debug.dart';

typedef OnAuthRequestFailed = Function(Map<String, String> errors);

/// Инициализация параметров аккаунт-модуля
ThunkAction<AppState> initAccountParams() {
  return (Store<AppState> store) async {
    // Устанавливаем токен и статус авторизации из настроек:
    String token = await getPrefsUserToken();
    store.dispatch(SetUserToken(token));

    // Создаем и устанавливаем токен сессии пользователя:
    store.dispatch(SetSessionToken(Uuid().v4()));
  };
}

class SetUserToken {
  final String token;
  SetUserToken(this.token);
}

class SetSessionToken {
  final String sessionToken;
  SetSessionToken(this.sessionToken);
}

/// Запрос на авторизацию
ThunkAction<AppState> authRequest({
  @required String phone,
  String refCode,
  Function onSuccess,
  OnAuthRequestFailed onFailed,
}) {
  return (Store<AppState> store) async {
    // Сохраним данные в хранилище, они еще понадобятся:
    store.dispatch(SetAuthProps(phone, refCode));
    // Отправляем запрос:
    var result = await ApiClientAccount.authRequest(phone: phone, refCode: refCode);
    if (result != null && result['success']) {
      if (onSuccess != null) onSuccess();
    } else {
      if (result != null) {
        Map<String, String> errors = proccessResponseErrors(result['errors'], toastCommonError: true);
        if (onFailed != null) onFailed(errors);
      } else {
        if (onFailed != null) onFailed(null);
      }
    }
  };
}

class SetAuthProps {
  final String phone;
  final String refcode;
  SetAuthProps(this.phone, this.refcode);
}

/// Запрос на подтверждение авторизации
ThunkAction<AppState> authVerify({
  @required String smsCode,
  Function onSuccess,
  OnAuthRequestFailed onFailed,
}) {
  return (Store<AppState> store) async {
    // Определяем платформу:
    String platform = '';
    if (Platform.isAndroid) {
      platform = 'Android';
    } else if (Platform.isIOS) {
      platform = 'iOS';
    }
    // Отправляем запрос:
    var result = await ApiClientAccount.authVerify(
      phone: store.state.account.authPhone,
      smsCode: smsCode,
      platform: platform,
    );
    if (result != null && result['success']) {
      // Отправляем событие успешного входа/регистрации в AppsFlyer
      appsFlyerLogRegistrationEvent();

      store.dispatch(SetAuthProps(null, null));
      store.dispatch(SetUserToken(result['result']['token']));
      setPrefsUserToken(result['result']['token']);
      setPrefsUserLogged();

      // Устанавливаем данные пользователя:
      UserInfo userInfo = await compute(parseJsonUserInfo, result['result']);
      store.dispatch(SetUserInfo(userInfo));

      // Устанавливаем выбранный адрес:
      Address currentAddressPrefs = await getPrefsCurrentAddress();
      Address savedCurrentAddress;
      if (currentAddressPrefs != null) {
        savedCurrentAddress = userInfo.addresses.firstWhere(
          (address) => address.id == currentAddressPrefs.id,
          orElse: () => null,
        );
      }
      if (savedCurrentAddress != null) {
        store.dispatch(selectAddress(savedCurrentAddress));
      } else {
        // Если сохранненного адреса нет, то проверим временный адрес:
        // Если он есть, то оставим его как есть, если нет, то очищаем тек. адрес.
        Address tempAddress = store.state.account.currentAddress;
        if (tempAddress == null || !tempAddress.isTempAddress) {
          store.dispatch(selectAddress(null));
        }
      }

      // Устанавливаем выбранный способ оплаты:
      PaymentType paymentMethod = await getPrefsUserPaymentMethod();
      if (paymentMethod != null) store.dispatch(SetUserPaymentMethod(paymentMethod));
      if (onSuccess != null) onSuccess();
    } else {
      if (result != null) {
        Map<String, String> errors = proccessResponseErrors(result['errors'], toastCommonError: true);
        if (onFailed != null) onFailed(errors);
      } else {
        if (onFailed != null) onFailed(null);
      }
    }
  };
}

/// Логаут
ThunkAction<AppState> logout() {
  return (Store<AppState> store) async {
    store.dispatch(SetUserToken(null));
    setPrefsUserToken(null);
    store.dispatch(SetUserInfo(null));
    setPrefsUserPaymentMethod(null);
    store.dispatch(selectAddress(null));
    store.dispatch(clearCart());
    store.dispatch(selectDeliveryInterval(null));
  };
}

/// Запрос данных о пользователе
ThunkAction<AppState> getUserInfo({Function onFailed}) {
  return (Store<AppState> store) async {
    if (!store.state.account.userAuth) return;
    String token = store.state.account.userToken;
    var result = await ApiClientAccount.getUserInfo(token);
    if (result != null &&
        result['errors'] != null &&
        result['errors']['message'] != null &&
        result['errors']['message'][0] == 'Unauthenticated') {
      store.dispatch(logout());
      return;
    }
    if (result == null || result['success'] != true) {
      if (onFailed != null) onFailed();
      return;
    }
    UserInfo userInfo = await compute(parseJsonUserInfo, result['result']);
    store.dispatch(SetUserInfo(userInfo));
    // Устанавливаем выбранный адрес:
    Address currentAddressPrefs = await getPrefsCurrentAddress();
    if (currentAddressPrefs != null) {
      Address currentAddress = userInfo.addresses.firstWhere(
        (address) => address.id == currentAddressPrefs.id && address.deliveryPrice == currentAddressPrefs.deliveryPrice,
        orElse: () => null,
      );
      store.dispatch(selectAddress(currentAddress));
    }
    // Устанавливаем выбранный способ оплаты:
    PaymentType paymentMethod = await getPrefsUserPaymentMethod();
    if (paymentMethod != null) store.dispatch(SetUserPaymentMethod(paymentMethod));
    // printTimeMsg('GET USER INFO - данные распаршены');
  };
}

/// Обновление данных пользователя
ThunkAction<AppState> updateUserInfo({
  @required String name,
  @required String email,
  String birthday,
  Function onSuccess,
  Function onFailed,
}) {
  return (Store<AppState> store) async {
    String token = store.state.account.userToken;
    var result = await ApiClientAccount.updateUserInfo(token, name: name, birthday: birthday, email: email);
    if (result != null && result['success']) {
      UserInfo userInfo = await compute(parseJsonUserInfo, result['result']);
      store.dispatch(SetUserInfo(userInfo));
      if (onSuccess != null) onSuccess();
    } else {
      if (result != null) {
        Map<String, String> errors = proccessResponseErrors(result['errors'], toastCommonError: true);
        if (onFailed != null) onFailed(errors);
      } else {
        if (onFailed != null) onFailed(null);
      }
    }
  };
}

class SetUserInfo {
  final UserInfo userInfo;
  SetUserInfo(this.userInfo);
}

/// Добавление адреса
ThunkAction<AppState> addAddress(Address address, {Function onFailed}) {
  return (Store<AppState> store) async {
    String token = store.state.account.userToken;
    var result = await ApiClientAccount.addAddress(token, address);
    if (result != null && result['success']) {
      // Устанавливаем id адреса и точную цену доставки из ответа:
      address.id = result['result']['id'];
      address.deliveryPrice = result['result']['daPrice'];
      // Делаем данный адрес выбранным:
      store.dispatch(selectAddress(address));
      // Добавляем адрес в redux:
      store.dispatch(AddAddress(address));
    } else {
      if (result != null) proccessResponseErrors(result['errors'], toastAllErrors: true);
      if (onFailed != null) onFailed(result != null ? result['errors'] : null);
    }
  };
}

class AddAddress {
  final Address address;
  AddAddress(this.address);
}

/// Выбор адреса
ThunkAction<AppState> selectAddress(Address address) {
  return (Store<AppState> store) async {
    setPrefsCurrentAddress(address);
    store.dispatch(SetCurrentAddress(address));
  };
}

class SetCurrentAddress {
  final Address address;
  SetCurrentAddress(this.address);
}

/// Удаление адреса
ThunkAction<AppState> removeAddress(Address address, {Function onSuccess, Function onFailed}) {
  return (Store<AppState> store) async {
    String token = store.state.account.userToken;
    var result = await ApiClientAccount.removeAddress(token, address.id);
    if (result != null && result['success']) {
      if (onSuccess != null) onSuccess();
      // Если удаляемый адрес является выбранным, то он больше не может быть выбранным:
      Address currentAddressPrefs = await getPrefsCurrentAddress();
      if (currentAddressPrefs != null && currentAddressPrefs.id == address.id) {
        store.dispatch(selectAddress(null));
      }
      // Удаляем адрес из хранилища:
      store.dispatch(RemoveAddress(address));
    } else {
      if (result != null) proccessResponseErrors(result['errors'], toastAllErrors: true);
      if (onFailed != null) onFailed(result != null ? result['errors'] : null);
    }
  };
}

class RemoveAddress {
  final Address address;
  RemoveAddress(this.address);
}

/// Запрос истории заказов
ThunkAction<AppState> getOrdersHistory({onFailed(), onSuccess(List<HistoryOrder> orders)}) {
  return (Store<AppState> store) async {
    if (!store.state.account.userAuth) return;
    String token = store.state.account.userToken;
    var result = await ApiClientAccount.getOrdersHistory(token);
    if (result == null || result['success'] != true) {
      if (onFailed != null) onFailed();
      return;
    }
    List<HistoryOrder> orders = await compute(
      parseJsonHistoryOrders,
      ParseJsonHistoryOrdersParams(
        json: result['result']['orders'],
        di: store.state.general.deliveryIntervals,
      ),
    );
    store.dispatch(SetUserOrders(orders));
    if (onSuccess != null) await onSuccess(orders);
  };
}

class SetUserOrders {
  final List<HistoryOrder> orders;
  SetUserOrders(this.orders);
}

/// Добавление заказа в историю заказов (если они загружены ранее)
ThunkAction<AppState> addOrdersHistoryItem(HistoryOrder order) {
  return (Store<AppState> store) async {
    if (store.state.account.userInfo.orders == null) return;
    store.dispatch(AddUserOrder(order));
  };
}

class AddUserOrder {
  final HistoryOrder order;
  AddUserOrder(this.order);
}

/// Создание заказа
ThunkAction<AppState> createOrder(
  Order order, {
  Function onFailed,
  Function onSuccess,
  @required String defaultErrorText,
}) {
  return (Store<AppState> store) async {
    String token = store.state.account.userToken;
    var result = await ApiClientAccount.createOrder(token, order);
    if (result != null && result['success'] == true) {
      // Отправляем событие покупки в appsFlyer:
      appsFlyerLogPurchaseEvent(result['result']);

      // Обновляем бонусы пользователя:
      store.dispatch(UpdateUserBonuses(result['result']['clientBonuses']));

      // Добавляем заказ в историю:
      // Время доставки определяем на фронте:
      DeliveryInterval di = findDeliveryIntervalById(
        result['result']['deliveryIntervalId'],
        store.state.general.deliveryIntervals,
      );
      result['result']['deliveryTime'] = di != null ? di.intervalText : '';
      HistoryOrder historyOrder = await compute(parseJsonHistoryOrder, result['result']);
      store.dispatch(addOrdersHistoryItem(historyOrder));

      // Проверяем пришли ли данные для подтверждения оплаты:
      String confirmationLink;
      var paymentData = result['result']['paymentData'] != null ? result['result']['paymentData'][0] : null;
      if (paymentData != null && paymentData['confirmation'] != null && paymentData['confirmation'] != '') {
        confirmationLink = paymentData['confirmation'];
      }
      // Коллбэк успешного заказа:
      if (onSuccess != null) await onSuccess(confirmationLink);
    } else {
      if (result != null && result['errors'] != null) {
        proccessResponseErrors(result['errors'], toastAllErrors: true, defaultErrorText: defaultErrorText);
      } else {
        showToast(defaultErrorText, isError: true);
      }
      if (onFailed != null) onFailed(result != null ? result['errors'] : null);
    }
  };
}

/// Выбор способа оплаты
ThunkAction<AppState> selectPaymentMethod(PaymentType paymentMethod) {
  return (Store<AppState> store) async {
    store.dispatch(SetUserPaymentMethod(paymentMethod));
    setPrefsUserPaymentMethod(paymentMethod);
  };
}

class SetUserPaymentMethod {
  final PaymentType paymentMethod;
  SetUserPaymentMethod(this.paymentMethod);
}

class UpdateUserBonuses {
  final int bonuses;
  UpdateUserBonuses(this.bonuses);
}
