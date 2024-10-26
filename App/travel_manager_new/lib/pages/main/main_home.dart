import 'dart:convert';
import 'dart:ui';
import "package:flutter/material.dart";
import 'package:intl/intl.dart';
import 'package:travel_manager_new/pages/add_travel/choose_town.dart';
import 'package:travel_manager_new/pages/uikit/uikit.dart';
import 'package:flutter_svg/svg.dart';
import '../../main.dart';

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
  List<Widget> towns = [];

  bool ok = false;
  bool townsVisible = false;

  var ic = 0;
  var loaded = false;

  TextEditingController controller = TextEditingController();

  void rebuildAllChildren(BuildContext context) {
    void rebuild(Element el) {
      el.markNeedsBuild();
      el.visitChildren(rebuild);
    }

    (context as Element).visitChildren(rebuild);
  }

  @override
  Widget build(BuildContext context) {
    time = int.parse(formatHours.format(now));

    Future.delayed(Duration.zero, () async {
      name = await service.storage.read("name");

      var content = await service.data.getAllTravels();

      travels = [];

      travels.add(SizedBox(
        width: (MediaQuery.of(context).size.width - 291) / 2,
      ));

      ic = 0;
      for (var elem in content) {
        setState(
          () {
            ic++;
            travels.add(
              TravelBlock(
                id: int.parse(elem["id"]),
                travelName: elem["plan_name"],
                town: elem["town"],
                fromDate: elem["from_date"],
                toDate: elem["to_date"],
                moneys: elem["budget"],
                activities: elem["activities"].runtimeType == String
                    ? jsonDecode(elem["activities"])
                    : elem["activities"],
                onReturn: () {
                  // rebuild the widget
                  rebuildAllChildren(context);
                },
              ),
            );
            travels.add(SizedBox(
              width: MediaQuery.of(context).size.width - 291,
            ));
          },
        );
      }
    });

    setState(() {
      loaded = true;
    });

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

    return Scaffold(
      bottomNavigationBar: BottomAppBar(
        height: 65,
        elevation: 0,
        color: Colors.black,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            AppFooterButton(
              text: "Главная",
              icon: Icons.home,
              onPressed: () {},
            ),
            AppFooterButton(
              text: "Лента",
              icon: Icons.list,
              onPressed: () {
                // TODO: open feed
              },
            ),
            AppFooterButton(
              text: "Истории",
              icon: Icons.history,
              onPressed: () {
                // TODO: open history
              },
            ),
            AppFooterButton(
              text: "Настройки",
              icon: Icons.settings,
              onPressed: () {
                // TODO: open settings
              },
            ),
          ],
        ),
      ),
      backgroundColor: const Color(0xFF453E34),
      body: Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: 224,
            margin: EdgeInsets.zero,
            decoration: const BoxDecoration(
              boxShadow: [
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
              image: DecorationImage(
                image: AssetImage(
                  "assets/images/png/main_pages/bg1.jpg",
                ),
                fit: BoxFit.cover,
                filterQuality: FilterQuality.high,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 2,
                    sigmaY: 2,
                  ),
                  child: Container(
                    color: Colors.black.withOpacity(0.2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.only(
                            top: 55,
                            left:
                                23 * (370 / MediaQuery.of(context).size.width),
                          ),
                          child: Text(
                            "$texttime $name\nКуда отправимся?",
                            style: const TextStyle(
                              color: Color(0xFFFFFFFF),
                              fontSize: 26,
                              fontFamily: "Calibri",
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(
              top: 157,
              left: 23 * (370 / MediaQuery.of(context).size.width),
            ),
            child: Row(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    boxShadow: [
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
                      )
                    ],
                  ),
                  width: MediaQuery.of(context).size.width - 97,
                  height: 45,
                  child: TextField(
                    controller: controller,
                    style: const TextStyle(color: Color(0xffffffff)),
                    decoration: InputDecoration(
                      filled: true,
                      hintText: "начните ввод города...",
                      hintStyle: const TextStyle(
                        color: Color(
                          0xFFD5D5D5,
                        ),
                        fontWeight: FontWeight.w400,
                        fontFamily: "Pro",
                      ),
                      fillColor: const Color(0xFF4A4A4A),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.only(
                        top: 0,
                        left: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 7,
                ),
                Container(
                  width: 45,
                  height: 45,
                  decoration: const BoxDecoration(
                    boxShadow: [
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
                  ),
                  child: TextButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                        const Color(0xFF4A4A4A),
                      ),
                      shape: MaterialStateProperty.all<OutlinedBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    child: SvgPicture.asset(
                      "assets/images/svg/paper_plane.svg",
                    ),
                    onPressed: () {
                      if (controller.text.isNotEmpty) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => CreateTravelChooseTown(
                              params: {"preTown": controller.text},
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Нужно вписать хотя бы первый символ города",
                            ),
                          ),
                        );
                      }
                    },
                  ),
                )
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 224),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 15,
                  ),
                  Container(
                    alignment: Alignment.topLeft,
                    margin: const EdgeInsets.only(
                      left: 21,
                      bottom: 10,
                    ),
                    child: const Text(
                      "Ваши поездки",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.48,
                      ),
                    ),
                  ),
                  loaded
                      ? ic > 0
                          ? TravelScroll(
                              itemCount: ic,
                              children: travels,
                            )
                          : Container(
                              alignment: Alignment.center,
                              child: const Text(
                                "Пока что тут пусто",
                                style: TextStyle(
                                  color: Color(0xFFaaaaaa),
                                ),
                              ),
                            )
                      : const CircularProgressIndicator(
                          color: Color(
                            0xFFFFFFFF,
                          ),
                        ),
                  Container(
                    alignment: Alignment.topLeft,
                    margin: const EdgeInsets.only(
                      left: 21,
                      bottom: 10,
                      top: 20,
                    ),
                    child: const Text(
                      "Информация",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.48,
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: const Info(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
