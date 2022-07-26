import 'package:flutter/material.dart';
import 'package:auto_animated/auto_animated.dart';

/// Функция, анимирующая появление картинок категорий и товаров
Widget Function(BuildContext context, int index, Animation<double> animation) cardsAnimationBuilder(
  Widget Function(int index) child, {
  EdgeInsets padding = EdgeInsets.zero,
}) {
  return (BuildContext context, int index, Animation<double> animation) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0, end: 1).animate(animation),
      child: SlideTransition(
        position: Tween<Offset>(begin: Offset(0, 0.15), end: Offset.zero).animate(animation),
        child: child(index),
      ),
    );
  };
}

/// Виджет для анимированного появления элементов (scale + fade)
class FadeIfVisible extends StatefulWidget {
  FadeIfVisible({
    Key key,
    @required this.child,
    @required this.animKey,
    this.duration = const Duration(milliseconds: 300),
  }) : super(key: key);

  final Widget child;
  final String animKey;
  final Duration duration;

  @override
  _FadeIfVisibleState createState() => _FadeIfVisibleState();
}

class _FadeIfVisibleState extends State<FadeIfVisible> {
  @override
  Widget build(BuildContext context) {
    return AnimateIfVisible(
      key: Key(widget.animKey),
      duration: widget.duration,
      builder: (BuildContext context, Animation<double> animation) => FadeTransition(
        opacity: Tween<double>(begin: 0, end: 1).animate(animation),
        child: widget.child,
      ),
    );
  }
}
