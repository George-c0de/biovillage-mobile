import 'package:flutter/foundation.dart';
import 'package:biovillage/widgets/map.dart';

/// Проверка на нахождение точки в нескольких многоугольниках
bool checkPointInManyPolygons({@required Point point, @required List<List<Point>> pointsLists}) {
  for (List<Point> pointsList in pointsLists) {
    if (checkPointInPolygon(point: point, pointsList: pointsList)) return true;
  }
  return false;
}

/// Проверка на нахождение точки в многоугольнике
bool checkPointInPolygon({@required Point point, @required List<Point> pointsList}) {
  int intersectCount = 0;
  for (int j = 0; j < pointsList.length - 1; j++) {
    if (_rayCastIntersect(point, pointsList[j], pointsList[j + 1])) {
      intersectCount++;
    }
  }
  return ((intersectCount % 2) == 1);
}

bool _rayCastIntersect(Point point, Point vertA, Point vertB) {
  double aY = vertA.latitude;
  double bY = vertB.latitude;
  double aX = vertA.longitude;
  double bX = vertB.longitude;
  double pY = point.latitude;
  double pX = point.longitude;
  if ((aY > pY && bY > pY) || (aY < pY && bY < pY) || (aX < pX && bX < pX)) {
    return false;
  }
  double m = (aY - bY) / (aX - bX);
  double bee = (-aX) * m + aY;
  double x = (pY - bee) / m;
  return x > pX;
}
