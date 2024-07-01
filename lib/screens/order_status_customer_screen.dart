import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:osm/services/common_variables.dart';

class OrderStatusCustomerScreen extends StatefulWidget {
  var orderDetails;
  OrderStatusCustomerScreen(this.orderDetails, {super.key});

  @override
  State<OrderStatusCustomerScreen> createState() =>
      _OrderStatusCustomerScreenState();
}

class _OrderStatusCustomerScreenState extends State<OrderStatusCustomerScreen> {
  RoadInfo? _roadInfo;
  final _mapController =
      MapController(initMapWithUserPosition: const UserTrackingOption());
  var _orderDetails = {};

  _addDestinationMarker() async {
    print("INNNN");
    var pos = GeoPoint(
        latitude: _orderDetails['postion']['latitude'],
        longitude: _orderDetails['postion']['longitude']);
    await Future.delayed(const Duration(seconds: 1), () async {
      await _mapController.addMarker(pos,
          markerIcon: const MarkerIcon(
            icon: Icon(
              Icons.location_on,
              size: 40,
              color: redColor,
            ),
          ));
      await _mapController.goToLocation(pos);
      double currentZoom = 4.0;
      double targetZoom = 10.0;
      double stepSize = 0.1;
      await Future.delayed(const Duration(milliseconds: 1000));
      for (double zoomLevel = currentZoom;
          zoomLevel <= targetZoom;
          zoomLevel += stepSize) {
        await _mapController.setZoom(zoomLevel: zoomLevel);
        await Future.delayed(const Duration(milliseconds: 5));
      }
      await _mapController.goToLocation(pos);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _orderDetails = widget.orderDetails;
    _addDestinationMarker();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appColor,
        title: const Text(
          "Order delivery",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Text("Status:",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Container(
                    decoration:
                        BoxDecoration(border: Border.all(color: appColor)),
                    child: Text(" Delivery staff not assigned",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: appColor)),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Text("Source:",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Icon(
                    Icons.location_on,
                    color: Colors.black,
                    size: 18,
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Text("Destination:",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Icon(
                    Icons.location_on,
                    color: Colors.red,
                    size: 18,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  OSMFlutter(
                      controller: _mapController,
                      // mapIsLoading: Center(
                      //   child: CircularProgressIndicator(),
                      // ),
                      onGeoPointClicked: (point) {},
                      onMapIsReady: (isReady) async {
                        print("Cheking $isReady");
                        if (isReady) {
                          await _mapController.currentLocation();
                          print("Ready");
                        }
                      },
                      osmOption: OSMOption(
                        userTrackingOption: const UserTrackingOption(
                          enableTracking: true,
                          unFollowUser: false,
                        ),
                        zoomOption: const ZoomOption(
                          initZoom: 8,
                          minZoomLevel: 3,
                          maxZoomLevel: 19,
                          stepZoom: 1.0,
                        ),
                        userLocationMarker: UserLocationMaker(
                          personMarker: const MarkerIcon(
                            icon: Icon(
                              Icons.location_history_rounded,
                              color: Colors.red,
                              size: 48,
                            ),
                          ),
                          directionArrowMarker: const MarkerIcon(
                            icon: Icon(
                              Icons.double_arrow,
                              size: 48,
                            ),
                          ),
                        ),
                        roadConfiguration: const RoadOption(
                          roadColor: Colors.red,
                        ),
                        markerOption: MarkerOption(
                            defaultMarker: const MarkerIcon(
                          icon: Icon(
                            Icons.person_pin_circle,
                            color: Colors.blue,
                            size: 56,
                          ),
                        )),
                      )),
                  _roadInfo == null
                      ? Container()
                      : Positioned(
                          bottom: 0,
                          child: Container(
                            color: Color.fromARGB(157, 0, 0, 0),
                            margin: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            padding: EdgeInsets.symmetric(
                                horizontal: 15, vertical: 10),
                            child: Text(
                              "Distance: " +
                                  _roadInfo!.distance!.toStringAsFixed(2) +
                                  "km",
                              overflow: TextOverflow.visible,
                              style: TextStyle(
                                  color: whiteColor,
                                  fontWeight: FontWeight.w900),
                            ),
                          ),
                        )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
