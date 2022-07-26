import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:biovillage/redux/state/app-state.dart';
import 'package:biovillage/redux/actions/cart.dart';
import 'package:biovillage/models/delivery-interval.dart';
import 'package:biovillage/helpers/delivery-intervals.dart';
import 'package:biovillage/helpers/colors.dart';
import 'package:biovillage/theme/colors.dart';
import 'package:biovillage/theme/bv-icons.dart';
import 'package:biovillage/widgets/appbar.dart';
import 'package:biovillage/widgets/form-elements.dart';

class DeliveryIntervalsPage extends StatefulWidget {
  DeliveryIntervalsPage({Key key}) : super(key: key);

  @override
  DeliveryIntervalsPageState createState() => DeliveryIntervalsPageState();
}

class DeliveryIntervalsPageState extends State<DeliveryIntervalsPage> with SingleTickerProviderStateMixin {
  List<Weekday> _weekDays;
  DeliveryInterval _currentDeliveryInterval;

  /// Выбор интервала
  void _selectInterval(DeliveryInterval di, DateTime date) async {
    di.date = date;
    setState(() => _currentDeliveryInterval = di);
    var store = StoreProvider.of<AppState>(context);
    store.dispatch(selectDeliveryInterval(_currentDeliveryInterval));
    await Future.delayed(Duration(milliseconds: 500));
    Navigator.pop(context, '/cart-step-2');
  }

  /// Получение лейбла для дня доставки
  String _getDateLabel(Weekday weekday) {
    final String dateFormat = 'yyyy-MM-dd';
    final dateNow = DateTime.now();
    if (DateFormat(dateFormat).format(weekday.date) == DateFormat(dateFormat).format(dateNow)) {
      return FlutterI18n.translate(context, 'common.delivery_intervals.today');
    }
    if (DateFormat(dateFormat).format(weekday.date) == DateFormat(dateFormat).format(dateNow.add(Duration(days: 1)))) {
      return FlutterI18n.translate(context, 'common.delivery_intervals.tommorow');
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Устанавливаем выбранный интервал из хранилища:
      var store = StoreProvider.of<AppState>(context);
      setState(() {
        _currentDeliveryInterval = store.state.cart.deliveryInterval;
        _weekDays = calcWeekdaysOrder(DateTime.now(), store.state.general.deliveryIntervals, daysLength: 7);
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: FlutterI18n.translate(context, 'common.delivery_intervals.select_time')),
      drawerEdgeDragWidth: 0,
      body: StoreConnector<AppState, dynamic>(
        converter: (store) => store,
        builder: (context, store) => SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                if (_weekDays != null)
                  for (int i = 0; i < _weekDays.length; i++)
                    _DeliveryIntervalDay(
                      currentInterval: _currentDeliveryInterval,
                      onSelect: (DeliveryInterval di, DateTime date) => _selectInterval(di, date),
                      dayOfWeek: _weekDays[i].weekdayNum,
                      minStartHour: _weekDays[i].minStartHour,
                      date: _weekDays[i].date,
                      dateLabel: _getDateLabel(_weekDays[i]),
                      deliveryIntervals: store.state.general.deliveryIntervals[_weekDays[i].weekdayNum],
                      isExpanded: store.state.cart.deliveryInterval != null
                          ? _weekDays[i].weekdayNum == store.state.cart.deliveryInterval.dayOfWeek
                          : i < 2,
                      showDivider: i + 1 < _weekDays.length,
                    ),
                SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

typedef OnSelectDeliveryInterval = Function(DeliveryInterval deliveryInterval, DateTime date);

class _DeliveryIntervalDay extends StatefulWidget {
  _DeliveryIntervalDay({
    Key key,
    @required this.currentInterval,
    @required this.onSelect,
    @required this.dayOfWeek,
    @required this.date,
    @required this.deliveryIntervals,
    this.minStartHour,
    this.dateLabel,
    this.isExpanded = false,
    this.showDivider = false,
  }) : super(key: key);

  final DeliveryInterval currentInterval;
  final OnSelectDeliveryInterval onSelect;
  final int dayOfWeek;
  final DateTime date;
  final List<DeliveryInterval> deliveryIntervals;
  final int minStartHour;
  final String dateLabel;
  final bool isExpanded;
  final bool showDivider;

  @override
  _DeliveryIntervalDayState createState() => _DeliveryIntervalDayState();
}

class _DeliveryIntervalDayState extends State<_DeliveryIntervalDay> with SingleTickerProviderStateMixin {
  AnimationController _expandController;

  void _toggleExpand() {
    if (_expandController.isCompleted)
      _expandController.reverse();
    else
      _expandController.forward();
  }

  @override
  void initState() {
    _expandController = AnimationController(duration: Duration(milliseconds: 300), vsync: this);
    if (widget.isExpanded) _toggleExpand();
    super.initState();
  }

  @override
  void dispose() {
    _expandController.dispose();
    super.dispose();
  }

  bool _checkIntervalActivity(int i) {
    if (widget.deliveryIntervals[i].active && widget.minStartHour == null) return true;
    if (widget.deliveryIntervals[i].startHour >= widget.minStartHour) return true;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.deliveryIntervals == null || widget.deliveryIntervals.isEmpty) return Container();
    return Container(
      decoration: BoxDecoration(
        border: widget.showDivider
            ? Border(
                bottom: BorderSide(
                  color: darken(ColorsTheme.bg, .04),
                  width: 4,
                ),
              )
            : null,
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => _toggleExpand(),
            splashColor: ColorsTheme.primary.withOpacity(.3),
            highlightColor: ColorsTheme.primary.withOpacity(.15),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Row(
                children: [
                  Icon(BvIcons.calendar, color: ColorsTheme.primary),
                  SizedBox(width: 12),
                  Text(
                    FlutterI18n.translate(context, 'common.delivery_intervals.day_${widget.dayOfWeek}_short') +
                        ', ' +
                        DateFormat(FlutterI18n.translate(context, 'common.date_format')).format(widget.date),
                    style: TextStyle(
                      fontSize: 14.w,
                      fontWeight: FontWeight.w700,
                      letterSpacing: .2,
                    ),
                  ),
                  if (widget.dateLabel != null)
                    Container(
                      margin: EdgeInsets.only(left: 4),
                      child: Text(
                        '(' + widget.dateLabel + ')',
                        style: TextStyle(
                          fontSize: 13.w,
                          letterSpacing: .2,
                          color: ColorsTheme.textTertiary,
                        ),
                      ),
                    ),
                  Spacer(),
                  SizedBox(width: 4),
                  RotationTransition(
                    turns: Tween(begin: 0.0, end: -0.5).animate(_expandController),
                    child: Icon(BvIcons.chevron_down, color: ColorsTheme.textFivefold),
                  ),
                ],
              ),
            ),
          ),
          SizeTransition(
            sizeFactor: CurvedAnimation(parent: _expandController, curve: Curves.easeOut),
            axisAlignment: -1,
            child: Column(
              children: [
                Container(height: 1, color: darken(ColorsTheme.bg, .04)),
                SizedBox(height: 8),
                for (int i = 0; i < widget.deliveryIntervals.length; i++)
                  GestureDetector(
                    onTap: _checkIntervalActivity(i)
                        ? () => widget.onSelect(widget.deliveryIntervals[i], widget.date)
                        : null,
                    child: Opacity(
                      opacity: _checkIntervalActivity(i) ? 1 : 0.4,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            CustomRadio(
                              value: widget.deliveryIntervals[i],
                              activeValue: widget.currentInterval,
                              onChange: widget.deliveryIntervals[i].active
                                  ? (v) => widget.onSelect(widget.deliveryIntervals[i], widget.date)
                                  : null,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                widget.deliveryIntervals[i].intervalText,
                                style: TextStyle(fontSize: 13.w, fontWeight: FontWeight.w700, letterSpacing: .2),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
