import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:biovillage/redux/state/app-state.dart';
import 'package:biovillage/models/prod-category.dart';
import 'package:biovillage/helpers/catalog.dart';
import 'package:biovillage/widgets/appbar.dart';
import 'package:biovillage/widgets/navbar.dart';
import 'package:biovillage/widgets/search-input.dart';
import 'package:biovillage/widgets/main-slider.dart';
import 'package:biovillage/widgets/drawer/drawer.dart';
import 'package:biovillage/widgets/catalog/filter-tags.dart';
import 'package:biovillage/widgets/catalog/categories-grid.dart';
import 'package:biovillage/widgets/cart/floating-cart-button.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DrawerMode _drawerMode;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: CustomAppBar(
          isHome: true,
          showAddress: true,
          showBonuses: true,
          onOpenDrawer: (DrawerMode drawerMode) => setState(() {
            _drawerMode = drawerMode;
          }),
        ),
        drawer: CustomDrawer(drawerMode: _drawerMode),
        drawerEdgeDragWidth: 0,
        body: StoreConnector<AppState, dynamic>(
          converter: (store) => store,
          builder: (context, store) {
            List<ProdCategory> _filteredCategories =
                filterCategories(store.state.catalog.categories, store.state.catalog.tags);
            return SafeArea(
              child: CustomScrollView(
                slivers: <Widget>[
                  /// Slider, search, filters:
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        /// Margin:
                        SizedBox(height: 8),

                        /// Home slider:
                        if (store.state.general.homeSlider != null && store.state.general.homeSlider.isNotEmpty)
                          MainSlider(slides: store.state.general.homeSlider),

                        /// Margin:
                        SizedBox(height: 16),

                        /// Search:
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Hero(
                            tag: 'search',
                            child: SearchInput(isLink: true),
                          ),
                        ),

                        /// Filters Chips:
                        FilterTags(),
                      ],
                    ),
                  ),

                  /// Categories grid:
                  CategoriesGrid(categories: _filteredCategories),

                  /// Margin:
                  SliverToBoxAdapter(child: SizedBox(height: 64)),
                ],
              ),
            );
          },
        ),
        floatingActionButton: FloatingCartButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: CustomNavbar(
          onOpenDrawer: (DrawerMode drawerMode) => setState(() {
            _drawerMode = drawerMode;
          }),
        ),
      ),
    );
  }
}
