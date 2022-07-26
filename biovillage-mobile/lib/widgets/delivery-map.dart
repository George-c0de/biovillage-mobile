import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:biovillage/redux/state/app-state.dart';
import 'package:biovillage/models/delivery-area.dart';
import 'package:biovillage/helpers/colors.dart';
import 'package:biovillage/widgets/map.dart';

class DeliveryMap extends StatefulWidget {
  DeliveryMap({
    Key key,
    this.scrollable = false,
    this.mapHeight = 500,
  }) : super(key: key);

  final bool scrollable;
  final double mapHeight;

  @override
  _DeliveryMapState createState() => _DeliveryMapState();
}

class _DeliveryMapState extends State<DeliveryMap> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, dynamic>(
      converter: (store) => store,
      builder: (context, store) => Container(
        height: widget.mapHeight,
        child: CustomMap(
          center: store.state.general.deliveryMapCenter,
          zoom: store.state.general.deliveryMapZoom,
          polygons: [
            for (DeliveryArea deliveryArea in store.state.general.deliveryAreas)
              Polygon(
                outerRingCoordinates: deliveryArea.points,
                style: PolygonStyle(
                  fillColor: HexColor.fromHex(deliveryArea.color).withOpacity(.5),
                  strokeColor: HexColor.fromHex(deliveryArea.color),
                  strokeWidth: 1,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
