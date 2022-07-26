import 'package:flutter/foundation.dart';
import 'package:biovillage/models/payment-type.dart';

class PaymentDeliveryInfo {
  String paymentDesc;
  String deliveryDesc;
  List<PaymentType> disabledPaymentMethods;
  String paymentCurrency;
  String paymentGatewayShopId;
  String paymentGatewayMobileKey;
  String paymentGatewayReturnUrl;
  String paymentGatewayPurchaseName;
  String paymentGatewayPurchaseDesc;

  PaymentDeliveryInfo({
    @required this.paymentDesc,
    @required this.deliveryDesc,
    @required this.disabledPaymentMethods,
    this.paymentCurrency,
    this.paymentGatewayShopId,
    this.paymentGatewayMobileKey,
    this.paymentGatewayReturnUrl,
    this.paymentGatewayPurchaseName,
    this.paymentGatewayPurchaseDesc,
  });

  factory PaymentDeliveryInfo.fromJson(Map<String, dynamic> json) {
    List<PaymentType> disabledPaymentMethods = [];
    if (json["paymentAPayEnabled"] != 1) disabledPaymentMethods.add(PaymentType.apay);
    if (json["paymentGPayEnabled"] != 1) disabledPaymentMethods.add(PaymentType.gpay);
    if (json["paymentCardEnabled"] != 1) disabledPaymentMethods.add(PaymentType.card);
    if (json["paymentCCardEnabled"] != 1) disabledPaymentMethods.add(PaymentType.ccard);
    if (json["paymentCashEnabled"] != 1) disabledPaymentMethods.add(PaymentType.cash);
    return PaymentDeliveryInfo(
      paymentDesc: json["paymentDesc"],
      deliveryDesc: json["deliveryDesc"],
      disabledPaymentMethods: disabledPaymentMethods,
      paymentCurrency: json["paymentCurrency"],
      paymentGatewayShopId: json["paymentGatewayShopId"],
      paymentGatewayMobileKey: json["paymentGatewayMobileKey"],
      paymentGatewayReturnUrl: json["paymentGatewayReturnUrl"],
      paymentGatewayPurchaseName: json["paymentGatewayPurchaseName"],
      paymentGatewayPurchaseDesc: json["paymentGatewayPurchaseDesc"],
    );
  }
}

PaymentDeliveryInfo parseJsonPaymentDeliveryInfo(json) {
  return PaymentDeliveryInfo.fromJson(json);
}
