import 'package:redux/redux.dart';
import 'package:biovillage/redux/state/account.dart';
import 'package:biovillage/redux/actions/account.dart';

final accountReducer = TypedReducer<Account, dynamic>(_accountReducer);

Account _accountReducer(Account state, action) {
  if (action is SetAuthProps) {
    state.authPhone = action.phone;
    state.authRefCode = action.refcode;
  }
  if (action is SetUserToken) {
    state.userToken = action.token;
    state.userAuth = action.token != null && action.token != '';
  }
  if (action is SetSessionToken) state.userSessionToken = action.sessionToken;
  if (action is SetUserInfo) state.userInfo = action.userInfo;
  if (action is UpdateUserBonuses) state.userInfo.bonuses = action.bonuses;
  if (action is AddAddress) state.userInfo.addresses.insert(0, action.address);
  if (action is RemoveAddress) state.userInfo.addresses.remove(action.address);
  if (action is SetCurrentAddress) state.currentAddress = action.address;
  if (action is SetUserOrders) state.userInfo.orders = action.orders;
  if (action is AddUserOrder) state.userInfo.orders.insert(0, action.order);
  if (action is SetUserPaymentMethod) state.userInfo.paymentMethod = action.paymentMethod;
  return state;
}
