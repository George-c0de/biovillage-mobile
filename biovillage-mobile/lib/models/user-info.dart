import 'package:flutter/foundation.dart';
import 'package:biovillage/models/address.dart';
import 'package:biovillage/models/history-order.dart';
import 'package:biovillage/models/payment-type.dart';

class UserInfo {
  String phone;
  String email;
  String name;
  String birthday;
  List<Address> addresses;
  int bonuses;
  String refCode;
  List<HistoryOrder> orders;
  PaymentType paymentMethod;

  UserInfo({
    @required this.phone,
    this.email,
    this.name,
    this.birthday,
    this.addresses,
    this.bonuses = 0,
    this.refCode,
    this.orders,
    this.paymentMethod,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) => UserInfo(
        phone: json["phone"],
        email: json["email"],
        name: json["name"],
        birthday: json["birthday"],
        addresses: json["addresses"].map((c) => Address.fromJson(c)).toList().cast<Address>(),
        bonuses: json["bonuses"],
        refCode: json["referralCode"],
        paymentMethod: json["lastPayType"] == null
            ? PaymentType.cash
            : PaymentType.values.firstWhere(
                (val) => val.toString().split('.').last == json["lastPayType"],
                orElse: () => PaymentType.cash,
              ),
      );
}

UserInfo parseJsonUserInfo(json) {
  return UserInfo.fromJson(json);
}
