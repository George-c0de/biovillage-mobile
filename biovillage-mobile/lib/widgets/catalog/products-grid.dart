import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:biovillage/models/product.dart';
import 'package:biovillage/widgets/catalog/product-card.dart';

class ProductsGrid extends StatefulWidget {
  ProductsGrid({
    Key key,
    @required this.products,
    this.sliverPadding = const EdgeInsets.symmetric(horizontal: 16),
  }) : super(key: key);

  final List<Product> products;
  final EdgeInsetsGeometry sliverPadding;

  @override
  _ProductsGridState createState() => _ProductsGridState();
}

class _ProductsGridState extends State<ProductsGrid> {
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
    if (widget.products.isEmpty)
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
    double aspectRatio = cardWidth / 0.519 < 210 ? cardWidth / 210 : 0.519;
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
            return ProductCard(
              product: widget.products[index],
              specialProductGroup: widget.products,
            );
          },
          childCount: widget.products.length,
        ),
      ),
    );
  }
}
