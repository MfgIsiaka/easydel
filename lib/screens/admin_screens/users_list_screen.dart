import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:osm/screens/admin_screens/user_profile_screen.dart';
import 'package:osm/services/common_responses.dart';
import 'package:osm/services/common_variables.dart';
import 'package:osm/services/database_services.dart';

class UsersListscreen extends StatefulWidget {
  const UsersListscreen({super.key});

  @override
  State<UsersListscreen> createState() => _UsersListscreenState();
}

class _UsersListscreenState extends State<UsersListscreen> {
  bool _isLoading = true;
  List _usersList = [];

  Future<void> getAllUsers() async {
    var res = await DatabaseServices().getAllUsers();
    setState(() {
      _isLoading = false;
    });
    if (res['msg'] == "done") {
      setState(() {
        _usersList = res['data'].where((el) => el['role'] != "admin").toList();
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAllUsers();
  }

  @override
  Widget build(BuildContext context) {
    print(_usersList);
    return Scaffold(
      appBar: AppBar(
        title: const Text("App users"),
      ),
      body: Center(
        child: _isLoading
            ? SpinKitCircle(
                color: appColor,
              )
            : _usersList.isEmpty
                ? Text("No data was found")
                : ListView.builder(
                    itemCount: _usersList.length,
                    itemBuilder: (context, ind) {
                      var user = _usersList[ind];
                      print(user['profile_photo']);
                      return ExpansionTile(
                        title: Text(
                          "${user['first_name']} ${user['last_name']}",
                        ),
                        subtitle: Text(user['email']),
                        trailing: IconButton(
                            onPressed: () {
                              CommonResponses()
                                  .shiftPage(context, UserProfileScreen(user));
                            },
                            icon: Icon(
                              Icons.arrow_right,
                              size: 40,
                            )),
                        leading: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                              color: Color.fromARGB(15, 0, 0, 0),
                              borderRadius: BorderRadius.circular(50)),
                          child: user['profile_photo'] == null
                              ? Icon(Icons.person)
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: CachedNetworkImage(
                                    fit: BoxFit.cover,
                                    imageUrl: user['profile_photo'],
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
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text("Phone: "),
                              Text(user['phone']),
                            ],
                          )
                        ],
                      );
                    }),
      ),
    );
  }
}
