import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:biovillage/redux/state/app-state.dart';
import 'package:biovillage/models/company-info.dart';
import 'package:biovillage/theme/bv-icons.dart';
import 'package:biovillage/theme/colors.dart';
import 'package:biovillage/widgets/appbar.dart';
import 'package:biovillage/widgets/drawer/drawer.dart';

class AboutCompanyPage extends StatefulWidget {
  AboutCompanyPage({Key key}) : super(key: key);
  @override
  _AboutCompanyPageState createState() => _AboutCompanyPageState();
}

class _AboutCompanyPageState extends State<AboutCompanyPage> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: FlutterI18n.translate(context, 'common.about.title')),
      drawer: CustomDrawer(),
      drawerEdgeDragWidth: 0,
      body: StoreConnector<AppState, dynamic>(
        converter: (store) => store,
        builder: (context, store) {
          CompanyInfo companyInfo = store.state.general.companyInfo;
          List<String> advantages = [
            companyInfo.aboutAdvantage1,
            companyInfo.aboutAdvantage2,
            companyInfo.aboutAdvantage3,
            companyInfo.aboutAdvantage4,
          ];
          return SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image(
                    image: AssetImage('assets/img/about-company-img-1.jpg'),
                    fit: BoxFit.cover,
                  ),
                  Container(
                    transform: Matrix4.translationValues(0, -24, 0),
                    margin: EdgeInsets.symmetric(horizontal: 16),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: ColorsTheme.bg,
                      borderRadius: BorderRadius.circular(10),
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
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(companyInfo.founderPhoto),
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.transparent,
                          radius: 52,
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            companyInfo.founderName,
                            style: TextStyle(
                              fontSize: 13.w,
                              color: ColorsTheme.textQuaternary,
                              fontWeight: FontWeight.bold,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (companyInfo.aboutPurposes != null)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      margin: EdgeInsets.only(bottom: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            FlutterI18n.translate(context, 'common.about.purposes'),
                            style: TextStyle(
                              fontSize: 13.w,
                              fontWeight: FontWeight.w700,
                              height: 1.54,
                              color: ColorsTheme.textQuaternary,
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            companyInfo.aboutPurposes,
                            style: TextStyle(fontSize: 12.w, height: 1.5, color: ColorsTheme.textQuaternary),
                          ),
                        ],
                      ),
                    ),
                  Container(
                    color: ColorsTheme.accent,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(BvIcons.certification, color: ColorsTheme.primary),
                        SizedBox(width: 8),
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: FlutterI18n.translate(context, 'common.product.certificated_1') + ' ',
                              ),
                              TextSpan(
                                text: FlutterI18n.translate(context, 'common.product.certificated_2'),
                                style: TextStyle(color: ColorsTheme.primary),
                              ),
                            ],
                          ),
                          style: TextStyle(
                            fontSize: 12.w,
                            letterSpacing: .2,
                            color: ColorsTheme.bg,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                  if (companyInfo.aboutAdvantage1 != null && companyInfo.aboutAdvantage1.isNotEmpty)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          for (int i = 0; i < advantages.length; i++)
                            if (advantages[i] != null)
                              Container(
                                margin: EdgeInsets.only(bottom: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 12,
                                          height: 12,
                                          decoration: BoxDecoration(
                                            color: ColorsTheme.primary,
                                            borderRadius: BorderRadius.circular(100),
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            FlutterI18n.translate(context, 'common.about.advantage_${i + 1}'),
                                            style: TextStyle(
                                              fontSize: 13.w,
                                              color: ColorsTheme.textQuaternary,
                                              fontWeight: FontWeight.w700,
                                              height: 1.3,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      advantages[i],
                                      style: TextStyle(
                                        fontSize: 12.w,
                                        height: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          SizedBox(height: 12),
                        ],
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
