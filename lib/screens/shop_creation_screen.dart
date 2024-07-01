import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:osm/services/common_responses.dart';
import 'package:osm/services/common_variables.dart';
import 'package:osm/services/database_services.dart';
import 'package:osm/services/modal_services.dart';

class ShopCreationScreen extends StatefulWidget {
  const ShopCreationScreen({super.key});

  @override
  State<ShopCreationScreen> createState() => _ShopCreationScreenState();
}

class _ShopCreationScreenState extends State<ShopCreationScreen> {
  Position? location;
  File? _pickedFile;
  File? _pickedLicenceFile;
  final _auth = FirebaseAuth.instance;
  final _titleTxtCntrl = TextEditingController();
  final _descriptionTxtCntrl = TextEditingController();

  final DatabaseReference _districtsRef =
      FirebaseDatabase.instance.reference().child("DISTRICTS");
  final DatabaseReference _regionsRef =
      FirebaseDatabase.instance.reference().child("REGIONS");
  // SharedPreferences? _filterPref;
  Region? _selectedRegion;
  District? _selectedDistrict;
  TextEditingController _streetController = TextEditingController();

  Geolocator _geolocator = Geolocator();

  bool _fetchingLocation = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.blueGrey,
            title: Text(
              "Create shop",
              style: TextStyle(fontWeight: FontWeight.bold),
            )),
        body: StatefulBuilder(builder: (context, stateSetter) {
          return Padding(
            padding: const EdgeInsets.all(5.0),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Column(
                              children: [
                                const Text(
                                  "Shop logo",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    final res = await ImagePicker().pickImage(
                                        source: ImageSource.gallery,
                                        imageQuality: 20);
                                    setState(() {
                                      _pickedFile = File(res!.path);
                                    });
                                  },
                                  child: _pickedFile == null
                                      ? CircleAvatar(
                                          radius: 70,
                                          child: Icon(
                                            Icons.shop,
                                            size: 50,
                                          ))
                                      : Container(
                                          height: 130,
                                          width: 130,
                                          decoration: BoxDecoration(
                                              color: redColor,
                                              boxShadow: [
                                                BoxShadow(
                                                    color: blackColor,
                                                    blurRadius: 10)
                                              ],
                                              borderRadius:
                                                  BorderRadius.circular(70),
                                              image: DecorationImage(
                                                  fit: BoxFit.cover,
                                                  image: FileImage(
                                                    _pickedFile!,
                                                  ))),
                                        ),
                                ),
                              ],
                            ),
                            Spacer(),
                            Column(
                              children: [
                                const Text(
                                  "Bussiness licence",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    final res = await ImagePicker().pickImage(
                                        source: ImageSource.gallery,
                                        imageQuality: 20);
                                    setState(() {
                                      _pickedLicenceFile = File(res!.path);
                                    });
                                  },
                                  child: _pickedLicenceFile == null
                                      ? CircleAvatar(
                                          radius: 70,
                                          child: Icon(
                                            Icons.edit,
                                            size: 50,
                                          ))
                                      : Container(
                                          height: 130,
                                          width: 130,
                                          decoration: BoxDecoration(
                                              color: redColor,
                                              boxShadow: [
                                                BoxShadow(
                                                    color: blackColor,
                                                    blurRadius: 10)
                                              ],
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              image: DecorationImage(
                                                  fit: BoxFit.cover,
                                                  image: FileImage(
                                                    _pickedLicenceFile!,
                                                  ))),
                                        ),
                                ),
                              ],
                            ),
                            SizedBox(
                              width: 10,
                            )
                          ],
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Shop name",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                height: 40,
                                child: TextFormField(
                                  controller: _titleTxtCntrl,
                                  decoration: const InputDecoration(
                                      enabledBorder: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 10),
                                      hintText:
                                          "Write here eg Mlimani city mal",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(-1),
                                          bottomLeft: Radius.circular(-1),
                                        ),
                                      )),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Description",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              TextFormField(
                                controller: _descriptionTxtCntrl,
                                minLines: 5,
                                maxLines: 6,
                                decoration: const InputDecoration(
                                    enabledBorder: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 10),
                                    hintText:
                                        "Describe more eg We're selling baby products like pampers etc",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(-1),
                                        bottomLeft: Radius.circular(-1),
                                      ),
                                    )),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        const Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Location",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Region ",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: greyColor)),
                              GestureDetector(
                                onTap: () {
                                  showRegionsOrDistrictsBottomsheet(
                                      "regions", stateSetter);
                                },
                                child: AbsorbPointer(
                                  child: Container(
                                    height: 40,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: Colors.grey)),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5),
                                    child: Row(
                                      children: [
                                        Text(_selectedRegion == null
                                            ? "Select region"
                                            : _selectedRegion!.name),
                                        const Spacer(),
                                        IconButton(
                                            onPressed: () {
                                              showRegionsOrDistrictsBottomsheet(
                                                  "regions", stateSetter);
                                            },
                                            icon: const Icon(
                                                Icons.arrow_drop_down))
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              const Text("District",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: greyColor)),
                              GestureDetector(
                                onTap: () {
                                  if (_selectedRegion != null) {
                                    showRegionsOrDistrictsBottomsheet(
                                        "districts", stateSetter);
                                  } else {
                                    Fluttertoast.showToast(
                                        msg: "Select region first!!");
                                  }
                                },
                                child: AbsorbPointer(
                                  child: Container(
                                    height: 40,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: Colors.grey)),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5),
                                    child: Row(
                                      children: [
                                        Text(_selectedDistrict == null
                                            ? "Select district"
                                            : _selectedDistrict!.name),
                                        const Spacer(),
                                        IconButton(
                                            onPressed: _selectedRegion == null
                                                ? null
                                                : () {
                                                    showRegionsOrDistrictsBottomsheet(
                                                        "districts",
                                                        stateSetter);
                                                  },
                                            icon: const Icon(
                                                Icons.arrow_drop_down))
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                "Ward/street",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: greyColor),
                              ),
                              SizedBox(
                                height: 40,
                                child: TextFormField(
                                  controller: _streetController,
                                  decoration: const InputDecoration(
                                      enabledBorder: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 10),
                                      hintText: "write here eg kimara suka",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(-1),
                                          bottomLeft: Radius.circular(-1),
                                        ),
                                      )),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 50,
                        )
                      ],
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(2),
                  child: ElevatedButton(
                    onPressed: () async {
                      //().showLoadingDialog(context);
                      if (_pickedFile != null) {
                        String title = _titleTxtCntrl.text.trim();
                        String desc = _descriptionTxtCntrl.text.trim();
                        String street = _streetController.text.trim();
                        if (title.isNotEmpty && desc.isNotEmpty) {
                          if (street.isNotEmpty &&
                              _selectedRegion != null &&
                              _selectedDistrict != null) {
                            if (_pickedLicenceFile != null) {
                              Map<String, dynamic> data = {
                                'title': title,
                                'description': desc,
                                'logo': _pickedFile,
                                'licence': _pickedLicenceFile,
                                'region': _selectedRegion!.name,
                                'approval_status': "Not approved",
                                'district': _selectedDistrict!.name,
                                'street': _streetController.text.trim()
                              };
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text("Exact location"),
                                      content: StatefulBuilder(
                                          builder: (context, setState) {
                                        return Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: _fetchingLocation
                                              ? [
                                                  const Text(
                                                      "Please wait, we are fetching your location.."),
                                                  SizedBox(
                                                    height: 100,
                                                    child: SpinKitRipple(
                                                      borderWidth: 10,
                                                      color: appColor,
                                                      size: 100,
                                                      duration:
                                                          Duration(seconds: 1),
                                                    ),
                                                  )
                                                ]
                                              : [
                                                  Text(
                                                      "We need exact location of your shop for easy reach by your customers, Please make you're at your shop and click proceed"),
                                                  ElevatedButton(
                                                      onPressed: () async {
                                                        setState(() {
                                                          _fetchingLocation =
                                                              true;
                                                        });
                                                        bool serviceEnabled =
                                                            await Geolocator
                                                                .isLocationServiceEnabled();
                                                        if (serviceEnabled) {
                                                          var permission =
                                                              await Geolocator
                                                                  .checkPermission();
                                                          print("PERMISSION " +
                                                              permission
                                                                  .toString());
                                                          if (permission ==
                                                                  LocationPermission
                                                                      .whileInUse ||
                                                              permission ==
                                                                  LocationPermission
                                                                      .always) {
                                                            _fetchLocation(
                                                                data);
                                                          } else {
                                                            var permission =
                                                                await Geolocator
                                                                    .requestPermission();
                                                            print(permission
                                                                .toString());
                                                            if (permission ==
                                                                    LocationPermission
                                                                        .whileInUse ||
                                                                permission ==
                                                                    LocationPermission
                                                                        .always) {
                                                              _fetchLocation(
                                                                  data);
                                                            } else {
                                                              setState(() {
                                                                _fetchingLocation =
                                                                    false;
                                                              });
                                                              CommonResponses()
                                                                  .showToast(
                                                                      "Access denied ",
                                                                      isError:
                                                                          true);
                                                            }
                                                          }
                                                        } else {
                                                          setState(() {
                                                            _fetchingLocation =
                                                                false;
                                                          });
                                                          CommonResponses()
                                                              .showToast(
                                                                  "Enable location services(turn on GPS) in your device");
                                                        }
                                                      },
                                                      child: Text("Proceed"))
                                                ],
                                        );
                                      }),
                                    );
                                  });
                            } else {
                              CommonResponses().showToast(
                                  "Valid business licence is needed!!",
                                  isError: true);
                            }
                          } else {
                            CommonResponses().showToast(
                                "Location details are required!!",
                                isError: true);
                          }
                        } else {
                          CommonResponses().showToast(
                              "Please fill all informations",
                              isError: true);
                        }
                      } else {
                        CommonResponses().showToast(
                            "Please select a logo for your shop",
                            isError: true);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: appColor, foregroundColor: whiteColor),
                    child: const Text("Create"),
                  ),
                )
              ],
            ),
          );
        }));
  }

  void showRegionsOrDistrictsBottomsheet(
      String choice, Function(void Function()) stateSetter) {
    Size screenSize = MediaQuery.of(context).size;
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        )),
        builder: (context) {
          return Container(
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            )),
            height: screenSize.height * 0.7,
            child: Column(
              children: [
                Container(
                  decoration: const BoxDecoration(
                      color: greyColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                      )),
                  height: 40,
                  child: Center(
                      child: Text(
                    choice == "districts"
                        ? "Wilaya za ${_selectedRegion!.name.toString()}"
                        : "Mikoa ya Tanzania",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  )),
                ),
                Expanded(
                  child: StreamBuilder(
                      stream: choice == "districts"
                          ? _districtsRef
                              .child("3")
                              .child(_selectedRegion!.id.toString())
                              .onValue
                          : _regionsRef.child("3").onValue,
                      builder: (context, AsyncSnapshot snap) {
                        if (snap.connectionState == ConnectionState.done ||
                            snap.connectionState == ConnectionState.active) {
                          if (snap.data != null) {
                            if (choice == "regions") {
                              regions.clear();
                            }
                            if (choice == "districts") {
                              districts.clear();
                            }
                            if (choice == "regions") {
                              for (int i = 0;
                                  i < snap.data!.snapshot.value.length;
                                  i++) {
                                var val = snap.data!.snapshot.value[i];
                                regions.add(Region(val["id"], val["name"],
                                    val["latitude"], val["longitude"]));
                              }
                            }
                            if (choice == "districts") {
                              snap.data!.snapshot.value.forEach((val) {
                                districts.add(District(val["id"], val["name"]));
                              });
                            }
                            return ListView.builder(
                                itemCount: choice == "districts"
                                    ? districts.length
                                    : regions.length,
                                itemBuilder: (context, index) {
                                  Region? thisRegion;
                                  District? thisDistrict;
                                  if (choice == "regions") {
                                    thisRegion = regions[index];
                                  }
                                  if (choice == "districts") {
                                    thisDistrict = districts[index];
                                  }
                                  return Container(
                                    margin: const EdgeInsets.only(top: 3),
                                    decoration: BoxDecoration(
                                        border: Border(
                                            left: BorderSide(
                                                color: appColor, width: 5),
                                            right: BorderSide(
                                                color: appColor, width: 5))),
                                    child: ListTile(
                                      onTap: () {
                                        if (choice == "regions") {
                                          stateSetter(() {
                                            _selectedDistrict = null;
                                            // provider.propertyFilters[
                                            //     "district"] = null;
                                            // provider.propertyFilters[
                                            //     "districtName"] = null;
                                            _selectedRegion = thisRegion;
                                          });
                                          Navigator.pop(context);
                                          showRegionsOrDistrictsBottomsheet(
                                              "districts", stateSetter);
                                        }
                                        if (choice == "districts") {
                                          stateSetter(() {
                                            _selectedDistrict = thisDistrict;
                                          });
                                          Navigator.pop(context);
                                        }
                                      },
                                      dense: true,
                                      visualDensity:
                                          const VisualDensity(vertical: -3),
                                      title: Text(choice == "districts"
                                          ? thisDistrict!.name
                                          : thisRegion!.name),
                                    ),
                                  );
                                });
                          } else {
                            if (snap.hasError) {
                              return Text(snap.error.toString());
                            } else {
                              return Center(child: Text("No data was found"));
                            }
                          }
                        } else {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      }),
                ),
              ],
            ),
          );
        });
  }

  _fetchLocation(var data) async {
    await Geolocator.getCurrentPosition().then((value) async {
      if (value != null) {
        data['latitude'] = value.latitude;
        data['longitude'] = value.longitude;
        data['ownerId'] = _auth.currentUser!.uid;
        print(data);
        // setState(() {
        //   _fetchingLocation = false;
        // });
        var res = await DatabaseServices().createShop(data);
        print(res);
        setState(() {
          _fetchingLocation = false;
        });
        Navigator.pop(context, 'done');
        if (res['msg'] == 'done') {
          Navigator.pop(context, 'done');
          CommonResponses().showToast(
            "Shop created successfully..",
          );
        } else {
          CommonResponses().showToast(res['msg']);
        }
      } else {
        setState(() {
          _fetchingLocation = false;
        });
        CommonResponses()
            .showToast("Location not found, try again!!", isError: true);
      }
    }).catchError((e) {
      setState(() {
        _fetchingLocation = false;
      });
      CommonResponses().showToast(e.toString(), isError: true);
    });
  }
}


//showLoadingDialog