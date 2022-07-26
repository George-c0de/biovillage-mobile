import 'package:biovillage/models/slide.dart';
import 'package:biovillage/models/payment-delivery-info.dart';
import 'package:biovillage/models/delivery-interval.dart';
import 'package:biovillage/models/delivery-area.dart';
import 'package:biovillage/models/company-info.dart';
import 'package:biovillage/helpers/system-elements.dart';
import 'package:biovillage/widgets/map.dart';

class General {
  NavBarTheme navBarTheme;
  List<Slide> homeSlider;
  PaymentDeliveryInfo paymentDeliveryInfo;
  Map<int, List<DeliveryInterval>> deliveryIntervals;
  List<DeliveryArea> deliveryAreas;
  Point deliveryMapCenter;
  double deliveryMapZoom;
  double deliveryMapSearchRadius;
  String googleMapsKey;
  CompanyInfo companyInfo;

  General({
    this.navBarTheme = NavBarTheme.white,
    this.homeSlider,
    this.paymentDeliveryInfo,
    this.deliveryIntervals,
    this.deliveryAreas,
    this.deliveryMapCenter,
    this.deliveryMapZoom,
    this.deliveryMapSearchRadius,
    this.googleMapsKey = '',
    this.companyInfo,
  });
}
