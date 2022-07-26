import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:biovillage/widgets/map.dart';

class Address {
  int id;
  String name;
  Point coords;
  String address;
  String city;
  String appt;
  String entrance;
  String doorphone;
  String floor;
  String comment;
  bool isTempAddress;
  int deliveryPrice;
  int deliveryFreeSum;

  Address({
    this.id,
    this.name,
    @required this.coords,
    @required this.address,
    this.city,
    this.appt,
    this.entrance,
    this.doorphone,
    this.floor,
    this.comment,
    this.isTempAddress = false,
    this.deliveryPrice,
    this.deliveryFreeSum,
  });

  factory Address.fromJson(Map<String, dynamic> json) => Address(
        id: json["id"],
        name: json["name"],
        coords: Point(latitude: json["lat"], longitude: json["lon"]),
        address: json["street"],
        city: json["city"],
        appt: json["appt"],
        entrance: json["entrance"],
        doorphone: json["doorphone"],
        floor: json["floor"],
        comment: json["comment"],
        deliveryPrice: json["daPrice"],
        deliveryFreeSum: json["daFreeSum"],
      );

  String toJson() => jsonEncode({
        "id": id,
        "name": name,
        "lat": coords.latitude,
        "lon": coords.longitude,
        "street": address,
        "city": city,
        "appt": appt,
        "entrance": entrance,
        "doorphone": doorphone,
        "floor": floor,
        "comment": comment,
        "daPrice": deliveryPrice,
        "daFreeSum": deliveryFreeSum,
      });
}

String addressToJson(Address address) {
  return address.toJson();
}

Address addressFromJson(json) {
  return Address.fromJson(jsonDecode(json));
}
