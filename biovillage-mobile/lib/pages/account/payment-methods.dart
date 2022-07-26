import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:biovillage/redux/state/app-state.dart';
import 'package:biovillage/widgets/appbar.dart';
import 'package:biovillage/widgets/account/payment-methods-list.dart';

class PaymentMethodsPageArguments {
  PaymentMethodsPageArguments({this.backAfterChoice = false});
  final bool backAfterChoice;
}

class PaymentMethodsPage extends StatefulWidget {
  PaymentMethodsPage({Key key}) : super(key: key);
  @override
  _PaymentMethodsPageState createState() => _PaymentMethodsPageState();
}

class _PaymentMethodsPageState extends State<PaymentMethodsPage> {
  @override
  Widget build(BuildContext context) {
    final PaymentMethodsPageArguments args = ModalRoute.of(context).settings.arguments;
    final bool backAfterChoice = args != null && args.backAfterChoice ?? false;

    return Scaffold(
      appBar: CustomAppBar(title: FlutterI18n.translate(context, 'common.payment_methods')),
      body: StoreConnector<AppState, dynamic>(
        converter: (store) => store,
        builder: (context, store) {
          if (store.state.account.userInfo == null) return Container();
          String paymentMethodKey = store.state.account.userInfo.paymentMethod.toString().split('.').last;
          String paymentMethodText = FlutterI18n.translate(context, 'common.payment.${paymentMethodKey}_text');
          return SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: PaymentMethodsList(
                      selectable: true,
                      onSelect: (_) {
                        if (backAfterChoice) Timer(Duration(milliseconds: 300), () => Navigator.of(context).pop());
                      },
                    ),
                  ),
                  SizedBox(height: 12),
                  if (paymentMethodText.isNotEmpty)
                    Container(
                      padding: EdgeInsets.all(24),
                      child: Text(paymentMethodText),
                    ),
                  SizedBox(height: 18),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
