import 'dart:io';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:osm/screens/home_screen.dart';
import 'package:osm/screens/shop_creation_screen.dart';
import 'package:osm/services/common_responses.dart';
import 'package:osm/services/common_variables.dart';
import 'package:osm/services/database_services.dart';

class ProductUploadScreen extends StatefulWidget {
  const ProductUploadScreen({super.key});

  @override
  State<ProductUploadScreen> createState() => _ProductUploadScreenState();
}

class _ProductUploadScreenState extends State<ProductUploadScreen> {
  final _titleTxtCntrl = TextEditingController();
  final _subCategoryTxtCntrl = TextEditingController();
  final _quantityCntrl = TextEditingController();
  final _warrantCntrl = TextEditingController();
  final _priceTxtCntrl = TextEditingController();
  final _oldPriceTxtCntrl = TextEditingController();
  final _descriptionTxtCntrl = TextEditingController();
  final _auth = FirebaseAuth.instance;
  File? _pickedLicenceFile;
  Map<String, dynamic> _shopData = {};
  final List<File> _images = [];
  String _selectedCategory = "Select";
  String _selectedStatus = "Select";
  bool _loadingShop = true;

  Future<void> _getMyShop() async {
    setState(() {
      _loadingShop = true;
    });
    var res = await DatabaseServices().getMyShop(_auth.currentUser!.uid);
    setState(() {
      _loadingShop = false;
    });
    print(res);
    if (res['msg'] == "done") {
      if (res['data'] != null) {
        setState(() {
          _shopData = res['data'];
        });
        if (_shopData['licence'] == null) {
          _showLicenceUploadDialog();
        } else if (_shopData['approval_status'] != "Approved") {
          _showApprovalWarning();
        }
      } else {
        CommonResponses().showToast("You dont a shop yet", isError: true);
      }
    } else {
      CommonResponses().showToast(res['msg'], isError: true);
    }
  }

  void _showApprovalWarning() {
    AwesomeDialog(
            context: context,
            dialogType: DialogType.info,
            desc:
                "Your business licence is under approval process, please wait for our staff to finish checking it.",
            descTextStyle: const TextStyle(fontWeight: FontWeight.bold),
            btnOkOnPress: () => Navigator.pop(context),
            btnOkColor: appColor)
        .show();
  }

  void _showLicenceUploadDialog() {
    showGeneralDialog(
        context: context,
        pageBuilder: (context, anim1, anim2) {
          return AlertDialog(
            title: const Text(
              "Licence is needed",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: StatefulBuilder(builder: (context, stateSetter) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    "To upoad product you need to have a business licence related to your shop..",
                    textAlign: TextAlign.center,
                  ),
                  GestureDetector(
                    onTap: () async {
                      final res = await ImagePicker().pickImage(
                          source: ImageSource.gallery, imageQuality: 20);
                      stateSetter(() {
                        _pickedLicenceFile = File(res!.path);
                      });
                    },
                    child: _pickedLicenceFile == null
                        ? Container(
                            height: 130,
                            width: 130,
                            decoration: BoxDecoration(
                              color: Colors.blueGrey,
                              boxShadow: [
                                BoxShadow(color: blackColor, blurRadius: 1)
                              ],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.photo_size_select_actual_rounded,
                              color: whiteColor,
                            ),
                          )
                        : Container(
                            height: 130,
                            width: 130,
                            decoration: BoxDecoration(
                                color: redColor,
                                boxShadow: [
                                  BoxShadow(color: blackColor, blurRadius: 10)
                                ],
                                borderRadius: BorderRadius.circular(10),
                                image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: FileImage(
                                      _pickedLicenceFile!,
                                    ))),
                          ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                      onPressed: _pickedLicenceFile == null
                          ? null
                          : () async {
                              CommonResponses().showLoadingDialog(context);
                              _shopData['licence'] = _pickedLicenceFile;
                              var res = await DatabaseServices()
                                  .updateLicence(_shopData);
                              Navigator.pop(context);
                              if (res['msg'] == 'done') {
                                Navigator.pop(context);
                                await _getMyShop();
                                CommonResponses().showToast(
                                    "Licence uploaded successfully, please wait for approval");
                              } else {
                                CommonResponses()
                                    .showToast(res['msg'], isError: true);
                              }
                            },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: appColor,
                          foregroundColor: whiteColor),
                      child: const Text("Upload"))
                ],
              );
            }),
          );
        });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getMyShop();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: Colors.blueGrey,
            width: screenSize.width,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: SafeArea(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    "Advertise product",
                    style: TextStyle(
                        color: blackColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                  Positioned(
                      left: 0,
                      child: IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.arrow_back)))
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(left: 3, bottom: 10),
            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
            decoration: BoxDecoration(
                border: Border.all(),
                color: whiteColor,
                boxShadow: [BoxShadow(color: blackColor, blurRadius: 4)]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Shop",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(
                  width: screenSize.width,
                  child: _loadingShop
                      ? SpinKitRipple(
                          color: appColor,
                          duration: Duration(milliseconds: 500),
                        )
                      : _shopData.isNotEmpty
                          ? ListTile(
                              dense: true,
                              visualDensity: const VisualDensity(
                                  horizontal: -1, vertical: -1),
                              contentPadding: const EdgeInsets.only(
                                  left: 1, top: 0, bottom: 0),
                              leading: Container(
                                margin: const EdgeInsets.only(right: 5),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 3),
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                    color: whiteColor,
                                    boxShadow: [
                                      BoxShadow(
                                          blurRadius: 4.4, color: blackColor)
                                    ],
                                    borderRadius: BorderRadius.circular(50),
                                    image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: NetworkImage(
                                        _shopData['logo'],
                                      ),
                                    )),
                              ),
                              title: Text(
                                _shopData['title'],
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              subtitle: Text(
                                _shopData['description'],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text("You dont have a shop yet"),
                                SizedBox(
                                  height: 34,
                                  child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        const ShopCreationScreen()))
                                            .then((value) async {
                                          print(value);
                                          if (value == 'done') {
                                            await _getMyShop();
                                          }
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          backgroundColor: appColor,
                                          foregroundColor: whiteColor),
                                      child: const Text("Create one")),
                                )
                              ],
                            ),
                )
              ],
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          const Center(
            child: Text(
              "PRODUCT DETAILS",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
              child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Images",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Stack(
                          alignment: Alignment.topCenter,
                          children: [
                            Container(
                              height: 150,
                              width: screenSize.width,
                              padding: const EdgeInsets.all(0),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all()),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Container(
                                          color: greyColor,
                                          height: 150,
                                          width: (16 / 9) * 100,
                                          child: _images.isNotEmpty
                                              ? Image.file(_images[0])
                                              : Container(),
                                        ),
                                        const Text(
                                          "Cover photo",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        )
                                      ],
                                    ),
                                    Row(
                                      children: _images.map((e) {
                                        return e == _images[0]
                                            ? Container()
                                            : Container(
                                                margin: const EdgeInsets.only(
                                                    right: 4),
                                                color: greenColor,
                                                width: (9 / 16) * 170,
                                                child: Image.file(e));
                                      }).toList(),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            IconButton.outlined(
                                style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateColor.resolveWith(
                                            (states) => whiteColor)),
                                onPressed: () async {
                                  if (_images.isEmpty) {
                                    var pickedFile = await ImagePicker.platform
                                        .pickImage(source: ImageSource.gallery);
                                    var cropedFile = await ImageCropper.platform
                                        .cropImage(
                                            sourcePath: pickedFile!.path,
                                            aspectRatio: const CropAspectRatio(
                                                ratioX: 16, ratioY: 9));
                                    _images.add(File(cropedFile!.path));
                                  } else {
                                    var pickedFiles = await ImagePicker.platform
                                        .pickMultiImage();
                                    for (var fl in pickedFiles!) {
                                      _images.add(File(fl.path));
                                    }
                                  }
                                  setState(() {});
                                },
                                icon: const Icon(Icons.add))
                          ],
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
                          "Title",
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
                                    "Write here eg Infinix kali kwa bei chee",
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
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          "Category",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Container(
                          height: 40,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all()),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton2(
                                onChanged: (val) {
                                  FocusScopeNode currentScope =
                                      FocusScope.of(context);
                                  if (!currentScope.hasPrimaryFocus) {
                                    currentScope.unfocus();
                                  }
                                  setState(() {
                                    _selectedCategory = val.toString();
                                  });
                                },
                                hint: Text(
                                  _selectedCategory,
                                  style: TextStyle(color: blackColor),
                                ),
                                items: productCategories
                                    .map((e) => DropdownMenuItem(
                                        value: e, child: Text(e.toString())))
                                    .toList()),
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
                          "Brand/Sub category",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 40,
                          child: TextFormField(
                            controller: _subCategoryTxtCntrl,
                            decoration: const InputDecoration(
                                enabledBorder: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 10),
                                hintText: "Write here eg Infinix hot 10i",
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
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          "Status",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Container(
                          height: 40,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all()),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton2(
                                onChanged: (val) {
                                  FocusScopeNode currentScope =
                                      FocusScope.of(context);
                                  if (!currentScope.hasPrimaryFocus) {
                                    currentScope.unfocus();
                                  }
                                  setState(() {
                                    _selectedStatus = val.toString();
                                  });
                                },
                                hint: Text(
                                  _selectedStatus,
                                  style: TextStyle(color: blackColor),
                                ),
                                items: productStatus
                                    .map((e) => DropdownMenuItem(
                                        value: e, child: Text(e.toString())))
                                    .toList()),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                "Quantity",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                height: 40,
                                width: MediaQuery.of(context).size.width * 0.6,
                                child: TextFormField(
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  controller: _quantityCntrl,
                                  decoration: const InputDecoration(
                                      enabledBorder: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 10),
                                      hintText: "Eg 5 pairs",
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
                          width: 10,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                "Warrant",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                height: 40,
                                width: MediaQuery.of(context).size.width * 0.6,
                                child: TextFormField(
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  controller: _warrantCntrl,
                                  decoration: const InputDecoration(
                                      enabledBorder: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 10),
                                      hintText: "In months eg 10 months",
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
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                "Price",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                height: 40,
                                width: MediaQuery.of(context).size.width * 0.6,
                                child: TextFormField(
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  controller: _priceTxtCntrl,
                                  decoration: const InputDecoration(
                                      enabledBorder: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 10),
                                      hintText: "Price in Tsh",
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
                          width: 10,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                "Old price(optional)",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                height: 40,
                                width: MediaQuery.of(context).size.width * 0.6,
                                child: TextFormField(
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  controller: _oldPriceTxtCntrl,
                                  decoration: const InputDecoration(
                                      enabledBorder: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 10),
                                      hintText: "Old price in Tsh",
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
                        )
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Description(optional)",
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
                              hintText: "Describe more",
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
                ],
              ),
            ),
          )),
          Container(
            margin: const EdgeInsets.all(10),
            child: ElevatedButton(
              onPressed: _shopData.isEmpty ||
                      _shopData['approval_status'] != "Approved"
                  ? null
                  : () async {
                      if (_images.isNotEmpty) {
                        String title = _titleTxtCntrl.text.trim();
                        String subcategory = _subCategoryTxtCntrl.text.trim();
                        String quantity = _quantityCntrl.text.trim();
                        String warrant = _warrantCntrl.text.trim();
                        String price = _priceTxtCntrl.text.trim();
                        String oldPrice = _oldPriceTxtCntrl.text.trim();
                        String description = _descriptionTxtCntrl.text.trim();
                        if (title.isNotEmpty &&
                            subcategory.isNotEmpty &&
                            quantity.isNotEmpty &&
                            warrant.isNotEmpty &&
                            price.isNotEmpty &&
                            oldPrice.isNotEmpty &&
                            description.isNotEmpty &&
                            _selectedCategory != "Select" &&
                            _selectedStatus != "Select") {
                          Map<String, dynamic> data = {
                            'title': title,
                            'category': _selectedCategory,
                            'subcategory': subcategory,
                            'status': _selectedStatus,
                            'approval_status': "Not approved",
                            'quantity': int.parse(quantity),
                            'warrant': int.parse(warrant),
                            'price': price,
                            'oldprice': oldPrice,
                            'description': description,
                            'shopId': _shopData['id'],
                            'ownerId': _auth.currentUser!.uid,
                            'images': _images,
                            'region': _shopData['region'],
                            'district': _shopData['district'],
                            'latitude': _shopData['latitude'],
                            'longitude': _shopData['longitude']
                          };
                          CommonResponses().showLoadingDialog(context);
                          var res =
                              await DatabaseServices().uploadProperty(data);
                          Navigator.pop(context);
                          if (res['msg'] == "done") {
                            CommonResponses()
                                .showToast("Product uploaded successfully..");
                            CommonResponses()
                                .shiftPage(context, HomeScreen(), kill: true);
                          } else {
                            CommonResponses()
                                .showToast(res['msg'], isError: true);
                          }
                        } else {
                          CommonResponses().showToast(
                              "All details are required!!",
                              isError: true);
                        }
                      } else {
                        CommonResponses().showToast(
                            "Please select photos for your product!!",
                            isError: true);
                      }
                    },
              style: ElevatedButton.styleFrom(
                  backgroundColor: appColor, foregroundColor: whiteColor),
              child: const Text("Upload"),
            ),
          )
        ],
      ),
    );
  }
}


// import 'package:excel/excel.dart';
// import 'package:flutter/services.dart' show ByteData, rootBundle;

// Future<List<List<dynamic>>> excelToList(String assetPath) async {
//   ByteData data = await rootBundle.load(assetPath);
//   List<List<dynamic>> excelList = [];

//   var bytes = data.buffer.asUint8List();
//   var excel = Excel.decodeBytes(bytes);

//   for (var table in excel.tables.keys) {
//     for (var row in excel.tables[table]!.rows) {
//       excelList.add(row);
//     }
//   }

//   return excelList;
// }



// class MyWidget extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<List<List<dynamic>>>(
//       future: excelToList('assets/data.xlsx'), // Replace 'assets/data.xlsx' with your Excel file path
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return CircularProgressIndicator();
//         } else if (snapshot.hasError) {
//           return Text('Error: ${snapshot.error}');
//         } else {
//           List<List<dynamic>> data = snapshot.data ?? [];
//           return ListView.builder(
//             itemCount: data.length,
//             itemBuilder: (context, index) {
//               return ListTile(
//                 title: Text(data[index].toString()),
//               );
//             },
//           );
//         }
//       },
//     );
//   }
// }
