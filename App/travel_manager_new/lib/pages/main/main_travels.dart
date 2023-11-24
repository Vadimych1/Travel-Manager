import "package:flutter/material.dart";
// import 'package:intl/intl.dart';
import 'package:travel_manager_new/uikit/uikit.dart';
import 'main_home.dart';
import '../add_travel/main_info.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';

class MainTravels extends StatefulWidget {
  const MainTravels({super.key});

  @override
  State<MainTravels> createState() => _MainTravelsState();
}

class _MainTravelsState extends State<MainTravels> {
  int count = 0;
  List<Widget> travels = [];

  late String countS;

  @override
  void initState() {
    super.initState();
    var secureStorage = const FlutterSecureStorage();

    secureStorage.read(key: "username").then(
          (usr) => {
            secureStorage.read(key: "password").then(
                  (pwd) => {
                    get(
                      Uri.https(
                        "x1f9tspp-80.euw.devtunnels.ms",
                        "get_all_travels",
                        {"username": usr, "password": pwd},
                      ),
                    ).then(
                      (value) {
                        var undec = value.body;
                        print(undec);

                        var j = jsonDecode(
                          Uri.decodeComponent(undec)
                              .replaceAll("+", " ")
                              .replaceAll('"activities":"', '"activities":')
                              .replaceAll('}]"', "}]"),
                        );
                        for (var elem in j["content"]) {
                          print(elem);
                          setState(
                            () {
                              travels.add(
                                TravelBlock(
                                  id: int.parse(elem["id"]),
                                  travelName: elem["plan_name"],
                                  town: elem["town"],
                                  fromDate: elem["from_date"],
                                  toDate: elem["to_date"],
                                  moneys: elem["budget"],
                                  activities: elem["activities"],
                                  full: true,
                                ),
                              );
                            },
                          );
                        }
                      },
                    ),
                  },
                )
          },
        );

    String out = "";
    String countstring = count.toString();
    if (countstring[countstring.length - 1] == "1") {
      out = "$count поездка";
    } else if (countstring[countstring.length - 1] == "2" ||
        countstring[countstring.length - 1] == "3" ||
        countstring[countstring.length - 1] == "4") {
      out = "$count поездки";
    } else if (countstring[countstring.length - 1] == "5" ||
        countstring[countstring.length - 1] == "6" ||
        countstring[countstring.length - 1] == "7" ||
        countstring[countstring.length - 1] == "8" ||
        countstring[countstring.length - 1] == "9" ||
        countstring[countstring.length - 1] == "0") {
      out = "$count поездок";
    }

    countS = out;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // BG
          Column(
            children: [
              Stack(
                children: [
                  Image.asset(
                    r"assets\images\png\main_pages\bg1.png",
                    fit: BoxFit.fill,
                    width: MediaQuery.of(context).size.width,
                  ),
                  Positioned(
                    top: 237 / 393 * MediaQuery.of(context).size.width - 110,
                    left: 20,
                    child: Text(
                      "В ваших планах\n$countS",
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFFFFFFF),
                        fontFamily: "Pro",
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),

          // FG
          Column(
            children: [
              // Under content
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(
                    top: 237 / 393 * MediaQuery.of(context).size.width - 20,
                    left: 0,
                  ),
                  padding: const EdgeInsets.only(
                    top: 20,
                  ),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                        ),
                        // Travels
                        Column(
                          children: travels,
                        ),

                        // Text
                        Container(
                          margin: EdgeInsets.only(
                              top: travels.isNotEmpty ? 10 : 70),
                          child: Text(
                            travels.isNotEmpty
                                ? 'для редактирования нажмите\nна карточку плана'
                                : "Пока что тут пусто.\nНажмите на кнопку ниже,\nчтобы добавить новый план",
                            style: const TextStyle(
                              color: Color(0xFF757575),
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              fontFamily: "Pro",
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        // Button
                        Container(
                          margin: const EdgeInsets.only(top: 30),
                          child: BlackButton(
                            text: "Создать план",
                            onPressed: () {
                              Navigator.of(context).push(
                                PageRouteBuilder(
                                  pageBuilder: (context, _, __) =>
                                      const CreateTravelMainInfo(),
                                  transitionsBuilder: trans,
                                  transitionDuration:
                                      const Duration(milliseconds: 10),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Navbar
          Container(
            width: MediaQuery.of(context).size.width,
            height: 50,
            color: const Color(0xFFEEEEEE),
            margin:
                EdgeInsets.only(top: MediaQuery.of(context).size.height - 50),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Home
                TextButton(
                  child: SvgPicture.asset(
                    "assets/images/svg/navbar/home.svg",
                    color: const Color(0xFF000000),
                  ),
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      PageRouteBuilder(
                        pageBuilder: (context, _, __) => const MainHome(),
                        transitionsBuilder: trans,
                        transitionDuration: const Duration(milliseconds: 10),
                      ),
                    );
                  },
                ),

                // Travels
                TextButton(
                  child: SvgPicture.asset(
                    "assets/images/svg/navbar/travels.svg",
                    color: const Color(0xFF000000),
                  ),
                  onPressed: () {},
                ),

                // Settings
                TextButton(
                  child: SvgPicture.asset(
                    "assets/images/svg/navbar/settings.svg",
                    color: const Color(0xFF000000),
                  ),
                  onPressed: () {},
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
