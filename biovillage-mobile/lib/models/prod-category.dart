import 'package:flutter/foundation.dart';

class ProdCategory {
  int id;
  int order;
  String name;
  String imageSrc;
  String bgColor;
  List<int> tags;

  ProdCategory({
    @required this.id,
    this.order = 0,
    @required this.name,
    @required this.imageSrc,
    @required this.bgColor,
    this.tags = const [],
  });

  factory ProdCategory.fromJson(Map<String, dynamic> json) => ProdCategory(
        id: json["id"],
        order: json["order"],
        name: json["name"],
        imageSrc: json["imageSrc"],
        bgColor: json["bgColor"],
        tags: json["tags"] == null ? [] : json["tags"].map((t) => t[0]).cast<int>().toList(),
      );
}

List<ProdCategory> parseJsonCategories(json) {
  return json.map((c) => ProdCategory.fromJson(c)).toList().cast<ProdCategory>();
}

List<ProdCategory> parseAndSortJsonCategories(json) {
  List<ProdCategory> categories = parseJsonCategories(json);
  categories.sort((a, b) => a.order.compareTo(b.order));
  return categories;
}
