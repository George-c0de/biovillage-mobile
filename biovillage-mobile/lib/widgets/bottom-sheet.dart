import 'package:flutter/material.dart';
import 'package:biovillage/theme/colors.dart';
import 'package:biovillage/theme/bv-icons.dart';
import 'package:biovillage/widgets/button.dart';

showCustomBottomSheet(
  BuildContext context, {
  @required Widget Function(ScrollController scrollController) builder,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    enableDrag: true,
    barrierColor: Color.fromRGBO(15, 14, 14, .66),
    backgroundColor: ColorsTheme.bg,
    clipBehavior: Clip.antiAlias,
    elevation: 25,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
    builder: (context) => _CustomBottomSheet(builder: builder),
  );
}

class _CustomBottomSheet extends StatelessWidget {
  _CustomBottomSheet({@required this.builder});
  final Widget Function(ScrollController scrollController) builder;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: .89,
      maxChildSize: .89,
      minChildSize: .65,
      expand: false,
      builder: (context, scrollController) => Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
        ),
        child: Stack(
          children: [
            builder(scrollController),
            Positioned(
              right: 0,
              top: 0,
              child: CircleButton(
                onTap: () => Navigator.pop(context),
                size: 60,
                color: Colors.transparent,
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                child: Icon(BvIcons.close, size: 22, color: ColorsTheme.textTertiary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
