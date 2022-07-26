import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:biovillage/redux/state/app-state.dart';
import 'package:biovillage/models/address.dart';
import 'package:biovillage/models/user-info.dart';
import 'package:biovillage/helpers/address.dart';
import 'package:biovillage/helpers/colors.dart';
import 'package:biovillage/theme/bv-icons.dart';
import 'package:biovillage/theme/colors.dart';
import 'package:biovillage/widgets/drawer/drawer.dart';
import 'package:biovillage/widgets/button.dart';

typedef OnOpenDrawerCallback = Function(DrawerMode drawerMode);

class CustomAppBar extends StatelessWidget with PreferredSizeWidget {
  CustomAppBar({
    Key key,
    this.isHome = false,
    this.title,
    this.onOpenDrawer,
    this.onTapBackBtn,
    this.showAddress = false,
    this.showBonuses = false,
    this.appendWidget,
  }) : super(key: key);

  final bool isHome;
  final String title;
  final OnOpenDrawerCallback onOpenDrawer;
  final Function onTapBackBtn;
  final bool showAddress;
  final bool showBonuses;
  final Widget appendWidget;

  @override
  Size get preferredSize => Size.fromHeight(56);

  Widget build(BuildContext context) {
    return AppBar(
      titleSpacing: 0,
      elevation: 0,
      backgroundColor: ColorsTheme.bg,
      automaticallyImplyLeading: false,
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          /// Margin:
          SizedBox(width: 4),

          /// Menu/Back button:
          isHome
              ? CircleButton(
                  size: 48,
                  child: Icon(BvIcons.menu, size: 24, color: ColorsTheme.accent),
                  splashColor: ColorsTheme.accent.withOpacity(.4),
                  highlightColor: ColorsTheme.accent.withOpacity(.2),
                  onTap: () async {
                    if (onOpenDrawer != null) await onOpenDrawer(DrawerMode.menu);
                    Scaffold.of(context).openDrawer();
                  },
                )
              : CircleButton(
                  size: 48,
                  child: Icon(BvIcons.chevron_left, size: 26, color: ColorsTheme.accent),
                  splashColor: ColorsTheme.accent.withOpacity(.4),
                  highlightColor: ColorsTheme.accent.withOpacity(.2),
                  onTap: () async {
                    if (onTapBackBtn != null)
                      await onTapBackBtn();
                    else
                      Navigator.pop(context);
                  },
                ),

          /// Margin:
          SizedBox(width: 4),

          /// Logo:
          if (title == null || isHome)
            Image(
              width: showBonuses ? 28 : 110,
              image: AssetImage(showBonuses ? 'assets/img/logo_small.png' : 'assets/img/logo.png'),
              fit: BoxFit.contain,
            ),

          if (title == null && !showAddress) Spacer(),

          /// Title:
          if (title != null)
            Expanded(
              child: Container(
                padding: EdgeInsets.only(bottom: 2.5),
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16.w,
                    color: ColorsTheme.accent,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
              ),
            ),

          /// Margin:
          if (showAddress || appendWidget != null) SizedBox(width: 8),

          /// Address:
          if (showAddress)
            Expanded(
              child: StoreConnector<AppState, dynamic>(
                converter: (store) => store,
                builder: (context, store) {
                  Address currentAddress = store.state.account.currentAddress;
                  return Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.only(top: 2),
                    child: GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/account/select-address'),
                      child: Text.rich(
                        TextSpan(
                          children: [
                            WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: Icon(BvIcons.map_marker_2, color: ColorsTheme.primary, size: 22),
                            ),
                            TextSpan(
                              text: ' ',
                            ),
                            currentAddress == null
                                ? TextSpan(
                                    text: FlutterI18n.translate(context, 'common.choose_address'),
                                  )
                                : TextSpan(
                                    text: shortenAddress(context, currentAddress.address),
                                  ),
                          ],
                        ),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: ColorsTheme.accent,
                          fontSize: 11.w,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

          /// Append Widget:
          if (!showAddress && appendWidget != null) appendWidget,

          /// Bonuses:
          if (showBonuses)
            StoreConnector<AppState, dynamic>(
              converter: (store) => store,
              builder: (context, store) {
                bool userAuth = store.state.account.userAuth;
                UserInfo userInfo = store.state.account.userInfo;
                int bonuses = userInfo != null ? userInfo.bonuses ?? 0 : 0;
                return Container(
                  margin: EdgeInsets.only(left: 8),
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomLeft,
                      end: Alignment.centerRight,
                      stops: [0.05, 1],
                      colors: [
                        HexColor.fromHex('#FF16DC'),
                        HexColor.fromHex('#FF8A00'),
                      ],
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Color.fromRGBO(123, 49, 110, 0.25),
                        offset: Offset(0, 1),
                        blurRadius: 2,
                      ),
                      BoxShadow(
                        color: Color.fromRGBO(123, 49, 110, 0.2),
                        offset: Offset(0, 5),
                        blurRadius: 10,
                      ),
                    ],
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(25),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      splashColor: ColorsTheme.accent.withOpacity(.4),
                      highlightColor: ColorsTheme.accent.withOpacity(.2),
                      onTap: () async {
                        if (userAuth) {
                          Navigator.pushNamed(context, '/account/bonuses');
                        } else {
                          if (onOpenDrawer != null) await onOpenDrawer(DrawerMode.account);
                          Scaffold.of(context).openDrawer();
                        }
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(width: 14),
                          Text(
                            bonuses.toString() + FlutterI18n.translate(context, 'common.cart.currency_symbol'),
                            style: TextStyle(color: ColorsTheme.bg, fontWeight: FontWeight.w600, fontSize: 13.w),
                          ),
                          SizedBox(width: 4),
                          Icon(BvIcons.gift_2, color: ColorsTheme.bg, size: 24),
                          SizedBox(width: 10),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

          /// Margin:
          SizedBox(width: 16),
        ],
      ),
    );
  }
}
