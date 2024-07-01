import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:osm/screens/product_details_view_screen.dart';
import 'package:osm/services/common_responses.dart';
import 'package:osm/services/common_variables.dart';
import 'package:osm/services/database_services.dart';

class ShopDetailsScreen extends StatefulWidget {
  var shop;
  ShopDetailsScreen(this.shop, {super.key});

  @override
  State<ShopDetailsScreen> createState() => _ShopDetailsScreenState();
}

class _ShopDetailsScreenState extends State<ShopDetailsScreen> {
  var _shop = {};
  bool _isLoading = true;
  bool _isLoadingProducts = true;
  var _shopOwner = {};
  List _shopProducts = [];

  Future<void> _getShopOwner() async {
    var res = await DatabaseServices().getSingleUser(_shop['ownerId']);
    setState(() {
      _isLoading = false;
    });
    if (res['msg'] == "done") {
      setState(() {
        _shopOwner = res['data'];
      });
    }
  }

  Future<void> _getShopProducts() async {
    var res = await DatabaseServices().getAllProducts();
    setState(() {
      _isLoadingProducts = false;
    });
    if (res['msg'] == "done") {
      setState(() {
        _shopProducts =
            res['data'].where((el) => el['shopId'] == _shop['id']).toList();
      });
    }
  }

  Future<void> _getThisShop() async {
    var res = await DatabaseServices().getMyShop(_shop['ownerId']);
    if (res['msg'] == 'done') {
      setState(() {
        _shop = res['data'];
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _shop = widget.shop;
    _getShopOwner();
    _getShopProducts();
    _getThisShop();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_shop['title']),
          bottom:
              const TabBar(tabs: [Tab(text: "Details"), Tab(text: "Products")]),
        ),
        body: TabBarView(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Licence",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: bGreyColor),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 123, 157, 173),
                            boxShadow: [
                              BoxShadow(color: blackColor, blurRadius: 10)
                            ],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: _shop['licence'] == null
                              ? Center(
                                  child: Text(
                                  "Not found",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ))
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: CachedNetworkImage(
                                    fit: BoxFit.cover,
                                    imageUrl: _shop['licence'],
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
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              _shop['licence'] == null
                                  ? Text(
                                      "Tell the owner to upload their licence",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12),
                                      textAlign: TextAlign.center)
                                  : Container(),
                              ElevatedButton.icon(
                                  onPressed: () async {
                                    if (_shop['licence'] != null) {
                                      CommonResponses()
                                          .showLoadingDialog(context);
                                      var res = await DatabaseServices()
                                          .updateLicenceStatus(_shop);
                                      if (res['msg'] == 'done') {
                                        await _getThisShop();
                                        CommonResponses().showToast(
                                            "Licence status updated successfully");
                                      }
                                      Navigator.pop(context);
                                    } else {
                                      CommonResponses().showToast(
                                          "Licence is not uploaded!!",
                                          isError: true);
                                    }
                                  },
                                  icon: Icon(
                                      _shop['approval_status'] == "Approved"
                                          ? Icons.done
                                          : Icons.cancel),
                                  style: ElevatedButton.styleFrom(
                                      shadowColor: blackColor,
                                      elevation: 10,
                                      foregroundColor:
                                          _shop['approval_status'] == "Approved"
                                              ? greenColor
                                              : redColor),
                                  label: Text(_shop['approval_status'])),
                            ],
                          ),
                        )
                      ],
                    )
                  ],
                ),
                SizedBox(
                  height: 5,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Owner",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: bGreyColor),
                    ),
                    _isLoading
                        ? CircularProgressIndicator()
                        : ListTile(
                            contentPadding: EdgeInsets.all(0),
                            leading: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                  color: Color.fromARGB(15, 0, 0, 0),
                                  borderRadius: BorderRadius.circular(50)),
                              child: _shopOwner['profile_photo'] == null
                                  ? Icon(Icons.person)
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(50),
                                      child: CachedNetworkImage(
                                        fit: BoxFit.cover,
                                        imageUrl: _shopOwner['profile_photo'],
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
                            subtitle: Text("${_shopOwner['email']}"),
                            title: Text(
                                "${_shopOwner['first_name']} ${_shopOwner['last_name']}"),
                          )
                  ],
                ),
              ],
            ),
          ),
          Container(
            child: Center(
              child: _isLoading
                  ? SpinKitCircle(
                      color: appColor,
                    )
                  : _shopProducts.isEmpty
                      ? Text("No product for this user")
                      : ListView.builder(
                          itemCount: _shopProducts.length,
                          controller: ScrollController(),
                          itemBuilder: (context, ind) {
                            var product = _shopProducts[ind];
                            String time = CommonResponses()
                                .formatTimeDifference(
                                    DateTime.fromMillisecondsSinceEpoch(
                                        product['uploadedAt']));
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ProductdetailsViewScreen(product)));
                                // CommonResponses().shiftPage(
                                //     context,
                                //     ProductdetailsViewScreen(
                                //         product));
                              },
                              child: AbsorbPointer(
                                child: Container(
                                  height: 120,
                                  margin: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                      color: whiteColor,
                                      border: Border(
                                          bottom: BorderSide(
                                              color: appColor, width: 2)),
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                            color: blackColor, blurRadius: 4.4)
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
                                          child: Hero(
                                            tag: product['id'],
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
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        product['title'],
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                            fontSize: 17),
                                                      ),
                                                      Row(
                                                        children: [
                                                          Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        3),
                                                            decoration: BoxDecoration(
                                                                color: Colors
                                                                    .blueGrey,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            20)),
                                                            child: Text(
                                                              product['status'],
                                                              style: TextStyle(
                                                                  fontSize: 12,
                                                                  color:
                                                                      whiteColor,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                          ),
                                                          Spacer(),
                                                          Text(
                                                            product['approval_status'] ==
                                                                    null
                                                                ? "Not approved"
                                                                : product[
                                                                    'approval_status'],
                                                            style: TextStyle(
                                                                color: product[
                                                                            'approval_status'] ==
                                                                        "Approved"
                                                                    ? greenColor
                                                                    : redColor,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 12),
                                                          )
                                                        ],
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
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    "Tsh ${product['price']}/=",
                                                    style: TextStyle(
                                                        fontSize: 15.5,
                                                        color: appColor,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Text(
                                                    time,
                                                    style: const TextStyle(
                                                        color: greyColor,
                                                        fontSize: 12,
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
                          }),
            ),
          )
        ]),
      ),
    );
  }
}
