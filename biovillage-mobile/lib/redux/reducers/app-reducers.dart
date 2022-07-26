import 'package:biovillage/redux/state/app-state.dart';
import 'package:biovillage/redux/reducers/general.dart';
import 'package:biovillage/redux/reducers/catalog.dart';
import 'package:biovillage/redux/reducers/cart.dart';
import 'package:biovillage/redux/reducers/account.dart';

AppState appStateReducer(AppState state, action) {
  return AppState(
    general: generalReducer(state.general, action),
    catalog: catalogReducer(state.catalog, action),
    cart: cartReducer(state.cart, action),
    account: accountReducer(state.account, action),
  );
}
