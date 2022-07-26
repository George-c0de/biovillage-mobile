import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:biovillage/models/prod-category.dart';
import 'package:biovillage/pages/catalog/category.dart';
import 'package:biovillage/helpers/colors.dart';
import 'package:biovillage/theme/colors.dart';
import 'package:biovillage/widgets/image.dart';

class CategoriesGrid extends StatefulWidget {
  CategoriesGrid({
    Key key,
    @required this.categories,
    this.sliverPadding = const EdgeInsets.symmetric(horizontal: 16),
  }) : super(key: key);
  final List<ProdCategory> categories;
  final EdgeInsetsGeometry sliverPadding;

  @override
  _CategoriesGridState createState() => _CategoriesGridState();
}

class _CategoriesGridState extends State<CategoriesGrid> {
  ScrollController _scrollController;

  @override
  void initState() {
    _scrollController = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Если категорий нет, то выводим сообщение:
    if (widget.categories.isEmpty)
      return SliverToBoxAdapter(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          alignment: Alignment.centerLeft,
          child: Text(
            FlutterI18n.translate(context, 'common.search.no_results'),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.w, fontWeight: FontWeight.w500),
          ),
        ),
      );
    double cardWidth = (MediaQuery.of(context).size.width - 32) / 3 - 8;
    double aspectRatio = cardWidth / 0.727 < 150 ? cardWidth / 150 : 0.727;
    return SliverPadding(
      padding: widget.sliverPadding,
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: aspectRatio,
        ),
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            ProdCategory category = widget.categories[index];
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Color.fromRGBO(123, 49, 110, 0.25),
                    offset: Offset(0, 1),
                    blurRadius: 2,
                  ),
                  BoxShadow(
                    color: Color.fromRGBO(123, 49, 110, 0.25),
                    offset: Offset(0, 10),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Material(
                clipBehavior: Clip.antiAlias,
                borderRadius: BorderRadius.circular(14),
                color: HexColor.fromHex(category.bgColor),
                child: InkWell(
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/category',
                    arguments: CategoryPageArguments(category: category),
                  ),
                  splashColor: Colors.white.withOpacity(.4),
                  highlightColor: Colors.white.withOpacity(.2),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: CustomNetworkImage(
                          url: category.imageSrc,
                          fit: BoxFit.fitWidth,
                          alignment: Alignment.bottomCenter,
                          progressWidget: (ctx, url, dp) => Container(
                            alignment: Alignment.bottomCenter,
                            margin: EdgeInsets.only(bottom: 24),
                            child: CupertinoActivityIndicator(radius: 8),
                          ),
                          errorWidget: (ctx, url, err) => Container(
                            alignment: Alignment.bottomCenter,
                            margin: EdgeInsets.only(bottom: 16),
                            child: Icon(Icons.image_not_supported, color: ColorsTheme.bg),
                          ),
                        ),
                      ),
                      Container(
                        alignment: Alignment.topCenter,
                        padding: EdgeInsets.only(left: 10, right: 10, top: 24),
                        child: Text(
                          category.name,
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          style: TextStyle(
                            color: ColorsTheme.bg,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.1,
                            fontSize: 11.w,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          childCount: widget.categories.length,
        ),
      ),
    );
  }
}
