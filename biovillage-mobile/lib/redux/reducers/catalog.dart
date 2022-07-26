import 'package:biovillage/models/filter-tag.dart';
import 'package:redux/redux.dart';
import 'package:biovillage/redux/state/catalog.dart';
import 'package:biovillage/redux/actions/catalog.dart';

final catalogReducer = TypedReducer<Catalog, dynamic>(_catalogReducer);

Catalog _catalogReducer(Catalog state, action) {
  if (action is SetFilterTags) state.tags = action.tags;
  if (action is SetFilterTagActive) {
    FilterTag tag = state.tags.firstWhere((tag) => tag.id == action.id, orElse: () => null);
    if (tag != null) tag.active = action.active;
  }
  if (action is SetCategories) state.categories = action.categories;
  if (action is SetProducts) state.products[action.categoryId] = action.products;
  if (action is SetGifts) state.gifts = action.gifts;
  return state;
}
