import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:osm/screens/admin_screens/shop_details_screen.dart';
import 'package:osm/services/common_responses.dart';
import 'package:osm/services/common_variables.dart';
import 'package:osm/services/database_services.dart';

class ShopListScreen extends StatefulWidget {
  const ShopListScreen({super.key});

  @override
  State<ShopListScreen> createState() => _ShopListScreenState();
}

class _ShopListScreenState extends State<ShopListScreen> {
  bool _isLoading = true;
  List _shops = [];
  Future<void> _getAllShops() async {
    var res = await DatabaseServices().getAllShops();
    setState(() {
      _isLoading = false;
    });
    if (res['msg'] == "done") {
      setState(() {
        _shops = res['data'];
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getAllShops();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Shops"),
      ),
      body: _isLoading
          ? SpinKitCircle(
              color: appColor,
            )
          : _shops.isEmpty
              ? Text("No data was found")
              : ListView.builder(
                  itemCount: _shops.length,
                  controller: ScrollController(),
                  itemBuilder: (context, ind) {
                    var shop = _shops[ind];
                    // String time = CommonResponses().formatTimeDifference(
                    //     DateTime.fromMillisecondsSinceEpoch(
                    //         product['uploadedAt']));
                    return GestureDetector(
                      onTap: () async {
                        await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        ShopDetailsScreen(shop)))
                            .then((value) async {
                          await _getAllShops();
                        });
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
                                    tag: shop['id'],
                                    child: CachedNetworkImage(
                                      fit: BoxFit.cover,
                                      imageUrl: shop['logo'],
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
                                padding: const EdgeInsets.all(3.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      shop['title'],
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Expanded(child: Text(shop['description'])),
                                    Text(
                                      shop['approval_status'] == null
                                          ? "Not approved"
                                          : shop['approval_status'],
                                      style: TextStyle(
                                          color: shop['approval_status'] ==
                                                  "Approved"
                                              ? greenColor
                                              : redColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12),
                                    ),
                                    Text(
                                        "${shop['district']} ${shop['region']}")
                                  ],
                                ),
                              ))
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
    );
  }
}
