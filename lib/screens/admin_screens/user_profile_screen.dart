import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:osm/services/common_variables.dart';

class UserProfileScreen extends StatefulWidget {
  var user;
  UserProfileScreen(this.user, {super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  var _user = {};
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _user = widget.user;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_user['first_name']),
        actions: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
                color: Color.fromARGB(15, 0, 0, 0),
                borderRadius: BorderRadius.circular(50)),
            child: _user['profile_photo'] == null
                ? Icon(Icons.person)
                : ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: CachedNetworkImage(
                      fit: BoxFit.cover,
                      imageUrl: _user['profile_photo'],
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
        ],
      ),
    );
  }
}
