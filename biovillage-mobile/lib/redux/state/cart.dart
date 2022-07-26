import 'package:biovillage/models/cart-product.dart';
import 'package:biovillage/models/delivery-interval.dart';

class Cart {
  List<CartProduct> products;
  int amount;
  int cost;
  DeliveryInterval deliveryInterval;

  Cart({
    this.products,
    this.amount = 0,
    this.cost = 0,
    this.deliveryInterval,
  });
}
