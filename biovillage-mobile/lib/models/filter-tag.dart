import 'package:flutter/foundation.dart';

class FilterTag {
  int id;
  String name;
  bool active;

  FilterTag({
    @required this.id,
    @required this.name,
    this.active = false,
  });

  factory FilterTag.fromJson(Map<String, dynamic> json) => FilterTag(
        id: json["id"],
        name: json["name"],
        active: false,
      );
}

List<FilterTag> parseJsonFilterTags(json) {
  return json.map((c) => FilterTag.fromJson(c)).toList().cast<FilterTag>();
}
