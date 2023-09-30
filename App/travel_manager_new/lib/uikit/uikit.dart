import 'package:flutter/material.dart';
// import "package:flutter_svg/flutter_svg.dart";

// ! COLORS
Map myColors = {
  "green1": Color.fromRGBO(
    15,
    156,
    109,
    1,
  ),
  "blue1": Color.fromRGBO(
    13,
    143,
    171,
    1,
  ),
  "primaryText": Colors.white,
  "secondaryText": Color.fromRGBO(190, 190, 190, 1),
  "gray": Color.fromRGBO(
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
    this.color = const Color.fromRGBO(
      15,
      156,
      109,
      1,
    ),
  });

  final Function() onPressed;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62,
      width: 227,
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
          splashFactory: NoSplash.splashFactory,
          backgroundColor: MaterialStateProperty.all<Color>(
            Colors.transparent,
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w500,
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
      height: 62,
      width: 227,
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
          splashFactory: NoSplash.splashFactory,
          backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w500,
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
    this.inputType = TextInputType.text,
  });

  final String placeholder;
  final Function(String) onChanged;
  final TextEditingController controller;
  final TextInputType inputType;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 319,
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
        // color: const Color.fromARGB(
        //   255,
        //   246,
        //   246,
        //   246,
        // ),
        // color: Colors.black,
        borderRadius: BorderRadius.circular(
          10,
        ),
      ),
      child: TextField(
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 20,
          color: myColors["gray"],
        ),
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: placeholder,
          hintStyle: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 20,
            color: myColors["gray"],
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
  });

  final String text;
  final bool activated;
  final Function() onPressed;

  @override
  State<PreferencesItem> createState() => PreferencesItemState();
}

class PreferencesItemState extends State<PreferencesItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
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
        style: const ButtonStyle(
          splashFactory: NoSplash.splashFactory,
        ),
        onPressed: widget.onPressed,
        child: Text(
          widget.text,
          style: TextStyle(
            color: !widget.activated ? myColors["blue1"] : Colors.white,
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
                text: "Театры",
                activated: preferences["teatry"]!,
                onPressed: () {
                  setState(
                    () => preferences["teatry"] = !preferences["teatry"]!,
                  );
                },
              ),
              PreferencesItem(
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
                text: "Концерты",
                activated: preferences["koncerty"]!,
                onPressed: () {
                  setState(
                    () => preferences["koncerty"] = !preferences["koncerty"]!,
                  );
                },
              ),
              PreferencesItem(
                text: "Выставки",
                activated: preferences["vystavki"]!,
                onPressed: () {
                  setState(
                    () => preferences["vystavki"] = !preferences["vystavki"]!,
                  );
                },
              ),
              PreferencesItem(
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

// ! Activity blocks
class ActivityBlock extends StatefulWidget {
  ActivityBlock({
    super.key,
    required this.text,
    required this.enabled,
    required this.onPressed,
  });

  final bool enabled;
  final String text;
  final Function() onPressed;

  @override
  State<StatefulWidget> createState() => ActivityBlockState();
}

class ActivityBlockState extends State<ActivityBlock> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 305,
      height: 38,
      decoration: BoxDecoration(
        color: widget.enabled ? Colors.black : Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(
            Colors.transparent,
          ),
          splashFactory: NoSplash.splashFactory,
        ),
        child: Text(
          widget.text,
          style: TextStyle(
            color: widget.enabled ? Colors.white : Colors.black,
          ),
        ),
        onPressed: () {},
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

// ! ADAPTIVE

class Adaptive extends StatelessWidget {
  Adaptive({
    super.key,
    required this.child,
    required this.maxWidth,
    required this.maxHeight,
  });

  final Widget child;
  final double maxWidth;
  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      ),
      child: Expanded(
        child: child,
      ),
    );
  }
}
