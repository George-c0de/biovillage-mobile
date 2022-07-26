import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:package_info/package_info.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:biovillage/theme/bv-icons.dart';
import 'package:biovillage/theme/colors.dart';
import 'package:biovillage/helpers/colors.dart';
import 'package:biovillage/widgets/button.dart';

/// Виджет для построения табов дравера
class DrawerTab extends StatefulWidget {
  DrawerTab({
    @required this.children,
    this.title = '',
    this.actionBtnLabel,
    this.actionBtnOnTap,
    this.actionBtnLoading = false,
    this.actionBtnDisabled = false,
    this.showAppVersion = true,
  });

  final List<Widget> children;
  final String title;
  final String actionBtnLabel;
  final Function actionBtnOnTap;
  final bool actionBtnLoading;
  final bool actionBtnDisabled;
  final bool showAppVersion;

  @override
  _DrawerTabState createState() => _DrawerTabState();
}

class _DrawerTabState extends State<DrawerTab> with SingleTickerProviderStateMixin {
  String _appVersion;

  @override
  initState() {
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      if (widget.showAppVersion) {
        // Получаем версию приложения:
        PackageInfo packageInfo = await PackageInfo.fromPlatform();
        setState(() => _appVersion = packageInfo.version);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: EdgeInsets.only(left: 16, right: 15, top: 20, bottom: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          widget.title,
                          style: TextStyle(
                            color: ColorsTheme.accent,
                            fontWeight: FontWeight.w600,
                            fontSize: 16.w,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Material(
                        color: Colors.transparent,
                        child: CircleButton(
                          onTap: () => Navigator.pop(context),
                          size: 48,
                          child: Icon(BvIcons.close, size: 24, color: ColorsTheme.accent),
                          splashColor: ColorsTheme.accent.withOpacity(.4),
                          highlightColor: ColorsTheme.accent.withOpacity(.2),
                        ),
                      ),
                    ],
                  ),
                ),
                for (Widget child in widget.children) child,
              ],
            ),
          ),
        ),
        if (widget.showAppVersion && _appVersion != null)
          Container(
            padding: EdgeInsets.fromLTRB(16, 32, 16, 16),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: FlutterI18n.translate(context, 'common.app_version') + ': ',
                  ),
                  TextSpan(
                    text: _appVersion,
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              style: TextStyle(
                fontSize: 12.w,
                color: ColorsTheme.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        if (widget.actionBtnLabel != null)
          Container(
            decoration: BoxDecoration(border: Border(top: BorderSide(color: darken(ColorsTheme.bg, .04), width: 4))),
            padding: EdgeInsets.only(top: 16, bottom: 24, left: 16, right: 16),
            child: Button(
              label: widget.actionBtnLabel,
              loading: widget.actionBtnLoading,
              disabled: widget.actionBtnDisabled,
              onTap: () {
                if (widget.actionBtnOnTap != null && !widget.actionBtnLoading) widget.actionBtnOnTap();
              },
            ),
          ),
      ],
    );
  }
}
