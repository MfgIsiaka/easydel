import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:osm/screens/devivery_staff_screens/derivery_staff_screen.dart';
import 'package:osm/screens/home_screen.dart';
import 'package:osm/screens/profile_screens/my_orders_list_screen.dart';
import 'package:osm/screens/shop_product_list_screen.dart';
import 'package:osm/services/common_responses.dart';
import 'package:osm/services/common_variables.dart';
import 'package:osm/services/database_services.dart';
import 'package:osm/services/provider_services.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  var currentUser;
  ProfileScreen(this.currentUser, {super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _auth = FirebaseAuth.instance;
  AppDataProvider? _provider;
  bool _fetchingShop = true;
  var _currentUser = {};
  var _shopDetails = {};

  Future<void> _getMyshop() async {
    var res = await DatabaseServices().getMyShop(_auth.currentUser!.uid);
    if (res['msg'] == 'done' && res['msg'].isNotEmpty) {
      setState(() {
        _fetchingShop = false;
        _shopDetails = res['data'];
      });
    } else {
      print(res);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _currentUser = widget.currentUser;
    _getMyshop();
  }

  @override
  Widget build(BuildContext context) {
    _provider = Provider.of<AppDataProvider>(context);
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Profile",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
                onPressed: () {
                  _showLogoutConfirmDialog();
                },
                icon: Icon(Icons.logout))
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(3.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(width: 5)),
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20))),
                child: Row(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: _currentUser['profile_photo'] == null
                            ? Icon(Icons.person)
                            : CachedNetworkImage(
                                fit: BoxFit.cover,
                                imageUrl: _currentUser['profile_photo'],
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
                      child: Container(
                        margin: EdgeInsets.only(left: 7),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.person,
                                  color: appColor,
                                  size: 30,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  "${_currentUser['first_name']} ${_currentUser['last_name']}",
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.call_end,
                                  color: appColor,
                                  size: 30,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  _currentUser['phone'],
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.mail,
                                  color: appColor,
                                  size: 30,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Text(
                                    "${_currentUser['email']}",
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
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
              Center(
                  child: Text(
                "Details",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              )),
              Expanded(
                  child: ListView(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    margin: const EdgeInsets.only(top: 3),
                    decoration: const BoxDecoration(
                        color: whiteColor,
                        boxShadow: [
                          BoxShadow(color: blackColor, blurRadius: 2)
                        ]),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Your shop",
                          style: TextStyle(
                              color: appColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        ),
                        _fetchingShop
                            ? const Center(child: CircularProgressIndicator())
                            : _shopDetails.isEmpty
                                ? const Center(
                                    child: Text("You do not have a shop"),
                                  )
                                : ListTile(
                                    dense: true,
                                    onTap: () {
                                      CommonResponses().shiftPage(context,
                                          ShopProductListScreen(_shopDetails));
                                    },
                                    visualDensity: const VisualDensity(
                                        horizontal: -1, vertical: -1),
                                    contentPadding: const EdgeInsets.only(
                                        left: 1, top: 0, bottom: 0),
                                    leading: AbsorbPointer(
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
                                                "${_shopDetails['logo']}",
                                              ),
                                            )),
                                      ),
                                    ),
                                    title: Text(_shopDetails['title']),
                                    subtitle: Text(
                                      _shopDetails['description'],
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  GestureDetector(
                    onTap: () {
                      CommonResponses()
                          .shiftPage(context, const DeliveryStaffs());
                    },
                    child: AbsorbPointer(
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                            color: whiteColor,
                            boxShadow: [
                              BoxShadow(color: blackColor, blurRadius: 2)
                            ]),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Delivery staffs",
                              style: TextStyle(
                                  color: appColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18),
                            ),
                            const Text("Your staffs here")
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  GestureDetector(
                    onTap: () {
                      CommonResponses()
                          .shiftPage(context, const MyOrdersListScreen());
                    },
                    child: AbsorbPointer(
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                            color: whiteColor,
                            boxShadow: [
                              BoxShadow(color: blackColor, blurRadius: 2)
                            ]),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Customer orders",
                              style: TextStyle(
                                  color: appColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18),
                            ),
                            const Text("Your customer orders here")
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ))
            ],
          ),
        ));
  }

  List<int> selectedCouses = [];
  void _showLogoutConfirmDialog() {
    showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel: "logout_confirm",
        transitionDuration: Duration(seconds: 1),
        transitionBuilder: (context, anim1, anim2, child) {
          Animation<Offset> animation = Tween<Offset>(
                  begin: Offset(0, -(anim1.value * 0.4)), end: Offset(0, 0))
              .animate(anim1);
          return SlideTransition(
            position: animation,
            child: child,
          );
        },
        pageBuilder: (context, anim1, anim2) {
          return AlertDialog(
            title: Text("Confirm"),
            content: Text(
                "Dear ${_currentUser['first_name']}, Are you sure you want to logout?"),
            actions: [
              FilledButton.icon(
                  onPressed: () async {
                    CommonResponses().showLoadingDialog(context);
                    await _auth.signOut().then((value) {
                      _provider!.currentUser = {};
                      CommonResponses()
                          .shiftPage(context, HomeScreen(), kill: true);
                    });
                  },
                  icon: Icon(Icons.thumb_up),
                  label: Text("Yes")),
              FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.back_hand),
                  label: Text("No"))
            ],
          );
        });
  }
}
