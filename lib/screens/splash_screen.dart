import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:osm/screens/admin_screens/admin_home_screen.dart';
import 'package:osm/screens/home_screen.dart';
import 'package:osm/services/common_responses.dart';
import 'package:osm/services/common_variables.dart';
import 'package:osm/services/database_services.dart';
import 'package:osm/services/provider_services.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  AppDataProvider? _provider;
  final _auth = FirebaseAuth.instance;
  final _pgController = PageController();
  late Timer _timer;
  int page = 0;
  final List _images = [
    {"img": "img1.png", "name": "Trauser"},
    {"img": "img2.png", "name": "Motorbycicle"},
    {"img": "img3.png", "name": "Clothes"},
    {"img": "img4.png", "name": "Shoes"},
  ];

  getCurrentUser() async {
    var res = await DatabaseServices().getSingleUser(_auth.currentUser!.uid);
    _timer.cancel();
    if (res['msg'] == "done") {
      var user = res['data'];
      _provider!.currentUser = user;
      if (user['role'] == "admin") {
        CommonResponses().shiftPage(context, AdminHomeScreen());
      } else {
        CommonResponses().shiftPage(context, const HomeScreen());
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    int cnt = -1;
    Future.delayed(const Duration(seconds: 4), () {
      if (_auth.currentUser != null) {
        getCurrentUser();
      } else {
        CommonResponses().shiftPage(context, const HomeScreen());
      }
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (page < _images.length) {
        page++;
        _pgController.animateToPage(page,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut);
      } else {
        if (page == _images.length) {
          page = -1;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    _provider = Provider.of<AppDataProvider>(context);
    return Scaffold(
      body: Column(
        children: [
          Expanded(
              child: Stack(
            children: [
              Container(
                width: screenSize.width,
                decoration: BoxDecoration(
                    color: appColor,
                    borderRadius: const BorderRadius.only(
                        bottomRight: Radius.circular(1000))),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                            color: const Color.fromARGB(106, 0, 0, 0),
                            image: const DecorationImage(
                                fit: BoxFit.cover,
                                image:
                                    AssetImage("assets/images/app-icon.png")),
                            borderRadius: BorderRadius.circular(100)),
                      ),
                      Text(
                        "EasyDel",
                        style: TextStyle(
                            fontSize: 30,
                            color: whiteColor,
                            fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 30,
                child: SpinKitRipple(
                  duration: const Duration(milliseconds: 1000),
                  color: blackColor,
                ),
              )
            ],
          )),
          Container(
              height: screenSize.height * 0.3,
              color: whiteColor,
              child: PageView.builder(
                  itemCount: _images.length,
                  controller: _pgController,
                  itemBuilder: (context, ind) {
                    var data = _images[ind];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Image.asset(
                          "assets/images/${data['img']}",
                          width: 200,
                        ),
                        Text(
                          data['name'],
                          style: TextStyle(
                              fontFamily: 'App-font',
                              fontSize: 30,
                              color: appColor),
                        )
                      ],
                    );
                  }))
        ],
      ),
    );
  }
}
