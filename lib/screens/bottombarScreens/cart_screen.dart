import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:osm/screens/product_details_view_screen.dart';
import 'package:osm/services/common_responses.dart';
import 'package:osm/services/common_variables.dart';
import 'package:osm/services/database_services.dart';

class cartscreen extends StatefulWidget {
  const cartscreen({super.key});

  @override
  State<cartscreen> createState() => _cartscreenState();
}

class _cartscreenState extends State<cartscreen> {
  final _auth = FirebaseAuth.instance;
  List _cartProducts = [];
  bool _isLoading = true;

  Future<void> _getCartProducts() async {
    var carts =
        await DatabaseServices().getUserCartDetails(_auth.currentUser!.uid);
    _isLoading = false;
    if (carts['msg'] == 'done') {
      _cartProducts = carts['data'];
    }
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (_auth.currentUser != null) {
      _getCartProducts();
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appColor,
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text("Cart products"),
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
            : _cartProducts.isEmpty
                ? Text("No data was found")
                : ListView.builder(
                    itemCount: _cartProducts.length,
                    itemBuilder: (context, ind) {
                      var product = _cartProducts[ind];
                      return GestureDetector(
                        onTap: () {
                          CommonResponses().shiftPage(
                              context, ProductdetailsViewScreen(product));
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
                        ),
                      );
                    }),
      ),
    );
  }
}
