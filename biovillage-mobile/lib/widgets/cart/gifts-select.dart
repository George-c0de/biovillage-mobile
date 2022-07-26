import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:biovillage/models/gift.dart';
import 'package:biovillage/helpers/colors.dart';
import 'package:biovillage/theme/colors.dart';
import 'package:biovillage/theme/bv-icons.dart';
import 'package:biovillage/widgets/notifications.dart';
import 'package:biovillage/widgets/preloader.dart';
import 'package:biovillage/widgets/image.dart';

class GiftsSelect extends StatefulWidget {
  GiftsSelect({
    Key key,
    @required this.gifts,
    @required this.balance,
    @required this.onChange,
    this.connect = true,
  }) : super(key: key);

  final List<Gift> gifts;
  final int balance;
  final Function onChange;
  final bool connect;

  @override
  _GiftsSelectState createState() => _GiftsSelectState();
}

class _GiftsSelectState extends State<GiftsSelect> with SingleTickerProviderStateMixin {
  List<Gift> _selectedGifts = [];

  void _toggleGift(Gift gift) {
    if (_selectedGifts.contains(gift)) {
      setState(() => _selectedGifts.remove(gift));
    } else {
      int balance = widget.balance - _selectedGifts.fold(0, (acc, gift) => acc + gift.price);
      if (balance < gift.price) {
        showToast(FlutterI18n.translate(context, 'common.cart.not_enough_points'));
        return;
      }
      setState(() => _selectedGifts.add(gift));
    }
    widget.onChange(_selectedGifts);
  }

  @override
  Widget build(BuildContext context) {
    double cardWidth = (MediaQuery.of(context).size.width - 32) / 3 - (8 - 8 / 3);
    if (widget.gifts == null)
      return Column(
        children: [
          SizedBox(height: 30),
          CircularLoader(size: 80, strokeWidth: 5),
          if (!widget.connect)
            Container(
              margin: EdgeInsets.only(top: 20),
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                FlutterI18n.translate(context, 'common.no_internet'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: ColorsTheme.error,
                  fontSize: 13.w,
                ),
              ),
            ),
          SizedBox(height: 30),
        ],
      );
    else
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (Gift gift in widget.gifts)
            AnimatedContainer(
              width: cardWidth,
              duration: Duration(milliseconds: 500),
              decoration: BoxDecoration(
                color: ColorsTheme.bg,
                borderRadius: BorderRadius.circular(14),
                boxShadow: _selectedGifts.contains(gift)
                    ? <BoxShadow>[
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
                      ]
                    : <BoxShadow>[],
              ),
              child: Material(
                color: ColorsTheme.bg,
                clipBehavior: Clip.antiAlias,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  onTap: () => _toggleGift(gift),
                  splashColor: ColorsTheme.accent.withOpacity(.4),
                  highlightColor: ColorsTheme.accent.withOpacity(.2),
                  child: Stack(
                    children: [
                      Container(
                        padding: EdgeInsets.fromLTRB(10, 10, 10, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            CustomNetworkImage(
                              url: gift.imgUrl,
                              height: 100,
                            ),
                            SizedBox(height: 6),
                            Container(
                              height: 32,
                              alignment: Alignment.center,
                              child: Text(
                                gift.name,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style: TextStyle(
                                  fontSize: 12.w,
                                  fontWeight: FontWeight.w700,
                                  color: ColorsTheme.accent,
                                  height: 1.1,
                                ),
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              '${gift.price} ' +
                                  FlutterI18n.translate(context, 'common.cart.points_unit').toLowerCase(),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11.w,
                                fontWeight: FontWeight.w600,
                                color: ColorsTheme.accent,
                                letterSpacing: .2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 6,
                        right: 6,
                        width: 20,
                        height: 20,
                        child: Stack(
                          children: [
                            Container(
                              child: Icon(
                                BvIcons.check_circle,
                                color: _selectedGifts.contains(gift) ? ColorsTheme.accent : darken(ColorsTheme.bg, .15),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      );
  }
}
