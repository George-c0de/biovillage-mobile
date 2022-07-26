import 'package:flutter/material.dart';
import 'package:biovillage/theme/colors.dart';

class CirclesPattern extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 8,
      transform: Matrix4.translationValues(0, -2, 0),
      child: CustomPaint(
        painter: _CirclesPatternPainter(),
      ),
    );
  }
}

class _CirclesPatternPainter extends CustomPainter {
  final double _circleSize = 33;
  final double _overlaySize = 12;
  final Paint _paint = Paint()
    ..color = ColorsTheme.bg
    ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    int count = (size.width / (_circleSize - _overlaySize)).ceil() + 1;
    double top = -_circleSize + size.height;
    double offsetLeft = (count * (_circleSize - _overlaySize) - size.width + _overlaySize) / -2;
    canvas.clipRect(Rect.fromLTRB(0, 0, size.width, size.height), doAntiAlias: true);
    for (int i = 0; i < count; i++) {
      double left = offsetLeft + i * (_circleSize - _overlaySize);
      canvas.drawOval(Rect.fromLTWH(left, top, _circleSize, _circleSize), _paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
