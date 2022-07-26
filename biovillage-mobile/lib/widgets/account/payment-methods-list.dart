import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:biovillage/redux/state/app-state.dart';
import 'package:biovillage/redux/actions/account.dart';
import 'package:biovillage/models/payment-type.dart';
import 'package:biovillage/helpers/colors.dart';
import 'package:biovillage/theme/colors.dart';
import 'package:biovillage/widgets/form-elements.dart';

class PaymentMethodsList extends StatefulWidget {
  PaymentMethodsList({
    Key key,
    this.selectable = false,
    this.onSelect,
  }) : super(key: key);

  final bool selectable;
  final Function onSelect;

  @override
  _PaymentMethodsListState createState() => _PaymentMethodsListState();
}

class _PaymentMethodsListState extends State<PaymentMethodsList> {
  final Map<PaymentType, List<Widget>> _paymentMethodsIcons = {
    PaymentType.apay: [SvgPicture.asset('assets/img/icons/applepay-mark.svg', height: 20)],
    PaymentType.gpay: [SvgPicture.asset('assets/img/icons/googlepay-mark.svg', height: 20)],
    PaymentType.card: [
      SvgPicture.asset('assets/img/icons/mastercard.svg', height: 16),
      SvgPicture.asset('assets/img/icons/visa.svg', height: 16),
    ],
    PaymentType.ccard: [
      SvgPicture.asset('assets/img/icons/mastercard.svg', height: 16),
      SvgPicture.asset('assets/img/icons/visa.svg', height: 16),
    ],
    PaymentType.cash: [SvgPicture.asset('assets/img/icons/cash.svg', height: 16)],
  };

  /// Выбор метода оплаты
  void _tapMethod(PaymentType paymentMethod) {
    var store = StoreProvider.of<AppState>(context);
    store.dispatch(selectPaymentMethod(paymentMethod));
    if (widget.onSelect != null) widget.onSelect(paymentMethod);
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, dynamic>(
      converter: (store) => store,
      builder: (context, store) => Column(
        children: [
          for (PaymentType paymentMethod in PaymentType.values)
            Builder(builder: (context) {
              // Проверяем платформу и не пропускаем способы оплаты:
              if (paymentMethod == PaymentType.gpay && Platform.isIOS) return Container();
              if (paymentMethod == PaymentType.apay && Platform.isAndroid) return Container();
              // Обрабатываем остальные способы оплаты:
              String paymentMethodKey = paymentMethod.toString().split('.')[1];
              List<Widget> paymentIcons = _paymentMethodsIcons[paymentMethod];
              List<PaymentType> disabledMethods = store.state.general.paymentDeliveryInfo.disabledPaymentMethods;
              bool disabled = disabledMethods.contains(paymentMethod);
              // Если выбран заблокированный метод, то переключаем на кэш:
              if (store.state.account.userAuth) {
                PaymentType currPaymentMethod = store.state.account.userInfo.paymentMethod;
                if (disabled && currPaymentMethod == paymentMethod) {
                  store.dispatch(selectPaymentMethod(PaymentType.cash));
                }
              }
              // Временно скрываем недоступные методы оплаты:
              if (disabled) return Container();
              return Container(
                margin: EdgeInsets.only(bottom: 12),
                child: Opacity(
                  opacity: disabled ? .5 : 1,
                  child: Material(
                    clipBehavior: Clip.antiAlias,
                    borderRadius: BorderRadius.circular(10),
                    color: disabled ? darken(ColorsTheme.bg, .04) : ColorsTheme.bg,
                    child: InkWell(
                      onTap: disabled || !widget.selectable ? null : () => _tapMethod(paymentMethod),
                      splashColor: ColorsTheme.primary.withOpacity(.3),
                      highlightColor: ColorsTheme.primary.withOpacity(.15),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: darken(ColorsTheme.bg, .03)),
                        ),
                        child: Row(
                          children: [
                            if (widget.selectable)
                              Container(
                                margin: EdgeInsets.only(right: 12),
                                child: CustomRadio(
                                  value: paymentMethod,
                                  activeValue: store.state.account.userInfo.paymentMethod,
                                  onChange:
                                      disabled || !widget.selectable ? null : (method) => _tapMethod(paymentMethod),
                                ),
                              ),
                            Expanded(
                              child: Text(
                                FlutterI18n.translate(context, 'common.payment.${paymentMethodKey}_name'),
                                style: TextStyle(fontSize: 11.w, fontWeight: FontWeight.w600),
                              ),
                            ),
                            if (paymentIcons.isNotEmpty)
                              Container(
                                margin: EdgeInsets.only(left: 12),
                                child: Wrap(
                                  spacing: 16,
                                  children: [for (Widget icon in paymentIcons) icon],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
