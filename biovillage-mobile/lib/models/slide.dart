import 'package:flutter/foundation.dart';

class Slide {
  int id;
  String title;
  String subtitle;
  String bgColor;
  String imgUrl;

  Slide({
    @required this.id,
    @required this.title,
    @required this.subtitle,
    @required this.bgColor,
    @required this.imgUrl,
  });

  factory Slide.fromJson(Map<String, dynamic> json) => Slide(
        id: json["id"],
        title: json["name"],
        subtitle: json["description"],
        bgColor: json["bgColor"],
        imgUrl: json["imageSrc"],
      );
}

List<Slide> parseJsonSlides(json) {
  return json.map((c) => Slide.fromJson(c)).toList().cast<Slide>();
}
