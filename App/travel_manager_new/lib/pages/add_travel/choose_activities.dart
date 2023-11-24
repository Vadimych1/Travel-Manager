// Выбор активностей
// Бюджет
// Выбор города
import 'package:flutter/material.dart';
import "package:travel_manager_new/uikit/uikit.dart";
import "package:flutter_svg/flutter_svg.dart";
import "summary.dart";
// import 'package:address_search_field/address_search_field.dart';

class CreateTravelChooseActivities extends StatefulWidget {
  const CreateTravelChooseActivities({
    super.key,
    required this.params,
  });

  final Map params;

  @override
  State<CreateTravelChooseActivities> createState() =>
      _CreateTravelChooseActivitiesState();
}

class _CreateTravelChooseActivitiesState
    extends State<CreateTravelChooseActivities> {
  String prev = "";

  ListBridge<SelectedActivity> actBridge = ListBridge<SelectedActivity>(
    value: [],
  );
  Activities activs = Activities(
    town: "",
    bridge: ListBridge(
      value: [],
    ),
  );

  @override
  void initState() {
    super.initState();
    activs = Activities(town: widget.params["town"], bridge: actBridge);
  }

  @override
  Widget build(BuildContext context) {
    // print(widget.params);
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

          // Back button
          Container(
            margin: const EdgeInsets.only(
              top: 57,
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

          // FG
          SingleChildScrollView(
            child: Column(
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
                    "Выбор активностей",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFFDCDCDC),
                    ),
                  ),
                ),

                Container(
                  margin: const EdgeInsets.only(top: 20),
                  child: activs,
                ),

                ConstrainedBox(
                  constraints:
                      const BoxConstraints(maxHeight: 1000, maxWidth: 400),
                  // child: Expanded(
                  //   child: Container(),
                  // ),
                ),

                Container(
                  margin: const EdgeInsets.only(bottom: 40, top: 10),
                  child: BlackButton(
                    text: "Далее",
                    onPressed: () {
                      var pr = widget.params;

                      pr["activities"] = activs.toJson();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => CreateTravelSummary(
                            params: pr,
                          ),
                        ),
                      );
                    },
                    color: myColors['blue1'],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
