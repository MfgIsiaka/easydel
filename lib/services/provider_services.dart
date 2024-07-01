import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:osm/services/common_responses.dart';
import 'package:osm/services/database_services.dart';

class AppDataProvider extends ChangeNotifier {
  final _auth = FirebaseAuth.instance;
  var _deliveryUser = {};

  Map<String, dynamic> _currentUser = {};
  Timer? _timer;

  AppDataProvider() {
    startRouting();
  }

  Future<void> startRouting() async {
    if (_auth.currentUser != null) {
      print("YESS USER");
      Future.delayed(const Duration(seconds: 0), () async {
        await getDeliveryUser().then((value) async {
          if (_deliveryUser.isNotEmpty) {
            await getAndUploadLocation();
          }
        });
      });
    }
  }

  Future<void> getDeliveryUser() async {
    print("llllllllllll");
    var user = await DatabaseServices().getSingleUser(_auth.currentUser!.uid);
    if (user['data'] != null || user['data'].isNotEmpty) {
      _deliveryUser = user['data'];
    }
    print(_deliveryUser);
  }

  Future<Position> getAndUploadLocation() async {
    //print("OUTSIDE ${_deliveryUser['first_name']}");
    var position = await CommonResponses().getCurrentLocation();
    if (position != null) {
      //print("INSIDE ${position.latitude}");
      _deliveryUser['location'] = {
        'latitude': position.latitude,
        'longitude': position.longitude
      };
      var res = await DatabaseServices().updateStaffLocation(_deliveryUser);
      await Future.delayed(const Duration(seconds: 4), () async {
        await getAndUploadLocation();
      });
    }
    return position!;
  }

  Map<String, dynamic> get currentUser => _currentUser;

  set currentUser(Map<String, dynamic> currentUser) {
    _currentUser = currentUser;
    notifyListeners();
  }
}
