import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:biovillage/theme/bv-icons.dart';
import 'package:biovillage/theme/colors.dart';
import 'package:biovillage/widgets/drawer/drawer.dart';

typedef OnOpenDrawerCallback = Function(DrawerMode drawerMode);

class CustomNavbar extends StatelessWidget {
  CustomNavbar({Key key, this.onOpenDrawer}) : super(key: key);

  final OnOpenDrawerCallback onOpenDrawer;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'navbar',
      child: SizedBox(
        height: 82,
        child: Container(
          decoration: BoxDecoration(
            color: ColorsTheme.bg,
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                offset: Offset(0, -2),
                blurRadius: 20,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: EdgeInsets.only(bottom: 16, left: 16, right: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  _NavBarItem(
                    title: FlutterI18n.translate(context, 'common.shop'),
                    icon: BvIcons.vegetables,
                    iconSize: 22,
                    onTap: () => Navigator.popUntil(context, ModalRoute.withName('/home')),
                  ),
                  _NavBarItem(
                    title: FlutterI18n.translate(context, 'common.account.account'),
                    icon: BvIcons.user,
                    iconSize: 16,
                    onTap: () async {
                      if (onOpenDrawer != null) await onOpenDrawer(DrawerMode.account);
                      Scaffold.of(context).openDrawer();
                    },
                  ),
                  _NavBarItem(
                    title: FlutterI18n.translate(context, 'common.search.search'),
                    icon: BvIcons.search,
                    iconSize: 18,
                    onTap: () {
                      if (ModalRoute.of(context).settings.name != '/search') {
                        Navigator.pushNamed(context, '/search');
                      }
                    },
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

/// Вспомогательный виджет для кнопок навбара
class _NavBarItem extends StatelessWidget {
  _NavBarItem({
    @required this.title,
    @required this.icon,
    @required this.iconSize,
    @required this.onTap,
  });

  final String title;
  final IconData icon;
  final double iconSize;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
      ),
      child: Transform.scale(
        scale: 1.7,
        child: InkWell(
          borderRadius: BorderRadius.circular(100),
          splashColor: ColorsTheme.accent.withOpacity(.4),
          highlightColor: ColorsTheme.accent.withOpacity(.2),
          onTap: () => onTap(),
          child: Transform.scale(
            scale: (1 / 1.7),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 24,
                  height: 24,
                  child: Icon(icon, size: iconSize, color: ColorsTheme.accent),
                ),
                SizedBox(height: 8),
                Text(
                  title.toUpperCase(),
                  softWrap: false,
                  overflow: TextOverflow.visible,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 9.w,
                    color: ColorsTheme.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
