import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:biovillage/pages/splash-screen.dart';
import 'package:biovillage/redux/state/app-state.dart';
import 'package:biovillage/redux/reducers/app-reducers.dart';
import 'package:biovillage/helpers/colors.dart';
import 'package:biovillage/helpers/sentry.dart';
import 'package:biovillage/helpers/apps-flyer.dart';
import 'package:biovillage/helpers/system-elements.dart';
import 'package:biovillage/theme/colors.dart';

// Routes:
import 'package:biovillage/pages/home.dart';
import 'package:biovillage/pages/contacts.dart';
import 'package:biovillage/pages/about-company.dart';
import 'package:biovillage/pages/payment-delivery.dart';
import 'package:biovillage/pages/requisites.dart';
import 'package:biovillage/pages/search.dart';
import 'package:biovillage/pages/catalog/category.dart';
import 'package:biovillage/pages/catalog/product-certs.dart';
import 'package:biovillage/pages/cart/cart-step-1.dart';
import 'package:biovillage/pages/cart/cart-step-2.dart';
import 'package:biovillage/pages/cart/cart-step-3.dart';
import 'package:biovillage/pages/cart/cart-success.dart';
import 'package:biovillage/pages/cart/delivery-intervals.dart';
import 'package:biovillage/pages/account/settings.dart';
import 'package:biovillage/pages/account/orders-history.dart';
import 'package:biovillage/pages/account/order-details.dart';
import 'package:biovillage/pages/account/bonuses.dart';
import 'package:biovillage/pages/account/payment-methods.dart';
import 'package:biovillage/pages/account/add-address.dart';
import 'package:biovillage/pages/account/select-address.dart';
import 'package:biovillage/pages/inapp-browser.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Запрещаем горизонтальную ориентацию:
  SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
  );
  // Задаем тему для системного навбара:
  setNavBarTheme(null, NavBarTheme.black);
  // Инициализация словарей:
  final FlutterI18nDelegate flutterI18nDelegate = FlutterI18nDelegate(
    translationLoader: NamespaceFileTranslationLoader(
      namespaces: ['common'],
      useCountryCode: false,
      fallbackDir: 'ru',
      basePath: 'assets/i18n',
      forcedLocale: Locale('ru'),
    ),
    missingTranslationHandler: (key, locale) {
      print('--- Missing Key: $key, languageCode: ${locale.languageCode}');
    },
  );

  // Подключение .env:
  await DotEnv().load('.env');

  // Инициализация AppsFlyer:
  appsflyerSdk.initSdk(
    registerConversionDataCallback: true,
    registerOnAppOpenAttributionCallback: true,
    registerOnDeepLinkingCallback: true,
  );

  // Sentry для наблюдения за ошибками:
  FlutterError.onError = (details, {bool forceReport = false}) async {
    try {
      await Sentry.client.captureException(
        exception: details.exception,
        stackTrace: details.stack,
      );
    } catch (e) {
      print('Sending report to sentry.io failed: $e');
    } finally {
      FlutterError.dumpErrorToConsole(details, forceReport: forceReport);
    }
  };

  // Запуск приложения с отслеживанием ошибок:
  runZonedGuarded(
    () => runApp(MyApp(flutterI18nDelegate)),
    (Object error, StackTrace stackTrace) async {
      try {
        Sentry.client.captureException(
          exception: error,
          stackTrace: stackTrace,
        );
        print('Error sent to sentry.io: $error');
        print(stackTrace);
      } catch (e) {
        print('Sending report to sentry.io failed: $e');
        print('Original error: $error');
      }
    },
  );

  // Проверка на наличие обновлений и обновление:
  InAppUpdate.checkForUpdate().then((info) {
    // Если обновление доступно, то обновляемся:
    if (info?.updateAvailability == UpdateAvailability.updateAvailable)
      InAppUpdate.performImmediateUpdate().catchError((e) {
        Sentry.client.captureException(exception: e);
      });
  }).catchError((e) {
    print('Не удалось проверить наличие обновлений: $e');
  });
}

class MyApp extends StatelessWidget {
  MyApp(this.flutterI18nDelegate);
  final FlutterI18nDelegate flutterI18nDelegate;

  final Store store = Store<AppState>(
    appStateReducer,
    initialState: AppState.initialState(),
    middleware: [thunkMiddleware],
  );

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addObserver(
      WidgetBindingHandler(
        onResumed: () {
          // Добавляем обсервер для фикса бага с изменением цветов навбара:
          setNavBarTheme(null, store.state.general.navBarTheme);
          return;
        },
      ),
    );

    return new StoreProvider<AppState>(
      store: store,
      child: OverlaySupport(
        child: ScreenUtilInit(
          designSize: Size(375, 812),
          builder: () => MaterialApp(
            title: 'BioVillage',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              textTheme: TextTheme(bodyText2: TextStyle(fontSize: 14.w)),
              backgroundColor: ColorsTheme.bg,
              scaffoldBackgroundColor: ColorsTheme.bg,
              visualDensity: VisualDensity.adaptivePlatformDensity,
              brightness: Brightness.light,
              accentColor: lighten(ColorsTheme.accent, .4),
              primaryColor: ColorsTheme.primary,
              fontFamily: 'Montserrat',
              pageTransitionsTheme: PageTransitionsTheme(
                builders: {
                  TargetPlatform.android: CupertinoPageTransitionsBuilder(),
                  TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
                },
              ),
            ),
            localizationsDelegates: [
              flutterI18nDelegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate
            ],
            supportedLocales: [
              const Locale('ru'),
            ],
            home: SplashScreen(),
            onGenerateRoute: (RouteSettings settings) {
              switch (settings.name) {
                case '/home':
                  return CupertinoPageRoute(builder: (_) => HomePage(), settings: settings);
                case '/contacts':
                  return CupertinoPageRoute(builder: (_) => ContactsPage(), settings: settings);
                case '/about-company':
                  return CupertinoPageRoute(builder: (_) => AboutCompanyPage(), settings: settings);
                case '/payment-delivery':
                  return CupertinoPageRoute(builder: (_) => PaymentDeliveryPage(), settings: settings);
                case '/requisites':
                  return CupertinoPageRoute(builder: (_) => RequisitesPage(), settings: settings);
                case '/search':
                  return CupertinoPageRoute(builder: (_) => SearchPage(), settings: settings);
                case '/category':
                  return CupertinoPageRoute(builder: (_) => CategoryPage(), settings: settings);
                case '/product-certs':
                  return CupertinoPageRoute(builder: (_) => ProductCertsPage(), settings: settings);
                case '/cart-step-1':
                  return CupertinoPageRoute(builder: (_) => CartPageStep1(), settings: settings);
                case '/cart-step-2':
                  return CupertinoPageRoute(builder: (_) => CartPageStep2(), settings: settings);
                case '/cart-step-3':
                  return CupertinoPageRoute(builder: (_) => CartPageStep3(), settings: settings);
                case '/cart-success':
                  return CupertinoPageRoute(builder: (_) => CartSuccessPage(), settings: settings);
                case '/delivery-intervals':
                  return CupertinoPageRoute(builder: (_) => DeliveryIntervalsPage(), settings: settings);
                case '/account/settings':
                  return CupertinoPageRoute(builder: (_) => SettingsPage(), settings: settings);
                case '/account/orders-history':
                  return CupertinoPageRoute(builder: (_) => OrdersHistoryPage(), settings: settings);
                case '/account/order-details':
                  return CupertinoPageRoute(builder: (_) => OrderDetailsPage(), settings: settings);
                case '/account/bonuses':
                  return CupertinoPageRoute(builder: (_) => BonusesPage(), settings: settings);
                case '/account/payment':
                  return CupertinoPageRoute(builder: (_) => PaymentMethodsPage(), settings: settings);
                case '/account/add-address':
                  return CupertinoPageRoute(builder: (_) => AddAddressPage(), settings: settings);
                case '/account/select-address':
                  return CupertinoPageRoute(builder: (_) => SelectAddressPage(), settings: settings);
                case '/inapp-browser':
                  return CupertinoPageRoute(builder: (_) => InappBrowser(), settings: settings);
                default:
                  return CupertinoPageRoute(builder: (_) => HomePage(), settings: settings);
              }
            },
          ),
        ),
      ),
    );
  }
}

/// Вспомогательный класс для отслеживания жизненного цикла приложения
class WidgetBindingHandler extends WidgetsBindingObserver {
  WidgetBindingHandler({
    this.onInactive,
    this.onPaused,
    this.onDetached,
    this.onResumed,
  });

  final AsyncCallback onInactive;
  final AsyncCallback onPaused;
  final AsyncCallback onDetached;
  final AsyncCallback onResumed;

  @override
  Future<Null> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.inactive:
        if (onInactive != null) await onInactive();
        break;
      case AppLifecycleState.paused:
        if (onPaused != null) await onPaused();
        break;
      case AppLifecycleState.detached:
        if (onDetached != null) await onDetached();
        break;
      case AppLifecycleState.resumed:
        if (onResumed != null) await onResumed();
        break;
    }
  }
}
