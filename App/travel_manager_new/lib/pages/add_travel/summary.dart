// Обобщение
import "dart:convert";
import '../main/main_home.dart';
import "package:flutter/material.dart";
import 'package:travel_manager_new/uikit/uikit.dart';
import 'package:http/http.dart';
import "package:flutter_secure_storage/flutter_secure_storage.dart";

class CreateTravelSummary extends StatefulWidget {
  const CreateTravelSummary({super.key, required this.params});

  final Map params;

  @override
  State<CreateTravelSummary> createState() => _CreateTravelSummaryState();
}

class _CreateTravelSummaryState extends State<CreateTravelSummary> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // BG
          Container(
            color: const Color(0xFF005E72),
          ),

          // Unfocus
          GestureDetector(
            onTap: () {
              FocusScopeNode focus = FocusScope.of(context);
              if (focus.hasFocus || focus.hasPrimaryFocus) {
                focus.unfocus();
              }
              // print("AAA");
            },
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: Colors.transparent,
            ),
          ),

          // Back button
          Container(
            margin: const EdgeInsets.only(
              top: 57,
              left: 0,
            ),
            // color: Colors.red,
            child: const BackButton(),
          ),

          // FG
          Column(
            children: [
              // Title
              Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.only(top: 50),
                child: const Text(
                  "Создание поездки",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFFFFFFF),
                  ),
                ),
              ),

              // Undertext
              Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.only(top: 0),
                child: const Text(
                  "Итоги",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFFDCDCDC),
                  ),
                ),
              ),

              Container(
                width: 307,
                height: 140,
                margin: const EdgeInsets.only(top: 30),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFFFF),
                  border: Border.all(
                    color: const Color(0xFF000000),
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      'Поездка "${widget.params["travelName"]}"',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF000000),
                        fontFamily: "Pro",
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Text(
                      'План будет сохранен после нажатия кнопки "Завершить". Вы можете отредактировать поездку сейчас или позже, в Редакторе поездок. Также рекомендуем доработать\nВаш план в Редакторе поездок.',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: "Pro",
                      ),
                      textAlign: TextAlign.center,
                    )
                  ],
                ),
              ),

              Expanded(
                child: Container(),
              ),

              Container(
                margin: const EdgeInsets.only(bottom: 40, top: 10),
                child: BlackButton(
                  text: "Завершить",
                  onPressed: () {
                    var s = const FlutterSecureStorage();
                    var d = widget.params;

                    s.read(key: "username").then(
                      (usr) {
                        s.read(key: "password").then(
                          (pwd) {
                            // print(d);
                            var uri = Uri.http(
                              serveraddr,
                              "api/v1/create_travel",
                              {
                                "username": usr ?? "0",
                                "password": pwd ?? "0",
                                "plan_name": d["travelName"] ?? "0",
                                "activities": jsonEncode(d["activities"] ?? []),
                                "from_date": d["startDate"].toString(),
                                "to_date": d["endDate"].toString(),
                                "budget": "0", // deprecated
                                "live_place": "null", // deprecated
                                "expenses": "[]",
                                "meta": "{}",
                                "people_count": d["peopleCount"] ?? "0",
                                "town": d["town"] ?? "0",
                              },
                            );
                            get(uri).then(
                              (value) {
                                var j = jsonDecode(value.body);

                                if (j["status"] == "success") {
                                  Navigator.of(context)
                                      .popUntil((route) => false);
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => const MainHome(),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          "Произошла ошибка: ${j['code']}"),
                                    ),
                                  );
                                }
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
