import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:osm/services/common_responses.dart';
import 'package:osm/services/common_variables.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:osm/services/database_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:osm/services/provider_services.dart';
import 'package:osm/screens/home_screen.dart';
import 'package:provider/provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  AppDataProvider? _provider;
  final _auth = FirebaseAuth.instance;
  final _usersRef = FirebaseFirestore.instance.collection("USERS");
  String _countryCode = "+255";
  File? _pickedFile;
  final _lNameTxtController = TextEditingController();
  final _fNameTxtController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailTxtController = TextEditingController();
  final _passwordTxtController = TextEditingController();
  final _cPasswordTxtController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
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
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          child: Form(
              child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Sign up",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 5,
                ),
                GestureDetector(
                  onTap: () async {
                    final res = await ImagePicker.platform
                        .pickImage(source: ImageSource.gallery);
                    setState(() {
                      _pickedFile = File(res!.path);
                    });
                  },
                  child: _pickedFile == null
                      ? CircleAvatar(
                          radius: 70,
                          child: Icon(
                            Icons.person,
                            size: 50,
                          ))
                      : Container(
                          height: 130,
                          width: 130,
                          decoration: BoxDecoration(
                              color: redColor,
                              boxShadow: [
                                BoxShadow(color: blackColor, blurRadius: 10)
                              ],
                              borderRadius: BorderRadius.circular(70),
                              image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: FileImage(
                                    _pickedFile!,
                                  ))),
                        ),
                ),
                SizedBox(
                  height: 10,
                ),
                SizedBox(
                  height: 43,
                  child: TextFormField(
                    controller: _fNameTxtController,
                    decoration: const InputDecoration(
                        label: Text("FirstName"),
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                SizedBox(
                  height: 43,
                  child: TextFormField(
                    controller: _lNameTxtController,
                    decoration: const InputDecoration(
                        label: Text("Last name"),
                        prefixIcon: Icon(Icons.person_add),
                        border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                SizedBox(
                  height: 45,
                  child: TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        prefixIcon: FittedBox(
                          fit: BoxFit.contain,
                          child: CountryCodePicker(
                            initialSelection: "tanzania",
                            onChanged: (CountryCode code) {
                              _countryCode = code.toString();
                            },
                          ),
                        ),
                        // contentPadding:const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                        labelText: "Phone number",
                        border: OutlineInputBorder()),
                  ),
                ),
                SizedBox(
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
                SizedBox(
                  height: 43,
                  child: TextFormField(
                    controller: _cPasswordTxtController,
                    obscureText: true,
                    decoration: const InputDecoration(
                        label: Text("Confirm password"),
                        prefixIcon: Icon(Icons.password_outlined),
                        border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                GestureDetector(
                  onTap: () async {
                    var fName = _fNameTxtController.text;
                    var lName = _lNameTxtController.text;
                    var phone = _phoneController.text;
                    var email = _emailTxtController.text;
                    var pass = _passwordTxtController.text;
                    var cPass = _cPasswordTxtController.text;

                    if (fName.isNotEmpty &&
                        lName.isNotEmpty &&
                        phone.isNotEmpty &&
                        email.isNotEmpty &&
                        pass.isNotEmpty &&
                        cPass.isNotEmpty) {
                      if (pass.length >= 6) {
                        if (_pickedFile != null) {
                          if (pass == cPass) {
                            CommonResponses().showLoadingDialog(context);
                            var res = await DatabaseServices().signUpUser({
                              "first_name": fName,
                              "last_name": lName,
                              "phone": _countryCode + phone,
                              "email": email,
                              "password": pass,
                              "profile_photo": _pickedFile
                            });
                            Navigator.pop(context);
                            if (res['msg'] == "done") {
                              await getLogedInUser();
                            } else {
                              Fluttertoast.showToast(msg: res['msg']);
                            }
                          } else {
                            Fluttertoast.showToast(
                                msg: "Two passwords must be similar");
                          }
                        } else {
                          Fluttertoast.showToast(msg: "Your image is needed!!");
                        }
                      } else {
                        Fluttertoast.showToast(
                            msg: "Password should be six or more characters!!");
                      }
                    } else {
                      Fluttertoast.showToast(msg: "All details are required!!");
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
                            Text("Sign up  ",
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
              ],
            ),
          )),
        ),
      ),
    );
  }

  getLogedInUser() async {
    var userId = _auth.currentUser!.uid;
    await _usersRef.doc(userId).get().then((value) {
      _provider!.currentUser = value.data()!;
      CommonResponses().showToast("welcome");
      CommonResponses().shiftPage(context, HomeScreen(), kill: true);
    }).catchError((e) {
      CommonResponses().showToast("Retrying..");
      getLogedInUser();
    });
  }
}
