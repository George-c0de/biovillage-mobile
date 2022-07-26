import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:biovillage/theme/colors.dart';
import 'package:biovillage/widgets/appbar.dart';
import 'package:biovillage/widgets/notifications.dart';
import 'package:biovillage/widgets/button.dart';

typedef OnWebViewCreated = Function(String url);
typedef OnPageFinished = Function(String url);
typedef OnPageStarted = Function(String url);

class InappBrowserArguments {
  InappBrowserArguments({
    @required this.initialUrl,
    this.title,
    this.onWebViewCreated,
    this.onPageFinished,
    this.onPageStarted,
  });
  final String initialUrl;
  final String title;
  final OnWebViewCreated onWebViewCreated;
  final OnPageFinished onPageFinished;
  final OnPageStarted onPageStarted;
}

class InappBrowser extends StatefulWidget {
  @override
  _InappBrowserState createState() => _InappBrowserState();
}

class _InappBrowserState extends State<InappBrowser> {
  final Completer<WebViewController> _controller = Completer<WebViewController>();
  WebViewController _webViewController;
  bool _showReloadBtn = false;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    final InappBrowserArguments args = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: CustomAppBar(
        title: args.title,
        appendWidget: _showReloadBtn
            ? CircleButton(
                onTap: () => _webViewController.reload(),
                size: 42,
                child: Icon(Icons.replay, size: 24, color: ColorsTheme.accent),
                splashColor: ColorsTheme.accent.withOpacity(.4),
                highlightColor: ColorsTheme.accent.withOpacity(.2),
              )
            : null,
      ),
      body: Builder(builder: (BuildContext context) {
        return WebView(
          initialUrl: args.initialUrl,
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (WebViewController webViewController) async {
            _controller.complete(webViewController);
            _webViewController = webViewController;
            if (args.onWebViewCreated != null) {
              String url = await webViewController.currentUrl();
              args.onWebViewCreated(url);
            }
          },
          onPageStarted: (url) {
            if (args.onPageStarted != null) args.onPageStarted(url);
          },
          onPageFinished: (url) {
            // onPageStarted не срабатывает для iOS, поэтому выполним коллбэк здесь:
            if (Platform.isIOS && args.onPageStarted != null) args.onPageStarted(url);
            if (args.onPageFinished != null) args.onPageFinished(url);
          },
          onWebResourceError: (error) {
            showToast(FlutterI18n.translate(context, 'common.pageload_error'), isError: true);
            setState(() => _showReloadBtn = true);
          },
        );
      }),
    );
  }
}
