import 'package:shared_preferences/shared_preferences.dart';
import 'package:biovillage/models/payment-type.dart';

/// Имя настроек SharedPreferences для хранения флажка о входе пользователя
final String userLoggedPrefsName = 'userLogged';

/// Имя настроек SharedPreferences для хранения токена пользователя
final String userTokenPrefsName = 'userToken';

/// Имя настроек SharedPreferences для хранения выбранного способа оплаты
final String userPaymentMethodPrefsName = 'userPaymentMethod';

/// Устанавка флажка, сигнализирущего о том, что пользователь уже входил с этого устройства
Future<bool> setPrefsUserLogged({bool val = true}) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.setBool(userLoggedPrefsName, val);
}

/// Получение флажка, сигнализирущего о том, что пользователь уже входил с этого устройства
Future<bool> getPrefsUserLogged() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool(userLoggedPrefsName);
}

/// Установка токена в SharedPreferences
Future<bool> setPrefsUserToken(String token) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (token == null || token == '') return prefs.remove(userTokenPrefsName);
  return prefs.setString(userTokenPrefsName, token);
}

/// Получение токена из SharedPreferences
Future<String> getPrefsUserToken() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString(userTokenPrefsName);
}

/// Установка способа оплаты в SharedPreferences
Future<bool> setPrefsUserPaymentMethod(PaymentType paymentMethod) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (paymentMethod == null) return prefs.remove(userPaymentMethodPrefsName);
  String paymentMethodName = paymentMethod.toString().split('.').last;
  return prefs.setString(userPaymentMethodPrefsName, paymentMethodName);
}

/// Получение способа оплаты из SharedPreferences
Future<PaymentType> getPrefsUserPaymentMethod() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String paymentMethodName = prefs.getString(userPaymentMethodPrefsName);
  return PaymentType.values.firstWhere(
    (val) => val.toString().split('.').last == paymentMethodName,
    orElse: () => null,
  );
}
