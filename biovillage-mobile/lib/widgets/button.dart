import 'package:flutter/material.dart';
import 'package:biovillage/theme/colors.dart';

enum ButtonColor { accent, primary }

class Button extends StatefulWidget {
  Button({
    @required this.onTap,
    this.label,
    this.child,
    this.loading = false,
    this.disabled = false,
    this.color = ButtonColor.accent,
    this.outlined = false,
    this.flat = false,
    this.height = 44,
    this.fontSize = 13,
    this.fontWeight = FontWeight.w600,
    this.disableShadow = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
  });

  final Function onTap;
  final String label;
  final Widget child;
  final bool loading;
  final bool disabled;
  final ButtonColor color;
  final bool outlined;
  final bool flat;
  final double height;
  final double fontSize;
  final FontWeight fontWeight;
  final bool disableShadow;
  final EdgeInsets padding;

  @override
  _ButtonState createState() => _ButtonState();
}

class _ButtonState extends State<Button> {
  Color _mainColor;
  Color _splashColor;
  Color _highlightColor;
  List<BoxShadow> _shadow = [
    BoxShadow(
      color: Color.fromRGBO(123, 49, 110, 0.15),
      offset: Offset(0, 1),
      blurRadius: 1,
    ),
    BoxShadow(
      color: Color.fromRGBO(123, 49, 110, 0.25),
      offset: Offset(0, 10),
      blurRadius: 20,
    ),
  ];

  @override
  void initState() {
    super.initState();
    setState(() {
      // Определяем цвета в зависимости от выбранной темы кнопки:
      switch (widget.color) {
        case ButtonColor.accent:
          _mainColor = ColorsTheme.accent;
          break;
        case ButtonColor.primary:
          _mainColor = ColorsTheme.primary;
          break;
      }
      // Определяем цвета и тени в зависимости от типа кнопки:
      if (widget.outlined || widget.disableShadow || widget.flat) _shadow = null;
      if (widget.outlined || widget.flat) {
        _splashColor = _mainColor.withOpacity(.2);
        _highlightColor = _mainColor.withOpacity(.15);
      } else {
        _splashColor = ColorsTheme.bg.withOpacity(.25);
        _highlightColor = ColorsTheme.bg.withOpacity(.1);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: widget.disabled ? .7 : 1,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(7),
          border: widget.outlined && !widget.flat ? Border.all(color: _mainColor) : null,
          boxShadow: _shadow,
        ),
        child: Material(
          clipBehavior: Clip.antiAlias,
          borderRadius: BorderRadius.circular(7),
          color: widget.outlined || widget.flat ? Colors.transparent : _mainColor,
          child: InkWell(
            onTap: widget.loading || widget.disabled ? null : () => widget.onTap(),
            splashColor: _splashColor,
            highlightColor: _highlightColor,
            child: Container(
              alignment: Alignment.center,
              height: widget.height,
              padding: widget.padding,
              child: Material(
                color: Colors.transparent,
                child: widget.loading
                    ? SizedBox(
                        height: widget.height * 0.6,
                        width: widget.height * 0.6,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              widget.outlined || widget.flat ? _mainColor : ColorsTheme.bg),
                          strokeWidth: 2,
                        ),
                      )
                    : widget.child == null
                        ? Text(
                            widget.label ?? '',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: widget.outlined || widget.flat ? _mainColor : ColorsTheme.bg,
                              fontSize: widget.fontSize,
                              fontWeight: widget.fontWeight,
                            ),
                          )
                        : widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CircleButton extends StatelessWidget {
  CircleButton({
    @required this.onTap,
    @required this.size,
    this.color = Colors.transparent,
    this.boxShadow,
    this.disabled = false,
    this.splashColor,
    this.highlightColor,
    @required this.child,
    this.loading = false,
    this.loaderColor,
  });

  final Function onTap;
  final double size;
  final Color color;
  final List<BoxShadow> boxShadow;
  final bool disabled;
  final Color splashColor;
  final Color highlightColor;
  final Widget child;
  final bool loading;
  final Color loaderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color, boxShadow: boxShadow),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: disabled || loading ? null : () => onTap(),
          splashColor: splashColor,
          highlightColor: highlightColor,
          child: Opacity(
            opacity: disabled ? .5 : 1,
            child: Center(
              child: loading
                  ? SizedBox(
                      height: size * 0.6,
                      width: size * 0.6,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(loaderColor ?? ColorsTheme.accent),
                        strokeWidth: 2,
                      ),
                    )
                  : child,
            ),
          ),
        ),
      ),
    );
  }
}
