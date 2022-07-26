import 'package:flutter/foundation.dart';

class Product {
  int id;
  int order;
  int categoryId;
  String name;
  String imgUrl;
  int price;
  int unitStep;
  int unitFactor;
  String unitShortName;
  String unitShortDerName;
  List<String> certs;
  String description;
  String composition;
  String shelfLife;
  String nutrition;
  List<int> tags;

  Product({
    @required this.id,
    this.order = 0,
    @required this.categoryId,
    @required this.name,
    @required this.imgUrl,
    @required this.price,
    @required this.unitStep,
    @required this.unitFactor,
    @required this.unitShortName,
    @required this.unitShortDerName,
    this.certs,
    this.description,
    this.composition,
    this.shelfLife,
    this.nutrition,
    this.tags = const [],
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json["id"],
        order: json["order"],
        categoryId: json["groupId"],
        name: json["name"],
        imgUrl: json["imageSrc"],
        price: json["price"],
        unitStep: json["unitStep"],
        unitFactor: json["unitFactor"],
        unitShortName: json["unitShortName"],
        unitShortDerName: json["unitShortDerName"],
        certs: json["certs"].toList().cast<String>(),
        description: json["description"],
        composition: json["composition"],
        shelfLife: json["shelfLife"],
        nutrition: json["nutrition"],
        tags: json["tags"] == null ? [] : json["tags"].map((t) => t[0]).cast<int>().toList(),
      );
}

List<Product> parseJsonProducts(json) {
  return json.map((c) => Product.fromJson(c)).toList().cast<Product>();
}

List<Product> parseAndSortJsonProducts(json) {
  List<Product> products = parseJsonProducts(json);
  products.sort((a, b) => a.order.compareTo(b.order));
  return products;
}
