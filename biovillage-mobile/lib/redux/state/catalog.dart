import 'package:biovillage/models/filter-tag.dart';
import 'package:biovillage/models/prod-category.dart';
import 'package:biovillage/models/product.dart';
import 'package:biovillage/models/gift.dart';

class Catalog {
  List<FilterTag> tags;
  List<ProdCategory> categories;
  Map<int, List<Product>> products;
  List<Gift> gifts;

  Catalog({
    this.tags,
    this.categories,
    this.products,
    this.gifts,
  });
}
