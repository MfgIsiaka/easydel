import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:osm/screens/product_details_view_screen.dart';
import 'package:osm/services/common_responses.dart';
import 'package:osm/services/common_variables.dart';
import 'package:osm/services/database_services.dart';

class ShopProductListScreen extends StatefulWidget {
  var shopDetails;
  ShopProductListScreen(this.shopDetails, {super.key});
  @override
  State<ShopProductListScreen> createState() => _ShopProductListScreenState();
}

class _ShopProductListScreenState extends State<ShopProductListScreen> {
  bool _isLoading = true;
  Map<String, dynamic> _propresult = {};
  var _shopDetails = {};
  List _products = [];

  Future<void> _getProperties() async {
    var res = await DatabaseServices().retriveProperty();
    _propresult = res;
    if (res['msg'] == "done" && res['data'].isNotEmpty) {
      _products = (res['data'] as List)
          .where((el) => el['shopId'] == _shopDetails['id'])
          .toList();
    }
    _isLoading = false;
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _shopDetails = widget.shopDetails;
    _getProperties();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appColor,
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(_shopDetails['title']),
            Text(
              _products.isEmpty ? "" : "${_products.length} products found",
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.bold, color: whiteColor),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? Center(
              child: SpinKitCircle(
                color: appColor,
              ),
            )
          : _propresult.isEmpty
              ? Center(
                  child: SpinKitCircle(
                    color: appColor,
                    size: 35,
                  ),
                )
              : _propresult['msg'] != 'done'
                  ? Center(
                      child: Text(_propresult['msg']),
                    )
                  : _products.isEmpty
                      ? const Center(
                          child: Text(
                            'No apartment found',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _products.length,
                          itemBuilder: (context, ind) {
                            var product = _products[ind];
                            String time = _formatTimeDifference(
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
                                                      Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 3),
                                                        decoration: BoxDecoration(
                                                            color:
                                                                Colors.blueGrey,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20)),
                                                        child: Text(
                                                          product['status'],
                                                          style: TextStyle(
                                                              fontSize: 12,
                                                              color: whiteColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
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
    );
  }

  String _formatTimeDifference(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} d';
    } else if (difference.inDays < 365) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks w';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years y';
    }
  }
}
