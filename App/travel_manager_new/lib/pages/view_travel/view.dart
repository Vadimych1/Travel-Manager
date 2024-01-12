import "dart:convert";
// ignore: depend_on_referenced_packages
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import "package:flutter/material.dart";
import "package:flutter_secure_storage/flutter_secure_storage.dart";
import "package:intl/intl.dart";
import "package:timezone/timezone.dart";
import "package:travel_manager_new/pages/auth/login.dart";
import "../../uikit/uikit.dart";
import "package:http/http.dart";
import "./activity_view.dart";
import "./expense_view.dart";

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

  var expenses = <Widget>[];
  var usr = "";
  var pwd = "";

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
      (usr_) {
        s.read(key: "password").then(
          (pwd_) {
            usr = usr_ ?? "";
            pwd = pwd_ ?? "";
            get(
              Uri.http(
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
                        .replaceAll("\\", "")
                        .replaceAll("}}\"", "}}")
                        .replaceAll("\"[", "[")
                        .replaceAll("]\"", "]"),
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

                    expenses = <Widget>[];

                    travel["expenses"].forEach(
                      (val) => {
                        expenses.add(
                          SizedBox(
                            child: TextButton(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "${val["name"]}: ",
                                  ),
                                  Text(
                                    "${int.parse(val["cost"])} руб.",
                                  ),
                                ],
                              ),
                              onPressed: () {},
                            ),
                          ),
                        ),
                      },
                    );

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
                        ),
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

                      // Activities
                      Container(
                        width: 307,
                        height: 240,
                        margin: const EdgeInsets.only(top: 40),
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFFFF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              "Активности",
                            ),
                            SizedBox(
                              height: 190,
                              child: SingleChildScrollView(
                                child: Column(
                                  children: activities,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ];

                    setState(() {
                      loaded = true;
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            "Произошла ошибка. Попробуйте выйти из режима просмотра и повторить попытку"),
                      ),
                    );
                    setState(() {
                      loaded = true;
                    });
                  }
                } catch (e) {
                  null;
                }
              },
            );
          },
        );
      },
    );
  }

  var loaded = false;

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
            color: loaded
                ? Colors.transparent
                : const Color(0xFFFFFFFF).withOpacity(0.4),
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisAlignment:
                  loaded ? MainAxisAlignment.start : MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: loaded
                  ? [
                      Container(
                        padding: const EdgeInsets.only(top: 50, left: 60),
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
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height - 100,
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              ...content,
                              // Expenses
                              Container(
                                width: 307,
                                height: 330,
                                margin: const EdgeInsets.only(top: 40),
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFFFFF),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  children: [
                                    const Text("Расходы"),
                                    Container(
                                      height: 200,
                                      width: 295,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          10,
                                        ),
                                        color: const Color(0xFFCCCCCC),
                                      ),
                                      margin: const EdgeInsets.only(bottom: 13),
                                      child: SingleChildScrollView(
                                        child: Column(children: expenses),
                                      ),
                                    ),
                                    Container(
                                      alignment: Alignment.bottomCenter,
                                      child: BlackButton(
                                        text: "Изменить",
                                        onPressed: () {
                                          Navigator.of(context)
                                              .push(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ExpenseView(travel: travel),
                                            ),
                                          )
                                              .then(
                                            (_) {
                                              get(
                                                Uri.http(
                                                  serveraddr,
                                                  "api/v1/get_travel",
                                                  {
                                                    "username": usr,
                                                    "password": pwd,
                                                    "id": widget.travelId
                                                        .toString(),
                                                  },
                                                ),
                                              ).then(
                                                (resp) {
                                                  var t = jsonDecode(
                                                    resp.body
                                                        .replaceAll("+", " ")
                                                        .replaceAll(
                                                            '"activities":"',
                                                            '"activities":')
                                                        .replaceAll('}]"', "}]")
                                                        .replaceAll("\"{", "{")
                                                        .replaceAll("}\"", "}")
                                                        .replaceAll("\\", "")
                                                        .replaceAll(
                                                            "}}\"", "}}")
                                                        .replaceAll("\"[", "[")
                                                        .replaceAll("]\"", "]"),
                                                  );

                                                  if (t["status"] ==
                                                      "success") {
                                                    setState(
                                                      () {
                                                        expenses = <Widget>[];

                                                        jsonDecode(travel[
                                                                    "expenses"] ??
                                                                "[]")
                                                            .forEach(
                                                          (val) => {
                                                            setState(
                                                              () {
                                                                expenses.add(
                                                                  SizedBox(
                                                                    child:
                                                                        TextButton(
                                                                      child:
                                                                          Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          Text(
                                                                            "${val["name"]}: ",
                                                                          ),
                                                                          Text(
                                                                            "${int.parse(val["cost"])} руб.",
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      onPressed:
                                                                          () {},
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                          },
                                                        );
                                                      },
                                                    );

                                                    setState(() {});
                                                  }
                                                },
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 50,
                              )
                            ],
                          ),
                        ),
                      ),
                    ]
                  : [
                      const CircularProgressIndicator(
                        color: Color(0xFF000000),
                        semanticsLabel: "Загрузка...",
                        semanticsValue: "Загрузка...",
                      ),
                    ],
            ),
          ),

          // Back button
          Container(
            margin: const EdgeInsets.only(
              top: 40,
              left: 0,
            ),
            child: const BackButton(),
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
                    // ignore: deprecated_member_use
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

                  flutterLocalNotificationsPlugin
                      .zonedSchedule(
                        1,
                        'Travel Manager',
                        'Напоминаем о поездке ${travel["plan_name"]}.',
                        time,
                        platformChannelSpecifics,
                        uiLocalNotificationDateInterpretation:
                            UILocalNotificationDateInterpretation.absoluteTime,
                        androidScheduleMode:
                            AndroidScheduleMode.exactAllowWhileIdle,
                      )
                      .onError(
                        (error, stackTrace) => null,
                      );
                }

                s.read(key: "username").then(
                  (usr) {
                    s.read(key: "password").then(
                      (pwd) {
                        get(
                          Uri.http(
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
