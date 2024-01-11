// Выбор активностей
// Бюджет
// Выбор города
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
    // print(widget.params);
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
          Column(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: activs,
              ),
              ConstrainedBox(
                constraints:
                    const BoxConstraints(maxHeight: 1000, maxWidth: 400),
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
        ],
      ),
    );
  }
}
