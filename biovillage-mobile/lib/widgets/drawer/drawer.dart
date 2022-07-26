import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:biovillage/redux/state/app-state.dart';
import 'package:biovillage/pages/catalog/category.dart';
import 'package:biovillage/theme/bv-icons.dart';
import 'package:biovillage/theme/colors.dart';
import 'package:biovillage/widgets/drawer/drawer-tab.dart';
import 'package:biovillage/widgets/drawer/drawer-login-tabs.dart';
import 'package:biovillage/widgets/drawer/drawer-menu.dart';

enum DrawerMode { menu, account }

class CustomDrawer extends StatefulWidget {
  CustomDrawer({
    Key key,
    this.drawerMode = DrawerMode.account,
    this.onSuccessAuth,
  }) : super(key: key);

  final DrawerMode drawerMode;
  final Function onSuccessAuth;

  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> with SingleTickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Определение индекса таба для отображения:
    if (widget.drawerMode == DrawerMode.menu) {
      _tabController = TabController(vsync: this, length: 4, initialIndex: 0);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.drawerMode == DrawerMode.account) {
        var store = StoreProvider.of<AppState>(context);
        int index = store.state.account.userAuth ? 3 : 1;
        setState(() => _tabController = TabController(vsync: this, length: 4, initialIndex: index));
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Главное меню:
    final List<MenuItem> mainMenu = <MenuItem>[
      MenuItem(
        title: FlutterI18n.translate(context, 'common.promo_products'),
        icon: BvIcons.sale,
        hasDividers: true,
        onTap: () {
          var store = StoreProvider.of<AppState>(context);
          Navigator.pop(context);
          Navigator.pushNamed(
            context,
            '/category',
            arguments: CategoryPageArguments(category: store.state.catalog.categories[0]),
          );
        },
      ),
      MenuItem(
        title: FlutterI18n.translate(context, 'common.account.personal_account'),
        icon: BvIcons.user,
        iconSize: 18,
        onTap: () {
          var store = StoreProvider.of<AppState>(context);
          if (store.state.account.userAuth) {
            _tabController.animateTo(3);
          } else {
            _tabController.animateTo(1);
          }
        },
      ),
      MenuItem(
        title: FlutterI18n.translate(context, 'common.bonuses_for_friends'),
        icon: BvIcons.gift,
        onTap: () {
          var store = StoreProvider.of<AppState>(context);
          if (store.state.account.userAuth) {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/account/bonuses');
          } else {
            _tabController.animateTo(1);
          }
        },
      ),
      MenuItem(
        title: FlutterI18n.translate(context, 'common.payment_methods'),
        icon: BvIcons.payment,
        onTap: () {
          var store = StoreProvider.of<AppState>(context);
          if (store.state.account.userAuth) {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/account/payment');
          } else {
            _tabController.animateTo(1);
          }
        },
      ),
      MenuItem(
        title: FlutterI18n.translate(context, 'common.about_company'),
        icon: BvIcons.info_outlined,
        submenuItems: <MenuItem>[
          MenuItem(
            title: FlutterI18n.translate(context, 'common.payment_and_delivery'),
            icon: BvIcons.delivery,
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/payment-delivery');
            },
          ),
          MenuItem(
            title: FlutterI18n.translate(context, 'common.about_us'),
            icon: BvIcons.info_outlined,
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/about-company');
            },
          ),
          MenuItem(
            title: FlutterI18n.translate(context, 'common.contacts.contacts'),
            icon: BvIcons.phone_outlined,
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/contacts');
            },
          ),
          MenuItem(
            title: FlutterI18n.translate(context, 'common.requisites'),
            icon: BvIcons.info_outlined,
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/requisites');
            },
          ),
        ],
      ),
    ];

    // Меню ЛК:
    final List<MenuItem> accountMenu = <MenuItem>[
      MenuItem(
        title: FlutterI18n.translate(context, 'common.account.profile'),
        icon: BvIcons.settings_outlined,
        onTap: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/account/settings');
        },
      ),
      MenuItem(
        title: FlutterI18n.translate(context, 'common.orders_history'),
        icon: BvIcons.history,
        onTap: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/account/orders-history');
        },
      ),
      MenuItem(
        title: FlutterI18n.translate(context, 'common.payment_methods'),
        icon: BvIcons.payment,
        onTap: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/account/payment');
        },
      ),
    ];

    return Drawer(
      child: SafeArea(
        child: Container(
          color: ColorsTheme.bg,
          child: _tabController != null
              ? TabBarView(
                  physics: NeverScrollableScrollPhysics(),
                  controller: _tabController,
                  children: [
                    /// Tab 0: [Main Menu]
                    DrawerTab(
                      title: FlutterI18n.translate(context, 'common.menu'),
                      actionBtnLabel: FlutterI18n.translate(context, 'common.feedback'),
                      actionBtnOnTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/contacts');
                      },
                      children: [for (MenuItem item in mainMenu) DrawerMenuItem(menuItem: item)],
                    ),

                    /// Tab 1: [Login - step 1]
                    LoginStep1Tab(onSuccess: () => _tabController.animateTo(2)),

                    /// Tab 2: [Login - step 2]
                    LoginStep2Tab(onSuccess: () {
                      if (widget.onSuccessAuth != null) widget.onSuccessAuth();
                      _tabController.animateTo(3);
                    }),

                    /// Tab 3: [Account Menu]
                    DrawerTab(
                      title: FlutterI18n.translate(context, 'common.account.personal_account'),
                      actionBtnLabel: FlutterI18n.translate(context, 'common.feedback'),
                      actionBtnOnTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/contacts');
                      },
                      children: [for (MenuItem item in accountMenu) DrawerMenuItem(menuItem: item)],
                    ),
                  ],
                )
              : Container(),
        ),
        // child: DrawerTab(menu: mainMenu),
      ),
    );
  }
}
