import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:biovillage/theme/bv-icons.dart';
import 'package:biovillage/theme/colors.dart';
import 'package:biovillage/helpers/colors.dart';

/// Класс-модель для элементов меню дравера
class MenuItem {
  String title;
  IconData icon;
  double iconSize;
  Function onTap;
  List<MenuItem> submenuItems;
  bool hasDividers;

  MenuItem({
    @required this.title,
    @required this.icon,
    this.iconSize = 24,
    this.onTap,
    this.submenuItems,
    this.hasDividers = false,
  });
}

/// Виджет для построения 2х-уровнего меню
class DrawerMenuItem extends StatefulWidget {
  DrawerMenuItem({
    Key key,
    @required this.menuItem,
    this.isSubmenu = false,
  }) : super(key: key);

  final MenuItem menuItem;
  final bool isSubmenu;

  @override
  _DrawerMenuItemState createState() => _DrawerMenuItemState();
}

class _DrawerMenuItemState extends State<DrawerMenuItem> with TickerProviderStateMixin {
  AnimationController _submenuController;
  bool _menuOpened = false;

  @override
  void initState() {
    _submenuController = AnimationController(duration: Duration(milliseconds: 300), vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _submenuController.dispose();
    super.dispose();
  }

  void toggleSubmenu() {
    setState(() {
      _menuOpened = !_menuOpened;
    });
    _menuOpened ? _submenuController.forward() : _submenuController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.isSubmenu ? darken(ColorsTheme.bg, 0.02) : ColorsTheme.bg,
      child: Column(
        children: [
          if (widget.menuItem.hasDividers) Container(height: 4, color: darken(ColorsTheme.bg, .04)),
          AnimatedContainer(
            duration: Duration(milliseconds: 350),
            color: _menuOpened || widget.isSubmenu ? darken(ColorsTheme.bg, 0.02) : ColorsTheme.bg,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  if (widget.menuItem.submenuItems != null) {
                    toggleSubmenu();
                  } else if (widget.menuItem.onTap != null) {
                    widget.menuItem.onTap();
                  }
                },
                splashColor: ColorsTheme.accent.withOpacity(.3),
                highlightColor: ColorsTheme.accent.withOpacity(.15),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  height: 44,
                  child: Row(
                    children: [
                      Container(
                        alignment: Alignment.center,
                        width: 24,
                        height: 24,
                        child: Icon(
                          widget.menuItem.icon,
                          color: ColorsTheme.primary,
                          size: widget.menuItem.iconSize,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.menuItem.title,
                          style: TextStyle(
                            fontSize: 13.w,
                            letterSpacing: 0.1,
                            fontWeight: widget.isSubmenu ? FontWeight.w400 : FontWeight.w700,
                            color: ColorsTheme.accent,
                          ),
                        ),
                      ),
                      Container(
                        alignment: Alignment.center,
                        margin: EdgeInsets.only(left: 8, right: 8),
                        child: widget.menuItem.submenuItems == null
                            ? Icon(BvIcons.chevron_right, size: 28, color: ColorsTheme.primary)
                            : RotationTransition(
                                turns: Tween(begin: 0.0, end: -0.5).animate(_submenuController),
                                child: Icon(BvIcons.chevron_down, size: 28, color: ColorsTheme.primary),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (widget.menuItem.hasDividers) Container(height: 4, color: darken(ColorsTheme.bg, .04)),
          if (!widget.isSubmenu && widget.menuItem.submenuItems != null)
            SizeTransition(
              sizeFactor: CurvedAnimation(parent: _submenuController, curve: Curves.easeOut),
              axisAlignment: -1,
              child: Column(
                children: [
                  for (MenuItem submenuItem in widget.menuItem.submenuItems)
                    DrawerMenuItem(menuItem: submenuItem, isSubmenu: true),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
