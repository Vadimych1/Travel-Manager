import "dart:convert";
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import "package:flutter/material.dart";
import "package:flutter_secure_storage/flutter_secure_storage.dart";
import "package:intl/intl.dart";
import "package:timezone/timezone.dart";
import "package:travel_manager_new/pages/auth/login.dart";
import "../../uikit/uikit.dart";
import "package:flutter_svg/flutter_svg.dart";
import "package:http/http.dart";
import "./activity_view.dart";

class ViewTravel extends StatefulWidget {
  const ViewTravel({super.key, required this.travelId});

  final int travelId;

  @override
  State<ViewTravel> createState() => _ViewTravelState();
}

class _ViewTravelState extends State<ViewTravel> {
  List<Widget> content = [];
  List<Widget> activities = [];
  bool napominanie = false;
  bool zaDenDo = false;
  final TextEditingController _napominanieTimeController =
      TextEditingController();
  String prevS = "";
  Map travel = {};

  bool settingsChanged = false;

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();

    var initializationSettingsAndroid = const AndroidInitializationSettings(
      r"@drawable/app_icon",
    );
    var initializationSettingsIOS = const DarwinInitializationSettings();
    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    flutterLocalNotificationsPlugin.initialize(initializationSettings);

    var s = const FlutterSecureStorage();

    s.read(key: "username").then(
      (usr) {
        s.read(key: "password").then(
          (pwd) {
            get(
              Uri.https(
                serveraddr,
                "api/v1/get_travel",
                {
                  "username": usr,
                  "password": pwd,
                  "id": widget.travelId.toString(),
                },
              ),
            ).then(
              (r) {
                try {
                  var resp = jsonDecode(
                    r.body
                        .replaceAll("+", " ")
                        .replaceAll('"activities":"', '"activities":')
                        .replaceAll('}]"', "}]")
                        .replaceAll("\"{", "{")
                        .replaceAll("}\"", "}")
                        .replaceAll("\\", ""),
                  );
                  if (resp["status"] == "success") {
                    travel = resp["content"];
                    try {
                      napominanie = travel["meta"]["napominanie"];
                      // print(napominanie);
                    } catch (e) {
                      // print(e);
                      napominanie = false;
                    }
                    try {
                      zaDenDo = travel["meta"]["za_den_do"];
                      // print(zaDenDo);
                    } catch (e) {
                      // print(e);
                      zaDenDo = false;
                    }

                    try {
                      _napominanieTimeController.text =
                          travel["meta"]["napominanie_time"];
                    } catch (e) {
                      _napominanieTimeController.text = "";
                    }

                    travel["activities"].forEach(
                      (e) => {
                        activities.add(
                          Container(
                            margin: const EdgeInsets.only(top: 5),
                            width: 290,
                            height: 40,
                            decoration: const BoxDecoration(
                              color: Color(0xFF444444),
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                            ),
                            child: TextButton(
                              child: Text(
                                e["name"],
                                style: const TextStyle(
                                  color: Color(0xFFFFFFFF),
                                ),
                              ),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => ActivityView(
                                      activity: e,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        )
                      },
                    );

                    content = [
                      // About
                      Container(
                        width: 307,
                        margin: const EdgeInsets.only(top: 20),
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFFFF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Поездка: ${travel["plan_name"]}",
                              style: const TextStyle(
                                fontFamily: "Pro",
                                fontSize: 16,
                                color: Color(0xFF000000),
                              ),
                              textAlign: TextAlign.start,
                            ),
                            Text(
                              "С - по: ${travel["from_date"]}-${travel["to_date"]}",
                              style: const TextStyle(
                                fontFamily: "Pro",
                              ),
                              textAlign: TextAlign.start,
                            ),
                            Text(
                              "В: ${travel["town"]}",
                              style: const TextStyle(
                                fontFamily: "Pro",
                              ),
                              textAlign: TextAlign.start,
                            ),
                          ],
                        ),
                      ),

                      // Reminders
                      Container(
                        width: 307,
                        margin: const EdgeInsets.only(top: 40),
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFFFF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            // напоминание?
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Напоминание:",
                                  style: TextStyle(
                                    fontFamily: "Pro",
                                    fontSize: 14,
                                  ),
                                ),
                                CheckboxNew(
                                  default_: napominanie,
                                  onChanged: (v) {
                                    setState(
                                      () {
                                        settingsChanged = true;
                                        napominanie = !napominanie;
                                      },
                                    );
                                  },
                                )
                              ],
                            ),

                            // напомнить за день до?
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Напомнить за день до:",
                                  style: TextStyle(
                                    fontFamily: "Pro",
                                    fontSize: 14,
                                  ),
                                ),
                                CheckboxNew(
                                  default_: zaDenDo,
                                  onChanged: (v) {
                                    setState(
                                      () {
                                        settingsChanged = true;
                                        zaDenDo = !zaDenDo;
                                      },
                                    );
                                  },
                                )
                              ],
                            ),

                            // время напоминания
                            Container(
                              margin: const EdgeInsets.only(
                                top: 15,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Время напоминания:",
                                    style: TextStyle(
                                      fontFamily: "Pro",
                                      fontSize: 14,
                                    ),
                                  ),
                                  SmallInput(
                                    controller: _napominanieTimeController,
                                    placeholder: "00:00",
                                    onChanged: (s) {
                                      setState(() {
                                        settingsChanged = true;
                                        s = s.trim();

                                        if (s.length > prevS.length) {
                                          if (s.length == 3) {
                                            if (s[2] != ":") {
                                              _napominanieTimeController.text =
                                                  "${s.substring(0, 2)}:${s.substring(2)}";
                                            }
                                          }

                                          var inputed = s[prevS.length];
                                          if (!RegExp(r"[0-9:]")
                                              .hasMatch(inputed)) {
                                            _napominanieTimeController.text =
                                                prevS;
                                          } else {
                                            prevS = s;
                                          }
                                        }
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Activities
                      Container(
                        width: 307,
                        height: 210,
                        margin: const EdgeInsets.only(top: 40),
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFFFF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            children: activities,
                          ),
                        ),
                      ),
                    ];
                    setState(() {});
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            "Произошла ошибка. Попробуйте выйти из режима просмотра и повторить попытку"),
                      ),
                    );
                  }
                } catch (e) {
                  print("Error");
                  print(e);
                }
              },
            );
          },
        );
      },
    );
  }

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
            },
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: Colors.transparent,
            ),
          ),

          // Content
          Container(
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.only(top: 50, left: 60),
                  width: MediaQuery.of(context).size.width,
                  height: 100,
                  decoration: const BoxDecoration(
                    color: Color(0xFF101010),
                  ),
                  child: const Text(
                    "Просмотр поездки",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontFamily: "Pro",
                      color: Color(0xFFFFFFFF),
                      fontSize: 20,
                    ),
                  ),
                ),
                Column(
                  children: content,
                )
              ],
            ),
          ),

          // Back button
          Container(
            margin: const EdgeInsets.only(
              top: 40,
              left: 0,
            ),
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

          // Save button
          Positioned(
            right: 5,
            bottom: 5,
            child: FloatingActionButton(
              onPressed: () {
                // SAVE
                var meta = {};
                // print(travel["activities"]);

                meta["napominanie"] = napominanie;
                meta["za_den_do"] = zaDenDo;
                meta["napominanie_time"] = _napominanieTimeController.text;

                if (napominanie) {
                  var androidPlatformChannelSpecifics =
                      const AndroidNotificationDetails(
                    'channel_id',
                    'channel_name',
                    importance: Importance.max,
                    priority: Priority.high,
                  );
                  var iOSPlatformChannelSpecifics =
                      const DarwinNotificationDetails();
                  var platformChannelSpecifics = NotificationDetails(
                    android: androidPlatformChannelSpecifics,
                    iOS: iOSPlatformChannelSpecifics,
                  );

                  var dtime = DateFormat("dd-MM-yyyy HH:mm:ss").parse(
                      travel["from_date"].replaceAll(".", "-") +
                          " " +
                          _napominanieTimeController.text +
                          ":00");
                  var time = TZDateTime.from(dtime, local);

                  flutterLocalNotificationsPlugin.zonedSchedule(
                    0,
                    'Travel Manager',
                    'Напоминаем о поездке ${travel["plan_name"]}.',
                    time,
                    platformChannelSpecifics,
                    uiLocalNotificationDateInterpretation:
                        UILocalNotificationDateInterpretation.absoluteTime,
                    androidAllowWhileIdle: true,
                  );
                }

                if (zaDenDo) {
                  var androidPlatformChannelSpecifics =
                      const AndroidNotificationDetails(
                    'channel_id',
                    'channel_name',
                    importance: Importance.max,
                    priority: Priority.high,
                  );
                  var iOSPlatformChannelSpecifics =
                      const DarwinNotificationDetails();
                  var platformChannelSpecifics = NotificationDetails(
                    android: androidPlatformChannelSpecifics,
                    iOS: iOSPlatformChannelSpecifics,
                  );

                  var dtime = DateFormat("dd-MM-yyyy HH:mm:ss").parse(
                      travel["from_date"].replaceAll(".", "-") +
                          " " +
                          _napominanieTimeController.text +
                          ":00");

                  dtime = DateTime(
                    dtime.year,
                    dtime.month - (dtime.day > 1 ? 0 : 1),
                    (dtime.day > 1
                        ? dtime.day - 1
                        : DateTime(
                              dtime.year,
                              dtime.month + 1,
                              0,
                            ).day -
                            1),
                    dtime.hour,
                    dtime.minute,
                  );

                  if (dtime.second <= DateTime.now().second) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            "Время должно быть позже, чем текущее. Попробуйте отключить параметр \"Напомнить за день до\""),
                      ),
                    );
                    return;
                  }
                  var time = TZDateTime.from(dtime, local);

                  flutterLocalNotificationsPlugin.zonedSchedule(
                    0,
                    'Travel Manager',
                    'Напоминаем о поездке ${travel["plan_name"]}.',
                    time,
                    platformChannelSpecifics,
                    uiLocalNotificationDateInterpretation:
                        UILocalNotificationDateInterpretation.absoluteTime,
                    androidAllowWhileIdle: true,
                  );
                }

                s.read(key: "username").then(
                  (usr) {
                    s.read(key: "password").then(
                      (pwd) {
                        get(
                          Uri.https(
                            serveraddr,
                            "api/v1/edit_travel",
                            {
                              "username": usr,
                              "password": pwd,
                              "id": travel["id"].toString(),
                              "plan_name": travel["plan_name"],
                              "activities": jsonEncode(travel["activities"]),
                              "from_date": travel["from_date"],
                              "to_date": travel["to_date"],
                              "budget": travel["budget"].toString(),
                              "live_place": travel["live_place"],
                              "expenses": jsonEncode(travel["expenses"]),
                              "meta": jsonEncode(meta),
                              "people_count": travel["people_count"],
                              "town": travel["town"],
                            },
                          ),
                        ).then(
                          (v) {
                            if (v.statusCode == 200) {
                              var resp = jsonDecode(v.body);

                              if (resp["status"] == "success") {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Сохранено"),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Произошла ошибка. Попробуйте сохранить ещё раз",
                                    ),
                                  ),
                                );
                                print(resp);
                              }
                            }
                          },
                        );
                      },
                    );
                  },
                );
              },
              backgroundColor: const Color(0xFFFFFFFF),
              child: const Icon(
                Icons.save,
                color: Color(0xFF000000),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
