import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:geolocator/geolocator.dart';
import 'package:osm/services/common_responses.dart';
import 'package:osm/services/common_variables.dart';

class mapScreen extends StatefulWidget {
  Map<String, dynamic> product;
  mapScreen(this.product, {super.key});

  @override
  State<mapScreen> createState() => _mapScreenState();
}

class _mapScreenState extends State<mapScreen> {
  List<Instruction> _routeInstructions = [];
  Map<String, dynamic> _product = {};
  RoadType _roadtype = RoadType.car;
  List _roadTypes = [
    {'icon': Icons.car_rental, 'type': RoadType.car},
    {'icon': Icons.pedal_bike, 'type': RoadType.bike},
    {'icon': Icons.directions_walk, 'type': RoadType.foot},
  ];
  GeoPoint? _prodLocation;
  GeoPoint? _userLocation;
  RoadInfo? _roadInfo;
  final _mapController =
      MapController(initMapWithUserPosition: const UserTrackingOption());
  final bool _isLoading = true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _product = widget.product;
    _prodLocation = GeoPoint(
        latitude: _product['latitude'], longitude: _product['longitude']);
    location();
  }

  Future<void> location() async {
    Future.delayed(Duration(milliseconds: 1000), () async {
      await _mapController.addMarker(_prodLocation!,
          markerIcon: const MarkerIcon(
            icon: Icon(
              Icons.location_on,
              size: 40,
              color: redColor,
            ),
          ));
      await _mapController.goToLocation(_prodLocation!);
      double currentZoom = 4.0;
      double targetZoom = 14.0;
      double stepSize = 0.1;
      await Future.delayed(const Duration(milliseconds: 1000));
      for (double zoomLevel = currentZoom;
          zoomLevel <= targetZoom;
          zoomLevel += stepSize) {
        await _mapController.setZoom(zoomLevel: zoomLevel);
        await Future.delayed(const Duration(milliseconds: 5));
      }
    });
    //CommonResponses().showLocationLoadingDialog(context);
    Position? userPos = await CommonResponses().getCurrentLocation();
    print("ASNTEEEEE");
    print(userPos);
    if (userPos != null) {
      _userLocation =
          GeoPoint(latitude: userPos.latitude, longitude: userPos.longitude);
      await _mapController.addMarker(_userLocation!,
          markerIcon: MarkerIcon(
            icon: Icon(
              Icons.location_on,
              size: 40,
              color: blackColor,
            ),
          ));
      await _mapController.goToLocation(_prodLocation!);

      _drawRoad();
    }
  }

  Future<void> _drawRoad() async {
    var rInfo = await _mapController.drawRoad(_prodLocation!, _userLocation!,
        roadOption: const RoadOption(roadColor: redColor, roadWidth: 10),
        roadType: _roadtype);

    setState(() {
      _routeInstructions = rInfo.instructions;
      _roadInfo = rInfo;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          OSMFlutter(
              controller: _mapController,
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
                    margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    child: Text(
                      "Distance: ${_routeInstructions.length} " +
                          _roadInfo!.distance!.toStringAsFixed(2) +
                          "km",
                      overflow: TextOverflow.visible,
                      style: TextStyle(
                          color: whiteColor, fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
          _roadInfo == null
              ? Container()
              : Positioned(
                  top: 100,
                  right: 0,
                  child: SafeArea(
                      child: Container(
                          margin: EdgeInsets.only(right: 5),
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          color: const Color.fromARGB(127, 0, 0, 0),
                          height: 150,
                          width: 50,
                          child: SizedBox(
                            child: ListView.builder(
                                itemCount: _roadTypes.length,
                                itemBuilder: (context, index) {
                                  var type = _roadTypes[index];
                                  return IconButton(
                                      onPressed: () {
                                        setState(() {
                                          _roadtype = type['type'];
                                          _mapController.clearAllRoads();
                                          _drawRoad();
                                        });
                                      },
                                      style: IconButton.styleFrom(
                                          backgroundColor:
                                              type['type'] == _roadtype
                                                  ? redColor
                                                  : blackColor),
                                      icon: Icon(
                                        type['icon'],
                                        color: whiteColor,
                                      ));
                                }),
                          ))))
        ],
      ),
    );
  }
}
