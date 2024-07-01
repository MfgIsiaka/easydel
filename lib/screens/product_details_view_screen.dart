import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:marquee/marquee.dart';
import 'package:osm/screens/bottombarScreens/order_placing_screen.dart';
import 'package:osm/screens/map_screen.dart';
import 'package:osm/screens/shop_product_list_screen.dart';
import 'package:osm/services/common_responses.dart';
import 'package:osm/services/common_variables.dart';
import 'package:osm/services/database_services.dart';
import 'package:osm/services/provider_services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductdetailsViewScreen extends StatefulWidget {
  var product;
  ProductdetailsViewScreen(this.product, {super.key});

  @override
  State<ProductdetailsViewScreen> createState() =>
      _ProductdetailsViewScreenState();
}

class _ProductdetailsViewScreenState extends State<ProductdetailsViewScreen> {
  AppDataProvider? _provider;
  var _product;
  final _auth = FirebaseAuth.instance;
  Map<String, dynamic> _retailDetails = {};
  List _carts = [];
  bool _fetchingUser = true;
  bool _fetchingCarts = true;
  bool _fetchingShop = true;
  Map<String, dynamic> _shopDetails = {};

  Future<void> _getShop() async {
    var res = await DatabaseServices().getSingleShop(_product['shopId']);
    _fetchingShop = false;
    if (res['msg'] == 'done') {
      setState(() {
        _shopDetails = res['data'];
      });
    }
  }

  Future<void> _cartProducts() async {
    var res = await DatabaseServices().getUserCarts(_auth.currentUser!.uid);
    _fetchingCarts = false;
    if (res['msg'] == 'done') {
      setState(() {
        _carts = res['data'];
      });
    }
  }

  Future<void> _getRetailorDetails() async {
    var res = await DatabaseServices().getSingleUser(_product['ownerId']);
    _fetchingUser = false;
    if (res['msg'] == 'done') {
      setState(() {
        _retailDetails = res['data'];
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _product = widget.product;
    _getRetailorDetails();
    _getShop();
    if (_auth.currentUser != null) {
      _cartProducts();
    } else {
      setState(() {
        _fetchingCarts = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _provider = Provider.of<AppDataProvider>(context);
    Size screenSize = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        body: SizedBox(
          height: screenSize.height,
          child: Stack(
            alignment: Alignment.topCenter,
            clipBehavior: Clip.none,
            children: [
              SizedBox(
                height: (9 / 16) * screenSize.width,
                child: PageView.builder(
                    itemCount: _product['images'].length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, ind) {
                      return Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          Container(
                            width: screenSize.width,
                            height: (9 / 16) * screenSize.width,
                            decoration: const BoxDecoration(
                              color: Color.fromARGB(85, 0, 0, 0),
                            ),
                            child: Hero(
                              tag: _product['id'],
                              child: CachedNetworkImage(
                                fit: BoxFit.cover,
                                imageUrl: _product['images'][ind],
                                errorWidget: (context, val, obj) {
                                  return const Icon(Icons.error);
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
                          Container(
                            color: blackColor,
                            child: Text(
                              "${ind + 1}/${_product['images'].length}",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: whiteColor),
                            ),
                          )
                        ],
                      );
                    }),
              ),
              Positioned(
                top: (9 / 16) * screenSize.width - 12,
                child: Stack(
                  alignment: Alignment.topCenter,
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: screenSize.width,
                      height:
                          screenSize.height - (9 / 16) * screenSize.width - 20,
                      padding: const EdgeInsets.only(
                          top: 20, left: 3, right: 3, bottom: 10),
                      decoration: BoxDecoration(
                          color: whiteColor,
                          boxShadow: [
                            BoxShadow(blurRadius: 4.4, color: blackColor)
                          ],
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15),
                          )),
                      child: ListView(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Stack(
                                alignment: Alignment.center,
                                children: [
                                  Divider(
                                    color: blackColor,
                                  ),
                                  Text(
                                    "PROPERTY DETAILS",
                                    style: TextStyle(
                                        color: appColor,
                                        backgroundColor: whiteColor,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.only(left: 3),
                                decoration: const BoxDecoration(
                                    border: Border(
                                        left: BorderSide(
                                            width: 2, color: appColor))),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "ABOUT:",
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: greyColor,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      _product['title'],
                                      style: TextStyle(fontSize: 16),
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                              SizedBox(
                                height: 100,
                                child: GridView(
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          childAspectRatio: 4 / 1,
                                          mainAxisSpacing: 3),
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.only(left: 3),
                                      decoration: BoxDecoration(
                                          border: Border(
                                              left: BorderSide(
                                                  width: 2, color: appColor))),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            "CATEGORY:",
                                            style: TextStyle(
                                                color: greyColor,
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            _product['category'],
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(fontSize: 16),
                                          )
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.only(left: 3),
                                      decoration: BoxDecoration(
                                          border: Border(
                                              left: BorderSide(
                                                  width: 2, color: appColor))),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            "BRAND:",
                                            style: TextStyle(
                                                color: greyColor,
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            _product['subcategory'],
                                            style: TextStyle(fontSize: 16),
                                          )
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.only(left: 3),
                                      decoration: BoxDecoration(
                                          border: Border(
                                              left: BorderSide(
                                                  width: 2, color: appColor))),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "STATUS:",
                                            style: TextStyle(
                                                color: greyColor,
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            _product['status'],
                                            style: TextStyle(fontSize: 16),
                                          )
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.only(left: 3),
                                      decoration: BoxDecoration(
                                          border: Border(
                                              left: BorderSide(
                                                  width: 2, color: appColor))),
                                      child: const Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "WARANT:",
                                            style: TextStyle(
                                                color: greyColor,
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            "2 months",
                                            style: TextStyle(fontSize: 16),
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                              Container(
                                padding: const EdgeInsets.only(left: 3),
                                decoration: BoxDecoration(
                                    border: Border(
                                        left: BorderSide(
                                            width: 2, color: appColor))),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "PRICE:",
                                          style: TextStyle(
                                              color: greyColor,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          "TSH ${_product['price']}/=",
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: appColor),
                                        )
                                      ],
                                    ),
                                    _provider!.currentUser['role'] == "admin"
                                        ? Container()
                                        : OutlinedButton.icon(
                                            onPressed: () {
                                              if (_auth.currentUser != null) {
                                                if (_auth.currentUser!.uid !=
                                                    _product['ownerId']) {
                                                  CommonResponses().shiftPage(
                                                      context,
                                                      OrderPlacingScreen(
                                                          _product));
                                                } else {
                                                  CommonResponses().showToast(
                                                      "You can't order your own product!!");
                                                }
                                              } else {
                                                CommonResponses().showToast(
                                                    "Pease login first..");
                                              }
                                            },
                                            style: OutlinedButton.styleFrom(
                                                foregroundColor: appColor),
                                            icon: const Icon(
                                                Icons.monetization_on),
                                            label: const Text("Order now"))
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                              Container(
                                padding: const EdgeInsets.only(left: 3),
                                decoration: BoxDecoration(
                                    border: Border(
                                        left: BorderSide(
                                            width: 2, color: appColor))),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            "LOCATION:",
                                            style: TextStyle(
                                                color: greyColor,
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(
                                            //width: 100,
                                            height: 40,
                                            child: Marquee(
                                              text:
                                                  "${_product['district']},${_product['region']}",
                                              style:
                                                  const TextStyle(fontSize: 16),
                                              blankSpace:
                                                  screenSize.width * 0.7,
                                              startAfter:
                                                  const Duration(seconds: 1),
                                              pauseAfterRound:
                                                  const Duration(seconds: 1),
                                              numberOfRounds: 2,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    OutlinedButton.icon(
                                        onPressed: () {
                                          CommonResponses().shiftPage(
                                              context, mapScreen(_product));
                                        },
                                        style: OutlinedButton.styleFrom(
                                            foregroundColor: appColor),
                                        icon: const Icon(Icons.location_on),
                                        label: const Text("Open map"))
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                              Container(
                                padding: const EdgeInsets.only(left: 3),
                                decoration: const BoxDecoration(
                                    border: Border(
                                        left: BorderSide(
                                            width: 2, color: appColor))),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "DESCRIPTION:",
                                      style: TextStyle(
                                          color: greyColor,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      _product['description'],
                                      maxLines: 4,
                                      style: TextStyle(fontSize: 16),
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                              Container(
                                  padding: const EdgeInsets.only(left: 3),
                                  decoration: BoxDecoration(
                                      border: Border(
                                          left: BorderSide(
                                              width: 2, color: appColor))),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "SHOP:",
                                        style: TextStyle(
                                            color: greyColor,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      _fetchingShop
                                          ? const Center(
                                              child:
                                                  CircularProgressIndicator())
                                          : ListTile(
                                              dense: true,
                                              visualDensity:
                                                  const VisualDensity(
                                                      horizontal: -1,
                                                      vertical: -1),
                                              contentPadding:
                                                  const EdgeInsets.only(
                                                      left: 1,
                                                      top: 0,
                                                      bottom: 0),
                                              leading: GestureDetector(
                                                onTap: () {
                                                  CommonResponses().shiftPage(
                                                      context,
                                                      ShopProductListScreen(
                                                          _shopDetails));
                                                },
                                                child: AbsorbPointer(
                                                  child: Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                            right: 5),
                                                    padding: const EdgeInsets
                                                        .symmetric(vertical: 3),
                                                    width: 50,
                                                    height: 50,
                                                    decoration: BoxDecoration(
                                                        color: whiteColor,
                                                        boxShadow: [
                                                          BoxShadow(
                                                              blurRadius: 4.4,
                                                              color: blackColor)
                                                        ],
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(50),
                                                        image: DecorationImage(
                                                          fit: BoxFit.cover,
                                                          image: NetworkImage(
                                                            "${_shopDetails['logo']}",
                                                          ),
                                                        )),
                                                  ),
                                                ),
                                              ),
                                              title:
                                                  Text(_shopDetails['title']),
                                              subtitle: Text(
                                                _shopDetails['description'],
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                    ],
                                  )),
                            ],
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  Divider(
                                    color: blackColor,
                                  ),
                                  Text(
                                    "RETAILOR INFORMATION",
                                    style: TextStyle(
                                        color: appColor,
                                        backgroundColor: whiteColor,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Center(
                                child: _fetchingUser
                                    ? CircularProgressIndicator()
                                    : _retailDetails.isEmpty
                                        ? const Text("No user found")
                                        : Column(
                                            children: [
                                              Container(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 3),
                                                  decoration: BoxDecoration(
                                                      border: Border(
                                                          left: BorderSide(
                                                              width: 2,
                                                              color:
                                                                  appColor))),
                                                  child: ListTile(
                                                    contentPadding:
                                                        const EdgeInsets.only(
                                                            left: 1,
                                                            top: 0,
                                                            bottom: 0),
                                                    leading: Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                              right: 5),
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 3),
                                                      width: 50,
                                                      height: 50,
                                                      decoration: BoxDecoration(
                                                          color: whiteColor,
                                                          boxShadow: [
                                                            BoxShadow(
                                                                blurRadius: 4.4,
                                                                color:
                                                                    blackColor)
                                                          ],
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(50),
                                                          image:
                                                              DecorationImage(
                                                            fit: BoxFit.cover,
                                                            image: NetworkImage(
                                                              "${_retailDetails['profile_photo']}",
                                                            ),
                                                          )),
                                                    ),
                                                    title: Text(
                                                        "${_retailDetails['first_name']} ${_retailDetails['last_name']}"),
                                                    // subtitle: const Text(
                                                    //   "Ninajihusisha na uuzaji wa pikipiki na bajaji",
                                                    //   maxLines: 1,
                                                    //   overflow:
                                                    //       TextOverflow.ellipsis,
                                                    // ),
                                                  )),
                                              const SizedBox(
                                                height: 4,
                                              ),
                                              Container(
                                                padding: const EdgeInsets.only(
                                                    left: 3),
                                                decoration: BoxDecoration(
                                                    border: Border(
                                                        left: BorderSide(
                                                            width: 2,
                                                            color: appColor))),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          "PHONE:",
                                                          style: TextStyle(
                                                              color: greyColor,
                                                              fontSize: 11,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        Text(
                                                          _retailDetails[
                                                              'phone'],
                                                          style: TextStyle(
                                                              fontSize: 16),
                                                        )
                                                      ],
                                                    ),
                                                    OutlinedButton.icon(
                                                        onPressed: () async {
                                                          await launch(
                                                              "tel:0763123345");
                                                        },
                                                        icon: const Icon(
                                                            Icons.phone),
                                                        label: const Text(
                                                            "Make a call"))
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 4,
                                              ),
                                              Container(
                                                padding: const EdgeInsets.only(
                                                    left: 3),
                                                decoration: BoxDecoration(
                                                    border: Border(
                                                        left: BorderSide(
                                                            width: 2,
                                                            color: appColor))),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          "EMAIL:",
                                                          style: TextStyle(
                                                              color: greyColor,
                                                              fontSize: 11,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        Text(
                                                          _retailDetails[
                                                              'email'],
                                                          style: TextStyle(
                                                              fontSize: 16),
                                                        )
                                                      ],
                                                    ),
                                                    OutlinedButton.icon(
                                                        style: OutlinedButton
                                                            .styleFrom(),
                                                        onPressed: () async {
                                                          await launch(
                                                              "mailto:${_retailDetails['email']}");
                                                        },
                                                        icon: const Icon(
                                                            Icons.phone),
                                                        label: const Text(
                                                            "Send mail"))
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              )
                                            ],
                                          ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                    Positioned(
                      top: -10,
                      child: SizedBox(
                        height: 30,
                        child: _provider!.currentUser['role'] == "admin"
                            ? ElevatedButton(
                                onPressed: () async {
                                  CommonResponses().showLoadingDialog(context);
                                  var res = await DatabaseServices()
                                      .updateProductLiveStatus(_product);
                                  Navigator.pop(context);
                                  if (res['msg'] == 'done') {
                                    if (_product['approval_status'] ==
                                        "Approved") {
                                      _product['approval_status'] =
                                          "Not approved";
                                    } else {
                                      _product['approval_status'] = "Approved";
                                    }
                                    setState(() {});
                                    CommonResponses().showToast(
                                        "product status updated successfully");
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        _product['approval_status'] ==
                                                "Approved"
                                            ? greenColor
                                            : redColor,
                                    foregroundColor: whiteColor),
                                child: Text(_product['approval_status']))
                            : (_auth.currentUser != null &&
                                    _product['ownerId'] ==
                                        _auth.currentUser!.uid)
                                ? Container()
                                : _fetchingCarts
                                    ? SpinKitThreeBounce(
                                        size: 18,
                                        duration:
                                            const Duration(milliseconds: 500),
                                        color: appColor,
                                      )
                                    : ElevatedButton(
                                        onPressed: () async {
                                          if (_auth.currentUser != null) {
                                            var cart = {
                                              'productId': _product['id'],
                                              'customerId':
                                                  _auth.currentUser!.uid,
                                              'ownerId': _product['id']
                                            };
                                            if (_carts.indexWhere((el) =>
                                                    el['productId'] ==
                                                    _product['id']) <
                                                0) {
                                              CommonResponses()
                                                  .showLoadingDialog(context);
                                              var res = await DatabaseServices()
                                                  .uploadUserCarts(cart);
                                              Navigator.pop(context);
                                              setState(() {
                                                _fetchingCarts = true;
                                              });
                                              _cartProducts();
                                              if (res['msg'] == 'done') {
                                                CommonResponses().showToast(
                                                    "Product added to cart successfully");
                                              }
                                            } else {
                                              int ind = _carts.indexWhere(
                                                  (el) =>
                                                      el['productId'] ==
                                                      _product['id']);
                                              print(ind);
                                              CommonResponses()
                                                  .showLoadingDialog(context);
                                              var res = await DatabaseServices()
                                                  .deleteUserCart(
                                                      _carts[ind]['id']);
                                              Navigator.pop(context);
                                              setState(() {
                                                _fetchingCarts = true;
                                              });
                                              _cartProducts();
                                              if (res['msg'] == 'done') {
                                                CommonResponses().showToast(
                                                    "Product removed from cart successfully",
                                                    isError: false);
                                              }
                                            }
                                          } else {
                                            CommonResponses().showToast(
                                                "Please login first, or create an account!!",
                                                isError: true);
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: appColor,
                                            foregroundColor: whiteColor),
                                        child: Text(_carts.indexWhere((el) =>
                                                    el['productId'] ==
                                                    _product['id']) >=
                                                0
                                            ? "Added to cart"
                                            : "Add to cart")),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
