import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:osm/firebase_options.dart';

class DatabaseServices {
  final _auth = FirebaseAuth.instance;
  final _usersRef = FirebaseFirestore.instance.collection("USERS");
  final _cartsRef = FirebaseFirestore.instance.collection("CART PRODUCTS");
  final _ordersRef = FirebaseFirestore.instance.collection("ORDERS");
  final _propertyDataRef =
      FirebaseFirestore.instance.collection("PROPERTY DATA");
  final _shopDataRef = FirebaseFirestore.instance.collection("SHOP DATA");
  final _userProfiles = FirebaseStorage.instance.ref("PROFILES");
  final _propertyFiles = FirebaseStorage.instance.ref("PROPERTY FILES");

  Future<Map<String, dynamic>> signUpUser(Map<String, dynamic> userData) async {
    Map<String, dynamic> result = {};
    await _auth
        .createUserWithEmailAndPassword(
            email: userData['email'], password: userData['password'])
        .then((value) async {
      var userId = value.user!.uid;
      userData['id'] = userId;
      await _userProfiles
          .child(userId)
          .putFile(userData['profile_photo'])
          .then((p0) async {
        await p0.ref.getDownloadURL().then((value) async {
          userData['profile_photo'] = value;
          userData.remove('password');
          await _usersRef.doc(userId).set(userData).then((value) {
            result = {'msg': "done", "data": userData};
          }).catchError((e) {
            result = {'msg': e.code};
          });
        }).catchError((e) {
          result = {'msg': e.code};
        });
      }).catchError((e) {
        result = {'msg': e.code};
      });
    }).catchError((e) {
      result = {'msg': e.code};
    });
    return result;
  }

  Future<Map<String, dynamic>> createDeliverySfaff(
      Map<String, dynamic> userData) async {
    Map<String, dynamic> result = {};
    await Firebase.initializeApp(
      name: 'SecondApp',
      options: DefaultFirebaseOptions.currentPlatform,
    ).then((_secondApp) async {
      await FirebaseAuth.instanceFor(app: _secondApp)
          .createUserWithEmailAndPassword(
        email: userData['email'],
        password: userData['password'],
      )
          .then((cred) async {
        userData['id'] = cred.user!.uid;
        userData.remove('password');
        await _usersRef.doc(userData['id']).set(userData).then((value) {
          result = {'msg': "done", "data": userData};
        }).catchError((e) {
          result = {'msg': e.code};
        });
      }).catchError((e) {
        result = {'msg': e.code};
      });
      await _secondApp.delete();
    }).catchError((e) {
      result = {'msg': e.code};
    });

    return result;
  }

  Future<Map<String, dynamic>> signInUser(Map<String, dynamic> userData) async {
    Map<String, dynamic> result = {};
    print("Im in");
    await _auth
        .signInWithEmailAndPassword(
            email: userData['email'], password: userData['password'])
        .then((value) async {
      await _usersRef.doc(value.user!.uid).get().then((value) {
        result = {'msg': "done", "data": value.data()};
      }).catchError((e) {
        result = {'msg': e.code};
      });
    }).catchError((e) {
      result = {'msg': e.code};
    });
    return result;
  }

  Future<Map<String, dynamic>> uploadUserCarts(
      Map<String, dynamic> cartDetails) async {
    Map<String, dynamic> result = {};
    int time = DateTime.now().millisecondsSinceEpoch;
    String id = _cartsRef.doc().id;
    cartDetails['id'] = id;
    cartDetails['uploadedAt'] = time;
    await _cartsRef.doc(id).set(cartDetails).then((value) {
      result = {'msg': 'done', 'data': ''};
    }).catchError((e) {
      result = {'msg': e.code};
    });
    return result;
  }

  Future<Map<String, dynamic>> deleteUserCart(String cartId) async {
    Map<String, dynamic> result = {};
    await _cartsRef.doc(cartId).delete().then((value) {
      result = {'msg': 'done', 'data': ''};
    }).catchError((e) {
      result = {'msg': e.code};
    });
    return result;
  }

  Future<Map<String, dynamic>> getUserCartDetails(String userId) async {
    Map<String, dynamic> result = {};
    await _cartsRef
        .where('customerId', isEqualTo: userId)
        .get()
        .then((value) async {
      List<Map<String, dynamic>> docs = [];

      if (value.docs.isNotEmpty) {
        for (var doc in value.docs) {
          await _propertyDataRef.doc(doc['productId']).get().then((docSnap) {
            print("Iniside");
            if (docSnap.exists) {
              docs.add(docSnap.data()!);
              print("Yes data " + docs.toString());
            } else {
              print("No data");
              result = {'msg': "done", "data": []};
            }
          }).catchError((e) {
            result = {'msg': e.code};
          });
          print("Outside");
        }
        result = {'msg': "done", "data": docs};
      } else {
        result = {'msg': "done", "data": []};
      }
    }).catchError((e) {
      result = {'msg': e.code};
    });
    return result;
  }

  Future<Map<String, dynamic>> getUserCarts(String uid) async {
    Map<String, dynamic> result = {};
    await _cartsRef.where('customerId', isEqualTo: uid).get().then((value) {
      List<Map<String, dynamic>> docs = [];
      if (value.docs.isNotEmpty) {
        value.docs.forEach((doc) {
          docs.add(doc.data());
        });
        result = {'msg': "done", "data": docs};
      } else {
        result = {'msg': "done", "data": []};
      }
    }).catchError((e) {
      result = {'msg': e.code};
    });
    return result;
  }

  Future<Map<String, dynamic>> uploadProperty(
      Map<String, dynamic> propertyData) async {
    Map<String, dynamic> result = {};
    String propertyId = _propertyDataRef.doc().id;
    propertyData['id'] = propertyId;
    List<String> imageUrls = [];
    for (var i = 0; i < propertyData['images'].length; i++) {
      String imgId = _propertyDataRef.doc().id;
      await _propertyFiles
          .child(propertyId)
          .child("IMAGES")
          .child(imgId)
          .putFile(propertyData['images'][i])
          .then((p0) async {
        String url = await p0.ref.getDownloadURL();
        imageUrls.add(url);
      });
    }
    propertyData['images'] = imageUrls;

    int time = DateTime.now().millisecondsSinceEpoch;
    propertyData['uploadedAt'] = time;
    //print(propertyData);
    await _propertyDataRef.doc(propertyId).set(propertyData).then((value) {
      result = {'msg': "done", "data": ""};
    }).catchError((e) {
      result = {'msg': e.toString(), "data": ""};
    });
    return result;
  }

  Future<Map<String, dynamic>> retriveProperty() async {
    Map<String, dynamic> result = {};
    List<Map<String, dynamic>> docs = [];
    await _propertyDataRef.get().then((value) {
      if (value.docs.isNotEmpty) {
        value.docs.forEach((doc) {
          docs.add(doc.data());
        });
        result = {'msg': "done", "data": docs};
      } else {
        result = {'msg': "done", "data": []};
      }
    }).catchError((e) {
      result = {'msg': e.code, "data": []};
    });
    return result;
  }

  Future<Map<String, dynamic>> getSingleUser(String uid) async {
    Map<String, dynamic> result = {};
    await _usersRef.doc(uid).get().then((value) {
      if (value.exists) {
        result = result = {'msg': "done", "data": value.data()};
      } else {
        result = result = {'msg': "done", "data": null};
      }
    }).catchError((e) {
      result = {'msg': e.code, "data": null};
    });
    return result;
  }

  Future<Map<String, dynamic>> createShop(Map<String, dynamic> shopData) async {
    Map<String, dynamic> result = {};
    String shopId = _shopDataRef.doc().id;
    shopData['id'] = shopId;
    await _propertyFiles
        .child("SHOP LOGOS")
        .child(shopData['ownerId'])
        .child(shopId)
        .putFile(shopData['logo'])
        .then((p0) async {
      print("File uploaded..");
      await p0.ref.getDownloadURL().then((url) async {
        shopData['logo'] = url;
        await _propertyFiles
            .child("LICENCES")
            .child(shopData['ownerId'])
            .child(shopId)
            .putFile(shopData['licence'])
            .then((p1) async {
          await p1.ref.getDownloadURL().then((licenceUrl) async {
            shopData['licence'] = licenceUrl;
            await _shopDataRef.doc(shopId).set(shopData).then((value) async {
              await _usersRef
                  .doc(shopData['ownerId'])
                  .update({"shopOwner": true}).then((value) {
                result = {'msg': "done", "data": null};
              }).catchError((e) {
                result = {'msg': e.code, "data": null};
              });
            }).catchError((e) {
              result = {'msg': e.code, "data": null};
            });
          }).catchError((e) {
            result = {'msg': e.code, "data": null};
          });
        }).catchError((e) {
          result = {'msg': e.code, "data": null};
        });
      }).catchError((e) {
        result = {'msg': e.code, "data": null};
      });
    }).catchError((e) {
      result = {'msg': e.code, "data": null};
    });
    return result;
  }

  Future<Map<String, dynamic>> getMyShop(String userId) async {
    Map<String, dynamic> result = {};
    await _shopDataRef.where('ownerId', isEqualTo: userId).get().then((value) {
      if (value.docs.isNotEmpty) {
        result = {'msg': "done", "data": value.docs[0].data()};
      } else {
        result = {'msg': "done", "data": {}};
      }
    }).catchError((e) {
      result = {'msg': e.code, "data": {}};
    });
    return result;
  }

  Future<Map<String, dynamic>> getAllShops() async {
    Map<String, dynamic> result = {};
    await _shopDataRef.get().then((value) {
      if (value.docs.isNotEmpty) {
        List data = [];
        value.docs.forEach((element) {
          data.add(element.data());
        });
        result = {'msg': "done", "data": data};
      } else {
        result = {'msg': "done", "data": []};
      }
    }).catchError((e) {
      result = {'msg': e.code, "data": null};
    });
    return result;
  }

  Future<Map<String, dynamic>> getAllProducts() async {
    Map<String, dynamic> result = {};
    await _propertyDataRef.orderBy("uploadedAt").get().then((value) {
      if (value.docs.isNotEmpty) {
        List data = [];
        value.docs.forEach((element) {
          data.add(element.data());
        });
        result = {'msg': "done", "data": data};
      } else {
        result = {'msg': "done", "data": value};
      }
    }).catchError((e) {
      result = {'msg': e.code, "data": null};
    });
    print(result);
    return result;
  }

  Future<Map<String, dynamic>> getAllUsers() async {
    Map<String, dynamic> result = {};
    await _usersRef.orderBy("first_name").get().then((value) {
      if (value.docs.isNotEmpty) {
        List data = [];
        value.docs.forEach((element) {
          data.add(element.data());
        });
        data.sort((a, b) => a['first_name'].compareTo(b['last_name']));
        result = {'msg': "done", "data": data};
      } else {
        result = {'msg': "done", "data": []};
      }
    }).catchError((e) {
      result = {'msg': e.code, "data": {}};
    });
    return result;
  }

  Future<Map<String, dynamic>> getDeliveryUsers(String uId) async {
    Map<String, dynamic> result = {};
    await _usersRef.where('boss_id', isEqualTo: uId).get().then((value) {
      if (value.docs.isNotEmpty) {
        List data = [];
        value.docs.forEach((element) {
          data.add(element.data());
        });
        result = {'msg': "done", "data": data};
      } else {
        result = {'msg': "done", "data": []};
      }
    }).catchError((e) {
      result = {'msg': e.code, "data": []};
    });
    return result;
  }

  Future<Map<String, dynamic>> getSingleShop(String shopId) async {
    Map<String, dynamic> result = {};
    await _shopDataRef.doc(shopId).get().then((val) {
      if (val.exists) {
        result = {'msg': "done", "data": val.data()};
      } else {
        result = {'msg': "done", "data": {}};
      }
    }).catchError((e) {
      result = {'msg': e.code, "data": {}};
    });
    return result;
  }

  Future<Map<String, dynamic>> uploadOrder(var orderData) async {
    Map<String, dynamic> result = {};
    String id = _ordersRef.doc().id;
    orderData['id'] = id;
    await _ordersRef.doc(orderData['id']).set(orderData).then((value) {
      result = {'msg': "done", "data": {}};
    }).catchError((e) {
      result = {'msg': e.code, "data": {}};
    });
    return result;
  }

  Future<Map<String, dynamic>> retriveOrders() async {
    Map<String, dynamic> result = {};
    await _ordersRef.get().then((value) async {
      List orders = [];
      if (value.docs.isNotEmpty) {
        for (var el in value.docs) {
          var order = el.data();
          await _propertyDataRef.doc(order['productId']).get().then((prod) {
            if (prod.exists) {
              order['product'] = prod.data();
              orders.add(order);
            }
          });
        }
        result = {'msg': "done", "data": orders};
      } else {
        result = {'msg': "done", "data": []};
      }
    }).catchError((e) {
      result = {'msg': e.code, "data": {}};
    });
    return result;
  }

  Future<Map<String, dynamic>> updateLicence(Map<String, dynamic> shop) async {
    Map<String, dynamic> result = {};
    String shopId = shop['id'];
    await _propertyFiles
        .child("LICENCES")
        .child(shop['ownerId'])
        .child(shopId)
        .putFile(shop['licence'])
        .then((p1) async {
      await p1.ref.getDownloadURL().then((licenceUrl) async {
        await _shopDataRef
            .doc(shopId)
            .update({'licence': licenceUrl}).then((value) async {
          result = {'msg': "done", "data": null};
        }).catchError((e) {
          result = {'msg': e.code, "data": null};
        });
      }).catchError((e) {
        result = {'msg': e.code, "data": null};
      });
    }).catchError((e) {
      result = {'msg': e.code, "data": null};
    });
    return result;
  }

  Future<Map<String, dynamic>> updateLicenceStatus(
      Map<dynamic, dynamic> shop) async {
    Map<String, dynamic> result = {};
    Map<Object, Object?> newPair = {};
    if (shop['approval_status'] == "Approved") {
      newPair['approval_status'] = "Not approved";
    } else {
      newPair['approval_status'] = "Approved";
    }
    await _shopDataRef.doc(shop['id']).update(newPair).then((value) {
      result = {'msg': "done", 'data': null};
    }).catchError((e) {
      result = {'msg': e.toString(), 'data': null};
    });
    return result;
  }

  Future<Map<String, dynamic>> updateProductLiveStatus(
      Map<dynamic, dynamic> product) async {
    Map<String, dynamic> result = {};
    Map<Object, Object?> newPair = {};
    if (product['approval_status'] == "Approved") {
      newPair['approval_status'] = "Not approved";
    } else {
      newPair['approval_status'] = "Approved";
    }
    await _propertyDataRef.doc(product['id']).update(newPair).then((value) {
      result = {'msg': "done", 'data': null};
    }).catchError((e) {
      result = {'msg': e.toString(), 'data': null};
    });
    return result;
  }

  Future<Map<String, dynamic>> assignOrderToStaff(
      Map<dynamic, dynamic> order, Map<dynamic, dynamic> staff) async {
    Map<String, dynamic> result = {};
    await _ordersRef.doc(order['id']).update({
      'staffId': staff['id'],
      'deliveryStatus': 'Staff ready to move'
    }).then((value) async {
      await _usersRef
          .doc(staff['id'])
          .update({'orderId': order['id']}).then((value) {
        result = {'msg': 'done', 'data': null};
      }).catchError((e) {
        print("UPPPPPPP");
        result = {'msg': e.toString(), 'data': null};
      });
    }).catchError((e) {
      print("DOWNNN ${order['id']}");
      result = {'msg': e.toString(), 'data': null};
    });
    return result;
  }

  Future<Map<String, dynamic>> updateStaffLocation(
      Map<dynamic, dynamic> staff) async {
    Map<String, dynamic> result = {};
    await _usersRef
        .doc(staff['id'])
        .update({'location': staff['location']}).then((value) {
      result = {'msg': 'done', 'data': null};
    }).catchError((e) {
      result = {'msg': e.toString(), 'data': null};
    });
    return result;
  }

  Future<Map<String, dynamic>> updateStaffDeliveryStatus(
      Map<dynamic, dynamic> data) async {
    Map<String, dynamic> result = {};
    await _ordersRef
        .doc(data['orderId'])
        .update({"deliveryStatus": data['deliveryStatus']}).then((value) async {
      if (data['deliveryStatus'] == "Staff arrived") {
        await _ordersRef.doc(data['orderId']).update({
          'deliveryStatus': 'Staff arrived',
        }).then((value) async {
          await _usersRef
              .doc(data['staffId'])
              .update({'orderId': null}).then((value) {
            result = {'msg': 'done', 'data': {}};
          }).catchError((e) {
            result = {'msg': e.toString(), 'data': {}};
          });
        }).catchError((e) {
          result = {'msg': e.toString(), 'data': {}};
        });
      } else {
        result = {'msg': "done", 'data': {}};
      }
    }).catchError((e) {
      result = {'msg': e.toString(), 'data': {}};
    });
    return result;
  }
}
