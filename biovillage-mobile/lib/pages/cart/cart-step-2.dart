import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:biovillage/redux/state/app-state.dart';
import 'package:biovillage/redux/actions/cart.dart';
import 'package:biovillage/models/delivery-interval.dart';
import 'package:biovillage/models/address.dart';
import 'package:biovillage/helpers/colors.dart';
import 'package:biovillage/helpers/cart.dart';
import 'package:biovillage/helpers/data-formating.dart';
import 'package:biovillage/theme/colors.dart';
import 'package:biovillage/theme/bv-icons.dart';
import 'package:biovillage/widgets/appbar.dart';
import 'package:biovillage/widgets/button.dart';
import 'package:biovillage/widgets/notifications.dart';

class CartPageStep2 extends StatefulWidget {
  CartPageStep2({Key key}) : super(key: key);
  @override
  _CartPageStep2State createState() => _CartPageStep2State();
}

class _CartPageStep2State extends State<CartPageStep2> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      var store = StoreProvider.of<AppState>(context);
      store.dispatch(selectDeliveryInterval(null));
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, dynamic>(
      converter: (store) => store,
      builder: (context, store) {
        DeliveryInterval deliveryInterval = store.state.cart.deliveryInterval;
        Address currentAddress = store.state.account.currentAddress;
        int deliverySum = calcDeliverySum(store.state);
        int deliveryFreeSum = store.state.account.currentAddress.deliveryFreeSum ?? 0;
        return Scaffold(
          appBar: CustomAppBar(title: FlutterI18n.translate(context, 'common.cart.title_step_2')),
          body: SafeArea(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints viewportConstraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: viewportConstraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(height: 8),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  currentAddress.name,
                                  style: TextStyle(
                                      fontSize: 13.w, fontWeight: FontWeight.w700, height: 1.5, letterSpacing: .2,),
                                ),
                                SizedBox(height: 12),
                                Text(
                                  addressToString(currentAddress, oneline: false),
                                  style: TextStyle(
                                    color: ColorsTheme.textTertiary,
                                    fontSize: 13.w,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: .2,
                                    height: 1.5,
                                  ),
                                ),
                                SizedBox(height: 16),
                                Button(
                                  onTap: () => Navigator.pushNamed(context, '/account/select-address'),
                                  label: FlutterI18n.translate(context, 'common.account.change_address'),
                                  color: ButtonColor.primary,
                                  outlined: true,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 16),
                            height: 4,
                            color: darken(ColorsTheme.bg, .04),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  FlutterI18n.translate(context, 'common.delivery.delivery_time'),
                                  style: TextStyle(fontSize: 14.w, color: ColorsTheme.textTertiary),
                                ),
                                SizedBox(height: 12),
                                Row(
                                  children: [
                                    Icon(BvIcons.calendar, color: ColorsTheme.primary, size: 24),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        deliveryInterval != null
                                            ? DateFormat(FlutterI18n.translate(context, 'common.date_format'))
                                                    .format(deliveryInterval.date) +
                                                ', ' +
                                                deliveryInterval.intervalText
                                            : FlutterI18n.translate(context, 'common.delivery_intervals.not_selected'),
                                        style: TextStyle(
                                          fontSize: 13.w,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: .2,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Button(
                                      onTap: () => Navigator.pushNamed(context, '/delivery-intervals'),
                                      color: ButtonColor.primary,
                                      outlined: true,
                                      height: 36,
                                      padding: EdgeInsets.symmetric(horizontal: 12),
                                      label: FlutterI18n.translate(context, 'common.change'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 16),
                            height: 4,
                            color: darken(ColorsTheme.bg, .04),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 16),
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
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 16),
                            height: 4,
                            color: darken(ColorsTheme.bg, .04),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              FlutterI18n.translate(context, 'common.cart.free_delivery_from') +
                                  ' ' +
                                  numToString(deliveryFreeSum) +
                                  ' ' +
                                  FlutterI18n.translate(context, 'common.cart.currency_symbol'),
                              style: TextStyle(fontSize: 12.w, fontWeight: FontWeight.w500, height: 1.5),
                            ),
                          ),
                          SizedBox(height: 36),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              alignment: Alignment.bottomCenter,
                              child: Button(
                                onTap: () {
                                  // Если инт-л доставки не выбран, то показываем тост с ошибкой:
                                  if (deliveryInterval == null) {
                                    showToast(
                                      FlutterI18n.translate(context, 'common.delivery_intervals.select_time_error'),
                                      isError: true,
                                    );
                                    return;
                                  }
                                  Navigator.pushNamed(context, '/cart-step-3');
                                },
                                height: 40,
                                label: FlutterI18n.translate(context, 'common.cart.to_payment').toUpperCase() +
                                    '   ' +
                                    numToString(store.state.cart.cost + deliverySum) +
                                    ' ' +
                                    FlutterI18n.translate(context, 'common.cart.currency_symbol'),
                              ),
                            ),
                          ),
                          SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
