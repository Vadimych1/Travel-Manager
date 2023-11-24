import 'dart:convert';

import "package:flutter/material.dart";
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:travel_manager_new/uikit/uikit.dart';
import 'main_travels.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MainHome extends StatefulWidget {
  const MainHome({super.key});

  @override
  State<MainHome> createState() => _MainHomeState();
}

class _MainHomeState extends State<MainHome> {
  DateTime now = DateTime.now();
  DateFormat formatHours = DateFormat.H();

  String texttime = "";
  late int time;

  List<Widget> travels = [];
  String name = "";

  @override
  void initState() {
    super.initState();
    time = int.parse(formatHours.format(now));
    // print(time);
    // print(now);
    // print(formatHours.format(now));

    FlutterSecureStorage secureStorage = const FlutterSecureStorage();
    try {
      print("Name read");
      secureStorage.read(key: "name").then(
        (e) {
          setState(() {
            name = e ?? "<ошибка>";
          });
        },
      );
      setState(() {});
    } catch (e) {
      print("Ошибка (имя)");

      setState(() {
        name = "<ошибка>";
      });
    }

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
                                  id: 0,
                                  travelName: elem["plan_name"],
                                  town: elem["town"],
                                  fromDate: elem["from_date"],
                                  toDate: elem["to_date"],
                                  moneys: elem["budget"],
                                  activities: elem["activities"],
                                  full: false,
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

    if (time >= 18 && time < 24) {
      texttime = "Добрый вечер,";
    } else if (time > 0 && time < 6) {
      texttime = "Доброй ночи,";
    } else if (time >= 6 && time < 12) {
      texttime = "Доброе утро,";
    } else if (time >= 12 && time < 18) {
      texttime = "Добрый день,";
    }

    name += "  " * (texttime.length - name.length);

    setState(() {});
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
                  Container(
                    color: const Color(0x08000000),
                    width: MediaQuery.of(context).size.width,
                    height: 237 /
                        393 *
                        MediaQuery.of(context).size.width, // 393 x 237
                  ),
                  Positioned(
                    top: 237 / 393 * MediaQuery.of(context).size.width - 110,
                    left: 20,
                    child: Text(
                      "$texttime $name\nКуда отправимся?",
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
                  decoration: const BoxDecoration(
                    color: Color(0xFF202020),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Text Ваши поездки
                        Container(
                          margin: const EdgeInsets.only(top: 20, left: 20),
                          alignment: Alignment.topLeft,
                          child: const Text(
                            "Ваши поездки",
                            style: TextStyle(
                              color: Color(0xFFFFFFFF),
                              fontWeight: FontWeight.w900,
                              fontSize: 24,
                              fontFamily: "Pro",
                            ),
                          ),
                        ),

                        // Travels
                        Column(
                          children: travels,
                        ),

                        // Text
                        Container(
                          margin: const EdgeInsets.only(top: 10),
                          child: Text(
                            travels.isNotEmpty
                                ? 'перейдите на вкладку "Поездки",\nчтобы создать новый план или\nотредактировать существующий'
                                : "пока что тут пусто.\nЧтобы добавить поездку, перейдите на\nстраницу поездок",
                            style: const TextStyle(
                              color: Color(0xFF757575),
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              fontFamily: "Pro",
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        // Text Ваши поездки
                        Container(
                          margin: const EdgeInsets.only(top: 20, left: 20),
                          alignment: Alignment.topLeft,
                          child: const Text(
                            "Информация",
                            style: TextStyle(
                              color: Color(0xFFFFFFFF),
                              fontWeight: FontWeight.w900,
                              fontSize: 24,
                              fontFamily: "Pro",
                            ),
                          ),
                        ),

                        // Info
                        const Info(),

                        const SizedBox(
                          height: 100,
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
            color: const Color(0x00EEEEEE),
            margin:
                EdgeInsets.only(top: MediaQuery.of(context).size.height - 50),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Home
                TextButton(
                  child: SvgPicture.asset(
                    "assets/images/svg/navbar/home.svg",
                    color: const Color(0xFFFFFFFF),
                  ),
                  onPressed: () {},
                ),

                // Travels
                TextButton(
                  child: SvgPicture.asset(
                    "assets/images/svg/navbar/travels.svg",
                    color: const Color(0xFFFFFFFF),
                  ),
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      PageRouteBuilder(
                        pageBuilder: (context, _, __) => const MainTravels(),
                        transitionsBuilder: trans,
                        transitionDuration: const Duration(milliseconds: 10),
                      ),
                    );
                  },
                ),

                // Settings
                TextButton(
                  child: SvgPicture.asset(
                    "assets/images/svg/navbar/settings.svg",
                    color: const Color(0xFFFFFFFF),
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
