import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:biovillage/models/filter-tag.dart';
import 'package:biovillage/models/prod-category.dart';
import 'package:biovillage/models/product.dart';

/// Имя настроек SharedPreferences для хранения активных тегов
final String activeTagsPrefsName = 'activeFilterTags';

/// Устанавка списка id активных тегов
Future<bool> setPrefsActiveTags(List<FilterTag> tags) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<int> activeTagsIds = [];
  tags.forEach((tag) {
    if (tag.active) activeTagsIds.add(tag.id);
  });
  return prefs.setString(activeTagsPrefsName, jsonEncode(activeTagsIds));
}

/// Получение списка id активных тегов
Future<List<int>> getPrefsActiveTags() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String activeTagsIdsJson = prefs.getString(activeTagsPrefsName);
  if (activeTagsIdsJson == null) return [];
  return jsonDecode(activeTagsIdsJson).cast<int>();
}

/// Фильтрация категорий по тегам:
filterCategories(List<ProdCategory> categories, List<FilterTag> tags) {
  List<int> activeIds = tags.where((t) => t.active).toList().map((t) => t.id).toList();
  if (activeIds.isEmpty) return categories;
  List<ProdCategory> result = categories.where((c) {
    // Промотовары всегда возвращаем, у этой категории нет тегов:
    if (c.id == -1) return true;
    if (c.tags.isEmpty) return false;
    for (int id in activeIds) if (!c.tags.contains(id)) return false;
    return true;
  }).toList();
  return result;
}

/// Фильтрация категорий по тегам:
filterProducts(List<Product> products, List<FilterTag> tags) {
  if (products == null) return null;
  List<int> activeIds = tags.where((t) => t.active).toList().map((t) => t.id).toList();
  if (activeIds.isEmpty) return products;
  List<Product> result = products.where((p) {
    if (p.tags.isEmpty) return false;
    for (int id in activeIds) if (!p.tags.contains(id)) return false;
    return true;
  }).toList();
  return result;
}
