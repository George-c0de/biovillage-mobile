import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:biovillage/theme/colors.dart';

/// Отображение прелоадера на время выполнения [loadingFunction]
void showPreloader(Function loadingFunction) {
  showOverlay((overlayContext, t) {
    return Opacity(
      opacity: t,
      child: _PreloaderWidget(
        loadingFunction: () async {
          await loadingFunction();
          OverlaySupportEntry.of(overlayContext).dismiss();
        },
      ),
    );
  }, duration: Duration.zero);
}

class _PreloaderWidget extends StatefulWidget {
  _PreloaderWidget({Key key, @required this.loadingFunction}) : super(key: key);
  final Function loadingFunction;

  @override
  _PreloaderWidgetState createState() => _PreloaderWidgetState();
}

class _PreloaderWidgetState extends State<_PreloaderWidget> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    widget.loadingFunction();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ColorsTheme.bg.withOpacity(.7),
      child: CircularLoader(),
    );
  }
}

class CircularLoader extends StatelessWidget {
  CircularLoader({this.size = 120, this.strokeWidth = 6, this.showLogo = true});
  final double size;
  final double strokeWidth;
  final bool showLogo;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          children: [
            Positioned.fill(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(ColorsTheme.accent),
                strokeWidth: strokeWidth,
              ),
            ),
            if (showLogo)
              Positioned.fill(
                child: Container(
                  alignment: Alignment.center,
                  child: Image(
                    image: AssetImage('assets/img/logo_preloader.png'),
                    width: size / 2,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
