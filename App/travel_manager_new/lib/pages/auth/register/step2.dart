import 'package:flutter/material.dart';
import 'package:travel_manager_new/uikit/uikit.dart';
import 'package:flutter_svg/svg.dart';

import '../../main/main_home.dart';

class RegisterStep2 extends StatefulWidget {
  const RegisterStep2();

  State<RegisterStep2> createState() => _RegisterStep2State();
}

class _RegisterStep2State extends State<RegisterStep2> {
  MapBridge prefsbridge = MapBridge(value: {});

  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // BG Image

          Positioned.fill(
            child: Image.asset(
              "assets/images/png/registerbg2.png",
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
                  "выбор предпочтений",
                  style: TextStyle(
                    color: myColors["secondaryText"],
                    fontSize: 20,
                    letterSpacing: -0.2,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              // Text Выберите, что вам по душе
              Container(
                margin: const EdgeInsets.only(top: 40),
                alignment: Alignment.center,
                child: const Text(
                  "Выберите, что вам по душе",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    letterSpacing: -1,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),

              // Preferences
              Container(
                margin: const EdgeInsets.only(top: 3),
                child: Preferences(
                  bridge: prefsbridge,
                ),
              ),

              // Text для чего нам это
              Container(
                margin: const EdgeInsets.only(top: 5),
                alignment: Alignment.center,
                child: const Text(
                  "мы используем эти данные, чтобы\nточнее подобрать для вас\nварианты отдыха",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color.fromRGBO(
                      224,
                      224,
                      224,
                      1,
                    ),
                    fontSize: 14,
                    letterSpacing: -1,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),

              // Margin
              Expanded(
                child: Container(),
              ),

              // Register button
              Container(
                margin: EdgeInsets.only(bottom: 60),
                child: BlackButton(
                  text: "Завершить",
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const MainHome(),
                      ),
                    );
                  },
                  color: myColors["blue1"],
                ),
              ),
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
                    builder: (context) => const MainHome(),
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
