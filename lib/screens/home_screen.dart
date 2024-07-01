import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:osm/screens/auth_screens/auth_screen.dart';
import 'package:osm/screens/bottombarScreens/cart_screen.dart';
import 'package:osm/screens/bottombarScreens/product_upload_screen.dart';
import 'package:osm/screens/bottombarScreens/orders_list_screen.dart';
import 'package:osm/screens/product_details_view_screen.dart';
import 'package:osm/screens/profile_screen.dart';
import 'package:osm/screens/shop_product_list_screen.dart';
import 'package:osm/services/common_responses.dart';
import 'package:osm/services/common_variables.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:osm/services/database_services.dart';
import 'package:osm/services/provider_services.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List _carts = [];
  bool _fetchingCarts = true;
  AppDataProvider? _provider;
  Map<String, dynamic> _propresult = {};
  List _shops = [];
  final _auth = FirebaseAuth.instance;
  final _pageController = PageController();
  final _productlistController = ScrollController();
  bool _isLoading = false;
  double searchWidth = 40;
  var _currentUser = {};

  Future<void> _cartProducts() async {
    var res = await DatabaseServices().getUserCarts(_auth.currentUser!.uid);
    _fetchingCarts = false;
    if (res['msg'] == 'done') {
      setState(() {
        _carts = res['data'];
      });
    }
  }

  Future<void> _loadingShops() async {
    var shops = await DatabaseServices().getAllShops();
    if (shops['msg'] == 'done' && shops['data'].isNotEmpty) {
      setState(() {
        _shops = shops['data'];
      });
    }
  }

  Future<void> _loadingUser() async {
    var user = await DatabaseServices().getSingleUser(_auth.currentUser!.uid);
    if (user['msg'] == 'done') {
      setState(() {
        _provider!.currentUser = user['data'];
        _currentUser = user['data'];
      });
    }
  }

  Future<void> _loading() async {
    setState(() {
      _isLoading = true;
    });
    await Future.delayed(const Duration(seconds: 5), () {
      _isLoading = false;
    });
    print("kkk");
    setState(() {});
  }

  Future<void> _getProperties() async {
    var res = await DatabaseServices().retriveProperty();
    setState(() {
      _propresult = res;
    });
  }

  bool _isScrolledDown = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadingShops();
    _getProperties();

    if (_auth.currentUser != null) {
      _cartProducts();
      _loadingUser();
    }
    _productlistController.addListener(() {
      if (_productlistController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        // User is scrolling down
        print("down");
        setState(() {
          _isScrolledDown = true;
        });
      } else if (_productlistController.position.userScrollDirection ==
          ScrollDirection.forward) {
        // User is scrolling up
        print("up");
        setState(() {
          _isScrolledDown = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _provider = Provider.of<AppDataProvider>(context);
    Size screenSize = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async {
        _shiftpageView(0);
        return false;
      },
      child: Scaffold(
        backgroundColor: appColor,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: appColor,
          title: Text(
            "Welcome",
            style: TextStyle(
                fontFamily: 'App-font', fontSize: 30, color: whiteColor),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: GestureDetector(
                onTap: () {
                  if (_auth.currentUser == null) {
                    CommonResponses().shiftPage(context, const Authscreen());
                  } else {
                    if (_currentUser.isNotEmpty) {
                      CommonResponses()
                          .shiftPage(context, ProfileScreen(_currentUser));
                    }
                  }
                },
                child: AbsorbPointer(
                  child: _auth.currentUser != null
                      ? Container(
                          decoration: BoxDecoration(
                            color: whiteColor,
                            borderRadius: BorderRadius.circular(40),
                          ),
                          width: 45,
                          height: 45,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(40),
                            child: _currentUser.isEmpty
                                ? SpinKitCircle(
                                    color: appColor,
                                    size: 30,
                                  )
                                : _currentUser['profile_photo'] == null
                                    ? Icon(Icons.person)
                                    : CachedNetworkImage(
                                        fit: BoxFit.cover,
                                        imageUrl: _currentUser['profile_photo'],
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
                        )
                      : CircleAvatar(
                          child: Icon(Icons.person_outline),
                        ),
                ),
              ),
            )
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    height: _isScrolledDown ? 0 : 80,
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Shops",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, color: whiteColor),
                          ),
                          SizedBox(
                            width: screenSize.width,
                            height: 52,
                            child: ListView.builder(
                                itemCount: _shops.length,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, ind) {
                                  var shop = _shops[ind];
                                  return GestureDetector(
                                    onTap: () {
                                      CommonResponses().shiftPage(
                                          context, ShopProductListScreen(shop));
                                    },
                                    child: AbsorbPointer(
                                      child: Container(
                                        margin: const EdgeInsets.only(right: 5),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 3),
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
                                                BorderRadius.circular(50),
                                            image: DecorationImage(
                                              fit: BoxFit.cover,
                                              image: NetworkImage(
                                                "${shop['logo']}",
                                              ),
                                            )),
                                      ),
                                    ),
                                  );
                                }),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    color: appColor,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 40,
                        width: searchWidth,
                        decoration: BoxDecoration(
                            color: whiteColor,
                            borderRadius: BorderRadius.circular(50)),
                        child: Stack(
                          alignment: Alignment.centerLeft,
                          children: [
                            TextFormField(
                              // controller: _singlePeriodAmountCntrl,
                              decoration: InputDecoration(
                                  prefix: const Text("       "),
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: blackColor),
                                      borderRadius: BorderRadius.circular(50)),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 10),
                                  hintText: "Search what you want",
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(50))),
                            ),
                            IconButton(
                                onPressed: () {
                                  setState(() {
                                    if (searchWidth == 40) {
                                      searchWidth = screenSize.width;
                                    } else {
                                      searchWidth = 40;
                                    }
                                  });
                                },
                                icon: const Icon(Icons.search_outlined))
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 3,
                  )
                ],
              ),
            ),
            Expanded(
                child: Container(
              decoration: BoxDecoration(
                  color: whiteColor,
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25))),
              child: Column(
                children: [
                  _propresult.isEmpty
                      ? Container()
                      : Text(
                          "${_propresult['data'].length} products found",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                  Expanded(
                    child: _propresult.isEmpty
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
                            : _propresult['data'].isEmpty
                                ? const Center(
                                    child: Text('No apartment found'),
                                  )
                                : Builder(builder: (context) {
                                    var _products = _propresult['data']
                                        .where((el) =>
                                            el['approval_status'] == "Approved")
                                        .toList();
                                    return ListView.builder(
                                        itemCount: _products.length,
                                        controller: _productlistController,
                                        itemBuilder: (context, ind) {
                                          var product = _products[ind];
                                          String time = _formatTimeDifference(
                                              DateTime
                                                  .fromMillisecondsSinceEpoch(
                                                      product['uploadedAt']));
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
                                                margin: const EdgeInsets.all(5),
                                                decoration: BoxDecoration(
                                                    color: whiteColor,
                                                    border: Border(
                                                        bottom: BorderSide(
                                                            color: appColor,
                                                            width: 2)),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    boxShadow: [
                                                      BoxShadow(
                                                          color: blackColor,
                                                          blurRadius: 4.4)
                                                    ]),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      width: 150,
                                                      height: 120,
                                                      decoration:
                                                          const BoxDecoration(
                                                        color: Color.fromARGB(
                                                            15, 0, 0, 0),
                                                        borderRadius:
                                                            BorderRadius.only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        10),
                                                                bottomLeft: Radius
                                                                    .circular(
                                                                        10)),
                                                      ),
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            const BorderRadius
                                                                .only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        10),
                                                                bottomLeft: Radius
                                                                    .circular(
                                                                        10)),
                                                        child: Hero(
                                                          tag: product['id'],
                                                          child:
                                                              CachedNetworkImage(
                                                            fit: BoxFit.cover,
                                                            imageUrl: product[
                                                                'images'][0],
                                                            errorWidget:
                                                                (context, val,
                                                                    obj) {
                                                              return Icon(
                                                                  Icons.error);
                                                            },
                                                            progressIndicatorBuilder:
                                                                (context, val,
                                                                    prog) {
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
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 3),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Expanded(
                                                              child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                      product[
                                                                          'title'],
                                                                      maxLines:
                                                                          2,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              17),
                                                                    ),
                                                                    Container(
                                                                      padding: const EdgeInsets
                                                                          .symmetric(
                                                                          horizontal:
                                                                              3),
                                                                      decoration: BoxDecoration(
                                                                          color: Colors
                                                                              .blueGrey,
                                                                          borderRadius:
                                                                              BorderRadius.circular(20)),
                                                                      child:
                                                                          Text(
                                                                        product[
                                                                            'status'],
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                12,
                                                                            color:
                                                                                whiteColor,
                                                                            fontWeight:
                                                                                FontWeight.bold),
                                                                      ),
                                                                    ),
                                                                    const Spacer(),
                                                                    Row(
                                                                      children: [
                                                                        Icon(
                                                                          Icons
                                                                              .location_on,
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
                                                                      fontSize:
                                                                          15.5,
                                                                      color:
                                                                          appColor,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                                Text(
                                                                  time,
                                                                  style: const TextStyle(
                                                                      color:
                                                                          greyColor,
                                                                      fontSize:
                                                                          12,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
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
                                        });
                                  }),
                  ),
                ],
              ),
            ))
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          onTap: (index) {
            if (index == 1) {
              if (_auth.currentUser == null) {
                AwesomeDialog(
                    context: context,
                    dialogType: DialogType.error,
                    title: "Info",
                    desc:
                        "To upload product you need to have account and login with it,\n Do you wish to proceed?",
                    btnCancelText: "No",
                    btnOkText: "Yes",
                    btnCancelOnPress: () {},
                    btnOkOnPress: () {
                      CommonResponses().shiftPage(context, Authscreen());
                    }).show();
              } else {
                CommonResponses()
                    .shiftPage(context, const ProductUploadScreen());
              }
            } else if (index == 0) {
              if (_auth.currentUser != null) {
                CommonResponses().shiftPage(context, const cartscreen());
              } else {
                CommonResponses()
                    .showToast("Please login first", isError: true);
              }
            } else {
              if (_auth.currentUser != null) {
                CommonResponses().shiftPage(context, const OrdersListScreen());
              } else {
                CommonResponses()
                    .showToast("Please login first", isError: true);
              }
            }
          },
          currentIndex: 1,
          selectedLabelStyle: const TextStyle(height: 0.0),
          items: [
            BottomNavigationBarItem(
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(Icons.shopping_cart),
                  Positioned(
                    right: -6,
                    child: CircleAvatar(
                        backgroundColor: redColor,
                        radius: 7,
                        child: Text(
                          "3",
                          style: TextStyle(fontSize: 10, color: whiteColor),
                        )),
                  )
                ],
              ),
              label: 'Cart',
            ),
            BottomNavigationBarItem(
              icon: Container(
                  width: 70,
                  height: 40,
                  decoration: BoxDecoration(
                      border: Border.all(width: 3),
                      borderRadius: BorderRadius.circular(20)),
                  child: const Icon(Icons.add)),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(Icons.list),
                  Positioned(
                    right: -6,
                    child: CircleAvatar(
                        backgroundColor: redColor,
                        radius: 7,
                        child: Text(
                          "3",
                          style: TextStyle(fontSize: 10, color: whiteColor),
                        )),
                  )
                ],
              ),
              label: 'Orders',
            ),
          ],
        ),
      ),
    );
  }

  void _shiftpageView(int page) async {
    _pageController.animateToPage(page,
        duration: const Duration(milliseconds: 300), curve: Curves.decelerate);
    if (page == 1) {
      await _loading();
    }
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
