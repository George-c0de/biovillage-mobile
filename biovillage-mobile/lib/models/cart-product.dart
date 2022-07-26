import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:biovillage/models/product.dart';

class CartProduct extends Product {
  int amount;
  int cost;

  CartProduct({
    @required id,
    @required categoryId,
    @required name,
    @required imgUrl,
    @required price,
    @required unitStep,
    @required unitFactor,
    @required unitShortName,
    @required unitShortDerName,
    @required this.amount,
    @required this.cost,
  }) : super(
          id: id,
          categoryId: categoryId,
          name: name,
          imgUrl: imgUrl,
          price: price,
          unitStep: unitStep,
          unitFactor: unitFactor,
          unitShortName: unitShortName,
          unitShortDerName: unitShortDerName,
        );

  factory CartProduct.fromProduct(Product product) => CartProduct(
        id: product.id,
        categoryId: product.categoryId,
        name: product.name,
        imgUrl: product.imgUrl,
        price: product.price,
        unitStep: product.unitStep,
        unitFactor: product.unitFactor,
        unitShortName: product.unitShortName,
        unitShortDerName: product.unitShortDerName,
        amount: 1,
        cost: product.price,
      );

  factory CartProduct.fromJson(Map<String, dynamic> json) => CartProduct(
        id: json["id"],
        categoryId: json["categoryId"],
        name: json["name"],
        imgUrl: json["imgUrl"],
        price: json["price"],
        unitStep: json["unitStep"],
        unitFactor: json["unitFactor"],
        unitShortName: json["unitShortName"],
        unitShortDerName: json["unitShortDerName"],
        amount: json["amount"],
        cost: json["cost"],
      );

  String toJson() => jsonEncode({
        "id": id,
        "categoryId": categoryId,
        "name": name,
        "imgUrl": imgUrl,
        "price": price,
        "unitStep": unitStep,
        "unitFactor": unitFactor,
        "unitShortName": unitShortName,
        "unitShortDerName": unitShortDerName,
        "amount": amount,
        "cost": cost,
      });
}

String cartProductToJson(CartProduct cartProduct) {
  return cartProduct.toJson();
}
