import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:group_radio_button/group_radio_button.dart';
import 'package:intl/intl.dart';
import 'package:osm/screens/product_details_view_screen.dart';
import 'package:osm/services/common_responses.dart';
import 'package:osm/services/database_services.dart';
import 'package:osm/services/provider_services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/common_variables.dart';

class OrderDetailsScreen extends StatefulWidget {
  var order;
  OrderDetailsScreen(this.order, {super.key});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  AppDataProvider? _provider;
  final _auth = FirebaseAuth.instance;
  List<String> _deliverstatuses = [
    "Staff ready to move",
    "Staff on the way",
    "Staff arrived"
  ];
  final _pgController = PageController();
  List _deliveryStaffs = [];
  Map<String, dynamic> _order = {};
  Map<String, dynamic> _productData = {};
  Map<String, dynamic> _deliveryStaff = {};
  Map<String, dynamic> _customerData = {};
  bool _loading = false;

  Future<void> _loadingUsers() async {
    var user =
        await DatabaseServices().getDeliveryUsers(_auth.currentUser!.uid);
    print(user);
    if (user['msg'] == 'done') {
      _deliveryStaffs = user['data'];
    }
  }

  Future<void> _loadingStaffData() async {
    var user = await DatabaseServices().getSingleUser(_order['staffId']);
    if (user['msg'] == 'done') {
      _deliveryStaff = user['data'];
      setState(() {});
    }
  }

  Future<void> _loadingCustomerData() async {
    var user = await DatabaseServices().getSingleUser(_order['customerId']);
    if (user['msg'] == 'done') {
      _customerData = user['data'];
      setState(() {});
      print(_customerData.toString() + " bbb");
    }
  }

  @override
  void initState() {
    super.initState();
    _order = widget.order;
    _productData = _order['product'];
    _loadingCustomerData();
    if (_order['staffId'] != null) {
      _loadingStaffData();
    }
  }

  @override
  Widget build(BuildContext context) {
    _provider = Provider.of<AppDataProvider>(context);
    return DefaultTabController(
      length: 3,
      initialIndex: 1,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Details"),
          bottom: const TabBar(tabs: [
            Tab(
              text: "Delivery staff",
            ),
            Tab(
              text: "Map",
            ),
            Tab(
              text: "Order info",
            ),
          ]),
        ),
        body: TabBarView(
            physics: const NeverScrollableScrollPhysics(),
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2, left: 2, right: 2),
                child: Center(
                    child: PageView(
                  controller: _pgController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _order['staffId'] == null || _order['staffId'].isEmpty
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "No delivery staff is assigned for this order!",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: redColor),
                              ),
                              _order['ownerId'] != _auth.currentUser!.uid
                                  ? Container()
                                  : ElevatedButton(
                                      onPressed: () async {
                                        CommonResponses()
                                            .showLoadingDialog(context);
                                        await _loadingUsers();
                                        Navigator.pop(context);
                                        setState(() {});
                                        if (_deliveryStaffs.isNotEmpty) {
                                          _pgController.nextPage(
                                              duration: const Duration(
                                                  milliseconds: 400),
                                              curve: Curves.decelerate);
                                        } else {
                                          CommonResponses().showToast(
                                              "You don't have delivery staffs ${_deliveryStaff.length}",
                                              isError: true);
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: appColor,
                                          foregroundColor: whiteColor),
                                      child: const Text("Assign staff"))
                            ],
                          )
                        : _deliveryStaff.isEmpty
                            ? Container(
                                child:
                                    Center(child: CircularProgressIndicator()),
                              )
                            : Column(
                                children: [
                                  Container(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                            color: appColor,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 5),
                                            child: const Text(
                                              "Identity",
                                              style: TextStyle(
                                                  color: whiteColor,
                                                  fontWeight: FontWeight.bold),
                                            )),
                                        Container(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: appColor, width: 2),
                                            ),
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: 100,
                                                  height: 100,
                                                  color: bGreyColor,
                                                  margin: const EdgeInsets.only(
                                                      top: 2,
                                                      bottom: 2,
                                                      left: 2),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            50),
                                                    child: _deliveryStaff[
                                                                'profile_photo'] ==
                                                            null
                                                        ? const Icon(
                                                            Icons.person,
                                                            color: whiteColor,
                                                            size: 50,
                                                          )
                                                        : CachedNetworkImage(
                                                            fit: BoxFit.cover,
                                                            imageUrl:
                                                                _deliveryStaff[
                                                                    'profile_photo'],
                                                            errorWidget:
                                                                (context, val,
                                                                    obj) {
                                                              return const Icon(
                                                                  Icons.error);
                                                            },
                                                            progressIndicatorBuilder:
                                                                (context, val,
                                                                    prog) {
                                                              return const SpinKitCircle(
                                                                color: appColor,
                                                                size: 30,
                                                              );
                                                            },
                                                          ),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                            left: 7),
                                                    child: Column(
                                                      children: [
                                                        Row(
                                                          children: [
                                                            const Icon(
                                                              Icons.person,
                                                              color: appColor,
                                                              size: 30,
                                                            ),
                                                            const SizedBox(
                                                              width: 10,
                                                            ),
                                                            Text(
                                                              "${_deliveryStaff['first_name']} ${_deliveryStaff['last_name']}",
                                                              style: const TextStyle(
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            )
                                                          ],
                                                        ),
                                                        Row(
                                                          children: [
                                                            GestureDetector(
                                                              onTap: () {
                                                                _launchCommunication(
                                                                    "tel:${_deliveryStaff['phone']}");
                                                              },
                                                              child:
                                                                  const AbsorbPointer(
                                                                child: Icon(
                                                                  Icons
                                                                      .call_end,
                                                                  color:
                                                                      appColor,
                                                                  size: 30,
                                                                ),
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              width: 10,
                                                            ),
                                                            Text(
                                                              _deliveryStaff[
                                                                  'phone'],
                                                              style: const TextStyle(
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            )
                                                          ],
                                                        ),
                                                        Row(
                                                          children: [
                                                            GestureDetector(
                                                              onTap: () {
                                                                _launchCommunication(
                                                                    "mailto:${_deliveryStaff['email']}");
                                                              },
                                                              child:
                                                                  const AbsorbPointer(
                                                                child: Icon(
                                                                  Icons.mail,
                                                                  color:
                                                                      appColor,
                                                                  size: 30,
                                                                ),
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              width: 10,
                                                            ),
                                                            Expanded(
                                                              child: Text(
                                                                "${_deliveryStaff['email']}",
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
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
                                        )
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                          color: appColor,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 5),
                                          child: const Text(
                                            "Status",
                                            style: TextStyle(
                                                color: whiteColor,
                                                fontWeight: FontWeight.bold),
                                          )),
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: appColor, width: 2),
                                        ),
                                        child: Column(
                                          children: [
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const Text(
                                                  "Status: ",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: greyColor),
                                                ),
                                                Text(
                                                  _order['deliveryStatus'],
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            _order['staffId'] !=
                                                    _auth.currentUser!.uid
                                                ? Container()
                                                : Container(
                                                    height: 34,
                                                    margin: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 5),
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    child: OutlinedButton(
                                                        onPressed: () {
                                                          _showDeliveryStatusUpdateBox();
                                                        },
                                                        child: const Text(
                                                            "Change Status")),
                                                  ),
                                            SizedBox(
                                              height: 2,
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                    Container(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Align(
                                alignment: Alignment.topLeft,
                                child: IconButton(
                                    onPressed: () {
                                      _pgController.previousPage(
                                          duration:
                                              const Duration(milliseconds: 400),
                                          curve: Curves.decelerate);
                                    },
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: bGreyColor,
                                        foregroundColor: whiteColor),
                                    icon: const Icon(Icons.arrow_back_ios_new)),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              const Text(
                                "Select delivery staff",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              )
                            ],
                          ),
                          Expanded(
                            child: ListView.builder(
                                itemCount: _deliveryStaffs.length,
                                itemBuilder: (context, ind) {
                                  var user = _deliveryStaffs[ind];
                                  return Container(
                                    decoration: const BoxDecoration(
                                        border: Border(bottom: BorderSide())),
                                    child: ListTile(
                                      onTap: () async {
                                        if (user['orderId'] == null ||
                                            user['orderId'].isEmpty) {
                                          CommonResponses()
                                              .showLoadingDialog(context);
                                          var res = await DatabaseServices()
                                              .assignOrderToStaff(_order, user);
                                          if (res['msg'] == 'done') {
                                            _order['staffId'] = user['id'];
                                            await _loadingUsers();
                                            await _loadingStaffData();
                                            _order['deliveryStatus'] =
                                                'Staff ready to move';
                                            setState(() {});
                                            Navigator.pop(context);
                                            _pgController.previousPage(
                                                duration: const Duration(
                                                    milliseconds: 500),
                                                curve: Curves.decelerate);
                                            CommonResponses().showToast(
                                                "Staff assigned successful..");
                                          } else {
                                            Navigator.pop(context);
                                            CommonResponses().showToast(
                                                res['msg'],
                                                isError: true);
                                          }
                                        } else {
                                          CommonResponses().showToast(
                                              "This staff is already assigned a task",
                                              isError: true);
                                        }
                                      },
                                      dense: true,
                                      visualDensity: const VisualDensity(
                                          horizontal: -3, vertical: -3),
                                      title: Text(
                                        "${user['first_name']} ${user['last_name']}",
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Text(
                                        user['orderId'] == null ||
                                                user['orderId'].isEmpty
                                            ? 'Not assigned'
                                            : 'Assigned',
                                        style: TextStyle(
                                            fontWeight:
                                                user['orderId'] == null ||
                                                        user['orderId'].isEmpty
                                                    ? FontWeight.normal
                                                    : FontWeight.bold,
                                            color: user['orderId'] == null ||
                                                    user['orderId'].isEmpty
                                                ? blackColor
                                                : appColor),
                                      ),
                                      leading: SizedBox(
                                        width: 40,
                                        height: 40,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(40),
                                          child: user['profile_photo'] == null
                                              ? Container(
                                                  color: Colors.blueGrey,
                                                  child:
                                                      const Icon(Icons.person))
                                              : CachedNetworkImage(
                                                  fit: BoxFit.cover,
                                                  imageUrl:
                                                      user['profile_photo'],
                                                  errorWidget:
                                                      (context, val, obj) {
                                                    return const Icon(
                                                        Icons.error);
                                                  },
                                                  progressIndicatorBuilder:
                                                      (context, val, prog) {
                                                    return const SpinKitCircle(
                                                      color: appColor,
                                                      size: 30,
                                                    );
                                                  },
                                                ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                          )
                        ],
                      ),
                    )
                  ],
                )),
              ),
              MapDeliveryscreen(_order),
              Container(
                child: SingleChildScrollView(
                  child: Center(
                    child: _customerData.isEmpty
                        ? const CircularProgressIndicator()
                        : Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: Column(
                              children: [
                                Container(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                          color: appColor,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 5),
                                          child: const Text(
                                            "Customer",
                                            style: TextStyle(
                                                color: whiteColor,
                                                fontWeight: FontWeight.bold),
                                          )),
                                      Container(
                                        child: Column(
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: appColor, width: 2),
                                              ),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    width: 100,
                                                    height: 100,
                                                    margin:
                                                        const EdgeInsets.only(
                                                            top: 2,
                                                            bottom: 2,
                                                            left: 2),
                                                    child: _customerData[
                                                                'profile_photo'] ==
                                                            null
                                                        ? const Icon(
                                                            Icons.person)
                                                        : CachedNetworkImage(
                                                            fit: BoxFit.cover,
                                                            imageUrl: _customerData[
                                                                'profile_photo'],
                                                            errorWidget:
                                                                (context, val,
                                                                    obj) {
                                                              return const Icon(
                                                                  Icons.error);
                                                            },
                                                            progressIndicatorBuilder:
                                                                (context, val,
                                                                    prog) {
                                                              return const SpinKitCircle(
                                                                color: appColor,
                                                                size: 30,
                                                              );
                                                            },
                                                          ),
                                                  ),
                                                  Expanded(
                                                    child: Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                              left: 7),
                                                      child: Column(
                                                        children: [
                                                          Row(
                                                            children: [
                                                              const Icon(
                                                                Icons.person,
                                                                color: appColor,
                                                                size: 30,
                                                              ),
                                                              const SizedBox(
                                                                width: 10,
                                                              ),
                                                              Text(
                                                                "${_customerData['first_name']} ${_customerData['last_name']}",
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              )
                                                            ],
                                                          ),
                                                          Row(
                                                            children: [
                                                              GestureDetector(
                                                                onTap: () {
                                                                  _launchCommunication(
                                                                      "tel:${_customerData['phone']}");
                                                                },
                                                                child:
                                                                    const AbsorbPointer(
                                                                  child: Icon(
                                                                    Icons
                                                                        .call_end,
                                                                    color:
                                                                        appColor,
                                                                    size: 30,
                                                                  ),
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                width: 10,
                                                              ),
                                                              Text(
                                                                _customerData[
                                                                    'phone'],
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              )
                                                            ],
                                                          ),
                                                          Row(
                                                            children: [
                                                              GestureDetector(
                                                                onTap: () {
                                                                  _launchCommunication(
                                                                      "mailTo:${_customerData['email']}");
                                                                },
                                                                child:
                                                                    const AbsorbPointer(
                                                                  child: Icon(
                                                                    Icons.mail,
                                                                    color:
                                                                        appColor,
                                                                    size: 30,
                                                                  ),
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                width: 10,
                                                              ),
                                                              Expanded(
                                                                child: Text(
                                                                  "${_customerData['email']}",
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          16,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
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
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Container(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                          color: appColor,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 5),
                                          child: const Text(
                                            "Product",
                                            style: TextStyle(
                                                color: whiteColor,
                                                fontWeight: FontWeight.bold),
                                          )),
                                      Container(
                                          padding:
                                              EdgeInsets.symmetric(vertical: 2),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: appColor, width: 2),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Column(
                                                    children: [
                                                      Text(
                                                        "QUANTITY:",
                                                        style: TextStyle(
                                                            fontSize: 11,
                                                            color:
                                                                Colors.black54,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      Text(
                                                        _order['quantity']
                                                            .toString(),
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      )
                                                    ],
                                                  ),
                                                  Column(
                                                    children: [
                                                      const Text(
                                                        "PRICE: ",
                                                        style: TextStyle(
                                                            fontSize: 11,
                                                            color:
                                                                Colors.black54,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      Text(
                                                        "Tsh " +
                                                            _order['price']
                                                                .toString() +
                                                            "/=",
                                                        style: const TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      )
                                                    ],
                                                  ),
                                                  Column(
                                                    children: [
                                                      const Text(
                                                        "TOTAL: ",
                                                        style: TextStyle(
                                                            fontSize: 11,
                                                            color:
                                                                Colors.black54,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      Text(
                                                        "Tsh ${_order['price'] * int.parse(_order['quantity'])}/=",
                                                        style: const TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      )
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Text(
                                                    "PLACED ON:",
                                                    style: TextStyle(
                                                        fontSize: 11,
                                                        color: Colors.black54,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Builder(builder: (context) {
                                                    final date = DateTime
                                                        .fromMillisecondsSinceEpoch(
                                                            _order[
                                                                'uploadedAt']);
                                                    String formattedDate =
                                                        DateFormat('d MMMM y')
                                                            .format(date);
                                                    return Text(
                                                      formattedDate,
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    );
                                                  })
                                                ],
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Text(
                                                    "DESTINATION:",
                                                    style: TextStyle(
                                                        fontSize: 11,
                                                        color: Colors.black54,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Text(
                                                    _order['address']
                                                        .toString(),
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  )
                                                ],
                                              ),
                                              Builder(builder: (context) {
                                                var product = _productData;
                                                String time = CommonResponses()
                                                    .formatTimeDifference(DateTime
                                                        .fromMillisecondsSinceEpoch(
                                                            product[
                                                                'uploadedAt']));

                                                return GestureDetector(
                                                  onTap: () {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                ProductdetailsViewScreen(
                                                                    product)));
                                                    // CommonResponses().shiftPage(
                                                    //     context,
                                                    //     ProductdetailsViewScreen(
                                                    //         product));
                                                  },
                                                  child: AbsorbPointer(
                                                    child: Container(
                                                      height: 120,
                                                      margin:
                                                          const EdgeInsets.all(
                                                              5),
                                                      decoration: BoxDecoration(
                                                          color: whiteColor,
                                                          border: Border(
                                                              bottom: BorderSide(
                                                                  color: appColor,
                                                                  width: 2)),
                                                          borderRadius: BorderRadius.circular(10),
                                                          boxShadow: [
                                                            BoxShadow(
                                                                color:
                                                                    blackColor,
                                                                blurRadius: 4.4)
                                                          ]),
                                                      child: Row(
                                                        children: [
                                                          Container(
                                                            width: 150,
                                                            height: 120,
                                                            decoration:
                                                                const BoxDecoration(
                                                              color: Color
                                                                  .fromARGB(15,
                                                                      0, 0, 0),
                                                              borderRadius: BorderRadius.only(
                                                                  topLeft: Radius
                                                                      .circular(
                                                                          10),
                                                                  bottomLeft: Radius
                                                                      .circular(
                                                                          10)),
                                                            ),
                                                            child: ClipRRect(
                                                              borderRadius: const BorderRadius
                                                                  .only(
                                                                  topLeft: Radius
                                                                      .circular(
                                                                          10),
                                                                  bottomLeft: Radius
                                                                      .circular(
                                                                          10)),
                                                              child: Hero(
                                                                tag: product[
                                                                    'id'],
                                                                child:
                                                                    CachedNetworkImage(
                                                                  fit: BoxFit
                                                                      .cover,
                                                                  imageUrl:
                                                                      product['images']
                                                                          [0],
                                                                  errorWidget:
                                                                      (context,
                                                                          val,
                                                                          obj) {
                                                                    return Icon(
                                                                        Icons
                                                                            .error);
                                                                  },
                                                                  progressIndicatorBuilder:
                                                                      (context,
                                                                          val,
                                                                          prog) {
                                                                    return SpinKitCircle(
                                                                      color:
                                                                          appColor,
                                                                      size: 30,
                                                                    );
                                                                  },
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          Expanded(
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          3),
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Expanded(
                                                                    child: Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                          Text(
                                                                            product['title'],
                                                                            maxLines:
                                                                                2,
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                            style:
                                                                                TextStyle(fontSize: 17),
                                                                          ),
                                                                          Container(
                                                                            padding:
                                                                                const EdgeInsets.symmetric(horizontal: 3),
                                                                            decoration:
                                                                                BoxDecoration(color: Colors.blueGrey, borderRadius: BorderRadius.circular(20)),
                                                                            child:
                                                                                Text(
                                                                              product['status'],
                                                                              style: TextStyle(fontSize: 12, color: whiteColor, fontWeight: FontWeight.bold),
                                                                            ),
                                                                          ),
                                                                          const Spacer(),
                                                                          Row(
                                                                            children: [
                                                                              Icon(
                                                                                Icons.location_on,
                                                                              ),
                                                                              Text("${product['district']}, ${product['region']}")
                                                                            ],
                                                                          )
                                                                        ]),
                                                                  ),
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                      Text(
                                                                        "Tsh ${product['price']}/=",
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                15.5,
                                                                            color:
                                                                                appColor,
                                                                            fontWeight:
                                                                                FontWeight.bold),
                                                                      ),
                                                                      Text(
                                                                        time,
                                                                        style: const TextStyle(
                                                                            color:
                                                                                greyColor,
                                                                            fontSize:
                                                                                12,
                                                                            fontWeight:
                                                                                FontWeight.bold),
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
                                                  ),
                                                );
                                              })
                                            ],
                                          ))
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
              )
            ]),
      ),
    );
  }

  void _launchCommunication(String uri) async {
    final Uri _url = Uri.parse(uri);
    if (await canLaunch(uri)) {
      await launch(uri);
    } else {
      throw 'Could not launch $uri';
    }
  }

  void _showDeliveryStatusUpdateBox() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: const Center(child: Text("Change status")),
              titlePadding: EdgeInsets.all(0),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              content: StatefulBuilder(builder: (context, stateSetter) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: _deliverstatuses.map<Widget>((status) {
                    return Container(
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: status == _order['deliveryStatus']
                                  ? appColor
                                  : whiteColor,
                              width: 3)),
                      child: ListTile(
                        dense: true,
                        onTap: () async {
                          if (_order['deliveryStatus'] != status) {
                            CommonResponses().showLoadingDialog(context);
                            var data = {
                              'orderId': _order['id'],
                              'deliveryStatus': status,
                              "staffId": _order['staffId']
                            };
                            var res = await DatabaseServices()
                                .updateStaffDeliveryStatus(data);
                            Navigator.pop(context);
                            if (res['msg'] == 'done') {
                              if (status == "Staff on the way") {
                                await _provider!.startRouting();
                              }
                              stateSetter(() {
                                _order['deliveryStatus'] = status;
                              });
                              setState(() {});
                              Navigator.pop(context);
                              CommonResponses()
                                  .showToast("Status changed successfully");
                            } else {
                              CommonResponses()
                                  .showToast(res['msg'], isError: true);
                            }
                          } else {
                            CommonResponses().showToast(
                                "Same as current status",
                                isError: true);
                          }
                        },
                        title: Text(
                          status,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  }).toList(),
                );
              }));
        });
  }
}

class MapDeliveryscreen extends StatefulWidget {
  var order;
  MapDeliveryscreen(this.order, {super.key});

  @override
  State<MapDeliveryscreen> createState() => _MapDeliveryscreenState();
}

class _MapDeliveryscreenState extends State<MapDeliveryscreen> {
  final _auth = FirebaseAuth.instance;
  RoadInfo? _roadInfo;
  Timer? _timer;
  var _order = {};
  Map<String, dynamic> _deliveryStaff = {};
  final _mapController =
      MapController(initMapWithUserPosition: const UserTrackingOption());
  GeoPoint? destination;

  Future<void> _addDestinationMarker() async {
    print("INNNN");
    await Future.delayed(const Duration(seconds: 1), () async {
      await _mapController.addMarker(destination!,
          markerIcon: MarkerIcon(
            key: UniqueKey(),
            icon: Icon(
              Icons.location_on_rounded,
              size: 40,
              color: blackColor,
            ),
          ));
      await _mapController.goToLocation(destination!);
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
      await _mapController.goToLocation(destination!);
    });
  }

  Future<void> _loadingStaffData() async {
    print("SSAAAAAAAAA");
    var user = await DatabaseServices().getSingleUser(_order['staffId']);
    if (user['msg'] == 'done') {
      _deliveryStaff = user['data'];
      await _addSourceMarker();
    }
  }

  GeoPoint? oldSource;
  Future<void> _addSourceMarker() async {
    print("Adding source marker");
    if (_deliveryStaff.isNotEmpty) {
      var source = GeoPoint(
          latitude: _deliveryStaff['location']['latitude'],
          longitude: _deliveryStaff['location']['longitude']);
      print("Source marker 2 ${source.latitude} ${source.longitude}");
      if (_roadInfo == null) {
        await _mapController.addMarker(source,
            markerIcon: MarkerIcon(
              key: UniqueKey(),
              icon: const Icon(
                Icons.location_on,
                size: 40,
                color: redColor,
              ),
            ));
        oldSource = source;
        print("Icon added");
      } else {
        if (oldSource != source) {
          print("Icon editing");
          print("Icon ${source.latitude} ${source.longitude}");
          print("Icon ${oldSource!.latitude} ${oldSource!.longitude}");
          await _mapController.changeLocationMarker(
              oldLocation: oldSource!, newLocation: source);
          oldSource = source;
          print("Icon edited");
        } else {
          print("Skipping");
        }
      }
      if (_roadInfo != null) {
        await _mapController.clearAllRoads();
      }
      _roadInfo = await _mapController.drawRoad(source, destination!,
          roadType: RoadType.foot,
          roadOption: const RoadOption(
              roadColor: redColor,
              roadBorderColor: appColor,
              roadWidth: 10,
              zoomInto: false));
      setState(() {});
    }

    await Future.delayed(const Duration(seconds: 3), () async {
      print("loading staff");
      await _loadingStaffData();
    });
  }

  @override
  void initState() {
    super.initState();
    _order = widget.order;
    destination = GeoPoint(
        latitude: _order['postion']['latitude'],
        longitude: _order['postion']['longitude']);
    _addDestinationMarker();
    Future.delayed(const Duration(seconds: 0), () async {
      if (_order['deliveryStatus'] == "Staff on the way") {
        await _loadingStaffData();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    if (_timer != null) {
      _timer!.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const Text("Status:",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Container(
                    decoration:
                        BoxDecoration(border: Border.all(color: appColor)),
                    child: Text(_order['deliveryStatus'],
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: appColor)),
                  )
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
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
                            color: const Color.fromARGB(157, 0, 0, 0),
                            margin: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 10),
                            child: Text(
                              "Distance: " +
                                  _roadInfo!.distance!.toStringAsFixed(2) +
                                  "km",
                              overflow: TextOverflow.visible,
                              style: const TextStyle(
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
