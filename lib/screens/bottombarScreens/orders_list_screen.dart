import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:osm/screens/order_status_customer_screen.dart';
import 'package:osm/screens/product_details_view_screen.dart';
import 'package:osm/screens/profile_screens/order_details_screen.dart';
import 'package:osm/services/common_responses.dart';
import 'package:osm/services/common_variables.dart';
import 'package:osm/services/database_services.dart';

class OrdersListScreen extends StatefulWidget {
  const OrdersListScreen({super.key});

  @override
  State<OrdersListScreen> createState() => _OrdersListScreenState();
}

class _OrdersListScreenState extends State<OrdersListScreen> {
  final _auth = FirebaseAuth.instance;
  bool _isLoading = true;
  List _orderProducts = [];
  Future<void> _loading() async {
    var res = await DatabaseServices().retriveOrders();
    setState(() {
      _isLoading = false;
    });
    if (res['msg'] == "done") {
      if (res['data'].isNotEmpty) {
        List ods = res['data'];

        setState(() {
          _orderProducts = ods
              .where((el) => el['customerId'] == _auth.currentUser!.uid)
              .toList();
        });
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loading();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appColor,
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text("Your orders"),
            Text(
              "3 items",
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.bold, color: whiteColor),
            ),
          ],
        ),
      ),
      body: Center(
        child: _isLoading
            ? SpinKitCircle(
                color: appColor,
              )
            : _orderProducts.isEmpty
                ? Text("No data was found")
                : ListView.builder(
                    itemCount: _orderProducts.length,
                    itemBuilder: (context, ind) {
                      var order = _orderProducts[ind];
                      var product = _orderProducts[ind]['product'];
                      var time = CommonResponses().formatTimeDifference(
                          DateTime.fromMillisecondsSinceEpoch(
                              order['uploadedAt']));
                      return GestureDetector(
                        onTap: () {
                          // CommonResponses().shiftPage(
                          //     context, ProductdetailsViewScreen(product));
                          CommonResponses()
                              .shiftPage(context, OrderDetailsScreen(order));
                        },
                        child: AbsorbPointer(
                          child: Container(
                            height: 120,
                            margin: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                                color: whiteColor,
                                border: Border(
                                    bottom:
                                        BorderSide(color: appColor, width: 2)),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(color: blackColor, blurRadius: 4.4)
                                ]),
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
                                      imageUrl: product['images'][0],
                                      errorWidget: (context, val, obj) {
                                        return Icon(Icons.error);
                                      },
                                      progressIndicatorBuilder:
                                          (context, val, prog) {
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
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 3),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  product['title'],
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style:
                                                      TextStyle(fontSize: 17),
                                                ),
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(horizontal: 3),
                                                  decoration: BoxDecoration(
                                                      color: Colors.blueGrey,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20)),
                                                  child: Text(
                                                    product['status'],
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color: whiteColor,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                                const Spacer(),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.location_on,
                                                    ),
                                                    Text(
                                                        "${product['district']}, ${product['region']}")
                                                  ],
                                                )
                                              ]),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Tsh ${product['price']}/=",
                                              style: TextStyle(
                                                  fontSize: 15.5,
                                                  color: appColor,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              time,
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
                        ),
                      );
                    }),
      ),
    );
  }
}
