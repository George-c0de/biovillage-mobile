import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:biovillage/redux/state/app-state.dart';
import 'package:biovillage/redux/actions/account.dart';
import 'package:biovillage/models/history-order.dart';
import 'package:biovillage/helpers/data-formating.dart';
import 'package:biovillage/helpers/colors.dart';
import 'package:biovillage/theme/colors.dart';
import 'package:biovillage/theme/bv-icons.dart';
import 'package:biovillage/widgets/appbar.dart';
import 'package:biovillage/widgets/button.dart';
import 'package:biovillage/widgets/notifications.dart';

class OrderDetailsPageArguments {
  OrderDetailsPageArguments({@required this.order});
  final HistoryOrder order;
}

class OrderDetailsPage extends StatefulWidget {
  OrderDetailsPage({Key key}) : super(key: key);

  @override
  _OrderDetailsPageState createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> with SingleTickerProviderStateMixin {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey2 = new GlobalKey<RefreshIndicatorState>();
  HistoryOrder _order;

  /// Обновление текущего заказа
  Future<void> _refreshOrder() async {
    var store = StoreProvider.of<AppState>(context);
    await store.dispatch(getOrdersHistory(
      onFailed: () {
        showToast(FlutterI18n.translate(context, 'common.order.refresh_error'), isError: true);
      },
      onSuccess: (List<HistoryOrder> orders) async {
        HistoryOrder updOrder = orders.firstWhere(
          (HistoryOrder order) => order.number == _order.number,
          orElse: () => null,
        );
        if (updOrder == null) {
          showToast(FlutterI18n.translate(context, 'common.order.refresh_error'), isError: true);
        } else {
          setState(() => _order = updOrder);
          await Future.delayed(Duration(milliseconds: 300));
        }
      },
    ));
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final OrderDetailsPageArguments args = ModalRoute.of(context).settings.arguments;
      setState(() => _order = args.order);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_order == null) return Scaffold();
    return Scaffold(
      appBar: CustomAppBar(title: FlutterI18n.translate(context, 'common.order.order') + ' №${_order.number}'),
      body: StoreConnector<AppState, dynamic>(
        converter: (store) => store,
        builder: (context, store) => SafeArea(
          child: Column(
            children: [
              Expanded(
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  slivers: [
                    CupertinoSliverRefreshControl(
                      key: _refreshIndicatorKey2,
                      onRefresh: () => _refreshOrder(),
                    ),
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(height: 8),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  FlutterI18n.translate(context, 'common.order.date') + ':',
                                  style: TextStyle(fontSize: 13.w, color: ColorsTheme.textQuaternary),
                                ),
                                SizedBox(height: 12),
                                Row(
                                  children: [
                                    Icon(BvIcons.time, color: ColorsTheme.primary, size: 18),
                                    SizedBox(width: 10),
                                    Text.rich(
                                      TextSpan(children: [
                                        TextSpan(text: '${_order.orderDate}, '),
                                        TextSpan(
                                          text: '${_order.orderTime}',
                                          style: TextStyle(fontWeight: FontWeight.w600),
                                        ),
                                      ]),
                                      style: TextStyle(fontSize: 13.w, letterSpacing: .1),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20),
                                Text(
                                  FlutterI18n.translate(context, 'common.order.completion_date') + ':',
                                  style: TextStyle(fontSize: 13.w, color: ColorsTheme.textQuaternary),
                                ),
                                SizedBox(height: 12),
                                Row(
                                  children: [
                                    Icon(BvIcons.time, color: ColorsTheme.primary, size: 18),
                                    SizedBox(width: 10),
                                    Text.rich(
                                      TextSpan(
                                        children: _order.completionDate != null
                                            ? [
                                                TextSpan(text: '${_order.completionDate}, '),
                                                TextSpan(
                                                  text: '${_order.completionTime}',
                                                  style: TextStyle(fontWeight: FontWeight.w600),
                                                ),
                                              ]
                                            : [TextSpan(text: '--')],
                                      ),
                                      overflow: TextOverflow.fade,
                                      style: TextStyle(fontSize: 13.w, letterSpacing: .1),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20),
                                Text(
                                  FlutterI18n.translate(context, 'common.order.planned_delivery_date') + ':',
                                  style: TextStyle(fontSize: 13.w, color: ColorsTheme.textQuaternary),
                                ),
                                SizedBox(height: 12),
                                Row(
                                  children: [
                                    Icon(BvIcons.calendar, color: ColorsTheme.primary, size: 20),
                                    SizedBox(width: 8),
                                    Text.rich(
                                      TextSpan(children: [
                                        TextSpan(text: '${_order.deliveryDate}, '),
                                        TextSpan(
                                          text: '${_order.deliveryTime}',
                                          style: TextStyle(fontWeight: FontWeight.w600),
                                        ),
                                      ]),
                                      overflow: TextOverflow.fade,
                                      style: TextStyle(fontSize: 13.w, letterSpacing: .1),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 14),
                          Container(height: 4, color: darken(ColorsTheme.bg, .02)),
                          SizedBox(height: 12),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text.rich(
                              TextSpan(children: [
                                TextSpan(text: FlutterI18n.translate(context, 'common.order.payment_method') + ':  '),
                                TextSpan(
                                  text: FlutterI18n.translate(context, 'common.payment.${_order.paymentMethod}_name'),
                                  style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: .2),
                                ),
                              ]),
                              overflow: TextOverflow.fade,
                              style: TextStyle(fontSize: 13.w),
                            ),
                          ),
                          SizedBox(height: 12),
                          Container(height: 4, color: darken(ColorsTheme.bg, .02)),
                          SizedBox(height: 12),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text.rich(
                              TextSpan(children: [
                                TextSpan(text: FlutterI18n.translate(context, 'common.order.payment_status') + ':  '),
                                TextSpan(
                                  text:
                                      FlutterI18n.translate(context, 'common.payment.statuses.${_order.paymentStatus}'),
                                  style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: .2),
                                ),
                              ]),
                              overflow: TextOverflow.fade,
                              style: TextStyle(fontSize: 13.w),
                            ),
                          ),
                          SizedBox(height: 12),
                          Container(height: 4, color: darken(ColorsTheme.bg, .02)),
                          SizedBox(height: 12),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text.rich(
                              TextSpan(children: [
                                TextSpan(text: FlutterI18n.translate(context, 'common.order.status') + ':  '),
                                TextSpan(
                                  text: FlutterI18n.translate(context, 'common.order.statuses.${_order.orderStatus}'),
                                  style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: .2),
                                ),
                              ]),
                              overflow: TextOverflow.fade,
                              style: TextStyle(fontSize: 13.w),
                            ),
                          ),
                          SizedBox(height: 12),
                          Container(height: 4, color: darken(ColorsTheme.bg, .02)),
                          SizedBox(height: 12),
                          if (_order.operatorComment.isNotEmpty)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    FlutterI18n.translate(context, 'common.order.operator_comment') + ':',
                                    style: TextStyle(fontSize: 13.w, color: ColorsTheme.textQuaternary),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    _order.operatorComment,
                                    style: TextStyle(fontSize: 12.w, height: 1.5, fontWeight: FontWeight.w500),
                                  ),
                                  SizedBox(height: 12),
                                  Container(height: 4, color: darken(ColorsTheme.bg, .02)),
                                ],
                              ),
                            ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                SizedBox(height: 12),
                                Text(
                                  FlutterI18n.translate(context, 'common.order.composition') + ':',
                                  style: TextStyle(color: ColorsTheme.textQuaternary, fontSize: 13.w, height: 1.54),
                                ),
                                SizedBox(height: 12),
                                for (int i = 0; i < _order.products.length; i++)
                                  Container(
                                    padding: EdgeInsets.only(bottom: 10),
                                    margin: EdgeInsets.only(bottom: 8),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(color: darken(ColorsTheme.bg, .02), width: 2),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          (i + 1).toString(),
                                          style: TextStyle(
                                            fontSize: 11.w,
                                            fontWeight: FontWeight.w700,
                                            color: darken(ColorsTheme.bg, .15),
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            '${_order.products[i].title}',
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(fontSize: 11.w, fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Text.rich(
                                          TextSpan(children: [
                                            TextSpan(text: '${_order.products[i].amount} × '),
                                            TextSpan(
                                              text:
                                                  '${_order.products[i].unitStep} ${_order.products[i].unitShortName}',
                                              style: TextStyle(color: ColorsTheme.textMain),
                                            ),
                                          ]),
                                          overflow: TextOverflow.fade,
                                          style: TextStyle(
                                              fontSize: 11.w,
                                              fontWeight: FontWeight.w500,
                                              color: ColorsTheme.textTertiary),
                                        ),
                                        SizedBox(width: 12),
                                        Text(
                                          numToString(_order.products[i].cost) +
                                              ' ' +
                                              FlutterI18n.translate(context, 'common.cart.currency_symbol'),
                                          style: TextStyle(fontSize: 11.w, fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                  ),
                                SizedBox(height: 4),
                                Container(
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          FlutterI18n.translate(context, 'common.order.total_sum') + ': ',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: .2,
                                              fontSize: 14.w,
                                              height: 1.43),
                                        ),
                                      ),
                                      Text(
                                        numToString(_order.totalCost) +
                                            ' ' +
                                            FlutterI18n.translate(context, 'common.cart.currency_symbol'),
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700, letterSpacing: .2, fontSize: 14.w, height: 1.43),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 24),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: darken(ColorsTheme.bg, .02), width: 4)),
                ),
                child: Button(
                  onTap: () => Navigator.pop(context),
                  outlined: true,
                  color: ButtonColor.primary,
                  label: FlutterI18n.translate(context, 'common.back'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
