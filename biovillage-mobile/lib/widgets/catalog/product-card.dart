import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:biovillage/redux/state/app-state.dart';
import 'package:biovillage/redux/actions/cart.dart';
import 'package:biovillage/models/product.dart';
import 'package:biovillage/models/cart-product.dart';
import 'package:biovillage/pages/account/select-address.dart';
import 'package:biovillage/helpers/cart.dart';
import 'package:biovillage/helpers/data-formating.dart';
import 'package:biovillage/theme/colors.dart';
import 'package:biovillage/widgets/button.dart';
import 'package:biovillage/widgets/image.dart';
import 'package:biovillage/widgets/catalog/product-sheet.dart';

class ProductCard extends StatefulWidget {
  ProductCard({Key key, @required this.product, this.specialProductGroup}) : super(key: key);

  final Product product;
  final List<Product> specialProductGroup;

  @override
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  void _addToCart() {
    var store = StoreProvider.of<AppState>(context);
    if (store.state.account.currentAddress == null) {
      // Если адрес не задан, то сначала предлагаем его задать:
      Navigator.pushNamed(
        context,
        '/account/select-address',
        arguments: SelectAddressPageArguments(
          onAddressSelected: () => store.dispatch(addToCart(widget.product)),
        ),
      );
    } else {
      store.dispatch(addToCart(widget.product));
    }
  }

  void _openProductSheet() {
    var store = StoreProvider.of<AppState>(context);
    List<Product> products;
    int index;
    if (widget.specialProductGroup != null) {
      products = widget.specialProductGroup;
    } else {
      products = store.state.catalog.products[widget.product.categoryId];
    }
    if (products == null) products = [widget.product];
    index = products.indexOf(widget.product);
    if (index < 0) {
      products = products = [widget.product];
      index = 0;
    }
    showProductSheet(
      context,
      products: products,
      index: index,
    );
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, dynamic>(
      converter: (store) => store,
      builder: (context, store) {
        CartProduct cartProduct = findCartProduct(store.state.cart.products, widget.product.id);
        int productCartAmount = cartProduct != null ? cartProduct.amount : 0;
        double cardWidth = 109.w;
        double cardHeight = 210.w;
        return SizedBox(
          width: cardWidth,
          height: cardHeight,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Color.fromRGBO(123, 49, 110, 0.15),
                  offset: Offset(0, 1.w),
                  blurRadius: 2.w,
                ),
                BoxShadow(
                  color: Color.fromRGBO(133, 41, 115, 0.1),
                  offset: Offset(0, 2.w),
                  blurRadius: 20.w,
                ),
              ],
            ),
            child: Material(
              clipBehavior: Clip.antiAlias,
              borderRadius: BorderRadius.circular(10),
              color: ColorsTheme.bg,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(6.w),
                          child: CustomNetworkImage(
                            url: widget.product.imgUrl,
                            height: cardHeight * .4,
                          ),
                        ),
                        Expanded(
                          child: Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(horizontal: 6),
                            child: Text(
                              widget.product.name,
                              maxLines: 3,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: ColorsTheme.textMain,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.1,
                                fontSize: 11.w,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          margin: EdgeInsets.only(top: 4),
                          child: Text(
                            formatWeight(
                              amount: 1,
                              unitStep: widget.product.unitStep,
                              unitFactor: widget.product.unitFactor,
                              unitShortName: widget.product.unitShortName,
                              unitShortDerName: widget.product.unitShortDerName,
                            ),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                              color: ColorsTheme.info,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.1,
                              fontSize: 11.w,
                              height: 1.4,
                            ),
                          ),
                        ),
                        SizedBox(height: 43.w),
                      ],
                    ),
                  ),
                  Positioned.fill(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _openProductSheet(),
                        splashColor: ColorsTheme.primary.withOpacity(.4),
                        highlightColor: ColorsTheme.primary.withOpacity(.2),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 6.w,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.w),
                      child: productCartAmount < 1
                          ? Button(
                              label: numToString(widget.product.price) +
                                  ' ' +
                                  FlutterI18n.translate(context, 'common.cart.currency_symbol'),
                              color: ButtonColor.primary,
                              height: 32.w,
                              fontSize: 10.w,
                              fontWeight: FontWeight.w700,
                              onTap: () => _addToCart(),
                            )
                          : Material(
                              color: Colors.transparent,
                              child: GestureDetector(
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 32.w,
                                      child: Button(
                                        color: ButtonColor.primary,
                                        height: 32.w,
                                        fontSize: 14.w,
                                        label: '-',
                                        onTap: () => store.dispatch(changeCartProductAmount(widget.product, -1)),
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        margin: EdgeInsets.symmetric(horizontal: 4),
                                        alignment: Alignment.center,
                                        child: Text(
                                          productCartAmount.toString(),
                                          style: TextStyle(
                                            fontSize: 11.w,
                                            color: ColorsTheme.textSecondary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 32.w,
                                      child: Button(
                                        color: ButtonColor.primary,
                                        height: 32.w,
                                        fontSize: 14.w,
                                        label: '+',
                                        onTap: () => store.dispatch(changeCartProductAmount(widget.product, 1)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
