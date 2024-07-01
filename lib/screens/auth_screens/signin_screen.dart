import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:osm/screens/admin_screens/admin_home_screen.dart';
import 'package:osm/services/common_responses.dart';
import 'package:osm/services/common_variables.dart';
import 'package:osm/services/provider_services.dart';

import 'package:osm/screens/home_screen.dart';
import 'package:osm/services/database_services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  final _auth = FirebaseAuth.instance;
  final _usersRef = FirebaseFirestore.instance.collection("USERS");
  AppDataProvider? _provider;
  final _emailTxtController = TextEditingController();
  final _passwordTxtController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    _provider = Provider.of<AppDataProvider>(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            boxShadow: const [BoxShadow(blurRadius: 10)],
            borderRadius: BorderRadius.circular(20),
            color: whiteColor,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
          child: Form(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              //crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Sign in",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 5,
                ),
                SizedBox(
                  height: 43,
                  child: TextFormField(
                    controller: _emailTxtController,
                    decoration: const InputDecoration(
                        label: Text("Email address"),
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                SizedBox(
                  height: 43,
                  child: TextFormField(
                    controller: _passwordTxtController,
                    obscureText: true,
                    decoration: const InputDecoration(
                        label: Text("Password"),
                        prefixIcon: Icon(Icons.password_outlined),
                        border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                GestureDetector(
                  onTap: () async {
                    var email = _emailTxtController.text.trim();
                    var password = _passwordTxtController.text.trim();
                    if (email.isNotEmpty && password.isNotEmpty) {
                      CommonResponses().showLoadingDialog(context);
                      var res = await DatabaseServices()
                          .signInUser({"email": email, "password": password});

                      if (res['msg'] == "done") {
                        await getLogedInUser();
                      } else {
                        Navigator.pop(context);
                        Fluttertoast.showToast(msg: res['msg']);
                      }
                    } else {
                      Fluttertoast.showToast(msg: "All details are requred!!");
                    }
                  },
                  child: AbsorbPointer(
                    child: Container(
                        padding:
                            const EdgeInsets.only(left: 10, top: 4, bottom: 4),
                        decoration: BoxDecoration(
                            color: appColor,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(color: blackColor, blurRadius: 4)
                            ]),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("Sign in  ",
                                style: TextStyle(
                                    color: whiteColor,
                                    fontWeight: FontWeight.bold)),
                            Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                    color: whiteColor,
                                    borderRadius: BorderRadius.circular(20)),
                                child: const Icon(Icons.login))
                          ],
                        )),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                GestureDetector(
                    onTap: () {
                      CommonResponses().shiftPageView(2);
                    },
                    child: AbsorbPointer(
                        child: Text(
                      "Forgot password?",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: appColor),
                    ))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  getLogedInUser() async {
    var userId = _auth.currentUser!.uid;
    print(userId);
    await _usersRef.doc(userId).get().then((value) {
      Navigator.pop(context);
      var user = value.data()!;
      _provider!.currentUser = user;
      CommonResponses().showToast("welcome");
      if (user['role'] == "admin") {
        CommonResponses().shiftPage(context, AdminHomeScreen(), kill: true);
      } else {
        CommonResponses().shiftPage(context, HomeScreen(), kill: true);
      }
    });

    // catchError((e) {
    //   print(e.toString());
    //   print(e.toString());
    //   //CommonResponses().showToast("Retrying..");
    //   getLogedInUser();
    // });
  }
}
