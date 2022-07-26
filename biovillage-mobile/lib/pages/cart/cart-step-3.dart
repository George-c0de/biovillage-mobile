import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:yandex_kassa/yandex_kassa.dart';
import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:biovillage/redux/state/app-state.dart';
import 'package:biovillage/redux/actions/cart.dart';
import 'package:biovillage/redux/actions/catalog.dart';
import 'package:biovillage/redux/actions/account.dart';
import 'package:biovillage/models/cart-product.dart';
import 'package:biovillage/models/gift.dart';
import 'package:biovillage/models/delivery-interval.dart';
import 'package:biovillage/models/order.dart';
import 'package:biovillage/models/payment-type.dart';
import 'package:biovillage/models/payment-delivery-info.dart';
import 'package:biovillage/helpers/colors.dart';
import 'package:biovillage/helpers/cart.dart';
import 'package:biovillage/helpers/net-connection.dart';
import 'package:biovillage/helpers/data-formating.dart';
import 'package:biovillage/theme/bv-icons.dart';
import 'package:biovillage/theme/colors.dart';
import 'package:biovillage/pages/inapp-browser.dart';
import 'package:biovillage/pages/account/payment-methods.dart';
import 'package:biovillage/widgets/appbar.dart';
import 'package:biovillage/widgets/form-elements.dart';
import 'package:biovillage/widgets/button.dart';
import 'package:biovillage/widgets/circles-pattern.dart';
import 'package:biovillage/widgets/cart/gifts-select.dart';
import 'package:biovillage/widgets/cart/cart-items-list.dart';
import 'package:biovillage/widgets/notifications.dart';

class CartPageStep3 extends StatefulWidget {
  CartPageStep3({Key key}) : super(key: key);
  @override
  _CartPageStep3State createState() => _CartPageStep3State();
}

class _CartPageStep3State extends State<CartPageStep3> {
  bool _analogProductOption = true;
  TextEditingController _promocode = TextEditingController();
  TextEditingController _comment = TextEditingController();
  List<Gift> _selectedGifts = [];
  bool _loading = false;
  bool _connection = false;

  final Map<PaymentType, List<Widget>> _paymentMethodsIcons = {
    PaymentType.apay: [SvgPicture.asset('assets/img/icons/applepay-mark.svg', height: 24)],
    PaymentType.gpay: [SvgPicture.asset('assets/img/icons/googlepay-mark.svg', height: 24)],
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

  void _selectAnalogProductOption(bool value) {
    if (_analogProductOption == value) return;
    setState(() => _analogProductOption = value);
  }

  /// Создание заказа
  void _createOrder() async {
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);
    var store = StoreProvider.of<AppState>(context);
    // Формируем список товаров:
    List<OrderProduct> products = [];
    for (CartProduct product in store.state.cart.products) {
      products.add(OrderProduct(
        id: product.id,
        qty: product.amount,
        price: product.price,
        total: product.cost,
      ));
    }
    // Формируем список подарков:
    List<OrderProduct> gifts = [];
    int giftsCost = 0;
    for (Gift gift in _selectedGifts) {
      giftsCost += gift.price;
      gifts.add(OrderProduct(
        id: gift.id,
        qty: 1,
        price: gift.price,
        total: gift.price,
      ));
    }
    // Формируем заказ:
    Order order = Order(
      deliveryIntervalId: store.state.cart.deliveryInterval.id,
      addressId: store.state.account.currentAddress.id,
      paymentPrimaryMethod: store.state.account.userInfo.paymentMethod,
      productsSum: store.state.cart.cost,
      deliverySum: calcDeliverySum(store.state),
      total: store.state.cart.cost + calcDeliverySum(store.state),
      giftBonuses: giftsCost,
      clientsComment: _comment.text,
      promoCode: _promocode.text,
      actionIfNotDelivery: _analogProductOption ? 'findAnalog' : 'notCallNotBuy',
      products: products,
      gifts: gifts,
    );

    // Проверяем метод оплаты, если оплата онлайн - то сразу проводим оплату:
    if ([PaymentType.apay, PaymentType.gpay, PaymentType.card].contains(order.paymentPrimaryMethod)) {
      // Определяем список методов оплаты для передачи в Я.Кассу:
      List<PaymentMethod> paymentMethods;
      switch (order.paymentPrimaryMethod) {
        case PaymentType.apay:
          paymentMethods = [PaymentMethod.applePay];
          break;
        case PaymentType.gpay:
          paymentMethods = [PaymentMethod.googlePay];
          break;
        case PaymentType.card:
          paymentMethods = [PaymentMethod.bankCard];
          break;
        default:
      }

      // Формируем настройки оплаты: ru.biovillage.ios
      PaymentDeliveryInfo paymentDeliveryInfo = store.state.general.paymentDeliveryInfo;
      final paymentParams = PaymentParameters(
        shopId: paymentDeliveryInfo.paymentGatewayShopId,
        clientApplicationKey: paymentDeliveryInfo.paymentGatewayMobileKey,
        purchaseName: paymentDeliveryInfo.paymentGatewayPurchaseName,
        purchaseDescription: paymentDeliveryInfo.paymentGatewayPurchaseDesc,
        paymentMethods: paymentMethods,
        returnUrl: paymentDeliveryInfo.paymentGatewayReturnUrl,
        applePayMerchantIdentifier: "merchant.ru.biovillage",
        googlePayParameters: [GooglePayCardNetwork('VISA'), GooglePayCardNetwork('MASTERCARD')],
        amount: Amount(
          order.total.toDouble(),
          currency: Currency.values.firstWhere(
            (c) => c.toString() == 'Currency.' + paymentDeliveryInfo.paymentCurrency.toLowerCase(),
            orElse: () => Currency.rub,
          ),
        ),
        showYandexCheckoutLogo: false,
        iosColorScheme: IosColorScheme(red: 123, green: 49, blue: 112),
        androidColorScheme: IosColorScheme(red: 123, green: 49, blue: 112),
      );
      final TokenizationResult result = await YandexKassa.startCheckout(paymentParams);
      if (!result.success) setState(() => _loading = false);
      // Если оплата прошла успешно, то добавляем токен оплаты в заказ:
      if (result.paymentData != null) {
        order.paymentToken = result.paymentData.token;
      } else {
        // Если возникла ошибка, выводим уведомления и выходим:
        showToast(FlutterI18n.translate(context, 'common.payment.error'), isError: true);
        return;
      }
    }

    // Отправляем заказ:
    await store.dispatch(
      createOrder(
        order,
        defaultErrorText: FlutterI18n.translate(context, 'common.order.create_error'),
        onFailed: (errors) => setState(() => _loading = false),
        onSuccess: (String confirmationLink) async {
          var store = StoreProvider.of<AppState>(context);

          // Отправляем событие покупки в Facebook:
          FacebookAppEvents().logPurchase(
            amount: order.total.toDouble(),
            currency: 'RUB',
            parameters: {},
          );

          // Если оплата онлайн:
          if (confirmationLink != null) {
            setState(() => _loading = false);
            await Navigator.pushNamed(
              context,
              '/inapp-browser',
              arguments: InappBrowserArguments(
                initialUrl: confirmationLink,
                onPageStarted: (url) {
                  if (url == null || url.isEmpty) return;

                  // Урл при успешной оплате:
                  String successUrl = store.state.general.paymentDeliveryInfo.paymentGatewayReturnUrl;

                  /// Вспомогательная функция для проверки слэша на конце ссылки:
                  String checkUrlSlash(String url) {
                    if (url.substring(url.length - 1, url.length) == '/') url = url.substring(0, url.length - 1);
                    return url;
                  }

                  // Сравниваем урлы, если все ок, то заказ считаем оформленным:
                  if (checkUrlSlash(url) == checkUrlSlash(successUrl)) {
                    Timer(Duration(milliseconds: 500), () {
                      store.dispatch(clearCart());
                      store.dispatch(selectDeliveryInterval(null));
                    });
                    Navigator.pushNamed(context, '/cart-success');
                  }
                },
              ),
            );
          } else {
            Timer(Duration(milliseconds: 500), () {
              store.dispatch(clearCart());
              store.dispatch(selectDeliveryInterval(null));
            });
            Navigator.pushNamed(context, '/cart-success');
          }
        },
      ),
    );
  }

  /// Запрос списков подарков с сервера
  void _getGifts() {
    var store = StoreProvider.of<AppState>(context);
    store.dispatch(getGifts(onFailed: () async {
      bool connect = await checkConnect(context, toast: false);
      setState(() => _connection = connect);
      await Future.delayed(Duration(milliseconds: 1500));
      _getGifts();
    }));
  }

  /// Формирование лейбла для кнопки оформления в зависимости от типа оплаты
  String _getCreateOrderLabel(int totalSum) {
    var store = StoreProvider.of<AppState>(context);
    PaymentType currPaymentMethod = store.state.account.userInfo.paymentMethod;
    String label;
    if ([PaymentType.cash, PaymentType.ccard].contains(currPaymentMethod)) {
      label = FlutterI18n.translate(context, 'common.cart.place_order').toUpperCase();
    } else {
      label = FlutterI18n.translate(context, 'common.cart.to_pay').toUpperCase();
    }
    return '$label   ' + numToString(totalSum) + FlutterI18n.translate(context, 'common.cart.currency_symbol');
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Запрашиваем список подарков:
      _getGifts();
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
        int deliverySum = calcDeliverySum(store.state);
        int totalSum = store.state.cart.cost + deliverySum;
        PaymentType currPaymentMethod = store.state.account.userInfo.paymentMethod;
        String currPaymentMethodKey = currPaymentMethod.toString().split('.')[1];
        String currPaymentMethodText = FlutterI18n.translate(context, 'common.payment.${currPaymentMethodKey}_text');
        return Scaffold(
          appBar: CustomAppBar(title: FlutterI18n.translate(context, 'common.cart.title_step_3')),
          body: SafeArea(
            child: Container(
              color: ColorsTheme.primary,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      color: ColorsTheme.bg,
                      child: Column(
                        children: [
                          SizedBox(height: 12),
                          CartItemsList(disableControls: true),
                          SizedBox(height: 24),
                          Container(height: 4, color: darken(ColorsTheme.bg, .04)),
                          SizedBox(height: 16),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                Icon(BvIcons.map_marker_2, color: ColorsTheme.primary, size: 24),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    store.state.account.currentAddress.address,
                                    style: TextStyle(fontSize: 13.w),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 16),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
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
                                        : '--',
                                    style: TextStyle(fontSize: 13.w),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 16),
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
                          SizedBox(height: 20),
                          Container(
                            color: ColorsTheme.info,
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  FlutterI18n.translate(context, 'common.enter_promocode') + ':',
                                  style: TextStyle(fontSize: 16.w, color: ColorsTheme.bg, fontWeight: FontWeight.w600),
                                ),
                                SizedBox(height: 12),
                                CustomTextFormField(
                                  controller: _promocode,
                                  textCapitalization: TextCapitalization.characters,
                                  hintText: FlutterI18n.translate(context, 'common.promocode'),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                            child: CustomTextFormField(
                              controller: _comment,
                              keyboardType: TextInputType.multiline,
                              hintText: FlutterI18n.translate(context, 'common.order.comment'),
                              maxLines: 3,
                            ),
                          ),
                          Container(height: 4, color: darken(ColorsTheme.bg, .04)),
                          Container(
                            padding: EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    FlutterI18n.translate(context, 'common.order.total_sum') + ':',
                                    style: TextStyle(fontSize: 13.w, fontWeight: FontWeight.w700),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  numToString(totalSum) +
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
                          Container(height: 4, color: darken(ColorsTheme.bg, .04)),
                          SizedBox(height: 16),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                Icon(BvIcons.phone, color: ColorsTheme.primary, size: 24),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    FlutterI18n.translate(context, 'common.contact_phone') + ':',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 13.w),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  store.state.account.userInfo.phone,
                                  style: TextStyle(
                                    fontSize: 14.w,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: .2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10),
                        ],
                      ),
                    ),
                    CirclesPattern(),
                    SizedBox(height: 18),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 16),
                      padding: EdgeInsets.fromLTRB(16, 16, 16, 22),
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
                      child: Column(
                        children: [
                          Text(
                            FlutterI18n.translate(context, 'common.cart.if_cannot_delivery_product') + ':',
                            style: TextStyle(
                              fontSize: 13.w,
                              fontWeight: FontWeight.w700,
                              letterSpacing: .2,
                              height: 1.5,
                            ),
                          ),
                          SizedBox(height: 18),
                          GestureDetector(
                            onTap: () => _selectAnalogProductOption(true),
                            child: Row(
                              children: [
                                CustomRadio(
                                  value: true,
                                  activeValue: _analogProductOption,
                                  onChange: (v) => _selectAnalogProductOption(true),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    FlutterI18n.translate(context, 'common.cart.call_to_find_analog') + '.',
                                    style: TextStyle(fontSize: 13.w),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 16),
                          GestureDetector(
                            onTap: () => _selectAnalogProductOption(false),
                            child: Row(
                              children: [
                                CustomRadio(
                                  value: false,
                                  activeValue: _analogProductOption,
                                  onChange: (v) => _selectAnalogProductOption(false),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    FlutterI18n.translate(context, 'common.cart.dont_call_dont_buy') + '.',
                                    style: TextStyle(fontSize: 13.w),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 16),
                      padding: EdgeInsets.fromLTRB(16, 16, 16, 22),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  FlutterI18n.translate(context, 'common.cart.weight_can_differ'),
                                  style: TextStyle(
                                    fontSize: 13.w,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: .2,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                              Icon(BvIcons.info, color: ColorsTheme.primary)
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            FlutterI18n.translate(context, 'common.cart.sum_can_differ'),
                            style: TextStyle(fontSize: 13.w, height: 1.8),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 16),
                      padding: EdgeInsets.fromLTRB(16, 16, 16, 22),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  FlutterI18n.translate(context, 'common.payment.${currPaymentMethodKey}_name'),
                                  style: TextStyle(
                                    fontSize: 13.w,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: .2,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(left: 12),
                                child: Wrap(
                                  spacing: 8,
                                  children: [for (Widget icon in _paymentMethodsIcons[currPaymentMethod]) icon],
                                ),
                              ),
                            ],
                          ),
                          if (currPaymentMethodText.isNotEmpty)
                            Container(
                              margin: EdgeInsets.only(top: 8),
                              child: Text(
                                currPaymentMethodText,
                                style: TextStyle(fontSize: 13.w, height: 1.8),
                              ),
                            ),
                          SizedBox(height: 16),
                          Button(
                            onTap: () {
                              FocusScope.of(context).unfocus();
                              Navigator.pushNamed(
                                context,
                                '/account/payment',
                                arguments: PaymentMethodsPageArguments(backAfterChoice: true),
                              );
                            },
                            label: FlutterI18n.translate(context, 'common.payment.change_method'),
                            outlined: true,
                            color: ButtonColor.primary,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                    Container(color: ColorsTheme.textMain.withOpacity(.05), height: 4),
                    Container(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(BvIcons.gift, color: ColorsTheme.bg),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              FlutterI18n.translate(context, 'common.cart.select_gift') + ':',
                              style: TextStyle(
                                fontSize: 13.w,
                                fontWeight: FontWeight.w700,
                                color: ColorsTheme.bg,
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            '${store.state.account.userInfo.bonuses} ' +
                                FlutterI18n.translate(context, 'common.cart.points_unit').toLowerCase(),
                            style: TextStyle(
                              fontSize: 14.w,
                              fontWeight: FontWeight.w700,
                              letterSpacing: .2,
                              color: ColorsTheme.bg,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: GiftsSelect(
                        balance: store.state.account.userInfo.bonuses,
                        gifts: store.state.catalog.gifts,
                        connect: _connection,
                        onChange: (gifts) => _selectedGifts = gifts,
                      ),
                    ),
                    SizedBox(height: 24),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Button(
                        onTap: () => _createOrder(),
                        loading: _loading,
                        height: 40,
                        label: _getCreateOrderLabel(totalSum),
                      ),
                    ),
                    SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
