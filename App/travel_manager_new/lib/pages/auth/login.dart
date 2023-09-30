import 'package:flutter/material.dart';
import 'package:travel_manager_new/uikit/uikit.dart';
import 'package:flutter_svg/svg.dart';
import './register/step1.dart';

class LoginPage extends StatefulWidget {
  const LoginPage();

  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // BG Image
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Positioned.fill(
              child: Image.asset("assets/images/png/loginbg.png",
                  fit: BoxFit.cover),
            ),
          ),

          // FG
          Column(
            children: [
              // Text Войти
              Container(
                margin: const EdgeInsets.only(
                  top: 70,
                ),
                alignment: Alignment.center,
                child: const Text(
                  "Войти",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 38,
                    letterSpacing: -0.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              // Inputs
              Container(
                margin: const EdgeInsets.only(
                  top: 43,
                ),
                alignment: Alignment.center,
                width: 319,
                height: 130,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Input(
                      controller: _email,
                      placeholder: "e-mail",
                      onChanged: (s) {},
                      icon: SvgPicture.asset(
                        "assets/images/svg/emailicon.svg",
                        width: 19,
                        height: 19,
                        fit: BoxFit.scaleDown,
                      ),
                    ),
                    Input(
                      controller: _password,
                      placeholder: "пароль",
                      onChanged: (s) {},
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
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minHeight: 100,
                  ),
                  child: Container(),
                ),
              ),

              // Buttons
              Container(
                margin: const EdgeInsets.only(
                  bottom: 60,
                ),
                alignment: Alignment.bottomCenter,
                child: Column(
                  children: [
                    BlackButton(
                      text: "Войти",
                      onPressed: () {},
                    ),
                    WhiteButton(
                      text: "Зарегестрироваться",
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterStep1(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
