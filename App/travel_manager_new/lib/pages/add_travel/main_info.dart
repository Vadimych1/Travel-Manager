// Общая информация
import 'package:flutter/material.dart';
import "package:travel_manager_new/uikit/uikit.dart";
import "package:flutter_svg/flutter_svg.dart";
// import '../main/main_travels.dart';
import 'choose_town.dart';
// import 'package:intl/intl.dart';

class CreateTravelMainInfo extends StatefulWidget {
  const CreateTravelMainInfo({
    super.key,
  });

  @override
  State<CreateTravelMainInfo> createState() => _CreateTravelMainInfoState();
}

class _CreateTravelMainInfoState extends State<CreateTravelMainInfo> {
  final TextEditingController _peopleCount = TextEditingController();
  final TextEditingController _travelname = TextEditingController();
  final DateBridge _startdate = DateBridge(value: DateTime.now());
  final DateBridge _enddate = DateBridge(value: DateTime.now());

  var prev = {
    "peopleCount": "",
    "travelName": "",
    "startdate": "",
    "enddate": "",
  };

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
            child: TextButton(
              child: SvgPicture.asset(
                "assets/images/svg/arrow_back.svg",
                color: const Color(
                  0xFFFFFFFF,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
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
                  "Общая информация",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFFDCDCDC),
                  ),
                ),
              ),

              // Inputs
              Container(
                margin: const EdgeInsets.only(top: 40),
                child: Input(
                  placeholder: "количество людей",
                  onChanged: (s) {
                    try {
                      if (s.isNotEmpty) {
                        int.parse(s);
                      }
                      prev["peopleCount"] = s;
                    } catch (e) {
                      _peopleCount.value = TextEditingValue(
                        text: prev["peopleCount"]!,
                      );
                    }
                  },
                  controller: _peopleCount,
                  icon: SvgPicture.asset(
                    "assets/images/svg/usericon.svg",
                    width: 19,
                    height: 19,
                    fit: BoxFit.scaleDown,
                  ),
                ),
              ),

              Container(
                margin: const EdgeInsets.only(top: 20),
                child: Input(
                  placeholder: "название поездки",
                  onChanged: (s) {
                    if (s.length > 30) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Максимальная длинна названия - 30 символов.",
                          ),
                        ),
                      );
                      _travelname.value = TextEditingValue(
                        text: prev["travelName"]!,
                      );
                    } else {
                      prev["travelName"] = s;
                      // print(prev["travelName"]);
                      // print(prev["travelName"]!.length);
                    }
                  },
                  controller: _travelname,
                  icon: SvgPicture.asset(
                    "assets/images/svg/pencil.svg",
                    width: 19,
                    height: 19,
                    fit: BoxFit.scaleDown,
                    color: Colors.grey,
                  ),
                ),
              ),

              Container(
                margin: const EdgeInsets.only(top: 20),
                child: DatePicker(
                  bridge: _startdate,
                  text: "Выберите дату начала",
                  message: "дата начала",
                  starttime: DateBridge(value: DateTime.now()),
                ),
              ),

              Container(
                margin: const EdgeInsets.only(top: 20),
                child: DatePicker(
                  bridge: _enddate,
                  starttime: _startdate,
                  text: "Выберите дату конца",
                  message: "дата конца",
                ),
              ),

              Expanded(
                child: Container(),
              ),

              Container(
                margin: const EdgeInsets.only(bottom: 100, top: 10),
                child: BlackButton(
                  text: "Далее",
                  onPressed: () {
                    if (_peopleCount.text.isNotEmpty &&
                        int.parse(_peopleCount.text) > 0 &&
                        _travelname.text.isNotEmpty &&
                        _enddate.changed &&
                        _startdate.changed) {
                      FocusScopeNode focus = FocusScope.of(context);
                      if (focus.hasFocus || focus.hasPrimaryFocus) {
                        focus.unfocus();
                      }

                      Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder: (context, _, __) =>
                              CreateTravelChooseTown(
                            params: {
                              "startDate": _startdate.value,
                              "endDate": _enddate.value,
                              "peopleCount": prev["peopleCount"],
                              "travelName": prev["travelName"],
                            },
                          ),
                          transitionsBuilder: trans,
                          transitionDuration: const Duration(milliseconds: 10),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(children: [
                            SvgPicture.asset(
                              "assets/images/svg/warn.svg",
                              color: Colors.red,
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            const Text("Заполните все поля")
                          ]),
                        ),
                      );
                    }
                  },
                  color: myColors['blue1'],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}