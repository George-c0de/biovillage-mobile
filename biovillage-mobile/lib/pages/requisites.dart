import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:biovillage/redux/state/app-state.dart';
import 'package:biovillage/theme/colors.dart';
import 'package:biovillage/widgets/appbar.dart';
import 'package:biovillage/widgets/drawer/drawer.dart';

class RequisitesPage extends StatefulWidget {
  RequisitesPage({Key key}) : super(key: key);
  @override
  _RequisitesPageState createState() => _RequisitesPageState();
}

class _RequisitesPageState extends State<RequisitesPage> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: FlutterI18n.translate(context, 'common.requisites')),
      drawer: CustomDrawer(),
      drawerEdgeDragWidth: 0,
      body: StoreConnector<AppState, dynamic>(
        converter: (store) => store,
        builder: (context, store) {
          String aboutOrgDetails = store.state.general.companyInfo.aboutOrgDetails;
          return SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (aboutOrgDetails != null)
                    Container(
                      margin: EdgeInsets.only(top: 8, bottom: 24),
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        aboutOrgDetails,
                        style: TextStyle(
                          fontSize: 13.w,
                          height: 1.54,
                          color: ColorsTheme.textQuaternary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
