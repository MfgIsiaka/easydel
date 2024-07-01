import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:osm/screens/admin_screens/admin_profile_screeen.dart';
import 'package:osm/screens/admin_screens/product_list_screen.dart';
import 'package:osm/screens/admin_screens/shop_list_screen.dart';
import 'package:osm/screens/admin_screens/users_list_screen.dart';
import 'package:osm/screens/auth_screens/auth_screen.dart';
import 'package:osm/services/common_responses.dart';
import 'package:osm/services/common_variables.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: appColor,
        title: Text(
          "Welcome Admin",
          style: TextStyle(
              fontFamily: 'App-font', fontSize: 30, color: whiteColor),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              CommonResponses().shiftPage(context, AdminProfileScreen());
            },
            child: AbsorbPointer(
              child: CircleAvatar(
                child: Icon(Icons.person_outline),
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: GridView(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              mainAxisSpacing: 10, crossAxisSpacing: 10, crossAxisCount: 3),
          children: [
            GestureDetector(
              onTap: () {
                CommonResponses().shiftPage(context, const UsersListscreen());
              },
              child: AbsorbPointer(
                child: Container(
                  margin: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      color: whiteColor,
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(blurRadius: 10)]),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people),
                      Text("Clients"),
                    ],
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                CommonResponses().shiftPage(context, const ProductListScreen());
              },
              child: AbsorbPointer(
                child: Container(
                  margin: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      color: whiteColor,
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(blurRadius: 10)]),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.storage),
                      Text("Products"),
                    ],
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                CommonResponses().shiftPage(context, const ShopListScreen());
              },
              child: AbsorbPointer(
                child: Container(
                  margin: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      color: whiteColor,
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(blurRadius: 10)]),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.store),
                      Text("Shops"),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
