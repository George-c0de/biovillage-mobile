import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:biovillage/redux/state/app-state.dart';
import 'package:biovillage/models/company-info.dart';
import 'package:biovillage/helpers/colors.dart';
import 'package:biovillage/helpers/data-formating.dart';
import 'package:biovillage/theme/colors.dart';
import 'package:biovillage/theme/bv-icons.dart';
import 'package:biovillage/widgets/button.dart';
import 'package:biovillage/widgets/map.dart';
import 'package:biovillage/widgets/appbar.dart';
import 'package:biovillage/widgets/drawer/drawer.dart';

class ContactsPage extends StatefulWidget {
  ContactsPage({Key key}) : super(key: key);
  @override
  _ContactsPageState createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: FlutterI18n.translate(context, 'common.contacts.contacts')),
      drawer: CustomDrawer(),
      drawerEdgeDragWidth: 0,
      body: StoreConnector<AppState, dynamic>(
        converter: (store) => store,
        builder: (context, store) {
          CompanyInfo companyInfo = store.state.general.companyInfo;
          return SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: 190,
                    child: CustomMap(
                      center: companyInfo.officeCoords,
                      markers: [companyInfo.officeCoords],
                      zoom: 14,
                    ),
                  ),
                  SizedBox(height: 6),
                  Column(
                    children: [
                      _ContactsItem(
                        icon: BvIcons.map_marker_2,
                        label: FlutterI18n.translate(context, 'common.contacts.office_address'),
                        value: companyInfo.officeAddress,
                      ),
                      _ContactsItem(
                        icon: BvIcons.phone,
                        iconSize: 20,
                        label: FlutterI18n.translate(context, 'common.contacts.office_phone_client'),
                        value: companyInfo.officePhoneClient,
                        onTap: () => launch(makePhoneLink(companyInfo.officePhoneClient)),
                      ),
                      _ContactsItem(
                        icon: BvIcons.phone,
                        iconSize: 20,
                        label: FlutterI18n.translate(context, 'common.contacts.office_phone_partners'),
                        value: companyInfo.officePhonePartners,
                        onTap: () => launch(makePhoneLink(companyInfo.officePhonePartners)),
                      ),
                      _ContactsItem(
                        icon: BvIcons.email,
                        iconSize: 20,
                        label: FlutterI18n.translate(context, 'common.contacts.office_email'),
                        value: companyInfo.officeEmail,
                        valueStyle: TextStyle(fontSize: 13.w, fontWeight: FontWeight.w700, color: ColorsTheme.accent),
                        onTap: () => launch('mailto:${companyInfo.officeEmail}'),
                      ),
                      SizedBox(height: 8),
                    ],
                  ),
                  if (companyInfo.socialVk != null &&
                      companyInfo.socialVk.isNotEmpty &&
                      companyInfo.socialInstagram != null &&
                      companyInfo.socialInstagram.isNotEmpty)
                    Container(
                      padding: EdgeInsets.fromLTRB(10, 12, 10, 16),
                      decoration: BoxDecoration(
                        border: Border(top: BorderSide(width: 4, color: darken(ColorsTheme.bg, .04))),
                      ),
                      child: Row(
                        children: [
                          for (String social in ['vk', 'instagram'])
                            Builder(builder: (context) {
                              String link;
                              Widget icon;
                              switch (social) {
                                case 'vk':
                                  link = companyInfo.socialVk;
                                  icon = SvgPicture.asset('assets/img/icons/vk.svg', height: 24);
                                  break;
                                case 'instagram':
                                  link = companyInfo.socialInstagram;
                                  icon = Image(image: AssetImage('assets/img/icons/instagram.png'), height: 24);
                                  break;
                              }
                              if (link == null || link.isEmpty) return Container();
                              return Container(
                                margin: EdgeInsets.symmetric(horizontal: 6),
                                child: CircleButton(
                                  onTap: () => launch(link),
                                  size: 30,
                                  splashColor: ColorsTheme.primary.withOpacity(.4),
                                  highlightColor: ColorsTheme.primary.withOpacity(.4),
                                  child: icon,
                                ),
                              );
                            }),
                        ],
                      ),
                    ),
                  if (companyInfo.supportTelegram != null && companyInfo.supportTelegram.isNotEmpty)
                    Container(
                      padding: EdgeInsets.fromLTRB(19, 24, 19, 0),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            darken(ColorsTheme.bg, .03),
                            ColorsTheme.bg,
                          ],
                        ),
                      ),
                      child: Material(
                        borderRadius: BorderRadius.circular(14),
                        color: HexColor.fromHex('#039BE5'),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () => launch(companyInfo.supportTelegram),
                          splashColor: ColorsTheme.accent.withOpacity(.4),
                          highlightColor: ColorsTheme.accent.withOpacity(.2),
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                            child: Row(
                              children: [
                                SvgPicture.asset('assets/img/icons/telegram.svg', height: 24),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      Text(
                                        FlutterI18n.translate(context, 'common.tech_support'),
                                        style: TextStyle(
                                          fontSize: 13.w,
                                          fontWeight: FontWeight.w600,
                                          color: ColorsTheme.bg,
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        FlutterI18n.translate(context, 'common.ask_question'),
                                        style: TextStyle(fontSize: 11.w, color: ColorsTheme.bg),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 10),
                                Icon(BvIcons.chevron_right, color: ColorsTheme.textFivefold),
                              ],
                            ),
                          ),
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

/// Вспомогательный виджет для списка контактов
class _ContactsItem extends StatelessWidget {
  _ContactsItem({
    @required this.icon,
    this.iconSize = 24,
    @required this.label,
    @required this.value,
    this.valueStyle,
    this.onTap,
  });

  final IconData icon;
  final double iconSize;
  final String label;
  final String value;
  final TextStyle valueStyle;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    final TextStyle _labelStyle = TextStyle(fontSize: 13.w, color: ColorsTheme.textQuaternary);
    final TextStyle _valueStyle = valueStyle ??
        TextStyle(
          fontSize: 13.w,
          fontWeight: FontWeight.bold,
          color: ColorsTheme.textQuaternary,
        );
    return InkWell(
      onTap: onTap != null ? () => onTap() : null,
      splashColor: ColorsTheme.primary.withOpacity(.4),
      highlightColor: ColorsTheme.primary.withOpacity(.2),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        color: Colors.transparent,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              transform: Matrix4.translationValues(0, -1, 0),
              alignment: Alignment.center,
              width: 24,
              child: Icon(icon, size: iconSize, color: ColorsTheme.primary),
            ),
            SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(label + ':', style: _labelStyle),
                  SizedBox(height: 6),
                  Text(value, style: _valueStyle),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
