// Общая информация
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:travel_manager_new/pages/add_travel/choose_activities.dart';
import 'package:travel_manager_new/pages/uikit/uikit.dart';
import "package:flutter_svg/flutter_svg.dart";
// import '../main/main_travels.dart';
// import 'package:intl/intl.dart';

class CreateTravelMainInfo extends StatefulWidget {
  const CreateTravelMainInfo(
    this.params, {
    super.key,
  });

  final Map<String, dynamic> params;

  @override
  State<CreateTravelMainInfo> createState() => _CreateTravelMainInfoState();
}

class _CreateTravelMainInfoState extends State<CreateTravelMainInfo> {
  // final TextEditingController _peopleCount = TextEditingController();
  final TextEditingController _travelname = TextEditingController();
  final DateBridge _startdate = DateBridge(value: DateTime.now());
  final DateBridge _enddate = DateBridge(value: DateTime.now());

  var prev = {
    // "peopleCount": "",
    "travelName": "",
    "startdate": "",
    "enddate": "",
  };

  DateFormat dateFormat = DateFormat("dd.MM.yyyy");

  var peopleCountB = Bridge<Map>(value: {"children": 0, "parents": 0});

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

          Column(
            children: [
              // Inputs
              Container(
                margin: const EdgeInsets.only(top: 140),
                child: PeoplesCountInput(bridge: peopleCountB),
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
                    }
                  },
                  controller: _travelname,
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
                margin: const EdgeInsets.only(bottom: 20, top: 10),
                child: BlackButton(
                  text: "К выбору активностей",
                  onPressed: () {
                    if (peopleCountB.value["parents"] > 0 &&
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
                              CreateTravelChooseActivities(
                            params: {
                              "town": widget.params["town"],
                              "startDate": dateFormat.format(_startdate.value),
                              "endDate": dateFormat.format(_enddate.value),
                              "peopleCount":
                                  "${peopleCountB.value["children"]};${peopleCountB.value["parents"]}",
                              "travelName": prev["travelName"],
                              "budget": "",
                            },
                          ),
                          transitionsBuilder: trans,
                          transitionDuration: const Duration(milliseconds: 10),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              SvgPicture.asset(
                                "assets/images/svg/warn.svg",
                                // ignore: deprecated_member_use
                                color: Colors.red,
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              const Text("Заполните все поля")
                            ],
                          ),
                        ),
                      );
                    }
                  },
                  // color: myColors['blue1'],
                ),
              ),
            ],
          ),

          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF232323),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
            ),
            width: MediaQuery.of(context).size.width,
            height: 100,
            padding: const EdgeInsets.only(
              left: 40,
              top: 67,
            ),
            child: const Text(
              "Введите нужные данные",
              style: TextStyle(
                color: Color(
                  0xFFFFFFFF,
                ),
                fontSize: 20,
              ),
            ),
          ),

          // Back button
          Container(
            margin: const EdgeInsets.only(
              top: 57,
              left: 0,
            ),
            // color: Colors.red,
            child: const BackButton(
              color: Color(0xFFFFFFFF),
            ),
          ),
        ],
      ),
    );
  }
}
