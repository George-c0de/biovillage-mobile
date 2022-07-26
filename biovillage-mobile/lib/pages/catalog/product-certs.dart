import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:biovillage/helpers/colors.dart';
import 'package:biovillage/theme/colors.dart';
import 'package:biovillage/widgets/appbar.dart';
import 'package:biovillage/widgets/button.dart';
import 'package:biovillage/widgets/image.dart';

class ProductCertsPageArguments {
  ProductCertsPageArguments({@required this.certs});
  final List<String> certs;
}

class ProductCertsPage extends StatefulWidget {
  ProductCertsPage({Key key}) : super(key: key);
  @override
  _ProductCertsPageState createState() => _ProductCertsPageState();
}

class _ProductCertsPageState extends State<ProductCertsPage> {
  @override
  Widget build(BuildContext context) {
    final ProductCertsPageArguments args = ModalRoute.of(context).settings.arguments;
    final List<String> certs = args.certs;
    return Scaffold(
      appBar: CustomAppBar(title: FlutterI18n.translate(context, 'common.product.certs_page_title')),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (String cert in certs)
                  Container(
                    margin: EdgeInsets.only(bottom: 24),
                    child: CustomNetworkImage(
                      url: cert,
                      progressWidget: (ctx, url, dp) => Container(
                        padding: EdgeInsets.symmetric(vertical: 48),
                        color: darken(ColorsTheme.bg, .02),
                        alignment: Alignment.center,
                        child: CupertinoActivityIndicator(radius: 12),
                      ),
                      errorWidget: (ctx, url, err) => Container(
                        padding: EdgeInsets.symmetric(vertical: 48),
                        color: darken(ColorsTheme.bg, .02),
                        alignment: Alignment.center,
                        child: Icon(Icons.image),
                      ),
                    ),
                  ),
                Button(
                  onTap: () => Navigator.pop(context),
                  label: FlutterI18n.translate(context, 'common.back'),
                  color: ButtonColor.primary,
                  outlined: true,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
