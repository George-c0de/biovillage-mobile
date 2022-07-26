import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:biovillage/redux/actions/general.dart';
import 'package:biovillage/redux/state/app-state.dart';
import 'package:biovillage/theme/colors.dart';

enum NavBarTheme { black, white, primary }

/// Установка темы для системного навбара
void setNavBarTheme(BuildContext context, NavBarTheme navBarTheme, {Duration delay = Duration.zero}) async {
  // Если задан контекст, то сохраним текущую тему в редакс:
  if (context != null) {
    var store = StoreProvider.of<AppState>(context);
    store.dispatch(SetNavBarTheme(navBarTheme));
  }

  Color systemNavigationBarColor;
  Brightness systemNavigationBarIconBrightness;

  switch (navBarTheme) {
    case NavBarTheme.black:
      systemNavigationBarColor = Colors.black;
      systemNavigationBarIconBrightness = Brightness.light;
      break;
    case NavBarTheme.white:
      systemNavigationBarColor = Colors.white;
      systemNavigationBarIconBrightness = Brightness.dark;
      break;
    case NavBarTheme.primary:
      systemNavigationBarColor = ColorsTheme.primary;
      systemNavigationBarIconBrightness = Brightness.dark;
      break;
  }
  await Future.delayed(delay);
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    systemNavigationBarColor: systemNavigationBarColor,
    systemNavigationBarIconBrightness: systemNavigationBarIconBrightness,
  ));
}
