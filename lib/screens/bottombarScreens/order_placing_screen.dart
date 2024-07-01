import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:osm/services/common_responses.dart';
import 'package:osm/services/common_variables.dart';
import 'package:osm/services/database_services.dart';

class OrderPlacingScreen extends StatefulWidget {
  var product;
  OrderPlacingScreen(this.product, {super.key});

  @override
  State<OrderPlacingScreen> createState() => _OrderPlacingScreenState();
}

class _OrderPlacingScreenState extends State<OrderPlacingScreen> {
  final _auth = FirebaseAuth.instance;
  Function? _stateSetter;
  var _product = {};
  GeoPoint? _userPoint;
  GeoPoint? _shopPoint;
  RoadInfo? _roadInfo;
  String _quantity = "1";
  final _countController = TextEditingController();
  final _addressController = TextEditingController();
  final _mapController =
      MapController(initMapWithUserPosition: const UserTrackingOption());

  Future<void> _getShoDetails() async {
    var shops = await DatabaseServices().getAllShops();
    print("USERS");
    if (shops['msg'] == 'done') {
      int index =
          shops['data'].indexWhere((el) => el['id'] == _product['shopId']);
      var shop = shops['data'][index];
      _shopPoint =
          GeoPoint(latitude: shop['latitude'], longitude: shop['longitude']);
      await _mapController.addMarker(_shopPoint!,
          markerIcon: MarkerIcon(
            icon: Icon(
              Icons.location_off_sharp,
              color: blackColor,
            ),
          ));
      await _mapController.goToLocation(_shopPoint!);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _countController.text = "1";
    _product = widget.product;
    _getShoDetails();

    // Timer.periodic(Duration(seconds: 3), (timer) {
    //   if (_userPoint != null) {
    //     _fetchUserPosition();
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 120,
                margin: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                    color: whiteColor,
                    border:
                        Border(bottom: BorderSide(color: appColor, width: 2)),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [BoxShadow(blurRadius: 1)]),
                child: Row(
                  children: [
                    Container(
                      width: 150,
                      height: 120,
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(15, 0, 0, 0),
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            bottomLeft: Radius.circular(10)),
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(10),
                            bottomLeft: Radius.circular(10)),
                        child: CachedNetworkImage(
                          fit: BoxFit.cover,
                          imageUrl: _product['images'][0],
                          errorWidget: (context, val, obj) {
                            return Icon(Icons.error);
                          },
                          progressIndicatorBuilder: (context, val, prog) {
                            return SpinKitCircle(
                              color: appColor,
                              size: 30,
                            );
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _product['title'],
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: 17),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 3),
                                      decoration: BoxDecoration(
                                          color: Colors.blueGrey,
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      child: Text(
                                        _product['status'],
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: whiteColor,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const Spacer(),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.location_on,
                                        ),
                                        Text(
                                          "${_product['district']}, ${_product['region']}",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        )
                                      ],
                                    )
                                  ]),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Tsh ${_product['price']}/=",
                                  style: TextStyle(
                                      fontSize: 15.5,
                                      color: appColor,
                                      fontWeight: FontWeight.bold),
                                ),
                                const Text(
                                  "Jan 10 2024",
                                  style: TextStyle(
                                      color: greyColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Quantity",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 5),
                      height: 45,
                      child: TextFormField(
                        controller: _countController,
                        onChanged: (val) {
                          if (val.trim().isEmpty) {
                            setState(() {
                              _quantity = "0";
                            });
                          } else {
                            setState(() {
                              _quantity = val;
                            });
                          }
                        },
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: const InputDecoration(
                            // contentPadding:const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                            labelText: "Amount you want eg 6 pairs",
                            border: OutlineInputBorder()),
                      ),
                    ),
                    Text(
                      "Total amount, Tsh ${int.parse(_quantity) * int.parse(_product['price'])}",
                      style: TextStyle(
                          color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      "Destination address",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 5),
                      height: 45,
                      child: TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                            // contentPadding:const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                            labelText: "Eg Block 5 CIVE UDOM, Dodoma",
                            border: OutlineInputBorder()),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Destination",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Expanded(
                        child: Container(
                          width: screenSize.width,
                          decoration: BoxDecoration(border: Border.all()),
                          child: Column(
                            children: [
                              ElevatedButton(
                                  onPressed: () async {
                                    CommonResponses()
                                        .showLocationLoadingDialog(context);
                                    await _fetchUserPosition();
                                    Navigator.pop(context);
                                  },
                                  child: Text("Current location")),
                              Expanded(
                                child: Stack(
                                  children: [
                                    ValueListenableBuilder(
                                        valueListenable: _mapController
                                            .listenerMapSingleTapping,
                                        builder: (context, point, child) {
                                          if (point != null) {
                                            if (_userPoint == null) {
                                              _userPoint = point;
                                              addMarker(_userPoint);
                                            } else {
                                              changeMarkerPosition(point);
                                            }
                                          }
                                          return OSMFlutter(
                                            controller: _mapController,
                                            osmOption: OSMOption(
                                              userTrackingOption:
                                                  const UserTrackingOption(
                                                enableTracking: true,
                                                unFollowUser: false,
                                              ),
                                              zoomOption: const ZoomOption(
                                                initZoom: 8,
                                                minZoomLevel: 3,
                                                maxZoomLevel: 19,
                                                stepZoom: 1.0,
                                              ),
                                              userLocationMarker:
                                                  UserLocationMaker(
                                                personMarker: const MarkerIcon(
                                                  icon: Icon(
                                                    Icons
                                                        .location_history_rounded,
                                                    color: Colors.red,
                                                    size: 48,
                                                  ),
                                                ),
                                                directionArrowMarker:
                                                    const MarkerIcon(
                                                  icon: Icon(
                                                    Icons.double_arrow,
                                                    size: 48,
                                                  ),
                                                ),
                                              ),
                                              roadConfiguration:
                                                  const RoadOption(
                                                roadColor: Colors.yellowAccent,
                                              ),
                                              markerOption: MarkerOption(
                                                  defaultMarker:
                                                      const MarkerIcon(
                                                icon: Icon(
                                                  Icons.person_pin_circle,
                                                  color: Colors.blue,
                                                  size: 56,
                                                ),
                                              )),
                                            ),
                                          );
                                        }),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Container(
                                        child: Row(
                                          children: [
                                            IconButton(
                                                onPressed: () async {
                                                  await _mapController.zoomIn();
                                                  await _mapController
                                                      .goToLocation(
                                                          _userPoint!);
                                                },
                                                style: IconButton.styleFrom(
                                                    backgroundColor:
                                                        const Color.fromARGB(
                                                            158, 0, 0, 0)),
                                                icon: Icon(
                                                  Icons.zoom_in,
                                                  color: whiteColor,
                                                )),
                                            IconButton(
                                                onPressed: () async {
                                                  await _mapController
                                                      .zoomOut();
                                                  await _mapController
                                                      .goToLocation(
                                                          _userPoint!);
                                                },
                                                style: IconButton.styleFrom(
                                                    backgroundColor:
                                                        const Color.fromARGB(
                                                            158, 0, 0, 0)),
                                                icon: Icon(
                                                  Icons.zoom_out,
                                                  color: whiteColor,
                                                )),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                        bottom: 0,
                                        child: StatefulBuilder(
                                            builder: (context, stateSetter) {
                                          _stateSetter = stateSetter;
                                          return _roadInfo == null
                                              ? Container()
                                              : Text(
                                                  "Distance: ${_roadInfo!.distance!.toStringAsFixed(2)} Km",
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold));
                                        }))
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              ElevatedButton(
                  onPressed: () async {
                    var address = _addressController.text.trim();
                    if (_quantity != "0" && address.isNotEmpty) {
                      if (_userPoint != null) {
                        var orderData = {
                          "productId": _product['id'],
                          "ownerId": _product['ownerId'],
                          "shopId": _product['shopId'],
                          "customerId": _auth.currentUser!.uid,
                          "staffId": null,
                          "deliveryStatus": "Staff not assigned",
                          "uploadedAt": DateTime.now().millisecondsSinceEpoch,
                          "quantity": _quantity,
                          "price": int.parse(_quantity) *
                              int.parse(_product['price']),
                          "address": address,
                          "postion": {
                            "latitude": _userPoint!.latitude,
                            "longitude": _userPoint!.longitude
                          }
                        };
                        CommonResponses().showLoadingDialog(context);
                        var res =
                            await DatabaseServices().uploadOrder(orderData);
                        Navigator.pop(context);
                        if (res['msg'] == "done") {
                          CommonResponses().showToast(
                            "Order placed successful..",
                          );
                          Navigator.pop(context);
                        } else {
                          CommonResponses()
                              .showToast(res['msg'], isError: true);
                        }
                      } else {
                        CommonResponses().showToast(
                            "Pick your location on map or click button to fetch location automatically!!",
                            isError: true);
                      }
                    } else {
                      CommonResponses().showToast(
                          "Order quantity and destination address are needed!!",
                          isError: true);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: appColor, foregroundColor: whiteColor),
                  child: Text("Place order"))
            ],
          ),
        ),
      ),
    );
  }

  void addMarker(GeoPoint? userPoint) async {
    await _mapController.addMarker(userPoint!,
        markerIcon: const MarkerIcon(
          icon: Icon(
            Icons.location_on,
            size: 40,
            color: redColor,
          ),
        ));
    await drawRoad();
  }

  void changeMarkerPosition(GeoPoint point) async {
    GeoPoint oldPoint = _userPoint!;
    await _mapController.changeLocationMarker(
        oldLocation: oldPoint, newLocation: point);
    _userPoint = point;
    await drawRoad();
  }

  drawRoad() async {
    await _mapController.removeLastRoad().then((value) async {
      var roadinfo = await _mapController.drawRoad(_userPoint!, _shopPoint!,
          roadType: RoadType.bike,
          roadOption: const RoadOption(roadColor: redColor, roadWidth: 10));
      _stateSetter!(() {
        _roadInfo = roadinfo;
      });
    });
  }

  _fetchUserPosition() async {
    var res = await CommonResponses().getCurrentLocation();
    if (res != null) {
      var userPoint =
          GeoPoint(latitude: res.latitude, longitude: res.longitude);
      if (_userPoint == null) {
        _userPoint = userPoint;
        addMarker(_userPoint);
      } else {
        changeMarkerPosition(userPoint);
      }
    }
  }
}
