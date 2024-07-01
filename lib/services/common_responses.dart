import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:osm/services/common_variables.dart';
import 'package:osm/screens/auth_screens/auth_screen.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:page_transition/page_transition.dart';

class CommonResponses {
  String formatTimeDifference(DateTime dateTime) {
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

  shiftPageView(int page) {
    controller.animateToPage(page,
        duration: const Duration(milliseconds: 500), curve: Curves.decelerate);
  }

  showToast(String msg, {bool? isError}) {
    Fluttertoast.showToast(
        msg: msg, backgroundColor: isError == true ? redColor : greenColor);
  }

  showLocationLoadingDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Exact location"),
            content: StatefulBuilder(builder: (context, setState) {
              return Column(mainAxisSize: MainAxisSize.min, children: [
                Text("Please wait, we are fetching your location.."),
                SizedBox(
                  height: 100,
                  child: SpinKitRipple(
                    borderWidth: 10,
                    color: appColor,
                    size: 100,
                    duration: const Duration(seconds: 1),
                  ),
                )
              ]);
            }),
          );
        });
  }

  Future<Position?> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    bool _goAhead = false;
    Position? pos;
    if (serviceEnabled) {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        _goAhead = true;
      } else {
        var permission = await Geolocator.requestPermission();
        print(permission.toString());
        if (permission == LocationPermission.whileInUse ||
            permission == LocationPermission.always) {
          _goAhead = true;
        } else {
          await getCurrentLocation();
        }
      }
    } else {
      showToast("Enable location services(turn on GPS) in your device",
          isError: true);
      getCurrentLocation();
    }
    if (_goAhead == true) {
      await Geolocator.getCurrentPosition().then((value) async {
        if (value != null) {
          pos = value;
        } else {
          CommonResponses()
              .showToast("Location not found, try again!!", isError: true);
        }
      }).catchError((e) {
        CommonResponses().showToast(e.toString(), isError: true);
      });
    } else {
      pos = null;
    }
    return pos!;
  }

  shiftPage(BuildContext context, Widget wid, {bool? kill}) {
    if (kill == true) {
      Navigator.pushAndRemoveUntil(context,
          PageTransition(child: wid, type: PageTransitionType.rightToLeft),
          (co) {
        return true;
      });
    } else {
      Navigator.push(context,
          PageTransition(child: wid, type: PageTransitionType.rightToLeft));
    }
  }

  showLoadingDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return const Center(
            child: SizedBox(
                width: 50,
                height: 50,
                child: CircleAvatar(
                  child: CircularProgressIndicator(),
                )),
          );
        });
  }
}
