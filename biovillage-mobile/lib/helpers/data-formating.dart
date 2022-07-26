import 'package:flutter/foundation.dart';
import 'package:biovillage/models/address.dart';
import 'package:biovillage/widgets/notifications.dart';

/// Приведение double в String с удалением  лишних нулей
String doubleToSting(double n) {
  return n.toString().replaceAll(RegExp(r'([.]*0)(?!.*\d)'), '');
}

/// Привидение числа в строку с разделением на разряды
String numToString(num number) {
  return number.toString().replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), ' ');
}

/// Форматирование веса
String formatWeight({
  @required int amount,
  @required int unitStep,
  @required int unitFactor,
  @required String unitShortName,
  @required String unitShortDerName,
}) {
  num total = amount * unitStep;
  if (total < unitFactor) return numToString(total) + ' ' + unitShortName;
  total = num.parse((total / unitFactor).toStringAsFixed(2));
  return numToString(total).replaceAll(RegExp(r"([.]*0)(?!.*\d)"), '') + ' ' + unitShortDerName;
}

/// Удаление всех букв и символов, кроме цифр, из строки
String numsFromString(String str) {
  return str.replaceAll(RegExp(r"[^0-9]+"), '');
}

/// Создание ссылки на номер телефона
String makePhoneLink(String phone) {
  phone = phone.replaceAll('(', '-');
  phone = phone.replaceAll(')', '-');
  phone = phone.replaceAll(' ', '');
  return 'tel:' + phone;
}

/// Форматирование ошибок из ответа сервера
Map<String, String> proccessResponseErrors(
  dynamic errors, {
  bool toastCommonError = false,
  bool toastAllErrors = false,
  String defaultErrorText,
}) {
  if (errors == null) {
    if (defaultErrorText != null) showToast(defaultErrorText, isError: true);
    return null;
  }
  Map<String, String> formattedErrors = {};
  if (errors is List<dynamic>) {
    formattedErrors['common'] = errors.join('; ');
    // Если требуется сразу вывести тост с общими ошибками:
    if (toastCommonError || toastAllErrors) showToast(formattedErrors['common'], isError: true);
  } else if (errors is Map<String, dynamic>) {
    errors.forEach((key, value) {
      String errVal;
      if (value is List)
        errVal = value.join('; ');
      else
        errVal = value.toString().trim();
      if (errVal.isNotEmpty) formattedErrors[key] = errVal;
      if (toastAllErrors && errVal.isNotEmpty) showToast(errVal, isError: true);
      if (toastAllErrors && errVal.isEmpty && defaultErrorText != null) showToast(defaultErrorText, isError: true);
    });
  } else {
    print('The error was not processed: ${errors.runtimeType} errors ==> $errors');
  }
  return formattedErrors;
}

String addressToString(Address address, {bool oneline = true}) {
  String str = address.address;
  List<String> extraProps = [];
  if (address.entrance != null && address.entrance.isNotEmpty) extraProps.add('подъезд ${address.entrance}');
  if (address.appt != null && address.appt.isNotEmpty) extraProps.add('квартира ${address.appt}');
  if (extraProps.isNotEmpty) {
    oneline ? str += ', ' : str += ',\n';
    str += extraProps.join(', ');
  }
  return str;
}
