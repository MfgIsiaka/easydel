import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:osm/services/common_responses.dart';
import 'package:osm/services/common_variables.dart';

class PasswordChangeScreen extends StatefulWidget {
  const PasswordChangeScreen({super.key});

  @override
  State<PasswordChangeScreen> createState() => _PasswordChangeScreenState();
}

class _PasswordChangeScreenState extends State<PasswordChangeScreen> {
  final _emailTxtController = TextEditingController();

  @override
  Widget build(BuildContext context) {
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Reset password",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 5,
                ),
                const Text("Password reset link will be sent to your email.."),
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
                GestureDetector(
                  onTap: () {
                    String email = _emailTxtController.text.trim();
                    String password = _emailTxtController.text.trim();
                    if (email.isNotEmpty) {
                      CommonResponses().showLoadingDialog(context);
                      Future.delayed(const Duration(seconds: 4), () {
                        Navigator.pop(context);
                        //AppResponseService().showSnackBar("Open your gmail account to procees..","info");
                      });
                    } else {
                      Fluttertoast.showToast(msg: "All fields are required!!");
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
