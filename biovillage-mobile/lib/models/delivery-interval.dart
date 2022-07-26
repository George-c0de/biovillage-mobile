import 'package:flutter/foundation.dart';

class DeliveryInterval {
  int id;
  int dayOfWeek;
  String intervalText;
  DateTime date;
  int startHour;
  bool active;

  DeliveryInterval({
    @required this.id,
    @required this.dayOfWeek,
    @required this.intervalText,
    @required this.startHour,
    this.date,
    this.active = true,
  });

  factory DeliveryInterval.fromJson(Map<String, dynamic> json) => DeliveryInterval(
        id: json["id"],
        dayOfWeek: json["dayOfWeek"],
        startHour: json["startHour"],
        intervalText: json["startHour"].toString().padLeft(2, '0') +
            ':' +
            json["startMinute"].toString().padLeft(2, '0') +
            '-' +
            json["endHour"].toString().padLeft(2, '0') +
            ':' +
            json["endMinute"].toString().padLeft(2, '0'),
        active: json["active"],
      );
}

Map<int, List<DeliveryInterval>> parseJsonDeliveryIntervals(json) {
  List<DeliveryInterval> allIntervals = json.map((c) => DeliveryInterval.fromJson(c)).toList().cast<DeliveryInterval>();
  Map<int, List<DeliveryInterval>> deliveryIntervals = {};
  allIntervals.forEach((DeliveryInterval di) {
    int day = di.dayOfWeek;
    if (deliveryIntervals[day] == null) deliveryIntervals[day] = [];
    deliveryIntervals[day].add(di);
  });
  return deliveryIntervals;
}
