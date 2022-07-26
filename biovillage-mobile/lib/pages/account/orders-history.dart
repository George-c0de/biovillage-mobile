import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:biovillage/redux/state/app-state.dart';
import 'package:biovillage/redux/actions/account.dart';
import 'package:biovillage/pages/account/order-details.dart';
import 'package:biovillage/models/history-order.dart';
import 'package:biovillage/helpers/data-formating.dart';
import 'package:biovillage/helpers/colors.dart';
import 'package:biovillage/helpers/net-connection.dart';
import 'package:biovillage/theme/colors.dart';
import 'package:biovillage/theme/bv-icons.dart';
import 'package:biovillage/widgets/appbar.dart';
import 'package:biovillage/widgets/button.dart';
import 'package:biovillage/widgets/notifications.dart';

class OrdersHistoryPage extends StatefulWidget {
  OrdersHistoryPage({Key key}) : super(key: key);

  @override
  _OrdersHistoryPageState createState() => _OrdersHistoryPageState();
}

class _OrdersHistoryPageState extends State<OrdersHistoryPage> with SingleTickerProviderStateMixin {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();

  /// Получение списка заказов
  void _getOrders() {
    var store = StoreProvider.of<AppState>(context);
    store.dispatch(getOrdersHistory(
      onFailed: () async {
        bool connection = await checkConnect(context);
        if (connection) showToast(FlutterI18n.translate(context, 'common.order.get_error'), isError: true);
        await Future.delayed(Duration(milliseconds: 3000));
        _getOrders();
      },
    ));
  }

  /// Обновление списка заказов
  Future<void> _refreshOrders() async {
    var store = StoreProvider.of<AppState>(context);
    await store.dispatch(getOrdersHistory(
      onFailed: () {
        showToast(FlutterI18n.translate(context, 'common.order.refresh_error'), isError: true);
      },
      onSuccess: (_) async {
        await Future.delayed(Duration(milliseconds: 500));
      },
    ));
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      var store = StoreProvider.of<AppState>(context);
      if (store.state.account.userInfo.orders == null) Timer(Duration(milliseconds: 500), () => _getOrders());
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: FlutterI18n.translate(context, 'common.orders_history')),
      drawerEdgeDragWidth: 0,
      body: StoreConnector<AppState, dynamic>(
        converter: (store) => store,
        builder: (context, store) {
          List<HistoryOrder> orders = store.state.account.userInfo.orders;
          if (orders == null)
            return Container(
              padding: EdgeInsets.symmetric(vertical: 40),
              alignment: Alignment.topCenter,
              child: CupertinoActivityIndicator(radius: 12),
            );
          else
            return SafeArea(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                slivers: [
                  CupertinoSliverRefreshControl(
                    key: _refreshIndicatorKey,
                    onRefresh: () => _refreshOrders(),
                  ),
                  SliverToBoxAdapter(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(height: 16),
                          if (orders.isEmpty)
                            Container(
                              margin: EdgeInsets.only(top: 24),
                              child: Text(
                                FlutterI18n.translate(context, 'common.order.no_orders'),
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 14.w, color: ColorsTheme.textTertiary),
                              ),
                            ),
                          for (int i = 0; i < orders.length; i++) _OrdersItem(order: orders[i], isExpanded: i < 3),
                          SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
        },
      ),
    );
  }
}

class _OrdersItem extends StatefulWidget {
  _OrdersItem({
    Key key,
    @required this.order,
    this.isExpanded = false,
  }) : super(key: key);

  final HistoryOrder order;
  final bool isExpanded;

  @override
  _OrdersItemState createState() => _OrdersItemState();
}

class _OrdersItemState extends State<_OrdersItem> with SingleTickerProviderStateMixin {
  AnimationController _expandController;
  bool _itemExpanded = false;

  void toggleExpand() {
    if (_itemExpanded) {
      _expandController.reverse();
    } else {
      _expandController.forward();
    }
    _itemExpanded = !_itemExpanded;
  }

  @override
  void initState() {
    _expandController = AnimationController(duration: Duration(milliseconds: 300), vsync: this);
    if (widget.isExpanded) toggleExpand();
    super.initState();
  }

  @override
  void dispose() {
    _expandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: ColorsTheme.bg,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Order num, date, expand-btn:
          Row(
            children: [
              Expanded(
                child: Text(
                  FlutterI18n.translate(context, 'common.order.order') + ' №${widget.order.number}',
                  style: TextStyle(
                    color: ColorsTheme.accent,
                    fontSize: 14.w,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(BvIcons.time, color: ColorsTheme.primary, size: 18),
              SizedBox(width: 8),
              Text.rich(
                TextSpan(children: [
                  TextSpan(text: '${widget.order.orderDate}, '),
                  TextSpan(
                    text: '${widget.order.orderTime}',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ]),
                overflow: TextOverflow.fade,
                style: TextStyle(
                  fontSize: 13.w,
                  letterSpacing: .1,
                ),
              ),
              SizedBox(width: 6),
              Container(
                margin: EdgeInsets.only(top: 2),
                child: CircleButton(
                  onTap: () => toggleExpand(),
                  size: 28,
                  splashColor: ColorsTheme.primary.withOpacity(.4),
                  highlightColor: ColorsTheme.primary.withOpacity(.2),
                  child: RotationTransition(
                    turns: Tween(begin: 0.0, end: -0.5).animate(_expandController),
                    child: Icon(BvIcons.chevron_down, color: ColorsTheme.textTertiary),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),

          /// Order delivery date, time:
          Text(
            FlutterI18n.translate(context, 'common.order.planned_delivery_date') + ':',
            style: TextStyle(color: ColorsTheme.textQuaternary, fontSize: 13.w, height: 1.54),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(BvIcons.calendar, color: ColorsTheme.primary, size: 20),
              SizedBox(width: 10),
              Text.rich(
                TextSpan(children: [
                  TextSpan(text: widget.order.deliveryDate),
                  if (widget.order.deliveryTime.isNotEmpty)
                    TextSpan(
                      text: ', ${widget.order.deliveryTime}',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                ]),
                overflow: TextOverflow.fade,
                style: TextStyle(fontSize: 13.w, letterSpacing: .1),
              ),
            ],
          ),
          SizedBox(height: 16),

          /// Order products, status:
          SizeTransition(
            sizeFactor: CurvedAnimation(parent: _expandController, curve: Curves.easeOut),
            axisAlignment: -1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  FlutterI18n.translate(context, 'common.order.composition') + ':',
                  style: TextStyle(color: ColorsTheme.textQuaternary, fontSize: 13.w, height: 1.54),
                ),
                SizedBox(height: 12),
                for (int i = 0; i < widget.order.products.length && i < 3; i++)
                  Container(
                    margin: EdgeInsets.only(bottom: i < 2 ? 16 : 22),
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
                            '${widget.order.products[i].title}',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 11.w, fontWeight: FontWeight.w500),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text.rich(
                          TextSpan(children: [
                            TextSpan(text: '${widget.order.products[i].amount} × '),
                            TextSpan(
                              text: '${widget.order.products[i].unitStep} ${widget.order.products[i].unitShortName}',
                              style: TextStyle(color: ColorsTheme.textMain),
                            ),
                          ]),
                          overflow: TextOverflow.fade,
                          style:
                              TextStyle(fontSize: 11.w, fontWeight: FontWeight.w500, color: ColorsTheme.textTertiary),
                        ),
                        SizedBox(width: 12),
                        Text(
                          numToString(widget.order.products[i].cost) +
                              ' ' +
                              FlutterI18n.translate(context, 'common.cart.currency_symbol'),
                          style: TextStyle(fontSize: 11.w, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                if (widget.order.products.length > 3)
                  Container(
                    height: 0,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 44,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment(0.0, 0.22),
                                colors: [
                                  Colors.white.withOpacity(0.0),
                                  ColorsTheme.bg,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                Row(
                  children: [
                    Text(
                      FlutterI18n.translate(context, 'common.order.status') + ':',
                      style: TextStyle(
                        color: ColorsTheme.textQuaternary,
                        fontSize: 13.w,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      FlutterI18n.translate(context, 'common.order.statuses.${widget.order.orderStatus}'),
                      style: TextStyle(
                        fontSize: 13.w,
                        color: ColorsTheme.info,
                        fontWeight: FontWeight.w600,
                        letterSpacing: .2,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),

                /// Divider:
                Container(
                  height: 4,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned.fromRect(
                        rect: Rect.fromLTWH(-20, 0, MediaQuery.of(context).size.width, 4),
                        child: Container(height: 4, color: darken(ColorsTheme.bg, .02)),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 10),
              ],
            ),
          ),

          /// Order total cost:
          Row(
            children: [
              Expanded(
                child: Text(
                  FlutterI18n.translate(context, 'common.order.total_sum') + ': ',
                  style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: .2, fontSize: 14.w, height: 1.43),
                ),
              ),
              Text(
                numToString(widget.order.totalCost) +
                    ' ' +
                    FlutterI18n.translate(context, 'common.cart.currency_symbol'),
                style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: .2, fontSize: 14.w, height: 1.43),
              ),
            ],
          ),

          /// More button:
          SizeTransition(
            sizeFactor: CurvedAnimation(parent: _expandController, curve: Curves.easeOut),
            axisAlignment: -1,
            child: Container(
              margin: EdgeInsets.only(top: 16),
              child: Button(
                onTap: () => Navigator.pushNamed(
                  context,
                  '/account/order-details',
                  arguments: OrderDetailsPageArguments(order: widget.order),
                ),
                outlined: true,
                color: ButtonColor.primary,
                label: FlutterI18n.translate(context, 'common.more_details'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
