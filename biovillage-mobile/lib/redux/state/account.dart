import 'package:biovillage/models/address.dart';
import 'package:biovillage/models/user-info.dart';

class Account {
  bool userAuth;
  String userToken;
  String userSessionToken;
  UserInfo userInfo;
  String authPhone;
  String authRefCode;
  Address currentAddress;

  Account({
    this.userAuth = false,
    this.userToken,
    this.userInfo,
    this.authPhone,
    this.authRefCode,
    this.currentAddress,
  });
}
