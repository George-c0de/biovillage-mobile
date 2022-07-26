import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:biovillage/redux/state/app-state.dart';
import 'package:biovillage/redux/actions/cart.dart';
import 'package:biovillage/models/cart-product.dart';
import 'package:biovillage/helpers/data-formating.dart';
import 'package:biovillage/helpers/colors.dart';
import 'package:biovillage/theme/colors.dart';
import 'package:biovillage/widgets/button.dart';
import 'package:biovillage/widgets/image.dart';

class CartItemsList extends StatefulWidget {
  CartItemsList({Key key, this.disableControls = false}) : super(key: key);

  final bool disableControls;

  @override
  CartItemsListState createState() => CartItemsListState();
}

class CartItemsListState extends State<CartItemsList> with TickerProviderStateMixin {
  final SlidableController _slidableController = SlidableController();
  List<CartProduct> _products = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      List<CartProduct> products = StoreProvider.of<AppState>(context).state.cart.products;
      setState(() => _products = products);
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
      builder: (context, store) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < _products.length; i++)
            Container(
              margin: i + 1 != _products.length ? EdgeInsets.only(bottom: 16) : null,
              child: Slidable(
                controller: _slidableController,
                actionPane: SlidableDrawerActionPane(),
                secondaryActions: widget.disableControls
                    ? null
                    : <Widget>[
                        Container(
                          margin: EdgeInsets.only(right: 10),
                          child: MaterialButton(
                            onPressed: () {
                              _slidableController.activeState.close();
                              store.dispatch(removeFromCart(_products[i].id));
                            },
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                            height: 20,
                            padding: EdgeInsets.symmetric(horizontal: 4),
                            splashColor: ColorsTheme.error.withOpacity(.4),
                            highlightColor: ColorsTheme.error.withOpacity(.2),
                            child: Text(
                              FlutterI18n.translate(context, 'common.delete'),
                              style: TextStyle(fontSize: 11.w, color: ColorsTheme.error, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                child: Container(
                  padding: EdgeInsets.only(left: 16, right: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        child: CustomNetworkImage(
                          url: _products[i].imgUrl,
                          progressWidget: (ctx, url, dp) => Container(
                            color: darken(ColorsTheme.bg, .02),
                            alignment: Alignment.center,
                            child: CupertinoActivityIndicator(radius: 8),
                          ),
                          errorWidget: (ctx, url, err) => Container(
                            color: darken(ColorsTheme.bg, .02),
                            alignment: Alignment.center,
                            child: Icon(Icons.image_not_supported, color: ColorsTheme.error, size: 22),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              '${_products[i].name} ' +
                                  formatWeight(
                                    amount: _products[i].amount,
                                    unitStep: _products[i].unitStep,
                                    unitFactor: _products[i].unitFactor,
                                    unitShortName: _products[i].unitShortName,
                                    unitShortDerName: _products[i].unitShortDerName,
                                  ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              softWrap: false,
                              style: TextStyle(fontSize: 11.w, height: 1.45, fontWeight: FontWeight.w500),
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  numToString(_products[i].cost) +
                                      ' ' +
                                      FlutterI18n.translate(context, 'common.cart.currency_symbol'),
                                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.w),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  '( ${_products[i].amount} × ${_products[i].price} ' +
                                      FlutterI18n.translate(context, 'common.cart.currency_symbol') +
                                      ' )',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 11.w,
                                    color: ColorsTheme.textTertiary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (!widget.disableControls)
                        Container(
                          width: 86,
                          height: 36,
                          margin: EdgeInsets.only(left: 8),
                          child: Stack(
                            children: [
                              Positioned(
                                top: 4,
                                left: 4,
                                child: Container(
                                  width: 78,
                                  height: 28,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(24),
                                    color: ColorsTheme.accent,
                                    boxShadow: <BoxShadow>[
                                      BoxShadow(
                                        color: Color.fromRGBO(123, 49, 110, 0.25),
                                        offset: Offset(0, 1),
                                        blurRadius: 2,
                                      ),
                                      BoxShadow(
                                        color: Color.fromRGBO(123, 49, 110, 0.25),
                                        offset: Offset(0, 10),
                                        blurRadius: 20,
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    _products[i].amount.toString(),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 11.w,
                                      fontWeight: FontWeight.w500,
                                      color: ColorsTheme.bg,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 0,
                                left: 0,
                                child: CircleButton(
                                  onTap: () => store.dispatch(changeCartProductAmount(_products[i], -1)),
                                  size: 36,
                                  splashColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  child: Container(
                                    child: Text(
                                      '-',
                                      style: TextStyle(
                                        color: ColorsTheme.bg,
                                        fontSize: 16.w,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: CircleButton(
                                  onTap: () => store.dispatch(changeCartProductAmount(_products[i], 1)),
                                  size: 36,
                                  splashColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  child: Container(
                                    child: Text(
                                      '+',
                                      style: TextStyle(
                                        color: ColorsTheme.bg,
                                        fontSize: 14.w,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
