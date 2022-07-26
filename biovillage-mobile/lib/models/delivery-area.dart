import 'package:flutter/foundation.dart';
import 'package:biovillage/widgets/map.dart';

class DeliveryArea {
  bool isAvailable;
  String color;
  String text;
  int price;
  int deliveryFreeSum;
  List<Point> points;

  DeliveryArea({
    this.isAvailable = true,
    @required this.color,
    @required this.text,
    @required this.price,
    @required this.deliveryFreeSum,
    @required this.points,
  });

  factory DeliveryArea.fromJson(Map<String, dynamic> json) => DeliveryArea(
        isAvailable: json["active"],
        color: json["color"],
        text: json["name"],
        price: json["price"],
        deliveryFreeSum: json["deliveryFreeSum"],
        points: json["poly"].map((c) => Point(latitude: c[0], longitude: c[1])).toList().cast<Point>(),
      );
}

List<DeliveryArea> parseJsonDeliveryAreas(json) {
  return json.map((c) => DeliveryArea.fromJson(c)).toList().cast<DeliveryArea>();
}
