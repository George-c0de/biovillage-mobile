import 'package:biovillage/widgets/notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share/share.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:biovillage/redux/state/app-state.dart';
import 'package:biovillage/helpers/colors.dart';
import 'package:biovillage/helpers/data-formating.dart';
import 'package:biovillage/theme/colors.dart';
import 'package:biovillage/theme/bv-icons.dart';
import 'package:biovillage/widgets/appbar.dart';
import 'package:biovillage/widgets/button.dart';

class BonusesPage extends StatefulWidget {
  BonusesPage({Key key}) : super(key: key);

  @override
  _BonusesPageState createState() => _BonusesPageState();
}

class _BonusesPageState extends State<BonusesPage> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: FlutterI18n.translate(context, 'common.bonuses')),
      body: StoreConnector<AppState, dynamic>(
        converter: (store) => store,
        builder: (context, store) {
          int bonuses = store.state.account.userInfo.bonuses ?? 0;
          String refCode = (store.state.account.userInfo.refCode ?? '--').toUpperCase();
          return SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            FlutterI18n.translate(context, 'common.account.sum_bonuses') + ':',
                            style: TextStyle(fontSize: 13.w, fontWeight: FontWeight.w700),
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          numToString(bonuses) + ' ' + FlutterI18n.translate(context, 'common.cart.currency_symbol'),
                          style: TextStyle(fontSize: 14.w, fontWeight: FontWeight.w700, letterSpacing: .2),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 18),
                  Container(
                    padding: EdgeInsets.fromLTRB(16, 20, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          FlutterI18n.translate(context, 'common.account.ref_code') + ':',
                          style: TextStyle(fontSize: 13.w, fontWeight: FontWeight.w700, height: 1.8),
                        ),
                        Text(
                          FlutterI18n.translate(context, 'common.account.ref_code_desc'),
                          style: TextStyle(fontSize: 12.w, color: ColorsTheme.textTertiary, height: 1.66),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: darken(ColorsTheme.bg, .015),
                      ),
                      padding: EdgeInsets.only(left: 16, right: 8),
                      height: 44,
                      child: Row(
                        children: [
                          Expanded(
                            child: SelectableText(
                              refCode,
                              style: TextStyle(
                                fontSize: 13.w,
                                fontWeight: FontWeight.w700,
                                color: ColorsTheme.textQuaternary,
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          MaterialButton(
                            padding: EdgeInsets.only(left: 5, right: 8),
                            height: 32,
                            splashColor: ColorsTheme.accent.withOpacity(.3),
                            highlightColor: ColorsTheme.accent.withOpacity(.15),
                            onPressed: () {
                              Clipboard.setData(new ClipboardData(text: refCode));
                              showToast(FlutterI18n.translate(context, 'common.account.ref_code_copied'));
                            },
                            child: Row(
                              children: [
                                Icon(
                                  BvIcons.copy,
                                  color: ColorsTheme.accent,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  FlutterI18n.translate(context, 'common.copy').toUpperCase(),
                                  style:
                                      TextStyle(color: ColorsTheme.accent, fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Button(
                      onTap: () async {
                        String text = FlutterI18n.translate(context, 'common.account.share_ref_code_text');
                        text = text.replaceAll('<CODE>', refCode);
                        await Share.share(text);
                      },
                      label: FlutterI18n.translate(context, 'common.share'),
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
