import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:biovillage/helpers/sentry.dart';

final AppsflyerSdk appsflyerSdk = AppsflyerSdk({
  "afDevKey": DotEnv().env['APPSFLYER_KEY'],
  "afAppId": DotEnv().env['APPSFLYER_ID'],
  "isDebug": !kReleaseMode,
});

/// Отправка событий в AppsFlyer
Future<bool> appsFlyerLogEvent(String eventName, Map eventValues) async {
  bool result;
  try {
    result = await appsflyerSdk.logEvent(eventName, eventValues);
  } on Exception catch (error, stackTrace) {
    Sentry.client.captureException(
      exception: error,
      stackTrace: stackTrace,
    );
  }
  return result;
}

/// Отправка события регистрации (входа) в AppsFlyer
Future<bool> appsFlyerLogRegistrationEvent() async {
  bool result;
  try {
    result = await appsflyerSdk.logEvent('AFEventCompleteRegistration', {});
  } on Exception catch (error, stackTrace) {
    Sentry.client.captureException(
      exception: error,
      stackTrace: stackTrace,
    );
  }
  return result;
}

/// Отправка события заказа в AppsFlyer
Future<bool> appsFlyerLogPurchaseEvent(Map<String, dynamic> jsonRes) async {
  bool result;
  try {
    String prodIds = '';
    String prodNames = '';
    int prodAmount = 0;
    jsonRes['itemsData'].forEach((product) {
      prodIds += prodIds.isEmpty ? product['prodId'].toString() : '; ' + product['prodId'].toString();
      prodNames += prodNames.isEmpty ? product['name'] : '; ' + product['name'];
      prodAmount += product['qty'];
    });
    result = await appsflyerSdk.logEvent('AFEventPurchase', {
      'AFEventParamRevenue': jsonRes['total'],
      'AFEventParamCurrency': 'RUB',
      'AFEventParamQuantity': prodAmount,
      'AFEventParamContent': prodNames,
      'AFEventParamContentId': prodIds,
      'AFEventParamReceiptId': jsonRes['id'].toString(),
    });
  } on Exception catch (error, stackTrace) {
    Sentry.client.captureException(
      exception: error,
      stackTrace: stackTrace,
    );
  }
  return result;
}
