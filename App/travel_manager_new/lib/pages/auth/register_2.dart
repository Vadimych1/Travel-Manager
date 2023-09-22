import 'package:flutter/material.dart';
import '../../uikit/uikit.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter_secure_storage/flutter_secure_storage.dart'
    // as secure_storage;
import 'package:flutter_svg/flutter_svg.dart';

class RegisterPage2 extends StatefulWidget {
  const RegisterPage2({super.key});

  @override
  State<RegisterPage2> createState() => RegisterPage2State();
}

class RegisterPage2State extends State<RegisterPage2> {
  MapBridge bridge = MapBridge(
    value: {
      "dostoprims": false,
      "sobytiya": false,
      "razvlecheniya": false,
      "architectura": false,
      "igry": false,
      "teatry": false,
      "voennaya_technica": false,
      "kino": false,
      "concerty": false,
      "vystavki": false,
      "muzika": false,
    },
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(
              left: 28,
              top: 81,
            ),
            child: TextButton(
              style: ButtonStyle(
                enableFeedback: false,
                backgroundColor: MaterialStateProperty.all<Color>(
                  Colors.transparent,
                ),
                shadowColor: MaterialStateProperty.all<Color>(
                  Colors.transparent,
                ),
                overlayColor: MaterialStateProperty.all<Color>(
                  Colors.transparent,
                ),
              ),
              child: SvgPicture.asset(
                "assets/images/arrow_back.svg",
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          Column(
            children: [
              // Top texts
              Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.only(
                  top: 70,
                ),
                child: const Column(
                  children: [
                    Text(
                      "Регистрация",
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      "выбор предпочтений",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Color.fromRGBO(
                          169,
                          169,
                          169,
                          1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Inputs
              Container(
                height: 197,
                color: const Color.fromRGBO(
                  246,
                  246,
                  246,
                  1,
                ),
                margin: const EdgeInsets.only(
                  top: 20,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Preferences(
                      bridge: bridge,
                    ),
                  ],
                ),
              ),

              // Adaptive margin
              Expanded(
                child: Container(),
              ),

              // Button
              Container(
                margin: const EdgeInsets.only(
                  bottom: 61,
                ),
                alignment: Alignment.bottomCenter,
                child: WhiteButton(
                  text: "Завершить",
                  onPressed: () {
                    // Auth logic
                  },
                ),
              ),
            ],
          ),

          // Debug button
          TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const RegisterPage2(),
                ),
              );
            },
            child: const Text(
              "Debug",
            ),
          ),

          TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const RegisterPage2(),
                ),
              );
            },
            child: const Text(
              "Debug",
            ),
          )
        ],
      ),
    );
  }
}
