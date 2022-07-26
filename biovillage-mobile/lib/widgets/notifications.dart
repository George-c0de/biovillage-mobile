import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:biovillage/theme/colors.dart';
import 'package:biovillage/theme/bv-icons.dart';

/// Функция вывода тост-уведомления
void showToast(String text, {bool isError = false, Duration duration = const Duration(milliseconds: 2000)}) {
  showOverlay(
    (context, t) {
      return Transform.translate(
        offset: Tween<Offset>(begin: Offset(0, 20), end: Offset(0, 0)).transform(t),
        child: Opacity(
          opacity: t,
          child: SafeArea(
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                  child: Container(
                    alignment: Alignment.bottomCenter,
                    padding: EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: MediaQuery.of(context).viewInsets.bottom != 0 ? 60 : 180,
                    ),
                    child: CustomToast(text: text, isError: isError),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
    duration: duration,
  );
}

class CustomToast extends StatelessWidget {
  CustomToast({
    Key key,
    @required this.text,
    this.isError = false,
  }) : super(key: key);

  final String text;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: isError ? ColorsTheme.error : ColorsTheme.accent,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Color.fromRGBO(123, 49, 110, 0.15),
            offset: Offset(0, 1),
            blurRadius: 2,
          ),
          BoxShadow(
            color: Color.fromRGBO(133, 41, 115, 0.1),
            offset: Offset(0, 2),
            blurRadius: 20,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          isError
              ? Icon(BvIcons.alert, color: ColorsTheme.bg)
              : Icon(BvIcons.info_outlined, color: ColorsTheme.primary),
          SizedBox(width: 12),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13.w,
                height: 1.4,
                fontWeight: FontWeight.w400,
                fontFamily: 'Montserrat',
                color: ColorsTheme.bg,
                decoration: TextDecoration.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
