import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:biovillage/theme/colors.dart';

class CustomNetworkImage extends StatelessWidget {
  CustomNetworkImage({
    Key key,
    @required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.progressWidget,
    this.errorWidget,
  }) : super(key: key);

  final String url;
  final double width;
  final double height;
  final BoxFit fit;
  final Alignment alignment;
  final Widget Function(BuildContext ctx, String url, dynamic dp) progressWidget;
  final Widget Function(BuildContext ctx, String url, dynamic err) errorWidget;

  // Static Params:
  final Duration animDuration = Duration(milliseconds: 100);
  final Duration stalePeriod = Duration(days: 14);
  final int maxNrOfCacheObjects = 99999;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      fadeOutDuration: animDuration,
      fadeInDuration: animDuration,
      imageUrl: url,
      fit: fit,
      alignment: alignment,
      height: height,
      width: height,
      progressIndicatorBuilder: progressWidget ??
          (ctx, url, dp) => Container(
                alignment: Alignment.center,
                child: CupertinoActivityIndicator(radius: 8),
              ),
      errorWidget: errorWidget ??
          (ctx, url, err) => Container(
                alignment: Alignment.center,
                child: Icon(Icons.image_not_supported, color: ColorsTheme.error, size: 22),
              ),
      cacheManager: CacheManager(Config(
        url,
        stalePeriod: stalePeriod,
        maxNrOfCacheObjects: maxNrOfCacheObjects,
      )),
    );
  }
}
