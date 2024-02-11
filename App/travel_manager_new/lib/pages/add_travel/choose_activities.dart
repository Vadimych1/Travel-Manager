// import "dart:convert";

import 'package:flutter/material.dart';
import "package:travel_manager_new/uikit/uikit.dart";
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
    return Scaffold(
      body: Stack(
        children: [
          // BG
          Container(
            color: const Color(0xFF3A3A3A),
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
            child: const BackButton(
              color: Color(0xFFFFFFFF),
            ),
          ),

          // FG
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: activs,
                ),
                ConstrainedBox(
                  constraints:
                      const BoxConstraints(maxHeight: 1000, maxWidth: 400),
                ),
              ],
            ),
          ),

          // Next and check buttons
          Positioned(
            bottom: 0,
            child: Container(
              width: MediaQuery.of(context).size.width,
              color: const Color(0xFF303030),
              child: Row(
                children: [
                  Container(
                    margin: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width / 2 - 140,
                    ),
                    width: 120,
                    child: TextButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                          Colors.black,
                        ),
                        shape: MaterialStateProperty.all<OutlinedBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            content: SingleChildScrollView(
                              child: Column(
                                children: actBridge.value.isNotEmpty
                                    ? actBridge.value
                                    : [
                                        const Text(
                                          "Ничего не выбрано",
                                        ),
                                      ],
                              ),
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        "Просмотреть",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  Container(
                    width: 120,
                    margin: const EdgeInsets.only(left: 40),
                    child: TextButton(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.white),
                        shape: MaterialStateProperty.all<OutlinedBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      child: const Text(
                        "Далее",
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
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
