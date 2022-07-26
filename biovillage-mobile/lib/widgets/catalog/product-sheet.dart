import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:biovillage/redux/state/app-state.dart';
import 'package:biovillage/redux/actions/cart.dart';
import 'package:biovillage/models/product.dart';
import 'package:biovillage/models/cart-product.dart';
import 'package:biovillage/pages/catalog/product-certs.dart';
import 'package:biovillage/pages/account/select-address.dart';
import 'package:biovillage/helpers/cart.dart';
import 'package:biovillage/helpers/data-formating.dart';
import 'package:biovillage/helpers/colors.dart';
import 'package:biovillage/theme/colors.dart';
import 'package:biovillage/theme/bv-icons.dart';
import 'package:biovillage/widgets/bottom-sheet.dart';
import 'package:biovillage/widgets/button.dart';
import 'package:biovillage/widgets/image.dart';
import 'package:biovillage/widgets/cart/floating-cart-button.dart';
import 'package:biovillage/widgets/expandable-text.dart';
import 'package:biovillage/widgets/form-elements.dart';

showProductSheet(BuildContext context, {@required List<Product> products, @required int index}) {
  return showCustomBottomSheet(
    context,
    builder: (scrollController) => _ProductSheetContent(
      scrollController: scrollController,
      products: products,
      index: index,
    ),
  );
}

class _ProductSheetContent extends StatefulWidget {
  _ProductSheetContent({
    Key key,
    @required this.products,
    @required this.index,
    @required this.scrollController,
  }) : super(key: key);

  final List<Product> products;
  final int index;
  final ScrollController scrollController;

  @override
  _ProductSheetContentState createState() => _ProductSheetContentState();
}

class _ProductSheetContentState extends State<_ProductSheetContent> with TickerProviderStateMixin {
  MaskedTextController _countFieldController = MaskedTextController(mask: '000');
  FocusNode _countFieldFocusNode = FocusNode();
  SwiperController _swiperController;
  AnimationController _showCartController;
  int _currentProductIndex;

  void _changeIndex(int index) {
    _countFieldFocusNode.unfocus();
    var store = StoreProvider.of<AppState>(context);
    Product currentProduct = widget.products[index];
    CartProduct cartProduct = findCartProduct(store.state.cart.products, currentProduct.id);
    int productCartAmount = cartProduct != null ? cartProduct.amount : 0;
    if (productCartAmount != null) {
      _countFieldController.text = productCartAmount.toString();
    }
    setState(() {
      _currentProductIndex = index;
    });
  }

  void _addToCart(Product product) {
    var store = StoreProvider.of<AppState>(context);
    if (store.state.account.currentAddress == null) {
      // Если адрес не задан, то сначала предлагаем его задать:
      Navigator.pushNamed(
        context,
        '/account/select-address',
        arguments: SelectAddressPageArguments(onAddressSelected: () {
          store.dispatch(addToCart(product));
          _countFieldController.text = '1';
        }),
      );
    } else {
      store.dispatch(addToCart(product));
      _countFieldController.text = '1';
    }
  }

  @override
  void initState() {
    super.initState();
    _currentProductIndex = widget.index;
    _swiperController = SwiperController();
    _showCartController = AnimationController(duration: Duration(milliseconds: 300), vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      var store = StoreProvider.of<AppState>(context);
      Product currentProduct = widget.products[_currentProductIndex];
      CartProduct cartProduct = findCartProduct(store.state.cart.products, currentProduct.id);
      int productCartAmount = cartProduct != null ? cartProduct.amount : 0;
      _countFieldController.text = productCartAmount.toString();
    });
  }

  @override
  void dispose() {
    _swiperController.dispose();
    _showCartController.dispose();
    _countFieldController.dispose();
    _countFieldFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, dynamic>(
      converter: (store) => store,
      builder: (context, store) {
        Product currentProduct = widget.products[_currentProductIndex];
        CartProduct cartProduct = findCartProduct(store.state.cart.products, currentProduct.id);
        int productCartAmount = cartProduct != null ? cartProduct.amount : 0;
        String weightText = formatWeight(
          amount: productCartAmount > 0 ? productCartAmount : 1,
          unitStep: currentProduct.unitStep,
          unitFactor: currentProduct.unitFactor,
          unitShortName: currentProduct.unitShortName,
          unitShortDerName: currentProduct.unitShortDerName,
        );
        if (productCartAmount > 0) {
          weightText += '   ' + numToString(cartProduct.cost);
          weightText += FlutterI18n.translate(context, 'common.cart.currency_symbol');
        }
        if (store.state.cart.amount < 1)
          _showCartController.reverse();
        else
          _showCartController.forward();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Theme(
                data: ThemeData(
                  accentColor: ColorsTheme.bg,
                ),
                child: Swiper(
                  controller: _swiperController,
                  itemCount: widget.products.length,
                  loop: widget.products.length > 1,
                  index: _currentProductIndex,
                  onIndexChanged: (i) => _changeIndex(i),
                  viewportFraction: .7,
                  fade: 0,
                  curve: Curves.easeIn,
                  itemBuilder: (BuildContext context, int index) {
                    Product product = widget.products[index];
                    return SingleChildScrollView(
                      controller: widget.scrollController,
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(height: 24),
                            CustomNetworkImage(
                              url: product.imgUrl,
                              width: 240,
                              height: 173,
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
                            SizedBox(height: 36),
                            Container(
                              constraints: BoxConstraints(minHeight: 48),
                              padding: EdgeInsets.symmetric(horizontal: 24),
                              child: Text(
                                product.name,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16.w,
                                  fontWeight: FontWeight.w700,
                                  height: 1.5,
                                ),
                              ),
                            ),
                            if (product.certs != null && product.certs.isNotEmpty)
                              Container(
                                margin: EdgeInsets.only(top: 8),
                                alignment: Alignment.center,
                                child: GestureDetector(
                                  onTap: () => Navigator.pushNamed(
                                    context,
                                    '/product-certs',
                                    arguments: ProductCertsPageArguments(certs: product.certs),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        BvIcons.certification,
                                        size: 24,
                                        color: ColorsTheme.info,
                                      ),
                                      SizedBox(width: 8),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            FlutterI18n.translate(context, 'common.product.certificated_1'),
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 12.w,
                                              letterSpacing: 0.2,
                                              height: 1.33,
                                            ),
                                          ),
                                          Text(
                                            FlutterI18n.translate(context, 'common.product.certificated_2'),
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 12.w,
                                              letterSpacing: 0.2,
                                              height: 1.33,
                                              color: ColorsTheme.info,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            SizedBox(height: 24),
                            _ProductPropText(
                              title: FlutterI18n.translate(context, 'common.product.description'),
                              text: product.description,
                              expandMaxLines: 3,
                            ),
                            _ProductPropText(
                              title: FlutterI18n.translate(context, 'common.product.composition'),
                              text: product.composition,
                            ),
                            _ProductPropText(
                              title: FlutterI18n.translate(context, 'common.product.shelf_life'),
                              text: product.shelfLife,
                            ),
                            _ProductPropText(
                              title: FlutterI18n.translate(context, 'common.product.nutrition'),
                              text: product.nutrition,
                            ),
                            SizedBox(height: 20),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(24, 8, 25, 26),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: ColorsTheme.bg,
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, .1),
                    offset: Offset(0, 2),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    weightText,
                    style: TextStyle(
                      color: ColorsTheme.info,
                      fontSize: 11.w,
                      height: 1.45,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 7),
                  productCartAmount > 0
                      ? Row(
                          children: [
                            SizedBox(
                              width: 40,
                              child: Button(
                                color: ButtonColor.primary,
                                disableShadow: true,
                                height: 40,
                                fontSize: 14.w,
                                label: '-',
                                onTap: () {
                                  _countFieldController.text = (productCartAmount - 1).toString();
                                  store.dispatch(changeCartProductAmount(currentProduct, -1));
                                },
                              ),
                            ),
                            Expanded(
                              child: Container(
                                alignment: Alignment.center,
                                margin: EdgeInsets.symmetric(horizontal: 8),
                                child: CustomTextFormField(
                                  controller: _countFieldController,
                                  focusNode: _countFieldFocusNode,
                                  contentPadding: EdgeInsets.symmetric(vertical: 11, horizontal: 16),
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  textStyle: TextStyle(
                                    fontSize: 14.w,
                                    color: ColorsTheme.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  fillColor: Colors.transparent,
                                  outlineInputBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: ColorsTheme.productSheetInputBorder),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  onTap: () {
                                    if (!_countFieldFocusNode.hasFocus) _countFieldController.text = '';
                                  },
                                  onChanged: (String val) {
                                    if (val.isEmpty) val = '0';
                                    if (val.length > 3) val = val.substring(0, 3);
                                    int newAmount = int.parse(val);
                                    if (val.isEmpty || newAmount == null || newAmount <= 0) {
                                      store.dispatch(changeCartProductAmount(currentProduct, -productCartAmount));
                                      return;
                                    }
                                    int diff = newAmount - productCartAmount;
                                    store.dispatch(changeCartProductAmount(currentProduct, diff));
                                  },
                                  onFieldSubmitted: () {
                                    String val = _countFieldController.text;
                                    if (val.isEmpty || int.parse(val) <= 0) {
                                      store.dispatch(changeCartProductAmount(currentProduct, -productCartAmount));
                                    }
                                  },
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 40,
                              child: Button(
                                color: ButtonColor.primary,
                                disableShadow: true,
                                height: 40,
                                fontSize: 14.w,
                                label: '+',
                                onTap: () {
                                  _countFieldController.text = (productCartAmount + 1).toString();
                                  store.dispatch(changeCartProductAmount(currentProduct, 1));
                                },
                              ),
                            ),
                          ],
                        )
                      : Button(
                          label: numToString(currentProduct.price) +
                              ' ' +
                              FlutterI18n.translate(context, 'common.cart.currency_symbol'),
                          onTap: () => _addToCart(currentProduct),
                          height: 40,
                          color: ButtonColor.primary,
                        ),
                  SizeTransition(
                    sizeFactor: CurvedAnimation(parent: _showCartController, curve: Curves.easeOut),
                    axisAlignment: -1,
                    child: FloatingCartButton(margin: EdgeInsets.only(top: 20)),
                  ),
                  SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Вспомогательный виджет для отрисовки харрактеристик товара
class _ProductPropText extends StatelessWidget {
  _ProductPropText({
    this.horizontal = false,
    @required this.title,
    @required this.text,
    this.expandMaxLines,
  });

  final bool horizontal;
  final String title;
  final String text;
  final int expandMaxLines;

  @override
  Widget build(BuildContext context) {
    final TextStyle titleStyle = TextStyle(
      fontSize: 11.w,
      color: ColorsTheme.textTertiary,
      height: 1.45,
    );
    final TextStyle textStyle = TextStyle(
      fontSize: 12.w,
      color: ColorsTheme.textMain,
      fontWeight: FontWeight.w500,
      height: 1.41,
    );
    if (text == null || text.isEmpty) return Container();
    return Container(
      margin: EdgeInsets.only(bottom: expandMaxLines == null ? 10 : 0),
      child: horizontal
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title + ':', style: titleStyle),
                SizedBox(width: 4),
                Expanded(
                  child: Text(text, style: textStyle),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title + ':', style: titleStyle),
                SizedBox(height: 2),
                ExpandableText(
                  text: text,
                  textStyle: textStyle,
                  maxLines: expandMaxLines,
                ),
              ],
            ),
    );
  }
}
