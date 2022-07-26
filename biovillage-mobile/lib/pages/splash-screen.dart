import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:rive/rive.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:biovillage/redux/state/app-state.dart';
import 'package:biovillage/redux/actions/general.dart';
import 'package:biovillage/redux/actions/cart.dart';
import 'package:biovillage/redux/actions/account.dart';
import 'package:biovillage/helpers/net-connection.dart';
// import 'package:biovillage/helpers/debug.dart';
import 'package:biovillage/helpers/system-elements.dart';
import 'package:biovillage/theme/colors.dart';
import 'package:biovillage/widgets/notifications.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  Artboard _riveArtboard;
  RiveAnimationController _riveController;
  AnimationController _toastController;
  bool _netConnection = true;
  String _toastText = '';
  DateTime _start; // Timestamp of start animation
  final int animDurationSecs = 4; // Animation in seconds

  /// Запрос необходимых данных для построения главной страницы:
  Future<void> getRequiredData() async {
    var store = StoreProvider.of<AppState>(context);
    // Проверка интернет соеденения:
    bool connect = await checkConnect(null, toast: false);
    setState(() => _netConnection = connect);
    if (_netConnection) {
      showLoadingToast(null);
      bool failed = false;
      // Запрашиваем и подготавливаем данные:
      // printTimeMsg('Приложение запущено. Запрашиваем необходимые данные');
      await store.dispatch(getSettings(onFailed: () => failed = true));
      await store.dispatch(initAccountParams());
      await store.dispatch(getUserInfo(onFailed: () => failed = true));
      await store.dispatch(initCartProducts());
      if (failed) {
        Timer(Duration(milliseconds: 1500), () => getRequiredData());
      } else {
        toHome();
      }
    } else {
      showLoadingToast(FlutterI18n.translate(context, 'common.no_internet'));
      Timer(Duration(milliseconds: 1500), () => getRequiredData());
    }
  }

  /// Выход из загрузочного экрана
  void toHome() {
    // Проверям, завершилась ли анимация:
    if (DateTime.now().difference(_start).inSeconds < animDurationSecs || _riveController.isActive) {
      Timer(Duration(milliseconds: 200), () => toHome());
      return;
    }

    // Изменяем цвета системного навбара:
    setNavBarTheme(context, NavBarTheme.white, delay: Duration(milliseconds: 300));
    // Переадресация на главную:
    // printTimeMsg('Переадресация на главную:');
    Navigator.pushReplacementNamed(context, '/home');
  }

  /// Отображение локального тост-уведомления:
  void showLoadingToast(String text) async {
    if (_toastText == text) return;
    if (text == null) {
      await _toastController.reverse();
      setState(() => _toastText = '');
      return;
    }
    if (_toastController.status == AnimationStatus.completed) {
      await _toastController.reverse();
      await Future.delayed(Duration(milliseconds: 200));
    }
    setState(() => _toastText = text);
    _toastController.forward();
  }

  @override
  void initState() {
    super.initState();
    _toastController = AnimationController(duration: Duration(milliseconds: 300), vsync: this);
    // Загружаем rive-анимацию:
    rootBundle.load('assets/bv_loader-3.riv').then((data) async {
      RiveFile file = RiveFile();
      var success = file.import(data);
      if (success) {
        var artboard = file.mainArtboard;
        artboard.addController(
          _riveController = SimpleAnimation('load'),
        );
        _start = DateTime.now();
        setState(() => _riveArtboard = artboard);
      }
    });
    // Запускаем getRequiredData():
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getRequiredData();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _toastController.dispose();
    _riveController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsTheme.launcherBgColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: _riveArtboard == null
                ? Image(
                    image: AssetImage('assets/img/splash-screen.png'),
                    fit: BoxFit.cover,
                  )
                : Rive(
                    artboard: _riveArtboard,
                    fit: BoxFit.cover,
                  ),
          ),
          Positioned(
            bottom: 80,
            left: 16,
            right: 16,
            child: FadeTransition(
              opacity: _toastController,
              child: SlideTransition(
                position: _toastController.drive(Tween(begin: Offset(0, 2), end: Offset.zero)),
                child: Container(
                  alignment: Alignment.center,
                  child: CustomToast(text: _toastText, isError: true),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
