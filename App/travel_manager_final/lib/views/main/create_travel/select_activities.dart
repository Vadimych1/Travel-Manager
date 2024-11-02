import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:travel_manager_final/main.dart';
import 'package:travel_manager_final/model/datatypes.dart';
import 'package:travel_manager_final/views/widgets/interactive.dart';

// activity type colors
const _actTypeColors = {
  ActivityType.entertainment: Color(0xFF659581),
  ActivityType.food: Color.fromARGB(255, 149, 128, 101),
  ActivityType.attraction: Color.fromARGB(255, 115, 101, 149),
  ActivityType.event: Color.fromARGB(255, 120, 149, 101),
  ActivityType.shop: Color.fromARGB(255, 149, 101, 101),
  ActivityType.new_: Color.fromARGB(255, 139, 101, 149),
};
// activity type icons // TODO
// const _actTypeIcons = {
//   ActivityType.entertainment: "assets/acticons/entertainment.svg",
//   ActivityType.food: "assets/acticons/food.svg",
//   ActivityType.attraction: "assets/acticons/attraction.svg",
//   ActivityType.event: "assets/acticons/event.svg",
//   ActivityType.shop: "assets/acticons/shop.svg",
//   ActivityType.new_: "assets/acticons/new.svg",
// };

class _ActivityBlock extends StatefulWidget {
  const _ActivityBlock({
    required this.activity,
    required this.currentActive,
    required this.setSelected,
    required this.add,
    required this.remove,
    required this.activeList,
    required this.index,
  });

  final int index;
  final Activity activity;
  final SelectActivityAnimateCall currentActive;
  final SelectActivityAnimateCall setSelected;
  final List<int> activeList;

  final void Function(int, int) add;
  final void Function(int, int) remove;

  @override
  State<_ActivityBlock> createState() => _ActivityBlockState();
}

class _ActivityBlockState extends State<_ActivityBlock>
    with TickerProviderStateMixin {
  final double nameSizePercent =
      0.63; // size of block where texts displayed in each activity in percents of screen size
  bool curOpened = false; // is menu currently opened?

  final double maxHeight = 60; // max menu height

  AnimationController? heightController;
  AnimationController? opacityController;

  Animation<double>? heightAnimation;
  Animation<double>? opacityAnimation;

  Tween<double>? heightTween;
  Tween<double>? opacityTween;

  bool selected = false; // determines how Add to plan button works
  void setSelected(bool s) {
    setState(() {
      selected = s;
    });
  }

  @override
  void initState() {
    super.initState();
    if (kDebugMode) print("Initializing state for ${widget.activity.name}");

    // provide a call function to main widget
    widget.currentActive.call = animate;

    // provide a call function to main widget
    widget.setSelected.call = setSelected;

    if (widget.activeList.contains(widget.activity.id)) {
      selected = true;
    }

    heightController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    opacityController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    heightTween = Tween<double>(begin: 0, end: maxHeight);
    opacityTween = Tween<double>(begin: 0, end: 1);

    heightAnimation = heightTween!.animate(
      CurvedAnimation(parent: heightController!, curve: Curves.easeInOut),
    );

    opacityAnimation = opacityTween!.animate(
      CurvedAnimation(parent: opacityController!, curve: Curves.easeInOut),
    );

    heightAnimation!.addListener(() {
      setState(() {
        print(widget.activity.name);
        print(heightAnimation!.value);
      });
    });

    opacityAnimation!.addListener(() {
      setState(() {});
    });

    // Done to prevent values of opacity and width smaller than 0
    assert(maxHeight > 10);
  }

  void animate(bool open) {
    if (curOpened == open) return;
    if (open) curOpened = open;

    if (open) {
      print("Open animation");
      heightController!.forward();
      opacityController!.forward();
    } else {
      print("Close animation");
      heightController!.reverse();
      opacityController!.reverse();
    }

    Future.delayed(const Duration(milliseconds: 1200), () {
      setState(() {
        curOpened = open;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 10, bottom: 0, left: 10, right: 6),
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFFFFFF),
            _actTypeColors[widget.activity.type] ?? Colors.orange,
          ],
        ),
      ),
      width: MediaQuery.of(context).size.width - 40,
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: (MediaQuery.of(context).size.width - 40) *
                        nameSizePercent,
                    child: Text(
                      widget.activity.name,
                      style: const TextStyle(
                        color: Color(0xFF000000),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  widget.activity.description.isNotEmpty
                      ? SizedBox(
                          width: (MediaQuery.of(context).size.width - 40) *
                              nameSizePercent,
                          child: Text(
                            widget.activity.description.length > 100
                                ? "${widget.activity.description.substring(97)}..."
                                : widget.activity.description,
                            style: const TextStyle(color: Color(0xFF222222)),
                          ),
                        )
                      : Container(),
                  const SizedBox(
                    height: 10,
                  ),
                ],
              ),
              Container(
                width: 45,
                height: 45,
                color: const Color(0x33FF0000),
                child: const Center(
                  child: Text("icon"),
                ), // TODO: ICONS (fix by designer)
              ),
              const Spacer(),
              Container(
                // color: Colors.blue,
                margin: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "4.5",
                      style: TextStyle(
                        color: Color(0xFFFFFFFF),
                        fontSize: 14,
                      ),
                    ), // TODO: ADD RATE ! ! !

                    Container(
                      margin:
                          const EdgeInsets.only(bottom: 3, left: 4, right: 5),
                      child: SvgPicture.asset(
                        "assets/star.svg",
                        width: 15,
                        height: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Opens when curOpened
          if (curOpened)
            SizedBox(
              // opened box
              height: (heightAnimation?.value) ?? 0,
              child: Opacity(
                opacity: (opacityAnimation?.value) ?? 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () {
                        // TODO: see reviews and pics
                      },
                      style: ButtonStyle(
                        foregroundColor: WidgetStateProperty.all<Color>(
                          const Color(0xFF000000),
                        ),
                        textStyle: WidgetStateProperty.all(
                          const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            side: const BorderSide(
                              color: Color(0xFF000000),
                            ),
                          ),
                        ),
                      ),
                      child: const Text("Отзывы и картинки"),
                    ),
                    TextButton(
                      onPressed: () {
                        if (selected) {
                          widget.remove(widget.activity.id, widget.index);
                        } else {
                          widget.add(widget.activity.id, widget.index);
                        }
                      },
                      style: ButtonStyle(
                        foregroundColor: WidgetStateProperty.all<Color>(
                          const Color(0xFFFFFFFF),
                        ),
                        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        backgroundColor: WidgetStateProperty.all<Color>(
                          selected
                              ? const Color(0xFFACACAC)
                              : const Color(0xFF659581),
                        ),
                      ),
                      child: Text(
                        selected ? "Убрать из плана" : "Добавить в план",
                      ),
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

class CreateTravelSelectActivities extends StatefulWidget {
  const CreateTravelSelectActivities({super.key});

  @override
  State<CreateTravelSelectActivities> createState() =>
      CreateTravelSelectActivitiesState();
}

class CreateTravelSelectActivitiesState
    extends State<CreateTravelSelectActivities> {
  // VARIABLES
  final TextEditingController search =
      TextEditingController(); // search controller

  List<Widget> searchResult = []; // search result widgets
  List<SelectActivityAnimateCall> currentActiveCalls =
      []; // all search`s widgets animate function providers

  List<SelectActivityAnimateCall> pressedCalls =
      []; // all search`s widgets set active providers

  int currentActiveIndex = -1; // index of currently active widget (opened0)

  bool searchValid = false; // is search valid?
  bool loaded = false; // is search loaded?

  String town = ""; // town (initializes in iniState from prev screens)

  Map<int, Activity> allActivitiesWidgets = {}; // searched previously widgets
  List<int> selectedActivities = []; // selected as in-plan activities list

  // fix of non-initializing state
  bool needsRebuild = false;

  // open check activities window
  bool activityCheckWindowOpened = false;

  // FUNCTIONS
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 500), () {
      town = (ModalRoute.of(context)!.settings.arguments
          as Map<String, dynamic>)["town"];
    }).then((v) {
      _search("%");
      loaded = true;
    });
  }

  // apply search by category on category button click
  void category(String s, String type) {
    search.text = s;
    setState(() {});
  }

  // search by text
  void _search(String q) async {
    if (q.isEmpty) {
      searchResult = [];
      currentActiveCalls = [];
      currentActiveIndex = -1;
      searchValid = false;
    } else {
      var ss = await service.data.searchActivities(town, q);
      var data = ss.additionalData ?? [];

      currentActiveIndex = -1;
      currentActiveCalls = [];
      searchResult = [];

      for (var i = 0; i < data.length; i++) {
        currentActiveCalls.add(SelectActivityAnimateCall(call: null));
        pressedCalls.add(SelectActivityAnimateCall(call: null));

        allActivitiesWidgets[data[i].id] = data[i];

        searchResult.add(
          InkWell(
            splashFactory: NoSplash.splashFactory,
            onTap: () {
              if (currentActiveIndex == i) {
                currentActiveIndex = -1;
              } else {
                currentActiveIndex = i;
              }

              reanimate();
            },
            child: _ActivityBlock(
              index: i,
              activity: data[i],
              currentActive: currentActiveCalls[i],
              setSelected: pressedCalls[i],
              add: addActivity,
              remove: removeActivity,
              activeList: selectedActivities,
            ),
          ),
        );
      }

      searchValid = true;
      needsRebuild = true;
    }
    setState(() {});
  }

  // reanimate all opened or closed widgets
  void reanimate() {
    for (var call in currentActiveCalls) {
      if (call.call != null) {
        call.call!(false);
      }
    }

    if (currentActiveIndex == -1) return;

    if (currentActiveCalls[currentActiveIndex].call != null) {
      currentActiveCalls[currentActiveIndex].call!(true);
    }
  }

  // add activity to selected activity list
  void addActivity(int id, int index) {
    selectedActivities.add(id);
    pressedCalls[index].call!(true);
  }

  // remove activity from selected activity list
  void removeActivity(int id, int index) {
    selectedActivities.remove(id);
    pressedCalls[index].call!(false);
  }

  // BUILD
  @override
  Widget build(BuildContext context) {
    if (needsRebuild) {
      Future.delayed(
        const Duration(milliseconds: 100),
        () {
          setState(() {
            needsRebuild = false;
          });
        },
      );

      Future.delayed(const Duration(microseconds: 160), () {
        setState(() {});
      });
    }

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFF162125),
        appBar: AppBar(
          backgroundColor: const Color(0xFF162125),
          leading: const BackButton(
            color: Color(0xFFFFFFFF),
          ),
        ),
        body: Stack(
          children: [
            Column(
              children: [
                // Top search bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.81),
                      child: Input(
                        controller: search,
                        label: "",
                        placeholder: "Введите что-нибудь для начала",
                        validator: (s) {
                          return s.length > 1;
                        },
                        onChanged: _search,
                        onValidChanged: (b) {},
                        bgColor: const Color(0xFFFFFFFF),
                        borderRadius: 10.0,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        // TODO: Search
                      },
                      splashFactory: NoSplash.splashFactory,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFFFF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.all(11),
                        child: const Icon(Icons.search),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // Search results and reccommendations
                !loaded
                    ? const Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              color: Color(0xFFFFFFFF),
                            )
                          ],
                        ),
                      )
                    : searchValid
                        ? Expanded(
                            child: SingleChildScrollView(
                            child: Column(
                              children: searchResult.isNotEmpty
                                  ? searchResult
                                  : [
                                      const Text(
                                        "По вашему запросу ничего не найдено",
                                        style:
                                            TextStyle(color: Color(0xFFFFFFFF)),
                                      ),
                                    ],
                            ),
                          ))
                        : SingleChildScrollView(
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ActivitiesSelectPreset(
                                      onChanged: category,
                                      name: "Развлечения",
                                      icon: const Icon(
                                        Icons.gamepad_outlined,
                                        color: Colors.white,
                                        size: 40,
                                      ),
                                      callbackQuery: "развлечения",
                                      type: "entertainment",
                                    ),
                                    ActivitiesSelectPreset(
                                      onChanged: category,
                                      name: "Где перекусить",
                                      icon: const Icon(
                                        Icons.fastfood_outlined,
                                        color: Colors.white,
                                        size: 40,
                                      ),
                                      callbackQuery: "еда",
                                      type: "food",
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 15),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ActivitiesSelectPreset(
                                        onChanged: category,
                                        name: "Что посмотреть",
                                        icon: const Icon(
                                          Icons.museum,
                                          color: Colors.white,
                                          size: 40,
                                        ),
                                        callbackQuery: "достопримечательности",
                                        type: "attraction"),
                                    ActivitiesSelectPreset(
                                      onChanged: category,
                                      name: "Куда сходить",
                                      icon: const Icon(
                                        Icons.directions_walk_outlined,
                                        color: Colors.white,
                                        size: 40,
                                      ),
                                      callbackQuery: "события",
                                      type: "event",
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 15),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ActivitiesSelectPreset(
                                        onChanged: category,
                                        name: "Торговые центры",
                                        icon: const Icon(
                                          Icons.museum,
                                          color: Colors.white,
                                          size: 40,
                                        ),
                                        callbackQuery: "магазины",
                                        type: "shop"),
                                    ActivitiesSelectPreset(
                                      onChanged: category,
                                      name: "Новое",
                                      icon: const Icon(
                                        Icons.time_to_leave,
                                        color: Colors.white,
                                        size: 40,
                                      ),
                                      callbackQuery: "новое",
                                      type: "new",
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                // loaded ? const Spacer() : Container(),

                // Bottom menu
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          activityCheckWindowOpened = true;
                        });
                      },
                      style: ButtonStyle(
                        foregroundColor: WidgetStateProperty.all<Color>(
                          const Color(0xFFFFFFFF),
                        ),
                        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            side: const BorderSide(
                              color: Color(0xFFFFFFFF),
                            ),
                          ),
                        ),
                      ),
                      child: const Text("Просмотр плана"),
                    ),
                    TextButton(
                      onPressed: () {
                        // TODO: save plan
                      },
                      style: ButtonStyle(
                        foregroundColor: WidgetStateProperty.all<Color>(
                          const Color(0xFFFFFFFF),
                        ),
                        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        backgroundColor: WidgetStateProperty.all<Color>(
                          const Color(0xFF659581),
                        ),
                      ),
                      child: const Text("Завершить план"),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
            activityCheckWindowOpened
                ? Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: const BoxDecoration(
                      color: Color(0xFF162125),
                    ),
                    child: const Column(
                      children: [
                        Text("Ваш план"),
                        SingleChildScrollView(
                          child: Column(),
                        ),
                      ],
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}

class SelectActivityAnimateCall {
  SelectActivityAnimateCall({this.call});
  Function(bool)? call;
}
