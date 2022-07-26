import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:biovillage/redux/state/app-state.dart';
import 'package:biovillage/models/prod-category.dart';
import 'package:biovillage/models/product.dart';
import 'package:biovillage/api-client/catalog.dart';
import 'package:biovillage/helpers/net-connection.dart';
import 'package:biovillage/widgets/appbar.dart';
import 'package:biovillage/widgets/drawer/drawer.dart';
import 'package:biovillage/widgets/navbar.dart';
import 'package:biovillage/widgets/preloader.dart';
import 'package:biovillage/widgets/search-input.dart';
import 'package:biovillage/widgets/catalog/categories-list.dart';
import 'package:biovillage/widgets/catalog/categories-grid.dart';
import 'package:biovillage/widgets/catalog/products-grid.dart';
import 'package:biovillage/widgets/cart/floating-cart-button.dart';

/// Статус поиска:
enum SearchStatus { emptyQuery, emptyResults, loading, ok }

class SearchPage extends StatefulWidget {
  SearchPage({Key key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with TickerProviderStateMixin {
  final FocusNode _inputFocusNode = FocusNode();
  AnimationController _loadingController;
  SearchStatus _searchStatus = SearchStatus.emptyQuery;
  int _throttleHelper = 0;
  List<ProdCategory> _resultCategories = [];
  List<Product> _resultProducts = [];

  void search(String value) async {
    // Увеличиваем троттлинг-счетчик и запомним тек. занчение:
    int currentThrottleVal = ++_throttleHelper;

    // Если длина поискового запроса < 3, то ничего не ищем:
    if (value.length < 3) {
      await _loadingController.reverse();
      setState(() => _searchStatus = SearchStatus.emptyQuery);
      return;
    }

    // Включаем прелоадер:
    if (_searchStatus != SearchStatus.loading) {
      _loadingController.reset();
      setState(() => _searchStatus = SearchStatus.loading);
      _loadingController.forward();
    }

    // Троттлинг для уменьшения кол-ва запросов к апи гугла:
    await Future.delayed(Duration(milliseconds: 800));
    if (_throttleHelper != currentThrottleVal) return;

    var result = await ApiClientCatalog.catalogSearch(value);
    if (result == null) {
      checkConnect(context);
      await _loadingController.reverse();
      setState(() => _searchStatus = SearchStatus.emptyQuery);
      return;
    }
    setState(() {
      _resultCategories = result['categories'];
      _resultProducts = result['products'];
    });
    if (_resultCategories.isEmpty && _resultProducts.isEmpty) {
      await _loadingController.reverse();
      setState(() => _searchStatus = SearchStatus.emptyResults);
    } else {
      await _loadingController.reverse();
      setState(() => _searchStatus = SearchStatus.ok);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(duration: Duration(milliseconds: 300), vsync: this);
    // Когда виджеты отрисованы фокусим инпут поиска:
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Timer(Duration(milliseconds: 800), () {
        try {
          FocusScope.of(context).requestFocus(_inputFocusNode);
        } catch (e) {
          // Пользователь покинул страницу раньше. Предупреждение некритично
        }
      });
    });
  }

  @override
  void dispose() {
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(showAddress: true, showBonuses: true),
      drawer: CustomDrawer(),
      drawerEdgeDragWidth: 0,
      body: StoreConnector<AppState, dynamic>(
        converter: (store) => store,
        builder: (context, store) => SafeArea(
          child: CustomScrollView(
            slivers: <Widget>[
              /// Search input:
              SliverToBoxAdapter(
                child: Container(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Hero(
                    tag: 'search',
                    child: SearchInput(
                      focusNode: _inputFocusNode,
                      onChanged: (value) => search(value),
                    ),
                  ),
                ),
              ),

              /// Preloader:
              if (_searchStatus == SearchStatus.loading)
                SliverFillRemaining(
                  child: ScaleTransition(
                    scale: CurvedAnimation(parent: _loadingController, curve: Curves.easeOut),
                    child: CircularLoader(),
                  ),
                ),

              /// Empty Result:
              if (_searchStatus == SearchStatus.emptyResults)
                SliverToBoxAdapter(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    margin: EdgeInsets.only(bottom: 18),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      FlutterI18n.translate(context, 'common.search.no_results'),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12.w, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),

              /// Categories list:
              if (_searchStatus == SearchStatus.emptyQuery || _searchStatus == SearchStatus.emptyResults)
                CategoriesList(categories: store.state.catalog.categories),

              /// Categories result:
              if (_searchStatus == SearchStatus.ok && _resultCategories.isNotEmpty)
                CategoriesGrid(categories: _resultCategories),

              /// Products result:
              if (_searchStatus == SearchStatus.ok && _resultProducts.isNotEmpty)
                ProductsGrid(
                  sliverPadding: EdgeInsets.fromLTRB(16, 16, 16, 32),
                  products: _resultProducts,
                ),

              /// Margin:
              SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingCartButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: CustomNavbar(),
    );
  }
}
