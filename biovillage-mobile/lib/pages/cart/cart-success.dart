import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:biovillage/helpers/system-elements.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:biovillage/theme/colors.dart';

class CartSuccessPage extends StatelessWidget {
  void _ok(BuildContext context) async {
    await Future.delayed(Duration(milliseconds: 600));
    setNavBarTheme(context, NavBarTheme.white, delay: Duration(milliseconds: 300));
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    setNavBarTheme(context, NavBarTheme.primary);
    return WillPopScope(
      onWillPop: () async {
        _ok(context);
        return false;
      },
      child: Scaffold(
        body: Material(
          color: ColorsTheme.primary,
          child: InkWell(
            splashColor: ColorsTheme.accent.withOpacity(.6),
            highlightColor: Colors.transparent,
            onTap: () => _ok(context),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Image(
                    image: AssetImage('assets/img/logo_success-page.png'),
                    width: 180,
                  ),
                  SizedBox(height: 20),
                  Text(
                    FlutterI18n.translate(context, 'common.cart.success_text'),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: ColorsTheme.accent, fontSize: 14.w, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
