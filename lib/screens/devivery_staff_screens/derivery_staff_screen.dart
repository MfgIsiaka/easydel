import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:osm/screens/devivery_staff_screens/add_delivery_staffs.dart';
import 'package:osm/screens/home_screen.dart';
import 'package:osm/services/common_responses.dart';
import 'package:osm/services/common_variables.dart';
import 'package:osm/services/database_services.dart';
import 'package:osm/services/provider_services.dart';
import 'package:provider/provider.dart';

class DeliveryStaffs extends StatefulWidget {
  const DeliveryStaffs({super.key});

  @override
  State<DeliveryStaffs> createState() => _DeliveryStaffsState();
}

class _DeliveryStaffsState extends State<DeliveryStaffs> {
  final _usersRef = FirebaseFirestore.instance.collection("USERS");
  AppDataProvider? _provider;
  Map<String, dynamic> _usersResult = {};
  bool _loading = true;
  final _auth = FirebaseAuth.instance;

  Future<void> _loadingUsers() async {
    var user =
        await DatabaseServices().getDeliveryUsers(_auth.currentUser!.uid);
    print("Back");
    if (user['msg'] == 'done') {
      setState(() {
        _loading = false;
        _usersResult = user;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadingUsers();
  }

  @override
  Widget build(BuildContext context) {
    _provider = Provider.of<AppDataProvider>(context);
    Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text("Your staffs"),
      ),
      body: Center(
        child: _loading
            ? CircularProgressIndicator()
            : _usersResult.isEmpty || _usersResult['data'].isEmpty
                ? const Text(
                    "No staff was found",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )
                : ListView.builder(
                    itemCount: _usersResult['data'].length,
                    itemBuilder: (context, ind) {
                      var user = _usersResult['data'][ind];

                      return Container(
                        decoration: const BoxDecoration(
                            border: Border(bottom: BorderSide())),
                        child: ListTile(
                          dense: true,
                          visualDensity:
                              VisualDensity(horizontal: -3, vertical: -3),
                          title: Text(
                            "${user['first_name']} ${user['last_name']}",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            user['orderId'] == null || user['orderId'].isEmpty
                                ? 'Not assigned'
                                : 'Assigned',
                            style: TextStyle(
                                fontWeight: user['orderId'] == null ||
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
                              borderRadius: BorderRadius.circular(40),
                              child: user['profile_photo'] == null
                                  ? Container(
                                      color: Colors.blueGrey,
                                      child: Icon(Icons.person))
                                  : CachedNetworkImage(
                                      fit: BoxFit.cover,
                                      imageUrl: _provider!
                                          .currentUser['profile_photo'],
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
                      );
                    }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
                  MaterialPageRoute(builder: (context) => AddDeliveryStaff()))
              .then((value) async {
            await _loadingUsers();
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
