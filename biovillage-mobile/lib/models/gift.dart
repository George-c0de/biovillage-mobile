import 'package:flutter/foundation.dart';

class Gift {
  int id;
  int order;
  String name;
  int price;
  String imgUrl;

  Gift({
    @required this.id,
    this.order = 0,
    @required this.name,
    @required this.price,
    @required this.imgUrl,
  });

  factory Gift.fromJson(Map<String, dynamic> json) => Gift(
        id: json["id"],
        order: json["order"],
        name: json["name"],
        price: json["price"],
        imgUrl: json["imageSrc"],
      );
}

List<Gift> parseAndSortJsonGifts(json) {
  List<Gift> gifts = json.map((c) => Gift.fromJson(c)).toList().cast<Gift>();
  gifts.sort((a, b) => a.order.compareTo(b.order));
  return gifts;
}
