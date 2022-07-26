import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:biovillage/models/slide.dart';
import 'package:biovillage/helpers/colors.dart';
import 'package:biovillage/theme/colors.dart';
import 'package:biovillage/widgets/image.dart';

class MainSlider extends StatefulWidget {
  MainSlider({
    Key key,
    @required this.slides,
  }) : super(key: key);

  final List<Slide> slides;

  @override
  _MainSliderState createState() => _MainSliderState();
}

class _MainSliderState extends State<MainSlider> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      height: 172,
      decoration: BoxDecoration(
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Color.fromRGBO(123, 49, 110, 0.1),
            offset: Offset(0, 15),
            blurRadius: 30,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        child: Swiper(
          itemCount: widget.slides.length,
          itemBuilder: (BuildContext context, int index) {
            Slide slide = widget.slides[index];
            return Container(
              color: HexColor.fromHex(slide.bgColor),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomNetworkImage(
                      url: slide.imgUrl,
                      fit: BoxFit.fitHeight,
                      alignment: Alignment.bottomRight,
                      progressWidget: (ctx, url, dp) => Container(
                        alignment: Alignment.centerRight,
                        margin: EdgeInsets.only(right: 24),
                        child: CupertinoActivityIndicator(radius: 12),
                      ),
                      errorWidget: (ctx, url, err) => Container(
                        alignment: Alignment.centerRight,
                        margin: EdgeInsets.only(right: 24),
                        child: Icon(Icons.image_not_supported, color: ColorsTheme.bg),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      padding: EdgeInsets.only(left: 24, top: 24, bottom: 24, right: 116),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            slide.title.replaceAll('\\n', '\n'),
                            softWrap: false,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 21.w,
                              height: 1.17,
                              fontWeight: FontWeight.w800,
                              color: ColorsTheme.bg,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            slide.subtitle.replaceAll('\\n', '\n'),
                            softWrap: false,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11.w,
                              height: 1.45,
                              fontWeight: FontWeight.w500,
                              color: ColorsTheme.bg,
                              // lin
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
          pagination: SwiperCustomPagination(
            builder: (BuildContext context, SwiperPluginConfig config) {
              int itemCount = config.itemCount;
              if (itemCount < 2) return Container();
              int activeIndex = config.activeIndex;
              Color activeColor = ColorsTheme.bg;
              Color color = ColorsTheme.bg.withOpacity(.5);
              List<Widget> dotsList = [];
              for (int i = 0; i < itemCount; ++i) {
                bool active = i == activeIndex;
                dotsList.add(Container(
                  key: Key('pagination_$i'),
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  child: ClipOval(
                    child: Container(
                      color: active ? activeColor : color,
                      width: 5,
                      height: 5,
                    ),
                  ),
                ));
              }
              return Container(
                alignment: Alignment.bottomCenter,
                padding: EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: dotsList,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
