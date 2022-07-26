import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:biovillage/models/delivery-interval.dart';

// Номера дня недель для связки флаттера с бэком:
final Map<String, int> _weekdaysNums = {'Mon': 1, 'Tue': 2, 'Wed': 3, 'Thu': 4, 'Fri': 5, 'Sat': 6, 'Sun': 7};

// Минимальная задержка с тек. момента до первого доступного интервала доставки в часах:
final int _minDelayHours = 5;

/// Вспомогательная модель для дня недели
class Weekday {
  int weekdayNum;
  int minStartHour;
  DateTime date;

  Weekday({
    @required this.weekdayNum,
    @required this.date,
    this.minStartHour,
  });
}

/// Подсчет порядка дней недели и их дат для выбора интервала доставки
List<Weekday> calcWeekdaysOrder(DateTime dateNow, Map<int, List<DeliveryInterval>> deliveryIntervals,
    {int daysLength = 7}) {
  int delayHours = _minDelayHours;
  if (dateNow.minute > 0) delayHours += 1;
  int minStartHour = dateNow.hour + delayHours;
  if (minStartHour > 23) {
    minStartHour = null;
    dateNow = dateNow.add(Duration(days: 1));
  } else {
    DeliveryInterval todayInterval = deliveryIntervals[_weekdaysNums[DateFormat('E').format(dateNow)]].firstWhere(
      (di) => di.startHour >= minStartHour,
      orElse: () => null,
    );
    if (todayInterval == null) {
      minStartHour = null;
      dateNow = dateNow.add(Duration(days: 1));
    }
  }

  Weekday currWeekday = Weekday(
    weekdayNum: _weekdaysNums[DateFormat('E').format(dateNow)],
    date: dateNow,
    minStartHour: minStartHour,
  );

  List<Weekday> weekDays = [];
  for (int i = 0; i < daysLength; i++) {
    weekDays.add(currWeekday);
    currWeekday = Weekday(
      weekdayNum: currWeekday.weekdayNum >= 7 ? 1 : currWeekday.weekdayNum + 1,
      date: currWeekday.date.add(Duration(days: 1)),
    );
  }
  return weekDays;
}

/// Поиск интервала доставки по его id
DeliveryInterval findDeliveryIntervalById(int id, Map<int, List<DeliveryInterval>> deliveryIntervals) {
  DeliveryInterval result;
  deliveryIntervals.forEach((key, value) {
    DeliveryInterval di = value.firstWhere((di) => di.id == id, orElse: () => null);
    if (di != null) {
      result = di;
      return false;
    }
  });
  return result;
}
