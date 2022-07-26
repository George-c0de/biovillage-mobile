import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:biovillage/redux/state/app-state.dart';
import 'package:biovillage/pages/account/select-address.dart';
import 'package:biovillage/helpers/data-formating.dart';
import 'package:biovillage/helpers/cart.dart';
import 'package:biovillage/theme/bv-icons.dart';
import 'package:biovillage/theme/colors.dart';
import 'package:biovillage/widgets/button.dart';

class FloatingCartButton extends StatefulWidget {
  FloatingCartButton({
    Key key,
    this.margin = const EdgeInsets.only(bottom: 40, left: 16, right: 16),
  }) : super(key: key);

  final EdgeInsets margin;

  @override
  _FloatingCartButtonState createState() => _FloatingCartButtonState();
}

class _FloatingCartButtonState extends State<FloatingCartButton> with SingleTickerProviderStateMixin {
  AnimationController _animController;

  void _toCart() {
    var store = StoreProvider.of<AppState>(context);
    // Если адрес не выбран, то для продолжения нужно ввести адрес:
    if (store.state.account.currentAddress == null) {
      Navigator.pushNamed(
        context,
        '/account/select-address',
        arguments: SelectAddressPageArguments(
          onAddressSelected: () => Navigator.pushNamed(context, '/cart-step-1'),
        ),
      );
    } else {
      Navigator.pushNamed(context, '/cart-step-1');
    }
  }

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(duration: Duration.zero, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      var store = StoreProvider.of<AppState>(context);
      if (store.state.cart.amount > 0) _animController.animateTo(1, duration: Duration.zero);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _animController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool keyboardIsOpened = MediaQuery.of(context).viewInsets.bottom != 0.0;
    if (keyboardIsOpened) return Container();
    return StoreConnector<AppState, dynamic>(
      converter: (store) => store,
      builder: (context, store) {
        int cartAmount = store.state.cart.amount;
        int cartCost = store.state.cart.cost;
        int deliverySum = calcDeliverySum(store.state);
        if (cartAmount < 1)
          _animController.reverse();
        else
          _animController.forward();
        return Hero(
          tag: 'floating-cart-button',
          child: Container(
            margin: widget.margin,
            child: ScaleTransition(
              alignment: Alignment.bottomCenter,
              scale: CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(7),
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromRGBO(123, 49, 110, 0.15),
                      offset: Offset(0, 1),
                      blurRadius: 1,
                    ),
                    BoxShadow(
                      color: Color.fromRGBO(123, 49, 110, 0.25),
                      offset: Offset(0, 10),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: Button(
                  disableShadow: true,
                  height: 40,
                  onTap: () => _toCart(),
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Icon(BvIcons.cart_outlined, size: 22, color: ColorsTheme.bg),
                            SizedBox(width: 6),
                            Text(
                              '($cartAmount ' + FlutterI18n.translate(context, 'common.cart.amount_label') + ')',
                              style: TextStyle(fontSize: 11.w, color: ColorsTheme.bg),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        numToString(cartCost) + ' ' + FlutterI18n.translate(context, 'common.cart.currency_symbol'),
                        style: TextStyle(fontSize: 12.w, fontWeight: FontWeight.w700, color: ColorsTheme.bg),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(BvIcons.delivery_car, size: 24, color: ColorsTheme.bg),
                            SizedBox(width: 6),
                            Text(
                              deliverySum == null
                                  ? FlutterI18n.translate(context, 'common.calculate').toLowerCase()
                                  : numToString(deliverySum) +
                                      ' ' +
                                      FlutterI18n.translate(context, 'common.cart.currency_symbol'),
                              style: TextStyle(fontSize: 11.w, color: ColorsTheme.bg),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
