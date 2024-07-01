import 'package:flutter/material.dart';
import 'package:osm/screens/auth_screens/password_reset_screen.dart';
import 'package:osm/screens/auth_screens/signin_screen.dart';
import 'package:osm/screens/auth_screens/signup_screen.dart';
import 'package:osm/services/common_responses.dart';
import 'package:osm/services/common_variables.dart';

PageController controller = PageController();

class Authscreen extends StatefulWidget {
  const Authscreen({super.key});

  @override
  State<Authscreen> createState() => _AuthscreenState();
}

class _AuthscreenState extends State<Authscreen> {
  bool _isSignin = true;

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: appColor,
      body: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            children: [
              Container(
                height: screenSize.height * 0.6,
                width: screenSize.width,
                decoration: BoxDecoration(
                    color: whiteColor,
                    image: const DecorationImage(
                        fit: BoxFit.cover,
                        image: AssetImage("assets/images/app-image.jpg")),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(1000),
                      bottomRight: Radius.circular(1000),
                    )),
              ),
            ],
          ),
          SafeArea(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isSignin = true;
                          });
                          CommonResponses().shiftPageView(0);
                        },
                        style: OutlinedButton.styleFrom(
                            backgroundColor: _isSignin == true
                                ? whiteColor
                                : Colors.transparent),
                        child: Text(
                          "Signin",
                          style: TextStyle(
                              color: _isSignin == true ? appColor : whiteColor),
                        )),
                    const SizedBox(
                      width: 40,
                    ),
                    OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _isSignin = false;
                          });
                          CommonResponses().shiftPageView(1);
                        },
                        style: OutlinedButton.styleFrom(
                            backgroundColor: _isSignin == false
                                ? whiteColor
                                : Colors.transparent),
                        child: Text(
                          "Signup",
                          style: TextStyle(
                              color:
                                  _isSignin == false ? appColor : whiteColor),
                        )),
                  ],
                ),
                Expanded(
                    child: PageView(
                  controller: controller,
                  children: const [
                    SigninScreen(),
                    SignupScreen(),
                    PasswordChangeScreen()
                  ],
                ))
              ],
            ),
          )
        ],
      ),
    );
  }
}
