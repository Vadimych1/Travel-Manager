import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import "../pages/view_travel/view.dart";
import 'package:http/http.dart';
import 'package:translit/translit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/svg.dart';

const String serveraddr = "x1f9tspp-80.euw.devtunnels.ms";

const String vkapiKey =
    "2320e98d2320e98d2320e98d652035789d223202320e98d47da2fa056600b3052f44d4c";

const String gisapiKey = "633b455e-9da5-47b6-8d30-040293bc52a3";

// ! COLORS
Map myColors = {
  "green1": const Color.fromRGBO(
    15,
    156,
    109,
    1,
  ),
  "blue1": const Color.fromRGBO(
    13,
    143,
    171,
    1,
  ),
  "primaryText": Colors.white,
  "secondaryText": Color.fromRGBO(190, 190, 190, 1),
  "gray": const Color.fromRGBO(
    148,
    148,
    148,
    1,
  ),
};

bool isEmailValid(String email) {
  return RegExp(
          r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
      .hasMatch(email);
}

// ! Black button
class BlackButton extends StatelessWidget {
  const BlackButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color = const Color(0xFF000000),
  });

  final Function() onPressed;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.all(
          Radius.circular(
            10,
          ),
        ),
      ),
      child: TextButton(
        style: ButtonStyle(
          padding: MaterialStateProperty.all<EdgeInsets>(
            const EdgeInsets.symmetric(vertical: 22, horizontal: 46),
          ),
          splashFactory: NoSplash.splashFactory,
          backgroundColor: MaterialStateProperty.all<Color>(
            Colors.transparent,
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(
            fontFamily: "Pro",
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w300,
            letterSpacing: -0.2,
          ),
        ),
      ),
    );
  }
}

// ! White button
class WhiteButton extends StatelessWidget {
  const WhiteButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  final Function() onPressed;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.all(
          Radius.circular(
            10,
          ),
        ),
      ),
      child: TextButton(
        style: ButtonStyle(
          padding: MaterialStateProperty.all<EdgeInsets>(
            const EdgeInsets.symmetric(vertical: 22, horizontal: 46),
          ),
          splashFactory: NoSplash.splashFactory,
          backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: "Pro",
            fontWeight: FontWeight.w300,
            letterSpacing: -0.2,
          ),
        ),
      ),
    );
  }
}

// ! Input
class Input extends StatelessWidget {
  const Input({
    super.key,
    required this.placeholder,
    required this.onChanged,
    required this.controller,
    // required this.icon,
    this.inputFormatters = const [],
    this.inputType = TextInputType.text,
    this.borderRadius = const BorderRadius.all(
      Radius.circular(10),
    ),
  });

  final String placeholder;
  final Function(String) onChanged;
  final TextEditingController controller;
  final TextInputType inputType;
  final List<TextInputFormatter> inputFormatters;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 307,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        border: Border.all(color: const Color(0xFF000000)),
        borderRadius: borderRadius,
      ),
      child: TextField(
        style: TextStyle(
          fontWeight: FontWeight.w300,
          fontSize: 16,
          // fontFamily: "Pro",
          color: myColors["gray"],
        ),
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: placeholder,
          hintStyle: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 16,
            color: myColors["gray"],
            // fontFamily: "Pro",
          ),
          filled: true,
          focusColor: Colors.transparent,
          hoverColor: Colors.transparent,
          fillColor: Colors.transparent,
          enabled: true,
          enabledBorder: InputBorder.none,
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }
}

// ! Prefereces (deprecated)
class PreferencesItem extends StatefulWidget {
  const PreferencesItem({
    super.key,
    required this.text,
    required this.activated,
    required this.onPressed,
    required this.elementsOn,
    // required this.blockWidth,
  });

  final String text;
  final bool activated;
  final Function() onPressed;
  final int elementsOn;
  // final double blockWidth;

  @override
  State<PreferencesItem> createState() => PreferencesItemState();
}

class PreferencesItemState extends State<PreferencesItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 35,
      width: (300 / 30 * widget.text.length +
              5 -
              widget.elementsOn * 2 -
              (widget.text.length > 11 ? 20 : 1) -
              (widget.text.length > 9 ? 10 : 1) +
              (widget.text.length < 5 ? 10 : 0) +
              (widget.text.length < 7 ? 10 : 0))
          .toDouble(),
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
      margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
      decoration: BoxDecoration(
        color: widget.activated ? myColors["blue1"] : Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            offset: Offset.fromDirection(3.14 / 2, 2),
            blurRadius: 3,
          ),
        ],
      ),
      child: TextButton(
        style: ButtonStyle(
          splashFactory: NoSplash.splashFactory,
          padding: MaterialStateProperty.all<EdgeInsets>(
            const EdgeInsets.symmetric(horizontal: 3),
          ),
        ),
        onPressed: widget.onPressed,
        child: Text(
          widget.text,
          style: TextStyle(
            color: !widget.activated ? myColors["blue1"] : Colors.white,
            fontSize: MediaQuery.of(context).size.width > 361 ? 14 : 12,
            fontFamily: "Pro",
          ),
        ),
      ),
    );
  }
}

class Preferences extends StatefulWidget {
  const Preferences({super.key, required this.bridge});

  final MapBridge bridge;

  @override
  State<Preferences> createState() => PreferencesState();
}

class PreferencesState extends State<Preferences> {
  final Map<String, bool> preferences = {
    "dostoprimechatelnosti": false,
    "sobytiya": false,
    "razvlecheniya": false,
    "architectura": false,
    "igry": false,
    "teatry": false,
    "voennaya_technika": false,
    "kino": false,
    "koncerty": false,
    "vystavki": false,
    "musica": false,
  };

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
    widget.bridge.value = preferences;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 292,
      height: 197,
      padding: const EdgeInsets.symmetric(
        vertical: 18,
        horizontal: 16,
      ),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(
          246,
          246,
          246,
          1,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // ! ROW 1
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              PreferencesItem(
                elementsOn: 2,
                text: "Достопримечательности",
                activated: preferences["dostoprimechatelnosti"]!,
                onPressed: () {
                  setState(
                    () => preferences["dostoprimechatelnosti"] =
                        !preferences["dostoprimechatelnosti"]!,
                  );
                },
              ),
              PreferencesItem(
                elementsOn: 2,
                text: "События",
                activated: preferences["sobytiya"]!,
                onPressed: () {
                  setState(
                    () => preferences["sobytiya"] = !preferences["sobytiya"]!,
                  );
                },
              ),
            ],
          ),

          // ! ROW 2
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              PreferencesItem(
                elementsOn: 3,
                text: "Развлечения",
                activated: preferences["razvlecheniya"]!,
                onPressed: () {
                  setState(
                    () => preferences["razvlecheniya"] =
                        !preferences["razvlecheniya"]!,
                  );
                },
              ),
              PreferencesItem(
                elementsOn: 3,
                text: "Выставки",
                activated: preferences["vystavki"]!,
                onPressed: () {
                  setState(
                    () => preferences["vystavki"] = !preferences["vystavki"]!,
                  );
                },
              ),
              PreferencesItem(
                elementsOn: 3,
                text: "Игры",
                activated: preferences["igry"]!,
                onPressed: () {
                  setState(
                    () => preferences["igry"] = !preferences["igry"]!,
                  );
                },
              ),
            ],
          ),
          // ! ROW 3
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              PreferencesItem(
                elementsOn: 3,
                text: "Театры",
                activated: preferences["teatry"]!,
                onPressed: () {
                  setState(
                    () => preferences["teatry"] = !preferences["teatry"]!,
                  );
                },
              ),
              PreferencesItem(
                elementsOn: 3,
                text: "Военная техника",
                activated: preferences["voennaya_technika"]!,
                onPressed: () {
                  setState(
                    () => preferences["voennaya_technika"] =
                        !preferences["voennaya_technika"]!,
                  );
                },
              ),
              PreferencesItem(
                elementsOn: 3,
                text: "Кино",
                activated: preferences["kino"]!,
                onPressed: () {
                  setState(
                    () => preferences["kino"] = !preferences["kino"]!,
                  );
                },
              ),
            ],
          ),
          // ! ROW 4
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              PreferencesItem(
                elementsOn: 3,
                text: "Концерты",
                activated: preferences["koncerty"]!,
                onPressed: () {
                  setState(
                    () => preferences["koncerty"] = !preferences["koncerty"]!,
                  );
                },
              ),
              PreferencesItem(
                elementsOn: 3,
                text: "Архитектура",
                activated: preferences["architectura"]!,
                onPressed: () {
                  setState(
                    () => preferences["architectura"] =
                        !preferences["architectura"]!,
                  );
                },
              ),
              PreferencesItem(
                elementsOn: 3,
                text: "Музыка",
                activated: preferences["musica"]!,
                onPressed: () {
                  setState(
                    () => preferences["musica"] = !preferences["musica"]!,
                  );
                },
              ),
            ],
          )
        ],
      ),
    );
  }
}

// ! BRIDGE
class MapBridge {
  MapBridge({required this.value});
  Map value;
}

class DateBridge {
  DateBridge({required this.value, this.changed = false});
  DateTime value;
  bool changed;
}

class ListBridge<T> {
  ListBridge({required this.value});
  List<T> value;
}

class Bridge<T> {
  Bridge({required this.value});
  T value;
}

// ! Activity blocks
class Activities extends StatefulWidget {
  const Activities({
    super.key,
    required this.town,
    required this.bridge,
  });

  final String town;
  final ListBridge<SelectedActivity> bridge;

  List<Map<String, dynamic>> toJson() {
    var toReturn = <Map<String, dynamic>>[];

    for (var item in bridge.value) {
      toReturn.add(
        item.toJson(),
      );
    }

    return toReturn;
  }

  @override
  State<Activities> createState() => _ActivitiesState();
}

class _ActivitiesState extends State<Activities> {
  final TextEditingController _controller = TextEditingController();
  List<Widget> searchResults = [];

  @override
  Widget build(BuildContext context) {
    var username = "";
    var password = "";

    FlutterSecureStorage secureStorage = const FlutterSecureStorage();
    secureStorage.read(key: "username").then((username_) {
      secureStorage.read(key: "password").then((password_) {
        username = username_ ?? "";
        password = password_ ?? "";
      });
    });

    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: 320,
        minWidth: 100,
      ),
      child: Column(
        children: [
          // Activity Name Input
          Input(
            controller: _controller,
            placeholder: "начните ввод",
            onChanged: (s) {
              if (s.length > 1) {
                get(
                  Uri.https(
                    serveraddr,
                    'api/activities/search',
                    {
                      'username': username,
                      'password': password,
                      'q': s,
                      'town': widget.town.replaceAll(",", ""),
                    },
                  ),
                ).then(
                  (resp) {
                    if (resp.statusCode == 200) {
                      try {
                        var responce = jsonDecode(resp.body);

                        searchResults = [];
                        for (var item in responce) {
                          searchResults.add(
                            Container(
                              child: TextButton(
                                child: Text(
                                  item["name"],
                                  style: const TextStyle(
                                    fontFamily: "Pro",
                                    fontSize: 12,
                                  ),
                                ),
                                onPressed: () {
                                  setState(() {
                                    var schedule = item["schedule"];
                                    if (schedule is String) {
                                      schedule = jsonDecode(schedule);
                                    }

                                    widget.bridge.value.add(
                                      SelectedActivity(
                                        name: item["name"],
                                        address:
                                            item["address"] ?? "нет адреса",
                                        schedule: schedule ?? {},
                                        bridge: widget.bridge,
                                        parent: this,
                                        p: item,
                                      ),
                                    );
                                  });
                                },
                              ),
                            ),
                          );
                          setState(() {});
                        }
                      } catch (e) {
                        //
                      }
                    }
                  },
                );
              } else {
                searchResults = [];
                setState(() {});
              }
            },
            // icon: const SizedBox(height: 1),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
          ),

          // Search results
          ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: 306,
              maxWidth: 307,
              minHeight: 120,
              maxHeight: 200,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFFFF),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
                border: Border.all(color: const Color(0xFF000000)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: searchResults,
                ),
              ),
            ),
          ),

          // Selected
          ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: 306,
              maxWidth: 307,
              minHeight: 120,
              maxHeight: 200,
            ),
            child: Container(
              // width: 307,
              // height: 200,
              margin: const EdgeInsets.only(top: 5),
              padding: const EdgeInsets.symmetric(
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFFFF),
                border: Border.all(color: const Color(0xFF000000)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: widget.bridge.value,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SelectedActivity extends StatefulWidget {
  const SelectedActivity({
    super.key,
    required this.name,
    required this.address,
    required this.schedule,
    required this.bridge,
    required this.parent,
    required this.p,
  });

  final String name;
  final String address;
  final Map<String, dynamic> schedule;
  final ListBridge bridge;
  final State parent;
  final Map<String, dynamic> p;

  Map<String, dynamic> toJson() {
    return p;
  }

  @override
  State<SelectedActivity> createState() => _SelectedActivityState();
}

class _SelectedActivityState extends State<SelectedActivity> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: TextButton(
        child: Text(widget.name),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Подробности"),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.schedule != {}
                    ? [
                        Text("Адрес: ${widget.address}"),
                        const Text("Время работы: ",
                            style: TextStyle(fontWeight: FontWeight.w600)),
                        // TODO: add working hours (on ss)
                        // Text(
                        //     "Понедельник - с ${widget.schedule["Mon"]["from"]} по ${widget.schedule["Mon"]["working_hours"][0]["to"]}"),
                        // Text(
                        //     "Вторник - с ${widget.schedule["Tue"]["from"]} по ${widget.schedule["Tue"]["working_hours"][0]["to"]}"),
                        // Text(
                        //     "Среда - с ${widget.schedule["Wed"]["from"]} по ${widget.schedule["Wed"]["working_hours"][0]["to"]}"),
                        // Text(
                        //     "Четверг - с ${widget.schedule["Thu"]["from"]} по ${widget.schedule["Thu"]["working_hours"][0]["to"]}"),
                        // Text(
                        //     "Пятница - с ${widget.schedule["Fri"]["from"]} по ${widget.schedule["Fri"]["working_hours"][0]["to"]}"),
                        // Text(
                        //     "Суббота - с ${widget.schedule["Sat"]["from"]} по ${widget.schedule["Sat"]["working_hours"][0]["to"]}"),
                        // Text(
                        //     "Воскресенье - с ${widget.schedule["Sun"]["from"]} по ${widget.schedule["Sun"]["working_hours"][0]["to"]}"),
                      ]
                    : [
                        Text("Адрес: ${widget.address}"),
                      ],
              ),
              actions: [
                TextButton(
                  child: const Text("Закрыть"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text("Удалить активность"),
                  onPressed: () {
                    widget.bridge.value.remove(widget);
                    widget.parent.setState(() {});
                    Navigator.of(context).pop();
                  },
                )
              ],
            ),
          );
          setState(() {});
        },
      ),
    );
  }
}

// ! TRAVEL BLOCKS

class TravelBlock extends StatefulWidget {
  const TravelBlock({
    super.key,
    required this.id,
    required this.travelName,
    required this.town,
    required this.fromDate,
    required this.toDate,
    required this.moneys,
    required this.activities,
  });

  final int id;
  final String travelName;
  final String town;
  final String fromDate;
  final String toDate;
  final String moneys;
  final List activities;

  @override
  State<TravelBlock> createState() => _TravelBlockState();
}

class _TravelBlockState extends State<TravelBlock> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 291,
      decoration: BoxDecoration(
        color: const Color(0xFF323232),
        boxShadow: const [
          BoxShadow(
            color: Color(
              0xBB000000,
            ),
            offset: Offset(
              0,
              4,
            ),
            blurRadius: 4,
            spreadRadius: 0,
          ),
        ],
        borderRadius: BorderRadius.circular(20),
      ),
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 13, left: 14),
            alignment: Alignment.topLeft,
            child: Text(
              widget.travelName,
              textAlign: TextAlign.left,
              style: const TextStyle(
                fontFamily: "Pro",
                color: Color(0xFFFFFFFF),
                fontSize: 14,
                fontWeight: FontWeight.w400,
                letterSpacing: -0.2,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 13, left: 12, bottom: 41),
            alignment: Alignment.topLeft,
            child: Text(
              "В ${widget.town}",
              textAlign: TextAlign.left,
              style: const TextStyle(
                fontFamily: "Pro",
                color: Color(0xFFFFFFFF),
                fontSize: 12,
                fontWeight: FontWeight.w400,
                letterSpacing: -0.2,
              ),
            ),
          ),
          TextButton(
            style: ButtonStyle(
              shape: MaterialStateProperty.all<OutlinedBorder>(
                const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                  side: BorderSide(
                    color: Color(0xFFFFFFFF),
                  ),
                ),
              ),
              padding: MaterialStateProperty.all<EdgeInsets>(
                const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 15,
                ),
              ),
            ),
            child: const Text(
              "Просмотр и редактирование",
              style: TextStyle(
                fontFamily: "Pro",
                color: Color(0xFFFFFFFF),
                fontSize: 12,
                fontWeight: FontWeight.w400,
                letterSpacing: -0.2,
              ),
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ViewTravel(
                    travelId: widget.id,
                  ),
                ),
              );
            },
          ),
          const SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }
}

// ! Date picker
class DatePicker extends StatefulWidget {
  DatePicker({
    super.key,
    required this.bridge,
    required this.text,
    required this.message,
    required this.starttime,
  });

  final DateBridge bridge;
  final DateBridge starttime;
  final String text;
  final String message;

  final DateFormat format = DateFormat("d/M/y");

  @override
  State<DatePicker> createState() => _DatePickerState();
}

class _DatePickerState extends State<DatePicker> {
  bool initial = true;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 307,
          height: 48,
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color(0xFF000000),
            ),
            color: const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(
              10,
            ),
          ),
          child: TextButton(
            onPressed: () {
              FocusScopeNode focus = FocusScope.of(context);
              if (focus.hasFocus || focus.hasPrimaryFocus) {
                focus.unfocus();
              }
              showDatePicker(
                context: context,
                initialDate: widget.bridge.value.millisecondsSinceEpoch >
                        widget.starttime.value.millisecondsSinceEpoch
                    ? widget.bridge.value
                    : widget.starttime.value,
                firstDate: widget.starttime.value,
                lastDate: DateTime(2100),
              ).then(
                (value) => {
                  setState(
                    () {
                      if (value != null) {
                        widget.bridge.value = value;
                        initial = false;
                        widget.bridge.changed = true;
                      }
                    },
                  ),
                },
              );
            },
            child: Text(
              initial
                  ? widget.text
                  : "${widget.message}: ${widget.format.format(widget.bridge.value)}",
              style: TextStyle(
                color: myColors["gray"],
                fontSize: 14,
                fontFamily: "Pro",
              ),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(
            top: 11,
            left: 10,
          ),
          child: SvgPicture.asset(
            "assets/images/svg/calendar.svg",
            width: 28,
            height: 28,
            fit: BoxFit.scaleDown,
            color: myColors["gray"],
          ),
        )
      ],
    );
  }
}

//! Town Hints
class TownHints extends StatefulWidget {
  TownHints({super.key, required this.controller, required this.onSelected});

  final TextEditingController controller;
  final void Function() onSelected;

  String prevText = "";
  List<Widget> towns = [];
  String curtown = "";
  bool responcing = false;

  void update(String request) {
    if (request.length > 1 && !responcing) {
      responcing = true;

      get(
        Uri.https(
          'api.vk.com',
          '/method/database.getCities',
          {
            "access_token": vkapiKey,
            "q": request,
            "need_all": '0',
            "v": "5.154",
            "country_id": "1",
          },
        ),
      ).then(
        (resp) {
          if (resp.statusCode == 200) {
            var resp_ = jsonDecode(resp.body);
            mystate.setState(
              () {
                towns = [
                  const SizedBox(
                    height: 5,
                  ),
                ];
              },
            );

            for (var place in resp_["response"]["items"]) {
              try {
                Translit tr = Translit();
                String town = tr.unTranslit(
                  source: place["title"],
                );

                String reg;
                try {
                  reg = tr.unTranslit(
                    source: place["region"],
                  );
                } catch (e) {
                  try {
                    reg = tr.unTranslit(
                      source: place["country"],
                    );
                  } catch (e) {
                    reg = "";
                  }
                }

                town = town
                    .replaceAll(r"Мосцоw", "Москва")
                    .replaceAll(r"Саинт Петерсбург", "Санкт Петербург")
                    .replaceAll(r"кх", "х")
                    .replaceAll(r"Кх", "Х")
                    .replaceAll(r"тс", "ц")
                    .replaceAll(r"Тс", "Ц")
                    .replaceAll(r"бласт", "бласть")
                    .replaceAll(r"аы", "ай")
                    .replaceAll(r"кы", "кий")
                    .replaceAll(r"лск", "льск")
                    .replaceAll(r"ны", "ний")
                    .replaceAll(r"еы", "ей")
                    .replaceAll(r"сх", "ш");
                town = town[0].toUpperCase() + town.substring(1);

                reg = reg
                    .replaceAll(r"кх", "х")
                    .replaceAll(r"тс", "ц")
                    .replaceAll(r"бласт", "бласть")
                    .replaceAll(r"аы", "ай")
                    .replaceAll(r"лск", "льск")
                    .replaceAll(r"кы", "кий")
                    .replaceAll(r"сх", "ш");
                reg = reg[0].toUpperCase() + reg.substring(1);

                mystate.setState(
                  () {
                    towns.add(
                      Container(
                        width: MediaQueryData.fromView(
                              WidgetsBinding.instance.window,
                            ).size.width /
                            1.5,
                        margin: const EdgeInsets.only(
                          bottom: 5,
                        ),
                        child: TextButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                              Colors.white,
                            ),
                            shape: MaterialStateProperty.all<OutlinedBorder>(
                              const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                town,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontFamily: "Pro",
                                ),
                              ),
                              Text(
                                reg,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontFamily: "Pro",
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          onPressed: () {
                            curtown = "$reg, $town";
                            controller.text = "$town, $reg";
                            onSelected();
                          },
                        ),
                      ),
                    );
                  },
                );
              } catch (e) {
                //
              }
            }
          }

          responcing = false;
        },
      );
    } else {
      mystate.setState(
        () {
          towns = [];
        },
      );
    }

    prevText = request;
  }

  State<TownHints> mystate = TownHintsState();
  @override
  // ignore: no_logic_in_create_state
  State<TownHints> createState() => mystate;
}

class TownHintsState extends State<TownHints> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width / 1.35,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        color: Color(0xFF303030),
        borderRadius: BorderRadius.all(
          Radius.circular(10),
        ),
      ),
      height: MediaQuery.of(context).size.height - 130 - 200,
      child: Stack(
        children: [
          Container(
            alignment: Alignment.center,
            child: SingleChildScrollView(
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: widget.towns,
              ),
            ),
          ),
          Container(
            height: 20,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF303030),
                  Colors.transparent,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(
              top: MediaQuery.of(context).size.height - 165 - 200,
            ),
            height: 20,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Color(0xFF303030),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          )
        ],
      ),
    );
  }
}

// ! Info on main screen
class InfoBlock extends StatelessWidget {
  const InfoBlock({
    super.key,
    required this.title,
    required this.text,
    required this.color,
  });

  final String title;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 30),
      padding: const EdgeInsets.only(left: 20, top: 10),
      width: 320,
      height: 150,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
              offset: Offset(3, 0), blurRadius: 6, color: Color(0xFF232323)),
          BoxShadow(
              offset: Offset(0, -3), blurRadius: 6, color: Color(0xFF232323)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            textAlign: TextAlign.left,
            style: const TextStyle(
              color: Color(0xFFFFFFFF),
              fontWeight: FontWeight.w900,
              fontSize: 21.5,
              fontFamily: "Pro",
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            text,
            textAlign: TextAlign.left,
            style: const TextStyle(
              color: Color(0xFFFFFFFF),
              fontWeight: FontWeight.w600,
              fontSize: 13.5,
              wordSpacing: -1,
              letterSpacing: -0.23,
              height: 1.1,
              fontFamily: "Pro",
            ),
          ),
        ],
      ),
    );
  }
}

class Info extends StatefulWidget {
  const Info({super.key});

  State<Info> createState() => _InfoState();
}

class _InfoState extends State<Info> {
  int screen = 0;
  bool animated = false;

  ScrollController controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    controller.addListener(() {
      var curscreenoffset = (MediaQuery.of(context).size.width) * (screen - 1);
      var offs = curscreenoffset - controller.offset;

      if (!animated) {
        animated = true;
        if (offs > 1) {
          screen--;
          controller.animateTo(
            MediaQuery.of(context).size.width * (screen - 1),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        } else if (offs < -1) {
          screen++;
          controller.animateTo(
            MediaQuery.of(context).size.width * (screen - 1),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }

        Future.delayed(const Duration(milliseconds: 600), () {
          animated = false;
        });
      }
    });
    return Container(
      width: MediaQuery.of(context).size.width,
      child: SingleChildScrollView(
        controller: controller,
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            // Margin
            SizedBox(
              width: (MediaQuery.of(context).size.width - 320) / 2,
            ),
            // Купить подпику
            const InfoBlock(
              title: "Купить подписку",
              text:
                  "Купите подписку и пользуйтесь\nвсеми возможностями\nTravel Manager",
              color: Color(
                0xFF97C65B,
              ),
            ),

            // Margin
            SizedBox(
              width: (MediaQuery.of(context).size.width - 320),
            ),

            // Подсказка
            const InfoBlock(
              title: "Подсказка",
              text:
                  "Вы всегда можете изменить\nсвои предпочтения в активностях на\nвкладке Настройки",
              color: Color(
                0xFFCFC357,
              ),
            ),

            // Margin
            SizedBox(
              width: (MediaQuery.of(context).size.width - 320),
            ),

            // Подсказка
            const InfoBlock(
              title: "Нашли ошибку?",
              text:
                  "Напишите нам в тех. поддержку,\nмы обязательно исправим недочет",
              color: Color(
                0xFFC6A15B,
              ),
            ),

            // Margin
            SizedBox(
              width: (MediaQuery.of(context).size.width - 320) / 2,
            ),
          ],
        ),
      ),
    );
  }
}

// ! Travel Scroll
class TravelScroll extends StatefulWidget {
  const TravelScroll(
      {super.key, required this.children, required this.itemCount});

  final List<Widget> children;
  final int itemCount;

  @override
  State<StatefulWidget> createState() => _TravelScrollState();
}

class _TravelScrollState extends State<TravelScroll> {
  int screen = 1;
  bool animated = false;

  ScrollController controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    controller.addListener(() {
      var curscreenoffset = (MediaQuery.of(context).size.width) * (screen - 1);
      var offs = curscreenoffset - controller.offset;

      if (!animated) {
        animated = true;
        if (offs > 1) {
          screen--;
          controller.animateTo(
            MediaQuery.of(context).size.width * (screen - 1),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        } else if (offs < -1) {
          screen++;
          controller.animateTo(
            MediaQuery.of(context).size.width * (screen - 1),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }

        Future.delayed(const Duration(milliseconds: 600), () {
          animated = false;
        });
      }
    });
    return Stack(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            controller: controller,
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.antiAlias,
            child: Row(
              children: widget.children,
            ),
          ),
        ),
        widget.itemCount > 1
            ? Container(
                margin: const EdgeInsets.only(
                  top: 60,
                ),
                alignment: Alignment.centerLeft,
                child: TextButton(
                  style:
                      const ButtonStyle(splashFactory: NoSplash.splashFactory),
                  child: const Text("<",
                      style: TextStyle(color: Color(0xFFFFFFFF))),
                  onPressed: () {
                    if (!animated) {
                      if (screen > 1) {
                        animated = true;
                        screen--;

                        controller.animateTo(
                          MediaQuery.of(context).size.width * (screen - 1),
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );

                        Future.delayed(const Duration(milliseconds: 600), () {
                          animated = false;
                        });
                      }
                    }
                  },
                ),
              )
            : Container(),
        widget.itemCount > 1
            ? Container(
                margin: const EdgeInsets.only(
                  top: 60,
                ),
                alignment: Alignment.centerRight,
                child: TextButton(
                  style:
                      const ButtonStyle(splashFactory: NoSplash.splashFactory),
                  child: const Text(">",
                      style: TextStyle(color: Color(0xFFFFFFFF))),
                  onPressed: () {
                    if (!animated) {
                      if (screen < widget.itemCount) {
                        animated = true;

                        screen++;
                        controller.animateTo(
                          MediaQuery.of(context).size.width * (screen - 1),
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );

                        Future.delayed(const Duration(milliseconds: 600), () {
                          animated = false;
                        });
                      }
                    }
                  },
                ),
              )
            : Container(),
      ],
    );
  }
}

// ! Page fade
FadeTransition trans(dynamic _, dynamic a, dynamic __, dynamic c) {
  return FadeTransition(opacity: a, child: c);
}

// ! Peoples count
class PeoplesCountInput extends StatefulWidget {
  const PeoplesCountInput({super.key, required this.bridge});

  final Bridge<Map> bridge;

  @override
  State<StatefulWidget> createState() => _PeoplesCountInputState();
}

class _PeoplesCountInputState extends State<PeoplesCountInput> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 307,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        border: Border.all(
          color: const Color(0xFF000000),
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          const Text(
            "Количество человек",
            style: TextStyle(fontFamily: "Pro", fontSize: 14),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                child: const Text(
                  "-",
                  style: TextStyle(
                    fontSize: 22.5,
                    fontFamily: "Pro",
                    color: Color(0xFF000000),
                  ),
                ),
                onPressed: () {
                  setState(
                    () {
                      if (widget.bridge.value["parents"] > 0) {
                        widget.bridge.value["parents"]--;
                      }
                    },
                  );
                },
              ),
              Text(
                "Взрослые: ${widget.bridge.value["parents"]}",
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: "Pro",
                  color: Color(0xFF000000),
                ),
              ),
              TextButton(
                child: const Text(
                  "+",
                  style: TextStyle(
                    fontSize: 22,
                    fontFamily: "Pro",
                    color: Color(0xFF000000),
                  ),
                ),
                onPressed: () {
                  setState(
                    () {
                      widget.bridge.value["parents"]++;
                    },
                  );
                },
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                child: const Text(
                  "-",
                  style: TextStyle(
                    fontSize: 22,
                    fontFamily: "Pro",
                    color: Color(0xFF000000),
                  ),
                ),
                onPressed: () {
                  setState(
                    () {
                      if (widget.bridge.value["children"] > 0) {
                        widget.bridge.value["children"]--;
                      }
                    },
                  );
                },
              ),
              Text(
                "Дети: ${widget.bridge.value["children"]}",
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: "Pro",
                  color: Color(0xFF000000),
                ),
              ),
              TextButton(
                child: const Text(
                  "+",
                  style: TextStyle(
                    fontSize: 22.5,
                    fontFamily: "Pro",
                    color: Color(0xFF000000),
                  ),
                ),
                onPressed: () {
                  setState(
                    () {
                      widget.bridge.value["children"]++;
                    },
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CheckboxNew extends StatefulWidget {
  const CheckboxNew(
      {super.key, required this.onChanged, this.default_ = false});
  final void Function(bool?) onChanged;
  final bool default_;
  @override
  State<StatefulWidget> createState() => _CheckboxNewState();
}

class _CheckboxNewState extends State<CheckboxNew> {
  var color = const Color(0xFFFFFFFF);
  var value = false;

  @override
  void initState() {
    super.initState();

    setState(() {
      value = widget.default_;
      color = value ? const Color(0xFF000000) : const Color(0xFFFFFFFF);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Checkbox(
      splashRadius: 0,
      value: value,
      fillColor: MaterialStateProperty.all<Color>(
        color,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
        side: const BorderSide(
          color: Color(0xFF000000),
        ),
      ),
      side: const BorderSide(
        color: Color(0xFF000000),
      ),
      onChanged: (v) {
        setState(
          () {
            widget.onChanged(v);

            color = v! ? const Color(0xFF000000) : const Color(0xFFFFFFFF);
            value = v;
          },
        );
      },
    );
  }
}

// Small input (for time or day)
class SmallInput extends StatefulWidget {
  const SmallInput({
    super.key,
    required this.controller,
    required this.placeholder,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String placeholder;
  final Function(String) onChanged;

  @override
  State<StatefulWidget> createState() => _SmallInputState();
}

class _SmallInputState extends State<SmallInput> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 53,
      height: 16,
      alignment: Alignment.center,
      child: TextField(
        controller: widget.controller,
        onChanged: widget.onChanged,
        style: const TextStyle(
          fontFamily: "Pro",
          fontSize: 10,
        ),
        decoration: InputDecoration(
          hintText: widget.placeholder,
          hintStyle: const TextStyle(
            fontFamily: "Pro",
            fontSize: 10,
            fontWeight: FontWeight.w300,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: const BorderSide(
              color: Color(0xFF000000),
            ),
          ),
          contentPadding: EdgeInsets.zero,
        ),
        textAlign: TextAlign.center,
        textAlignVertical: TextAlignVertical.center,
        keyboardType: TextInputType.datetime,
        maxLines: 1,
        showCursor: false,
      ),
    );
  }
}