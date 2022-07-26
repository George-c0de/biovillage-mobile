import 'package:flutter/foundation.dart';
import 'package:biovillage/models/delivery-interval.dart';
import 'package:biovillage/helpers/delivery-intervals.dart';

class HistoryOrder {
  int number;
  String orderDate;
  String orderTime;
  String deliveryDate;
  String deliveryTime;
  String completionDate;
  String completionTime;
  String orderStatus;
  String paymentStatus;
  String paymentMethod;
  String operatorComment;
  int totalCost;
  List<HistoryOrderProduct> products;

  HistoryOrder({
    @required this.number,
    @required this.orderDate,
    @required this.orderTime,
    @required this.deliveryDate,
    @required this.deliveryTime,
    @required this.completionDate,
    @required this.completionTime,
    @required this.orderStatus,
    @required this.paymentStatus,
    @required this.paymentMethod,
    @required this.operatorComment,
    @required this.totalCost,
    @required this.products,
  });

  factory HistoryOrder.fromJson(Map<String, dynamic> json) => HistoryOrder(
        number: json["id"],
        orderDate: _strDateFromStr(json["createdAt"]),
        orderTime: _strTimeFromStr(json["createdAt"]),
        deliveryDate: json["deliveryDate"],
        deliveryTime: json["deliveryTime"],
        completionDate: _strDateFromStr(json["packedAt"]),
        completionTime: _strTimeFromStr(json["packedAt"]),
        orderStatus: json["status"],
        paymentStatus: json["paymentData"][0]["status"],
        paymentMethod: json["paymentData"][0]["method"],
        operatorComment: json["commentForClient"],
        totalCost: json["total"],
        products: json["itemsData"].map((c) => HistoryOrderProduct.fromJson(c)).toList().cast<HistoryOrderProduct>(),
      );
}

class HistoryOrderProduct {
  int amount;
  String title;
  int cost;
  int unitStep;
  String unitShortName;

  HistoryOrderProduct({
    @required this.amount,
    @required this.title,
    @required this.cost,
    @required this.unitStep,
    @required this.unitShortName,
  });

  factory HistoryOrderProduct.fromJson(Map<String, dynamic> json) => HistoryOrderProduct(
        amount: json["qty"],
        title: json["name"],
        cost: json["total"],
        unitStep: json["unitStep"],
        unitShortName: json["unitShortName"],
      );
}

// Вспомогательные методы:

String _strDateFromStr(String dateTime) {
  if (dateTime == null || dateTime == '') return null;
  return dateTime.split(' ')[0];
}

String _strTimeFromStr(String dateTime) {
  if (dateTime == null || dateTime == '') return null;
  return dateTime.split(' ')[1];
}

class ParseJsonHistoryOrdersParams {
  ParseJsonHistoryOrdersParams({@required this.json, @required this.di});
  var json;
  Map<int, List<DeliveryInterval>> di;
}

List<HistoryOrder> parseJsonHistoryOrders(ParseJsonHistoryOrdersParams params) {
  return params.json
      .map((c) {
        // Определяем время доставки:
        DeliveryInterval di = findDeliveryIntervalById(c['deliveryIntervalId'], params.di);
        c['deliveryTime'] = di != null ? di.intervalText : '';
        return HistoryOrder.fromJson(c);
      })
      .toList()
      .cast<HistoryOrder>();
}

HistoryOrder parseJsonHistoryOrder(json) {
  return HistoryOrder.fromJson(json);
}
