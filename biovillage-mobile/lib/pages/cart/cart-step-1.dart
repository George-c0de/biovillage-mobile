import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:biovillage/redux/state/app-state.dart';
import 'package:biovillage/redux/actions/cart.dart';
import 'package:biovillage/models/cart-product.dart';
import 'package:biovillage/models/address.dart';
import 'package:biovillage/pages/account/add-address.dart';
import 'package:biovillage/helpers/data-formating.dart';
import 'package:biovillage/helpers/colors.dart';
import 'package:biovillage/helpers/cart.dart';
import 'package:biovillage/helpers/system-elements.dart';
import 'package:biovillage/theme/bv-icons.dart';
import 'package:biovillage/theme/colors.dart';
import 'package:biovillage/widgets/appbar.dart';
import 'package:biovillage/widgets/button.dart';
import 'package:biovillage/widgets/drawer/drawer.dart';
import 'package:biovillage/widgets/circles-pattern.dart';
import 'package:biovillage/widgets/cart/cart-items-list.dart';

class CartPageStep1 extends StatefulWidget {
  CartPageStep1({Key key}) : super(key: key);
  @override
  _CartPageStep1State createState() => _CartPageStep1State();
}

class _CartPageStep1State extends State<CartPageStep1> {
  void _toStep2(BuildContext context) {
    var store = StoreProvider.of<AppState>(context);
    if (!store.state.account.userAuth) {
      // Если юзер не авторизован, то сначала авторизуемся:
      Scaffold.of(context).openDrawer();
    } else {
      Address currentAddress = store.state.account.currentAddress;
      if (currentAddress == null) {
        // Если адрес не задан, то задаем:
        Navigator.pushNamed(context, '/account/select-address');
      } else if (currentAddress.isTempAddress) {
        // Если адрес задан как временный, то уточняем его и сохраняем:
        Navigator.pushNamed(
          context,
          '/account/add-address',
          arguments: AddAddressPageArguments(
            coords: currentAddress.coords,
            address: currentAddress.address,
            deliveryPrice: currentAddress.deliveryPrice,
            deliveryFreeSum: currentAddress.deliveryFreeSum,
            city: currentAddress.city,
            onAddressAdded: () => Navigator.pushNamed(context, '/cart-step-2'),
          ),
        );
      } else {
        // Если выбран постоянный адрес, то идем дальше:
        Navigator.pushNamed(context, '/cart-step-2');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        setNavBarTheme(context, NavBarTheme.white, delay: Duration(milliseconds: 300));
        return true;
      },
      child: StoreConnector<AppState, dynamic>(
        converter: (store) => store,
        builder: (ctx, store) {
          List<CartProduct> cartProducts = store.state.cart.products;
          bool cartEmpty = cartProducts.isEmpty;
          int deliverySum = calcDeliverySum(store.state);
          int deliveryFreeSum = store.state.account.currentAddress.deliveryFreeSum ?? 0;
          int sumForFreeDelivery = calcSumForFreeDelivery(store.state);
          return Scaffold(
            backgroundColor: ColorsTheme.primary,
            appBar: CustomAppBar(
              title: cartEmpty
                  ? FlutterI18n.translate(context, 'common.cart.title_empty_cart')
                  : FlutterI18n.translate(context, 'common.cart.title_step_1'),
              appendWidget: cartEmpty
                  ? null
                  : MaterialButton(
                      onPressed: () {
                        store.dispatch(clearCart());
                        setNavBarTheme(context, NavBarTheme.primary);
                      },
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                      height: 20,
                      minWidth: 20,
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      splashColor: ColorsTheme.accent.withOpacity(.4),
                      highlightColor: ColorsTheme.accent.withOpacity(.2),
                      child: Text(
                        FlutterI18n.translate(context, 'common.cart.clear').toLowerCase(),
                        style: TextStyle(
                          color: ColorsTheme.accent,
                          fontSize: 10.w,
                          letterSpacing: .2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
              onTapBackBtn: () {
                setNavBarTheme(context, NavBarTheme.white, delay: Duration(milliseconds: 300));
                Navigator.pop(context);
              },
            ),
            drawer: CustomDrawer(onSuccessAuth: () => Navigator.pop(context)),
            drawerEdgeDragWidth: 0,
            body: Builder(
              builder: (context) => SafeArea(
                child: cartEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              BvIcons.cart,
                              size: 100,
                              color: darken(ColorsTheme.bg, .04).withOpacity(.33),
                            ),
                            SizedBox(height: 4),
                            Text(
                              FlutterI18n.translate(context, 'common.cart.cart_empty_page.title'),
                              style: TextStyle(
                                color: ColorsTheme.bg,
                                fontSize: 14.w,
                                height: 1.7,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 4),
                            Wrap(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setNavBarTheme(context, NavBarTheme.white, delay: Duration(milliseconds: 300));
                                    Navigator.popUntil(context, ModalRoute.withName('/home'));
                                  },
                                  child: Text(
                                    FlutterI18n.translate(context, 'common.cart.cart_empty_page.to_shop_1'),
                                    style: TextStyle(
                                      color: ColorsTheme.accent,
                                      fontSize: 11.w,
                                      height: 1.45,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Text(
                                  ' ' + FlutterI18n.translate(context, 'common.cart.cart_empty_page.to_shop_2'),
                                  style: TextStyle(
                                    color: ColorsTheme.bg,
                                    fontSize: 11.w,
                                    height: 1.45,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 60),
                          ],
                        ),
                      )
                    : Stack(
                        fit: StackFit.expand,
                        children: [
                          SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Container(
                                  color: ColorsTheme.bg,
                                  child: Column(
                                    children: [
                                      SizedBox(height: 12),
                                      Container(
                                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                                        margin: EdgeInsets.symmetric(horizontal: 16),
                                        decoration: BoxDecoration(
                                          color: ColorsTheme.info,
                                          borderRadius: BorderRadius.circular(14),
                                          boxShadow: <BoxShadow>[
                                            BoxShadow(
                                              color: Color.fromRGBO(121, 142, 72, 0.25),
                                              offset: Offset(0, 1),
                                              blurRadius: 1,
                                            ),
                                            BoxShadow(
                                              color: Color.fromRGBO(121, 142, 72, 0.25),
                                              offset: Offset(0, 10),
                                              blurRadius: 20,
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(BvIcons.gift_2, color: ColorsTheme.bg),
                                            SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    FlutterI18n.translate(context, 'common.bonusesBanner.title'),
                                                    style: TextStyle(
                                                      color: ColorsTheme.bg,
                                                      fontSize: 13.w,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                  SizedBox(height: 4),
                                                  Text(
                                                    FlutterI18n.translate(context, 'common.bonusesBanner.text'),
                                                    style: TextStyle(fontSize: 11.w, color: ColorsTheme.bg),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 16),
                                      CartItemsList(),
                                      SizedBox(height: 36),
                                      Container(
                                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                                        margin: EdgeInsets.symmetric(horizontal: 16),
                                        decoration: BoxDecoration(
                                          color: ColorsTheme.bg,
                                          borderRadius: BorderRadius.circular(14),
                                          boxShadow: <BoxShadow>[
                                            BoxShadow(
                                              color: Color.fromRGBO(123, 49, 110, 0.15),
                                              offset: Offset(0, 1),
                                              blurRadius: 2,
                                            ),
                                            BoxShadow(
                                              color: Color.fromRGBO(133, 41, 115, 0.1),
                                              offset: Offset(0, 2),
                                              blurRadius: 20,
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          children: [
                                            SvgPicture.asset('assets/img/icons/eco.svg', height: 24),
                                            SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    FlutterI18n.translate(context, 'common.cart.delivery_eco_packages'),
                                                    style: TextStyle(fontSize: 12.w, fontWeight: FontWeight.w600),
                                                  ),
                                                  SizedBox(height: 4),
                                                  Text(
                                                    FlutterI18n.translate(
                                                        context, 'common.cart.delivery_eco_packages_desc'),
                                                    style: TextStyle(fontSize: 11.w, color: ColorsTheme.textTertiary),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 24),
                                    ],
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        darken(ColorsTheme.bg, .03),
                                        ColorsTheme.bg,
                                      ],
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.fromLTRB(16, 20, 16, 16),
                                        decoration: BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(color: darken(ColorsTheme.bg, .05), width: 4),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                FlutterI18n.translate(context, 'common.cart.total') + ':',
                                                style: TextStyle(fontSize: 13.w, fontWeight: FontWeight.w700),
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                            Text(
                                              numToString(store.state.cart.cost) +
                                                  ' ' +
                                                  FlutterI18n.translate(context, 'common.cart.currency_symbol'),
                                              style: TextStyle(
                                                fontSize: 14.w,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: .2,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 14),
                                      Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () => Navigator.pushNamed(context, '/account/select-address'),
                                          splashColor: ColorsTheme.primary.withOpacity(.4),
                                          highlightColor: ColorsTheme.primary.withOpacity(.2),
                                          child: Container(
                                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                            child: Row(
                                              children: [
                                                Icon(BvIcons.map_marker_2, color: ColorsTheme.primary, size: 24),
                                                SizedBox(width: 12),
                                                Expanded(
                                                  child: Text(
                                                    store.state.account.currentAddress != null
                                                        ? addressToString(store.state.account.currentAddress)
                                                        : FlutterI18n.translate(context, 'common.choose_address'),
                                                    overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(fontSize: 13.w),
                                                  ),
                                                ),
                                                SizedBox(width: 10),
                                                Icon(
                                                  BvIcons.chevron_right,
                                                  color: ColorsTheme.primary,
                                                  size: 24,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                        child: Row(
                                          children: [
                                            Icon(BvIcons.delivery_car, color: ColorsTheme.primary, size: 24),
                                            SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                FlutterI18n.translate(context, 'common.cart.delivery_cost') + ':',
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(fontSize: 13.w),
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                            Text(
                                              numToString(deliverySum) +
                                                  ' ' +
                                                  FlutterI18n.translate(context, 'common.cart.currency_symbol'),
                                              style: TextStyle(
                                                fontSize: 14.w,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: .2,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(color: darken(ColorsTheme.bg, .05), height: 4),
                                      SizedBox(height: 12),
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 16),
                                        alignment: Alignment.centerLeft,
                                        child: Text.rich(
                                          TextSpan(children: [
                                            TextSpan(
                                              text: FlutterI18n.translate(context, 'common.cart.free_delivery_from') +
                                                  ' ' +
                                                  numToString(deliveryFreeSum) +
                                                  FlutterI18n.translate(context, 'common.cart.currency_symbol'),
                                            ),
                                            if (sumForFreeDelivery != null && sumForFreeDelivery > 0)
                                              TextSpan(
                                                text: ' (' +
                                                    FlutterI18n.translate(context, 'common.cart.remained')
                                                        .toLowerCase() +
                                                    ' ' +
                                                    numToString(sumForFreeDelivery) +
                                                    FlutterI18n.translate(context, 'common.cart.currency_symbol') +
                                                    ')',
                                                style: TextStyle(fontWeight: FontWeight.w400),
                                              ),
                                          ]),
                                          style: TextStyle(fontSize: 12.w, fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                      SizedBox(height: 14),
                                    ],
                                  ),
                                ),
                                CirclesPattern(),
                                SizedBox(height: 120),
                              ],
                            ),
                          ),
                          Positioned(
                            bottom: 24,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Button(
                                onTap: () => _toStep2(context),
                                height: 40,
                                label: FlutterI18n.translate(context, 'common.to_next').toUpperCase() +
                                    '   ' +
                                    numToString(store.state.cart.cost + deliverySum) +
                                    ' ' +
                                    FlutterI18n.translate(context, 'common.cart.currency_symbol'),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}
