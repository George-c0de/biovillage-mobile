import 'package:redux/redux.dart';
import 'package:biovillage/redux/state/cart.dart';
import 'package:biovillage/redux/actions/cart.dart';
import 'package:biovillage/helpers/cart.dart';

final cartReducer = TypedReducer<Cart, dynamic>(_cartReducer);

Cart _cartReducer(Cart state, action) {
  if (action is SetCart) state.products = action.products;
  if (action is AddProduct) state.products.add(action.product);
  if (action is RemoveProduct) state.products.remove(action.product);
  if (action is UpdateProduct) {
    int index = state.products.indexOf(findCartProduct(state.products, action.product.id));
    if (index > -1) state.products[index] = action.product;
  }
  if (action is SetCartTotal) {
    state.amount = action.amount;
    state.cost = action.cost;
  }
  if (action is ClearCart) state.products = [];
  if (action is SetDeliveryInterval) state.deliveryInterval = action.deliveryInterval;
  return state;
}
