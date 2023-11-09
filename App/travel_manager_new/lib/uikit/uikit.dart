import 'dart:convert';

import 'package:http/http.dart';
import 'package:translit/translit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import "package:flutter_svg/flutter_svg.dart";
import 'package:intl/intl.dart';
import 'package:flutter_svg/svg.dart';

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
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            offset: Offset.fromDirection(3.14 / 2, 2),
            blurRadius: 3,
          ),
        ],
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
            fontSize: 20,
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
            fontSize: 20,
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
    required this.icon,
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
  final Widget icon;
  final List<TextInputFormatter> inputFormatters;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    // print(inputFormatters);

    return Container(
      width: 320,
      height: 53,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Colors.grey,
            Color(0xFFf7f5ec),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 0.2],
          tileMode: TileMode.clamp,
        ),
        border: Border.all(
          color: const Color.fromARGB(
            255,
            246,
            246,
            246,
          ),
        ),
        borderRadius: borderRadius,
      ),
      child: TextField(
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
          fontFamily: "Pro",
          color: myColors["gray"],
        ),
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: placeholder,
          hintStyle: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color: myColors["gray"],
            fontFamily: "Pro",
          ),
          filled: true,
          focusColor: Colors.transparent,
          hoverColor: Colors.transparent,
          fillColor: Colors.transparent,
          enabled: true,
          enabledBorder: InputBorder.none,
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          prefixIcon: Container(
              margin: const EdgeInsets.only(
                top: 5,
              ),
              child: icon),
        ),
      ),
    );
  }
}

// ! Prefereces
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
    // print(MediaQuery.of(context).size.width);

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

class ListBridge {
  ListBridge({required this.value});
  List<Widget> value;
}

// ! Activity blocks
class Activities extends StatefulWidget {
  const Activities({
    super.key,
    required this.town,
  });

  final String town;

  @override
  State<Activities> createState() => _ActivitiesState();
}

class _ActivitiesState extends State<Activities> {
  final TextEditingController _controller = TextEditingController();
  List<Widget> searchResults = [];
  ListBridge bridge = ListBridge(value: []);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: 350,
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
                    "catalog.api.2gis.com",
                    '3.0/items',
                    {
                      'key': gisapiKey,
                      'q': s + " в " + widget.town,
                      "fields": "items.address,items.schedule",
                      "locale": "ru_RU",
                      // "type":
                      // "search_type": "branch",
                    },
                  ),
                ).then(
                  (resp) {
                    if (resp.statusCode == 200) {
                      try {
                        var responce = jsonDecode(resp.body);
                        // print(responce);

                        searchResults = [];
                        for (var item in responce["result"]["items"]) {
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
                                  print(item);
                                  bridge.value.add(
                                    SelectedActivity(
                                      name: item["name"],
                                      address: item["address_name"] == null
                                          ? "нет адреса"
                                          : item["address_name"],
                                      schedule: item["schedule"],
                                      bridge: bridge,
                                      parent: this,
                                    ),
                                  );
                                  setState(() {});
                                },
                              ),
                            ),
                          );
                          setState(() {});
                        }
                      } catch (e) {
                        print("err $e");
                      }
                    } else {
                      print("$resp.statusCode $resp.body");
                    }
                  },
                );
              } else {
                searchResults = [];
                setState(() {});
              }
            },
            icon: const SizedBox(height: 1),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
          ),

          // Search results
          Container(
            width: 320,
            height: 200,
            padding: const EdgeInsets.symmetric(
              vertical: 10,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFFf7f5ec),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                children: searchResults,
              ),
            ),
          ),

          // Selected
          Container(
            width: 320,
            height: 200,
            margin: const EdgeInsets.only(top: 5),
            padding: const EdgeInsets.symmetric(
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFf7f5ec),
              borderRadius: BorderRadius.circular(10),
            ),
            child: SingleChildScrollView(
              child: Column(
                children: bridge.value,
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
  });

  final String name;
  final String address;
  final Map<String, dynamic> schedule;
  final ListBridge bridge;
  final State parent;

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
                children: [
                  Text("Адрес: ${widget.address}"),
                  const Text("Время работы: ",
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  Text(
                      "Понедельник - с ${widget.schedule["Mon"]["working_hours"][0]["from"]} по ${widget.schedule["Mon"]["working_hours"][0]["to"]}"),
                  Text(
                      "Вторник - с ${widget.schedule["Tue"]["working_hours"][0]["from"]} по ${widget.schedule["Tue"]["working_hours"][0]["to"]}"),
                  Text(
                      "Среда - с ${widget.schedule["Wed"]["working_hours"][0]["from"]} по ${widget.schedule["Wed"]["working_hours"][0]["to"]}"),
                  Text(
                      "Четверг - с ${widget.schedule["Thu"]["working_hours"][0]["from"]} по ${widget.schedule["Thu"]["working_hours"][0]["to"]}"),
                  Text(
                      "Пятница - с ${widget.schedule["Fri"]["working_hours"][0]["from"]} по ${widget.schedule["Fri"]["working_hours"][0]["to"]}"),
                  Text(
                      "Суббота - с ${widget.schedule["Sat"]["working_hours"][0]["from"]} по ${widget.schedule["Sat"]["working_hours"][0]["to"]}"),
                  Text(
                      "Воскресенье - с ${widget.schedule["Sun"]["working_hours"][0]["from"]} по ${widget.schedule["Sun"]["working_hours"][0]["to"]}"),
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

class TravelBlock extends StatelessWidget {
  const TravelBlock({
    super.key,
    required this.travelName,
    required this.town,
    required this.date,
    required this.moneys,
    required this.score,
    required this.full,
  });

  final String travelName;
  final String town;
  final String date;
  final String moneys;
  final String score;

  final bool full;

  @override
  Widget build(BuildContext context) {
    return !full
        ? Container(
            width: 361,
            height: 67,
            decoration: BoxDecoration(
              color: const Color.fromRGBO(233, 233, 233, 1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  travelName,
                  style: const TextStyle(
                    fontFamily: "Pro",
                    color: Color.fromRGBO(
                      61,
                      61,
                      61,
                      1,
                    ),
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                  ),
                ),
                Text(
                  "$town, $date",
                  style: const TextStyle(
                    fontFamily: "Pro",
                    color: Color.fromRGBO(
                      112,
                      112,
                      112,
                      1,
                    ),
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )
        : Container(
            width: 361,
            height: 134,
            padding: const EdgeInsets.symmetric(
              horizontal: 19,
            ),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(233, 233, 233, 1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  travelName,
                  style: const TextStyle(
                    fontFamily: "Pro",
                    color: Color.fromRGBO(
                      61,
                      61,
                      61,
                      1,
                    ),
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      "$town, $date",
                      style: const TextStyle(
                        fontFamily: "Pro",
                        color: Color.fromRGBO(
                          112,
                          112,
                          112,
                          1,
                        ),
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      moneys,
                      style: const TextStyle(
                        fontFamily: "Pro",
                        color: Color.fromRGBO(
                          112,
                          112,
                          112,
                          1,
                        ),
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Text(
                  "$score баллов",
                  style: const TextStyle(
                    fontFamily: "Pro",
                    color: Color.fromRGBO(
                      61,
                      61,
                      61,
                      1,
                    ),
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                  ),
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
          width: 319,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Colors.grey,
                Color(0xFFf7f5ec),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.0, 0.2],
              tileMode: TileMode.clamp,
            ),
            border: Border.all(
              color: const Color.fromARGB(
                255,
                246,
                246,
                246,
              ),
            ),
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
  TownHints({super.key, required this.controller});

  final TextEditingController controller;

  String prevText = "";
  List<Widget> towns = [];
  String curtown = "";

  void update(String request) {
    if (request.length > 1) {
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
                  print("Catched error while getting region");

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
                    .replaceAll(r"лск", "льск");

                reg = reg
                    .replaceAll(r"кх", "х")
                    .replaceAll(r"тс", "ц")
                    .replaceAll(r"бласт", "бласть")
                    .replaceAll(r"аы", "ай")
                    .replaceAll(r"лск", "льск")
                    .replaceAll(r"кы", "кий");

                mystate.setState(
                  () {
                    towns.add(
                      Container(
                        margin: const EdgeInsets.only(
                          bottom: 3,
                        ),
                        child: TextButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                              Colors.white,
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
                            print("Pressed. $reg $town");
                            curtown = "$reg $town";

                            controller.text = "$town, $reg";
                          },
                        ),
                      ),
                    );
                  },
                );
              } catch (e) {
                print(e);
              }
            }
          }
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
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: widget.towns,
        ),
      ),
    );
  }
}

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
          BoxShadow(offset: Offset(3, 0), blurRadius: 6, color: Colors.grey),
          BoxShadow(offset: Offset(0, -3), blurRadius: 6, color: Colors.grey),
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
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: SingleChildScrollView(
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
              width: (MediaQuery.of(context).size.width - 320) / 2,
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
              width: (MediaQuery.of(context).size.width - 320) / 2,
            ),

            // Подсказка
            const InfoBlock(
              title: "Нашли ошибку?",
              text:
                  "Напишите нам в тех. поддержку,\nмы обязательно исправим недочет",
              color: Color(
                0xFFC6A15B,
              ),
            )
          ],
        ),
      ),
    );
  }
}

FadeTransition trans(dynamic _, dynamic a, dynamic __, dynamic c) {
  return FadeTransition(opacity: a, child: c);
}
