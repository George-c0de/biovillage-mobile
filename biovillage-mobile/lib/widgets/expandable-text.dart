import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:biovillage/theme/colors.dart';

class ExpandableText extends StatefulWidget {
  ExpandableText({
    @required this.text,
    this.textStyle = const TextStyle(),
    this.textAlign = TextAlign.left,
    this.maxLines,
  });

  final String text;
  final TextStyle textStyle;
  final TextAlign textAlign;
  final int maxLines;

  @override
  _ExpandableTextState createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    // Если значение для maxLines не задано, то возвращаем обычный текст:
    if (widget.maxLines == null || widget.maxLines == 0) return Text(widget.text, style: widget.textStyle);
    return LayoutBuilder(builder: (context, size) {
      final span = TextSpan(text: widget.text, style: widget.textStyle);
      final tp = TextPainter(text: span, maxLines: widget.maxLines, textDirection: TextDirection.ltr);
      tp.layout(maxWidth: size.maxWidth);
      if (tp.didExceedMaxLines) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.text,
              textAlign: widget.textAlign,
              style: widget.textStyle,
              overflow: _expanded ? null : TextOverflow.ellipsis,
              maxLines: _expanded ? null : widget.maxLines,
            ),
            MaterialButton(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: EdgeInsets.only(left: 16, right: 16, top: 2),
              height: 28,
              onPressed: () => setState(() => _expanded = !_expanded),
              splashColor: ColorsTheme.accent.withOpacity(.3),
              highlightColor: ColorsTheme.accent.withOpacity(.15),
              child: Text(
                _expanded
                    ? FlutterI18n.translate(context, 'common.text_show_less').toUpperCase()
                    : FlutterI18n.translate(context, 'common.text_show_more').toUpperCase(),
                style: TextStyle(
                  fontSize: 12.w,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                  color: ColorsTheme.accent,
                ),
              ),
            ),
          ],
        );
      } else {
        return Text(
          widget.text,
          textAlign: widget.textAlign,
          style: widget.textStyle,
        );
      }
    });
  }
}
