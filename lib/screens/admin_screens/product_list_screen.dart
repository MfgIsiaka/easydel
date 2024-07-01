import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:osm/screens/product_details_view_screen.dart';
import 'package:osm/services/common_responses.dart';
import 'package:osm/services/common_variables.dart';
import 'package:osm/services/database_services.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  bool _isLoading = true;
  List _propresult = [];
  Future<void> _getProperties() async {
    var res = await DatabaseServices().retriveProperty();
    setState(() {
      _isLoading = false;
    });
    if (res['msg'] == "done") {
      setState(() {
        _propresult = res['data'];
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getProperties();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Products"),
      ),
      body: _isLoading
          ? SpinKitCircle(
              color: appColor,
            )
          : _propresult.isEmpty
              ? Text("No data was found")
              : ListView.builder(
                  itemCount: _propresult.length,
                  controller: ScrollController(),
                  itemBuilder: (context, ind) {
                    var product = _propresult[ind];
                    String time = CommonResponses().formatTimeDifference(
                        DateTime.fromMillisecondsSinceEpoch(
                            product['uploadedAt']));
                    return GestureDetector(
                      onTap: () async {
                        await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        ProductdetailsViewScreen(product)))
                            .then((value) async {
                          await _getProperties();
                        });
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
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 3),
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
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(fontSize: 17),
                                              ),
                                              Row(
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 3),
                                                    decoration: BoxDecoration(
                                                        color: Colors.blueGrey,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20)),
                                                    child: Text(
                                                      product['status'],
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          color: whiteColor,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                  Spacer(),
                                                  Text(
                                                    product['approval_status'],
                                                    style: TextStyle(
                                                        color:
                                                            product['approval_status'] ==
                                                                    "Approved"
                                                                ? greenColor
                                                                : redColor,
                                                        fontWeight:
                                                            FontWeight.bold,
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
                                            style: const TextStyle(
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
    );
  }
}
