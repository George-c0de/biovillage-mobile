import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:biovillage/redux/state/app-state.dart';
import 'package:biovillage/redux/actions/account.dart';
import 'package:biovillage/models/address.dart';
import 'package:biovillage/helpers/net-connection.dart';
import 'package:biovillage/helpers/data-formating.dart';
import 'package:biovillage/theme/bv-icons.dart';
import 'package:biovillage/theme/colors.dart';
import 'package:biovillage/widgets/form-elements.dart';
import 'package:biovillage/widgets/button.dart';
import 'package:biovillage/widgets/notifications.dart';

class AddressCard extends StatefulWidget {
  AddressCard({
    Key key,
    @required this.address,
    this.selectable = false,
    this.onSelect,
  }) : super(key: key);

  final Address address;
  final bool selectable;
  final Function onSelect;

  @override
  _AddressCardState createState() => _AddressCardState();
}

class _AddressCardState extends State<AddressCard> {
  bool _deleteLoading = false;

  void _deleteAddress() async {
    var store = StoreProvider.of<AppState>(context);
    setState(() => _deleteLoading = true);
    await store.dispatch(removeAddress(
      widget.address,
      onSuccess: () {
        showToast(FlutterI18n.translate(context, 'common.account.address_deleted'));
      },
      onFailed: (errors) {
        // Если ошибки не пришли, то проверим подключение к нету:
        if (errors == null) checkConnect(context);
      },
    ));
    setState(() => _deleteLoading = false);
  }

  void _tapAddress(address) {
    var store = StoreProvider.of<AppState>(context);
    store.dispatch(selectAddress(address));
    if (widget.onSelect != null) widget.onSelect(address);
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, dynamic>(
      converter: (store) => store,
      builder: (context, store) => AnimatedContainer(
        duration: Duration(milliseconds: 500),
        margin: EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: ColorsTheme.bg,
          borderRadius: BorderRadius.circular(14),
          boxShadow: widget.selectable && widget.address == store.state.account.currentAddress
              ? <BoxShadow>[
                  BoxShadow(
                    color: Color.fromRGBO(123, 49, 110, 0.15),
                    offset: Offset(0, 1),
                    blurRadius: 1,
                  ),
                  BoxShadow(
                    color: Color.fromRGBO(133, 41, 115, 0.2),
                    offset: Offset(0, 8),
                    blurRadius: 20,
                  ),
                ]
              : <BoxShadow>[
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
        child: Material(
          color: Colors.transparent,
          clipBehavior: Clip.antiAlias,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: widget.selectable ? () => _tapAddress(widget.address) : null,
            splashColor: ColorsTheme.primary.withOpacity(.4),
            highlightColor: ColorsTheme.primary.withOpacity(.2),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      if (!widget.selectable)
                        Icon(
                          BvIcons.map_marker_2,
                          color: ColorsTheme.primary,
                        ),
                      if (widget.selectable)
                        Container(
                          child: CustomRadio(
                            value: widget.address,
                            activeValue: store.state.account.currentAddress,
                            onChange: (address) => _tapAddress(address),
                          ),
                        ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.address.name,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13.w,
                            letterSpacing: .2,
                            fontWeight: FontWeight.w600,
                            color: ColorsTheme.accent,
                          ),
                        ),
                      ),
                      if (!widget.selectable)
                        Container(
                          margin: EdgeInsets.only(left: 8),
                          child: CircleButton(
                            onTap: () => _deleteAddress(),
                            loading: _deleteLoading,
                            size: 24,
                            child: Icon(BvIcons.remove, color: ColorsTheme.textTertiary, size: 18),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    addressToString(widget.address, oneline: false),
                    style: TextStyle(fontSize: 13.w, height: 1.53),
                  ),
                  if (widget.address.doorphone != null && widget.address.doorphone.isNotEmpty)
                    Container(
                      margin: EdgeInsets.only(top: 8),
                      child: Text.rich(
                        TextSpan(children: [
                          TextSpan(text: FlutterI18n.translate(context, 'common.account.doorphone_code') + ': '),
                          TextSpan(
                            text: widget.address.doorphone,
                            style: TextStyle(fontWeight: FontWeight.w600, color: ColorsTheme.textMain),
                          )
                        ]),
                        style: TextStyle(color: ColorsTheme.textTertiary, fontSize: 13.w, height: 1.53),
                      ),
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
