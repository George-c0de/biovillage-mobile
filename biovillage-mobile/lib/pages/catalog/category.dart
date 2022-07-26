import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
// import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:biovillage/redux/state/app-state.dart';
import 'package:biovillage/redux/actions/catalog.dart';
import 'package:biovillage/models/product.dart';
import 'package:biovillage/models/prod-category.dart';
// import 'package:biovillage/theme/bv-icons.dart';
import 'package:biovillage/theme/colors.dart';
// import 'package:biovillage/helpers/colors.dart';
import 'package:biovillage/helpers/catalog.dart';
import 'package:biovillage/helpers/net-connection.dart';
import 'package:biovillage/widgets/appbar.dart';
import 'package:biovillage/widgets/navbar.dart';
import 'package:biovillage/widgets/search-input.dart';
import 'package:biovillage/widgets/drawer/drawer.dart';
// import 'package:biovillage/widgets/catalog/product-card.dart';
import 'package:biovillage/widgets/catalog/products-grid.dart';
import 'package:biovillage/widgets/catalog/filter-tags.dart';
import 'package:biovillage/widgets/cart/floating-cart-button.dart';

class CategoryPageArguments {
  CategoryPageArguments({@required this.category});
  final ProdCategory category;
}

class CategoryPage extends StatefulWidget {
  CategoryPage({Key key}) : super(key: key);
  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  ScrollController _productSliderController;

  /// Получение списка товаров
  void _getProducts(int categoryId) {
    var store = StoreProvider.of<AppState>(context);
    store.dispatch(getProducts(
      categoryId,
      onFailed: () async {
        checkConnect(context);
        await Future.delayed(Duration(milliseconds: 1500));
        _getProducts(categoryId);
      },
    ));
  }

  @override
  void initState() {
    super.initState();
    _productSliderController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Подгружаем категории:
      CategoryPageArguments args = ModalRoute.of(context).settings.arguments;
      await Future.delayed(Duration(milliseconds: 500));
      _getProducts(args.category.id);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _productSliderController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final CategoryPageArguments args = ModalRoute.of(context).settings.arguments;
    final ProdCategory category = args.category;
    return Scaffold(
      appBar: CustomAppBar(showAddress: true, showBonuses: true),
      drawer: CustomDrawer(),
      drawerEdgeDragWidth: 0,
      body: StoreConnector<AppState, dynamic>(
        converter: (store) => store,
        builder: (context, store) {
          List<Product> products = store.state.catalog.products[category.id];
          List<Product> filteredProducts = filterProducts(products, store.state.catalog.tags);
          // TODO: Временно прячем промотовары со страниц категорий
          // List<Product> filteredPromoProducts = filterProducts(
          //   store.state.catalog.products[-1],
          //   store.state.catalog.tags,
          // );
          return SafeArea(
            child: CustomScrollView(
              slivers: <Widget>[
                /// Margin:
                SliverToBoxAdapter(child: SizedBox(height: 8)),

                /// Search:
                SliverToBoxAdapter(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: SearchInput(isLink: true),
                  ),
                ),

                /// Filters chips:
                SliverToBoxAdapter(
                  child: FilterTags(),
                ),

                /// Margin:
                SliverToBoxAdapter(child: SizedBox(height: 4)),

                /// Page Title:
                SliverToBoxAdapter(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      category.name.replaceAll('\n', ''),
                      style: TextStyle(
                        color: ColorsTheme.textMain,
                        fontSize: 18.w,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.1,
                        height: 1.3,
                      ),
                    ),
                  ),
                ),

                /// Margin:
                SliverToBoxAdapter(child: SizedBox(height: 8)),

                /// Preloader:
                // TODO: Временно прячем промотовары со страниц категорий
                // if (filteredPromoProducts == null && category.id != -1 || filteredProducts == null)
                if (filteredProducts == null)
                  SliverToBoxAdapter(
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 60),
                      alignment: Alignment.center,
                      child: CupertinoActivityIndicator(
                        radius: 12,
                      ),
                    ),
                  ),

                // TODO: Временно прячем промотовары со страниц категорий
                /// Promo Products slider:
                // if (category.id != -1 &&
                //     filteredPromoProducts != null &&
                //     filteredProducts != null &&
                //     filteredPromoProducts.isNotEmpty)
                //   SliverToBoxAdapter(
                //     child: Container(
                //       decoration: BoxDecoration(
                //         gradient: LinearGradient(
                //           begin: Alignment.topCenter,
                //           end: Alignment.bottomCenter,
                //           colors: [
                //             ColorsTheme.bg,
                //             darken(ColorsTheme.bg, .03),
                //           ],
                //         ),
                //       ),
                //       child: Stack(
                //         children: [
                //           Theme(
                //             data: ThemeData(
                //               accentColor: lighten(ColorsTheme.primary, .2),
                //             ),
                //             child: SingleChildScrollView(
                //               controller: _productSliderController,
                //               scrollDirection: Axis.horizontal,
                //               padding: EdgeInsets.only(left: 16, right: 16, top: 52, bottom: 56),
                //               child: Stack(
                //                 children: [
                //                   Wrap(
                //                     spacing: 8,
                //                     children: [
                //                       for (Product product in filteredPromoProducts)
                //                         ProductCard(
                //                           product: product,
                //                           specialProductGroup: filteredPromoProducts,
                //                         )
                //                     ],
                //                   ),
                //                 ],
                //               ),
                //             ),
                //           ),
                //           Positioned(
                //             top: 0,
                //             left: 0,
                //             right: 0,
                //             child: Material(
                //               color: Colors.transparent,
                //               child: Container(
                //                 padding: EdgeInsets.symmetric(horizontal: 16),
                //                 child: Row(
                //                   mainAxisAlignment: MainAxisAlignment.center,
                //                   children: [
                //                     Expanded(
                //                       child: Text(
                //                         FlutterI18n.translate(context, 'common.promo_products').toUpperCase(),
                //                         style: TextStyle(
                //                           color: ColorsTheme.primary,
                //                           fontSize: 11.w,
                //                           fontWeight: FontWeight.w600,
                //                           height: 1.45,
                //                         ),
                //                       ),
                //                     ),
                //                     if (filteredPromoProducts.length > 3)
                //                       Row(
                //                         children: [0, 1].map((i) {
                //                           return IconButton(
                //                             icon: Icon(i == 0 ? BvIcons.arrow_left : BvIcons.arrow_right),
                //                             iconSize: 14,
                //                             color: ColorsTheme.primary,
                //                             padding: EdgeInsets.only(right: 6),
                //                             splashRadius: 22,
                //                             splashColor: ColorsTheme.primary.withOpacity(.4),
                //                             highlightColor: ColorsTheme.primary.withOpacity(.2),
                //                             onPressed: () {
                //                               double cardWidth = (MediaQuery.of(context).size.width - 32) / 3 - 8;
                //                               int scrolledCardsAmount =
                //                                   ((_productSliderController.offset - 16) / cardWidth).floor();
                //                               double offset;
                //                               i == 0
                //                                   ? offset = scrolledCardsAmount * (cardWidth + 8) - 3 * (cardWidth + 8)
                //                                   : offset = (scrolledCardsAmount + 3) * (cardWidth + 8);
                //                               _productSliderController.animateTo(
                //                                 offset - 4,
                //                                 duration: Duration(milliseconds: 500),
                //                                 curve: Curves.easeInOut,
                //                               );
                //                             },
                //                           );
                //                         }).toList(),
                //                       ),
                //                   ],
                //                 ),
                //               ),
                //             ),
                //           ),
                //           Positioned(
                //             bottom: 3,
                //             left: 0,
                //             right: 0,
                //             child: Container(
                //               alignment: Alignment.center,
                //               padding: EdgeInsets.symmetric(horizontal: 16),
                //               child: MaterialButton(
                //                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                //                 padding: EdgeInsets.only(left: 16, right: 32),
                //                 height: 32,
                //                 onPressed: () => Navigator.pushNamed(
                //                   context,
                //                   '/category',
                //                   arguments: CategoryPageArguments(
                //                     category: store.state.catalog.categories[0],
                //                   ),
                //                 ),
                //                 splashColor: ColorsTheme.accent.withOpacity(.3),
                //                 highlightColor: ColorsTheme.accent.withOpacity(.15),
                //                 child: Row(
                //                   mainAxisAlignment: MainAxisAlignment.center,
                //                   children: [
                //                     Text(
                //                       FlutterI18n.translate(context, 'common.view_all_promo_products'),
                //                       style: TextStyle(
                //                         fontSize: 11.w,
                //                         fontWeight: FontWeight.w500,
                //                         letterSpacing: 0.2,
                //                         color: ColorsTheme.accent,
                //                       ),
                //                     ),
                //                     SizedBox(width: 8),
                //                     Icon(BvIcons.long_arrow_right, size: 8, color: ColorsTheme.accent),
                //                   ],
                //                 ),
                //               ),
                //             ),
                //           )
                //         ],
                //       ),
                //     ),
                //   ),

                // /// Margin:
                SliverToBoxAdapter(child: SizedBox(height: 16)),

                /// Products grid:
                // TODO: Временно прячем промотовары со страниц категорий
                // if (filteredPromoProducts != null && filteredProducts != null)
                if (filteredProducts != null)
                  ProductsGrid(
                    products: filteredProducts,
                  ),

                /// Margin:
                SliverToBoxAdapter(child: SizedBox(height: 64)),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingCartButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: CustomNavbar(),
    );
  }
}
