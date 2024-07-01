import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:osm/screens/home_screen.dart';
import 'package:osm/services/common_responses.dart';
import 'package:osm/services/common_variables.dart';
import 'package:osm/services/database_services.dart';
import 'package:osm/services/provider_services.dart';
import 'package:provider/provider.dart';

class AddDeliveryStaff extends StatefulWidget {
  const AddDeliveryStaff({super.key});

  @override
  State<AddDeliveryStaff> createState() => _AddDeliveryStaffState();
}

class _AddDeliveryStaffState extends State<AddDeliveryStaff> {
  AppDataProvider? _provider;
  final _auth = FirebaseAuth.instance;
  final _usersRef = FirebaseFirestore.instance.collection("USERS");
  String _countryCode = "+255";
  final _lNameTxtController = TextEditingController();
  final _fNameTxtController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailTxtController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    _provider = Provider.of<AppDataProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Add staff"),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
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
                  const SizedBox(
                    height: 5,
                  ),
                  GestureDetector(
                    onTap: () async {
                      var fName = _fNameTxtController.text;
                      var lName = _lNameTxtController.text;
                      var phone = _phoneController.text;
                      var email = _emailTxtController.text;

                      if (fName.isNotEmpty &&
                          lName.isNotEmpty &&
                          phone.isNotEmpty &&
                          email.isNotEmpty) {
                        CommonResponses().showLoadingDialog(context);
                        var res = await DatabaseServices().createDeliverySfaff({
                          "first_name": fName,
                          "last_name": lName,
                          "phone": _countryCode + phone,
                          "email": email,
                          "boss_id": _auth.currentUser!.uid,
                          "orderId": null,
                          "password": _countryCode + phone,
                        });
                        Navigator.pop(context);
                        if (res['msg'] == "done") {
                          _fNameTxtController.clear();
                          _lNameTxtController.clear();
                          _phoneController.clear();
                          _emailTxtController.clear();
                          Navigator.pop(context);
                          CommonResponses()
                              .showToast("Staff was added successfully");
                        } else {
                          Fluttertoast.showToast(
                            msg: res['msg'],
                          );
                        }
                      } else {
                        Fluttertoast.showToast(
                            msg: "All details are required!!");
                      }
                    },
                    child: AbsorbPointer(
                      child: Container(
                          padding: const EdgeInsets.only(
                              left: 10, top: 4, bottom: 4),
                          decoration: BoxDecoration(
                              color: appColor,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(color: blackColor, blurRadius: 4)
                              ]),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text("Create staff  ",
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
      ),
    );
  }
}
