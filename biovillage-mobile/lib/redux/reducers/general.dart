import 'package:redux/redux.dart';
import 'package:biovillage/redux/state/general.dart';
import 'package:biovillage/redux/actions/general.dart';

final generalReducer = TypedReducer<General, dynamic>(_generalReducer);

General _generalReducer(General state, action) {
  if (action is SetSlides) state.homeSlider = action.slides;
  if (action is SetDeliveryIntervals) state.deliveryIntervals = action.deliveryIntervals;
  if (action is SetDilveryAreas) {
    state.deliveryAreas = action.deliveryAreas;
    state.deliveryMapSearchRadius = action.deliveryMapSearchRadius;
    if (action.deliveryMapCenter != null) state.deliveryMapCenter = action.deliveryMapCenter;
    if (action.deliveryMapZoom != null) state.deliveryMapZoom = action.deliveryMapZoom;
  }
  if (action is SetPaymentDeliveryInfo) state.paymentDeliveryInfo = action.paymentDeliveryInfo;
  if (action is SetCompanyInfo) state.companyInfo = action.companyInfo;
  if (action is SetNavBarTheme) state.navBarTheme = action.navBarTheme;
  if (action is SetGoogleMapsKey) state.googleMapsKey = action.key;
  return state;
}
