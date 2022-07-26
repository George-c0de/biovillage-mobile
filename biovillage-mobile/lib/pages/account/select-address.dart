import 'dart:async';
import 'package:biovillage/widgets/appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:biovillage/redux/state/app-state.dart';
import 'package:biovillage/redux/actions/account.dart';
import 'package:biovillage/models/delivery-area.dart';
import 'package:biovillage/models/address.dart';
import 'package:biovillage/pages/account/add-address.dart';
import 'package:biovillage/helpers/colors.dart';
import 'package:biovillage/helpers/coordinates.dart';
import 'package:biovillage/helpers/sentry.dart';
import 'package:biovillage/helpers/net-connection.dart';
import 'package:biovillage/helpers/data-formating.dart';
import 'package:biovillage/theme/bv-icons.dart';
import 'package:biovillage/theme/colors.dart';
import 'package:biovillage/widgets/map.dart';
import 'package:biovillage/widgets/button.dart';
import 'package:biovillage/widgets/account/address-card.dart';
import 'package:biovillage/widgets/delivery-map.dart';
import 'package:biovillage/widgets/form-elements.dart';
import 'package:biovillage/widgets/notifications.dart';

/// Статус поиска подсказок адреса:
enum AdrSearchStatus { emptyQuery, emptyResults, loading, error, ok }

/// Класс для подсказок адресов
class AddressPrediction {
  Point coords;
  String title;
  String subtitle;
  bool isFinalAddress;
  DeliveryArea deliveryArea;

  AddressPrediction({
    @required this.coords,
    @required this.title,
    this.subtitle,
    this.isFinalAddress = false,
    this.deliveryArea,
  });
}

class SelectAddressPageArguments {
  SelectAddressPageArguments({
    this.addOnly = false,
    this.onAddressSelected,
  });
  final bool addOnly;
  final Function onAddressSelected;
}

class SelectAddressPage extends StatefulWidget {
  SelectAddressPage({Key key}) : super(key: key);

  @override
  _SelectAddressPageState createState() => _SelectAddressPageState();
}

class _SelectAddressPageState extends State<SelectAddressPage> with TickerProviderStateMixin {
  final _adrSearchFocusNode = FocusNode();
  SelectAddressPageArguments _args;
  bool _selectMode = false;
  TabController _tabController;
  TabController _searchTabController;
  int _adrSearchThrottleHelper = 0;
  TextEditingController _adrSearchController = TextEditingController();
  AnimationController _adrSearchLoadingController;
  GoogleMapsPlaces _googleMapsPlaces;
  AdrSearchStatus _adrSearchStatus = AdrSearchStatus.emptyQuery;
  List<AddressPrediction> _adrSearchResults;
  bool _search = false;

  /// Поиск подсказок к адресам
  void _searchAddress(String q) async {
    var store = StoreProvider.of<AppState>(context);

    // Увеличиваем троттлинг-счетчик и запомним тек. значение:
    int currentThrottleVal = ++_adrSearchThrottleHelper;
    _search = false;

    // Если длина поискового запроса < 3, то ничего не ищем:
    if (q.length < 3) {
      await _adrSearchLoadingController.reverse();
      setState(() => _adrSearchStatus = AdrSearchStatus.emptyQuery);
      return;
    }

    // Отображаем прелоадер:
    if (_adrSearchStatus != AdrSearchStatus.loading) {
      _adrSearchLoadingController.reset();
      setState(() => _adrSearchStatus = AdrSearchStatus.loading);
      _adrSearchLoadingController.forward();
    }

    // Троттлинг для уменьшения кол-ва запросов к апи гугла:
    await Future.delayed(Duration(milliseconds: 800));
    if (_adrSearchThrottleHelper != currentThrottleVal) return;

    // Отправляем поисковый запрос:
    _search = true;
    PlacesAutocompleteResponse res;
    try {
      Point deliveryMapCenter = store.state.general.deliveryMapCenter;
      res = await _googleMapsPlaces.autocomplete(
        q,
        sessionToken: store.state.account.userSessionToken,
        types: ['address'],
        language: 'ru',
        region: 'ru',
        strictbounds: true,
        location: Location(deliveryMapCenter.latitude, deliveryMapCenter.longitude),
        radius: store.state.general.deliveryMapSearchRadius,
      );
    } catch (e) {
      checkConnect(context);
    }
    // Устанавливаем рез-т:
    if (res == null || res.predictions == null) {
      if (res != null && res.errorMessage != null) {
        print('Google Places Api Error ==> ${res.errorMessage}');
        Sentry.client.captureException(
          exception: 'Google Places Api Error ==> ${res.errorMessage}',
        );
      }
      await _adrSearchLoadingController.reverse();
      setState(() => _adrSearchStatus = AdrSearchStatus.error);
    } else if (res.predictions.isEmpty) {
      await _adrSearchLoadingController.reverse();
      setState(() => _adrSearchStatus = AdrSearchStatus.emptyResults);
    } else {
      // Формируем результаты, запрашиваем координаты и сверяем с зонами доставки:
      List<AddressPrediction> adrSearchResults = [];
      for (Prediction prediction in res.predictions) {
        bool isFinalAddress = prediction.types.contains('street_address') || prediction.types.contains('premise');
        Point coords;
        DeliveryArea deliveryArea;
        if (isFinalAddress) {
          coords = await _getPlaceCoords(prediction.placeId);
          if (coords == null) {
            setState(() => _adrSearchStatus = AdrSearchStatus.error);
            await _adrSearchLoadingController.reverse();
            return;
          }
          for (DeliveryArea area in store.state.general.deliveryAreas) {
            bool isAvailable = checkPointInPolygon(point: coords, pointsList: area.points);
            if (isAvailable) {
              deliveryArea = area;
              break;
            }
          }
        }

        String adrTitle = prediction.structuredFormatting.mainText;
        String adrSubtitle = prediction.structuredFormatting.secondaryText;

        // Проверим, есть ли улица, если нет, то подставим нас. пункт:
        if (isFinalAddress && prediction.terms != null && prediction.terms[0] != null) {
          if (prediction.terms[0].value == adrTitle && prediction.terms[1] != null) {
            adrTitle = prediction.terms[1].value + ', ' + prediction.terms[0].value;
          }
        }

        if (adrTitle.contains('Null')) adrTitle = adrTitle.replaceAll('Null', '').trim();
        if (adrSubtitle.contains('Null')) adrSubtitle = adrSubtitle.replaceAll('Null', '').trim();

        adrSearchResults.add(
          AddressPrediction(
            title: adrTitle,
            subtitle: adrSubtitle,
            isFinalAddress: isFinalAddress,
            coords: coords,
            deliveryArea: deliveryArea,
          ),
        );
      }
      if (_search) {
        await _adrSearchLoadingController.reverse();
        setState(() {
          _adrSearchStatus = AdrSearchStatus.ok;
          _adrSearchResults = adrSearchResults;
        });
      }
    }
  }

  /// Получение координат объекта по его id
  Future<Point> _getPlaceCoords(String placeId) async {
    var store = StoreProvider.of<AppState>(context);
    PlacesDetailsResponse detail;
    try {
      detail = await _googleMapsPlaces.getDetailsByPlaceId(
        placeId,
        sessionToken: store.state.account.userSessionToken,
        fields: ['geometry/location'],
      );
    } catch (e) {
      checkConnect(context);
    }
    if (detail == null || detail.status != 'OK') {
      if (detail != null && detail.errorMessage != null) {
        print('Google Places Api Error ==> ${detail.errorMessage}');
        Sentry.client.captureException(
          exception: 'Google Places Api Error ==> ${detail.errorMessage}',
        );
      }
      setState(() => _adrSearchStatus = AdrSearchStatus.error);
      await _adrSearchLoadingController.reverse();
      return null;
    } else {
      return Point(latitude: detail.result.geometry.location.lat, longitude: detail.result.geometry.location.lng);
    }
  }

  /// Переключение на таб с картой зон доставок:
  void _showDeliveryAreas() async {
    FocusScope.of(context).unfocus();
    await Future.delayed(Duration(milliseconds: 200));
    _searchTabController.animateTo(0);
  }

  /// Клик по подсказке адреса
  void _tapAddressPrediction(AddressPrediction prediction) async {
    // Если это конечный адрес, то перенаправляем пользователя:
    if (prediction.isFinalAddress) {
      if (prediction.deliveryArea != null) {
        _saveAddress(prediction);
      } else {
        showToast(FlutterI18n.translate(context, 'common.delivery.delivery_unavailable'));
      }
    } else {
      // Если адрес неполный, то просто подставим его в инпут поиска:
      String newQuery = prediction.subtitle + ', ' + prediction.title + ' ';
      if (_adrSearchController.text == newQuery) {
        // Если был кликнут та же самая подсказка, то покажем тост:
        showToast(FlutterI18n.translate(context, 'common.delivery.must_enter_exact_address'));
      } else {
        _adrSearchController.text = newQuery;
      }
      // Управление фокусом и клавиатурой:
      if (MediaQuery.of(context).viewInsets.bottom == 0) {
        FocusScope.of(context).unfocus();
        await Future.delayed(Duration.zero);
      }
      FocusScope.of(context).requestFocus(_adrSearchFocusNode);
      // Поставим курсор в конец поискового запроса:
      await Future.delayed(Duration(milliseconds: 50));
      _adrSearchController.selection = TextSelection.fromPosition(TextPosition(
        offset: _adrSearchController.text.length,
      ));
    }
  }

  /// Переход на страницу с формой добавления адреса
  void _saveAddress(AddressPrediction prediction) async {
    var store = StoreProvider.of<AppState>(context);
    if (store.state.account.userAuth) {
      Navigator.pushNamed(
        context,
        '/account/add-address',
        arguments: AddAddressPageArguments(
          coords: prediction.coords,
          address: prediction.title,
          deliveryPrice: prediction.deliveryArea.price,
          deliveryFreeSum: prediction.deliveryArea.deliveryFreeSum,
          city: prediction.subtitle,
          onAddressAdded: _args != null ? _args.onAddressSelected : null,
        ),
      );
    } else {
      // Если пользователь неавторизован то сохраним адрес как временный:
      store.dispatch(selectAddress(Address(
        coords: prediction.coords,
        address: prediction.title,
        city: prediction.subtitle,
        deliveryPrice: prediction.deliveryArea.price,
        deliveryFreeSum: prediction.deliveryArea.deliveryFreeSum,
        isTempAddress: true,
      )));
      Navigator.pop(context);
      if (_args != null && _args.onAddressSelected != null) _args.onAddressSelected();
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 2, initialIndex: 0);
    _searchTabController = TabController(vsync: this, length: 2, initialIndex: 0);
    _adrSearchLoadingController = AnimationController(duration: Duration(milliseconds: 300), vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      var store = StoreProvider.of<AppState>(context);
      var userInfo = store.state.account.userInfo;
      setState(() {
        _args = ModalRoute.of(context).settings.arguments;
        _selectMode = (_args == null || !_args.addOnly) && userInfo != null && userInfo.addresses.isNotEmpty;
      });
      if (!_selectMode) _tabController.animateTo(1);

      // Устанавливаем ключ гугл карт из редакса:
      _googleMapsPlaces = GoogleMapsPlaces(apiKey: store.state.general.googleMapsKey);
    });

    // Если инпут зафокушен, то перекидываем на таб с подсказками адресов:
    _adrSearchFocusNode.addListener(() {
      if (_adrSearchFocusNode.hasFocus) _searchTabController.animateTo(1);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
    _searchTabController.dispose();
    _googleMapsPlaces.dispose();
    _adrSearchFocusNode.dispose();
    _adrSearchController.dispose();
    _adrSearchLoadingController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, dynamic>(
      converter: (store) => store,
      builder: (context, store) {
        return Scaffold(
          appBar: CustomAppBar(title: FlutterI18n.translate(context, 'common.delivery.choose_address')),
          body: SafeArea(
            child: TabBarView(
              physics: NeverScrollableScrollPhysics(),
              controller: _tabController,
              children: [
                /// Tab 0: Select address
                SingleChildScrollView(
                  child: store.state.account.userInfo != null
                      ? Container(
                          padding: EdgeInsets.fromLTRB(16, 0, 16, 32),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SizedBox(height: 24),
                              for (int i = 0; i < store.state.account.userInfo.addresses.length; i++)
                                AddressCard(
                                  selectable: true,
                                  address: store.state.account.userInfo.addresses[i],
                                  onSelect: (address) async {
                                    await Future.delayed(Duration(milliseconds: 300));
                                    Navigator.pop(context);
                                    if (_args != null && _args.onAddressSelected != null) _args.onAddressSelected();
                                  },
                                ),
                              Button(
                                onTap: () => _tabController.animateTo(1),
                                label: FlutterI18n.translate(context, 'common.account.add_address'),
                                color: ButtonColor.primary,
                                outlined: true,
                              ),
                            ],
                          ),
                        )
                      : Container(),
                ),

                /// Tab 1: Search address
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: CustomTextFormField(
                        controller: _adrSearchController,
                        minLines: 1,
                        maxLines: 4,
                        focusNode: _adrSearchFocusNode,
                        onChanged: (value) => _searchAddress(value),
                        prefixIcon: Icon(BvIcons.search, color: ColorsTheme.accent, size: 18),
                        hintStyle:
                            TextStyle(color: ColorsTheme.textSecondary, fontWeight: FontWeight.w600, fontSize: 13.w),
                        textStyle: TextStyle(color: ColorsTheme.textMain, fontWeight: FontWeight.w600, fontSize: 13.w),
                        hintText: FlutterI18n.translate(context, 'common.delivery.enter_address'),
                      ),
                    ),
                    SizedBox(height: 16),
                    Expanded(
                      child: RotatedBox(
                        quarterTurns: -1,
                        child: TabBarView(
                          physics: NeverScrollableScrollPhysics(),
                          controller: _searchTabController,
                          children: [
                            /// Tab 0: Delivery Map
                            RotatedBox(
                              quarterTurns: 1,
                              child: DeliveryMap(
                                scrollable: true,
                                mapHeight: MediaQuery.of(context).size.height * 0.5,
                              ),
                            ),

                            /// Tab 1: Address search
                            RotatedBox(
                              quarterTurns: 1,
                              child: Container(
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: SingleChildScrollView(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.stretch,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            // Загрузка подсказок адресов:
                                            if (_adrSearchStatus == AdrSearchStatus.loading)
                                              Container(
                                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                child: ScaleTransition(
                                                  scale: CurvedAnimation(
                                                    parent: _adrSearchLoadingController,
                                                    curve: Curves.easeOut,
                                                  ),
                                                  child: CupertinoActivityIndicator(radius: 12),
                                                ),
                                              ),

                                            // Пустой поисковый запрос:
                                            if (_adrSearchStatus == AdrSearchStatus.emptyQuery)
                                              Container(
                                                padding: EdgeInsets.all(16),
                                                child: Text(
                                                  FlutterI18n.translate(context, 'common.delivery.start_enter_address'),
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: 13.w,
                                                    color: ColorsTheme.textTertiary,
                                                  ),
                                                ),
                                              ),

                                            // Ошибка гугл-апи при поиске подсказок адресов:
                                            if (_adrSearchStatus == AdrSearchStatus.error)
                                              Container(
                                                padding: EdgeInsets.all(16),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      FlutterI18n.translate(
                                                          context, 'common.delivery.search_address_error'),
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(
                                                        fontSize: 13.w,
                                                        color: ColorsTheme.error,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                            // Пустой рез-т поиска:
                                            if (_adrSearchStatus == AdrSearchStatus.emptyResults)
                                              Container(
                                                padding: EdgeInsets.all(16),
                                                child: Text(
                                                  FlutterI18n.translate(
                                                      context, 'common.delivery.no_address_predictions'),
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: 13.w,
                                                    color: ColorsTheme.error,
                                                  ),
                                                ),
                                              ),

                                            // Список подсказок адресов:
                                            if (_adrSearchStatus == AdrSearchStatus.ok)
                                              for (AddressPrediction prediction in _adrSearchResults)
                                                InkWell(
                                                  onTap: () => _tapAddressPrediction(prediction),
                                                  splashColor: ColorsTheme.primary.withOpacity(.4),
                                                  highlightColor: ColorsTheme.primary.withOpacity(.3),
                                                  child: Container(
                                                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                                      children: [
                                                        Row(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Expanded(
                                                              child: Text(
                                                                prediction.title,
                                                                style: TextStyle(
                                                                    fontSize: 13.w, fontWeight: FontWeight.w600),
                                                              ),
                                                            ),
                                                            if (prediction.deliveryArea != null)
                                                              Container(
                                                                margin: EdgeInsets.only(left: 10),
                                                                child: Text(
                                                                  '${prediction.deliveryArea.price}' +
                                                                      FlutterI18n.translate(
                                                                          context, 'common.cart.currency_symbol'),
                                                                  style: TextStyle(
                                                                    fontSize: 13.w,
                                                                    color: ColorsTheme.textTertiary,
                                                                    fontWeight: FontWeight.w600,
                                                                  ),
                                                                ),
                                                              ),
                                                          ],
                                                        ),
                                                        if (prediction.subtitle != null)
                                                          Container(
                                                            padding: EdgeInsets.only(top: 6),
                                                            child: Text(
                                                              prediction.subtitle,
                                                              style: TextStyle(
                                                                  fontSize: 12.w, color: ColorsTheme.textTertiary),
                                                            ),
                                                          ),
                                                        if (prediction.deliveryArea != null &&
                                                            prediction.deliveryArea.deliveryFreeSum != null)
                                                          Container(
                                                            margin: EdgeInsets.only(top: 6),
                                                            child: Text(
                                                              FlutterI18n.translate(
                                                                      context, 'common.cart.free_delivery_from') +
                                                                  ' ' +
                                                                  numToString(prediction.deliveryArea.deliveryFreeSum) +
                                                                  FlutterI18n.translate(
                                                                      context, 'common.cart.currency_symbol'),
                                                              style: TextStyle(
                                                                fontSize: 12.w,
                                                                color: ColorsTheme.textTertiary,
                                                              ),
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Container(
                                      color: ColorsTheme.bg,
                                      height: 48,
                                      child: Stack(
                                        children: [
                                          Positioned(
                                            bottom: 0,
                                            left: 0,
                                            right: 0,
                                            child: Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                onTap: () => _showDeliveryAreas(),
                                                splashColor: ColorsTheme.primary.withOpacity(.4),
                                                highlightColor: ColorsTheme.primary.withOpacity(.3),
                                                child: Container(
                                                  height: 48,
                                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                                  decoration: BoxDecoration(
                                                    border: Border(top: BorderSide(color: darken(ColorsTheme.bg, .04))),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          FlutterI18n.translate(
                                                              context, 'common.delivery.delivery_areas'),
                                                          style: TextStyle(
                                                            fontSize: 13.w,
                                                            fontWeight: FontWeight.w600,
                                                            color: ColorsTheme.textTertiary,
                                                          ),
                                                        ),
                                                      ),
                                                      Icon(
                                                        BvIcons.chevron_down,
                                                        color: ColorsTheme.textTertiary,
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
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
