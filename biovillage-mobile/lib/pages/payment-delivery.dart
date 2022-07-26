import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:biovillage/redux/state/app-state.dart';
import 'package:biovillage/models/payment-delivery-info.dart';
import 'package:biovillage/theme/colors.dart';
import 'package:biovillage/widgets/appbar.dart';
import 'package:biovillage/widgets/drawer/drawer.dart';
import 'package:biovillage/widgets/delivery-map.dart';
import 'package:biovillage/widgets/account/payment-methods-list.dart';

class PaymentDeliveryPage extends StatefulWidget {
  PaymentDeliveryPage({Key key}) : super(key: key);
  @override
  PaymentDeliveryPageState createState() => PaymentDeliveryPageState();
}

class PaymentDeliveryPageState extends State<PaymentDeliveryPage> with SingleTickerProviderStateMixin {
  TabController _tabController;
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 2);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<String> _tabLabels = [
      FlutterI18n.translate(context, 'common.payment_terms'),
      FlutterI18n.translate(context, 'common.delivery_terms'),
    ];
    return Scaffold(
      appBar: CustomAppBar(title: FlutterI18n.translate(context, 'common.payment_and_delivery')),
      drawer: CustomDrawer(),
      drawerEdgeDragWidth: 0,
      body: StoreConnector<AppState, dynamic>(
        converter: (store) => store,
        builder: (context, store) {
          PaymentDeliveryInfo info = store.state.general.paymentDeliveryInfo;
          return SafeArea(
            child: Column(
              children: [
                SizedBox(height: 5),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: Colors.transparent,
                    indicatorWeight: double.minPositive,
                    unselectedLabelColor: ColorsTheme.primary,
                    labelColor: ColorsTheme.bg,
                    labelPadding: EdgeInsets.zero,
                    onTap: (i) => setState(() => _tabIndex = i),
                    tabs: [
                      for (int i = 0; i < _tabLabels.length; i++)
                        AnimatedContainer(
                          duration: Duration(milliseconds: 200),
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                          decoration: BoxDecoration(
                            color: i == _tabIndex ? ColorsTheme.primary : ColorsTheme.bg,
                            border: Border.all(color: ColorsTheme.primary),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(i == 0 ? 4 : 0),
                              bottomLeft: Radius.circular(i == 0 ? 4 : 0),
                              topRight: Radius.circular(i + 1 == _tabLabels.length ? 4 : 0),
                              bottomRight: Radius.circular(i + 1 == _tabLabels.length ? 4 : 0),
                            ),
                          ),
                          child: Text(
                            _tabLabels[i].toUpperCase(),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 11.w, letterSpacing: .2, fontWeight: FontWeight.w700),
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 12),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    physics: NeverScrollableScrollPhysics(),
                    children: [
                      SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              margin: EdgeInsets.only(bottom: 12, top: 8),
                              child: PaymentMethodsList(),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                info.paymentDesc,
                                style: TextStyle(fontSize: 12.w, height: 1.66, color: ColorsTheme.textQuaternary),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Image(
                              image: AssetImage('assets/img/delivery-img-1.jpg'),
                              fit: BoxFit.cover,
                            ),
                            SizedBox(height: 10),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                info.deliveryDesc,
                                style: TextStyle(fontSize: 12.w, height: 1.66, color: ColorsTheme.textQuaternary),
                              ),
                            ),
                            SizedBox(height: 16),
                            DeliveryMap(mapHeight: 500),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
