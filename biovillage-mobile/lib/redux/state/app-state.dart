import 'package:flutter/foundation.dart';
import 'package:biovillage/redux/state/general.dart';
import 'package:biovillage/redux/state/catalog.dart';
import 'package:biovillage/redux/state/cart.dart';
import 'package:biovillage/redux/state/account.dart';

@immutable
class AppState {
  final General general;
  final Catalog catalog;
  final Cart cart;
  final Account account;

  AppState({
    @required this.general,
    @required this.catalog,
    @required this.cart,
    @required this.account,
  });

  AppState.initialState()
      : general = General(),
        catalog = Catalog(products: {}),
        cart = Cart(products: []),
        account = Account();
}
