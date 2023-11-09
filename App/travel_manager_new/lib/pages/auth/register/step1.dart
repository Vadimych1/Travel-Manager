import 'package:flutter/material.dart';
import 'package:travel_manager_new/pages/auth/register/step2.dart';
import 'package:travel_manager_new/uikit/uikit.dart';
import 'package:flutter_svg/svg.dart';
import "../login.dart";

class RegisterStep1 extends StatefulWidget {
  const RegisterStep1();

  State<RegisterStep1> createState() => _RegisterStep1State();
}

class _RegisterStep1State extends State<RegisterStep1> {
  TextEditingController _name = TextEditingController();
  TextEditingController _email = TextEditingController();
  TextEditingController _password = TextEditingController();

  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // BG Image
          Positioned.fill(
            child: Image.asset(
              "assets/images/png/registerbg1.png",
              fit: BoxFit.fill,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
            ),
          ),

          // FG
          Column(
            children: [
              // Text Регистрация
              Container(
                margin: const EdgeInsets.only(
                  top: 70,
                ),
                alignment: Alignment.center,
                child: const Text(
                  "Регистрация",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 38,
                    letterSpacing: -0.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              // Text основные данные
              Container(
                margin: const EdgeInsets.only(
                  top: 0,
                ),
                alignment: Alignment.center,
                child: Text(
                  "основные данные",
                  style: TextStyle(
                    color: myColors["secondaryText"],
                    fontSize: 20,
                    letterSpacing: -0.2,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              // Inputs
              Container(
                margin: const EdgeInsets.only(
                  top: 43,
                ),
                height: 210,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Input(
                      placeholder: "имя",
                      onChanged: (s) {},
                      controller: _name,
                      icon: SvgPicture.asset(
                        "assets/images/svg/usericon.svg",
                        width: 19,
                        height: 19,
                        fit: BoxFit.scaleDown,
                      ),
                    ),
                    Input(
                      placeholder: "e-mail",
                      onChanged: (s) {},
                      controller: _email,
                      icon: SvgPicture.asset(
                        "assets/images/svg/emailicon.svg",
                        width: 19,
                        height: 19,
                        fit: BoxFit.scaleDown,
                      ),
                    ),
                    Input(
                      placeholder: "пароль",
                      onChanged: (s) {},
                      controller: _password,
                      icon: SvgPicture.asset(
                        "assets/images/svg/passwordicon.svg",
                        width: 19,
                        height: 19,
                        fit: BoxFit.scaleDown,
                      ),
                    ),
                  ],
                ),
              ),

              // Margin
              Expanded(
                child: Container(),
              ),

              // Next step
              Container(
                margin: const EdgeInsets.only(
                  bottom: 60,
                ),
                child: BlackButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterStep2(),
                      ),
                    );
                  },
                  text: "Далее",
                  color: myColors["blue1"],
                ),
              )
            ],
          ),

          // Back button
          Container(
            margin: const EdgeInsets.only(
              top: 86,
              left: 10,
            ),
            child: TextButton(
              child: SvgPicture.asset(
                "assets/images/svg/arrow_back.svg",
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const LoginPage(),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
