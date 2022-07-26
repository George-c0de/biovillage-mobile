import 'dart:async';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/cupertino.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:biovillage/helpers/colors.dart';
import 'package:biovillage/theme/colors.dart';
import 'package:biovillage/theme/icons-raw.dart';

export 'package:yandex_mapkit/yandex_mapkit.dart';

class CustomMap extends StatefulWidget {
  CustomMap({
    Key key,
    @required this.center,
    this.zoom = 12.6,
    this.polygons,
    this.markers,
    this.termsLink = true,
  }) : super(key: key);

  final Point center;
  final double zoom;
  final List<Polygon> polygons;
  final List<Point> markers;
  final bool termsLink;

  @override
  _CustomMapState createState() => _CustomMapState();
}

class _CustomMapState extends State<CustomMap> with TickerProviderStateMixin {
  bool loading = true;

  @override
  void initState() {
    // Задержка появления карты для исключения лагов анимации:
    Timer(Duration(milliseconds: 300), () => setState(() => loading = false));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    YandexMapController _mapController;

    return loading
        ? Container(
            color: darken(ColorsTheme.bg, .06),
            alignment: Alignment.center,
            child: CupertinoActivityIndicator(radius: 12),
          )
        : Stack(
            children: [
              Positioned.fill(
                child: YandexMap(
                  onMapCreated: (YandexMapController yandexMapController) async {
                    _mapController = yandexMapController;

                    // Устанавливаем центр карты и зум:
                    await _mapController.move(point: widget.center, zoom: widget.zoom, tilt: 0);

                    // Маркеры:
                    if (widget.markers != null)
                      widget.markers.forEach((marker) async {
                        await _mapController.addPlacemark(Placemark(
                          point: marker,
                          style: PlacemarkStyle(opacity: 1, scale: .8, rawImageData: placeIconRawData),
                        ));
                      });

                    // Полигоны:
                    if (widget.polygons != null)
                      widget.polygons.forEach((polygon) async {
                        await _mapController.addPolygon(polygon);
                      });
                  },
                ),
              ),
              if (widget.termsLink)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 9.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8.w),
                    margin: EdgeInsets.only(right: 70),
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: FlutterI18n.translate(context, 'common.yandexMap.termsText'),
                            style: TextStyle(color: ColorsTheme.textMain, decoration: TextDecoration.underline),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => launch(FlutterI18n.translate(context, 'common.yandexMap.termsUrl')),
                          ),
                        ],
                      ),
                      style: TextStyle(fontSize: 12.w, height: 1.5),
                    ),
                  ),
                ),
            ],
          );
  }
}
