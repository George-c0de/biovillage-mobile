import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:biovillage/models/prod-category.dart';
import 'package:biovillage/pages/catalog/category.dart';
import 'package:biovillage/helpers/colors.dart';
import 'package:biovillage/theme/bv-icons.dart';
import 'package:biovillage/theme/colors.dart';
import 'package:biovillage/widgets/image.dart';

class CategoriesList extends StatefulWidget {
  CategoriesList({Key key, @required this.categories}) : super(key: key);
  final List<ProdCategory> categories;

  @override
  _CategoriesListState createState() => _CategoriesListState();
}

class _CategoriesListState extends State<CategoriesList> {
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
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          ProdCategory category = widget.categories[index];
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Navigator.pushNamed(
                context,
                '/category',
                arguments: CategoryPageArguments(category: category),
              ),
              splashColor: ColorsTheme.primary.withOpacity(.4),
              highlightColor: ColorsTheme.primary.withOpacity(.2),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(
                  children: [
                    Container(
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: HexColor.fromHex(category.bgColor),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: CustomNetworkImage(
                        url: category.imageSrc,
                        fit: BoxFit.fitWidth,
                        alignment: Alignment.bottomCenter,
                        width: 36,
                        height: 36,
                        progressWidget: (ctx, url, dp) => Container(
                          color: darken(ColorsTheme.bg, .02),
                          alignment: Alignment.center,
                          child: CupertinoActivityIndicator(radius: 8),
                        ),
                        errorWidget: (ctx, url, err) => Container(
                          color: darken(ColorsTheme.bg, .02),
                          alignment: Alignment.center,
                          child: Icon(Icons.image_not_supported, color: ColorsTheme.error, size: 16),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        category.name,
                        style: TextStyle(fontSize: 11.w, fontWeight: FontWeight.w800, height: 1.45),
                      ),
                    ),
                    SizedBox(width: 12),
                    Container(
                      padding: EdgeInsets.only(right: 6),
                      child: Icon(BvIcons.arrow_right, color: ColorsTheme.primary, size: 12),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        childCount: widget.categories.length,
      ),
    );
  }
}
