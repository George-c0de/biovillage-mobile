import 'package:flutter/foundation.dart';
import 'package:biovillage/models/payment-type.dart';

class Order {
  int deliveryIntervalId;
  int addressId;
  PaymentType paymentPrimaryMethod;
  List<OrderProduct> products;
  int productsSum;
  int deliverySum;
  int total;
  List<OrderProduct> gifts;
  int giftBonuses;
  String clientsComment;
  String promoCode;
  String actionIfNotDelivery;
  String paymentToken;

  Order({
    @required this.deliveryIntervalId,
    @required this.addressId,
    @required this.paymentPrimaryMethod,
    @required this.products,
    @required this.productsSum,
    @required this.deliverySum,
    @required this.total,
    @required this.gifts,
    @required this.giftBonuses,
    @required this.clientsComment,
    @required this.promoCode,
    @required this.actionIfNotDelivery,
    this.paymentToken,
  });

  Map<String, String> toMap() {
    Map<String, String> map = {
      "deliveryIntervalId": deliveryIntervalId.toString(),
      "addressId": addressId.toString(),
      "paymentPrimaryMethod":
          paymentPrimaryMethod.toString().substring(paymentPrimaryMethod.toString().indexOf('.') + 1),
      "productsSum": productsSum.toString(),
      "deliverySum": deliverySum.toString(),
      "total": total.toString(),
      "giftBonuses": giftBonuses.toString(),
      "clientsComment": clientsComment,
      "promoCode": promoCode,
      "actionIfNotDelivery": actionIfNotDelivery,
    };
    // Добавляем токен, если есть:
    if (paymentToken != null && paymentToken.isNotEmpty) map["paymentToken"] = paymentToken;
    // Добавляем товары:
    for (int p = 0; p < products.length; p++) {
      map.addAll(products[p].toMap('products', p));
    }
    // Добавляем подарки:
    for (int g = 0; g < gifts.length; g++) {
      map.addAll(gifts[g].toMap('gifts', g));
    }
    return map;
  }
}

class OrderProduct {
  int id;
  int qty;
  int price;
  int total;
  OrderProduct({
    @required this.id,
    @required this.qty,
    @required this.price,
    @required this.total,
  });

  Map<String, String> toMap(String propName, int index) => {
        '$propName[$index][id]': id.toString(),
        '$propName[$index][qty]': qty.toString(),
        '$propName[$index][price]': price.toString(),
        '$propName[$index][total]': total.toString(),
      };
}
