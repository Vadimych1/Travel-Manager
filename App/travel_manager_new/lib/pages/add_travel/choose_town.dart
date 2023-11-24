// Выбор города
import 'package:flutter/material.dart';
import "package:travel_manager_new/uikit/uikit.dart";
import "package:flutter_svg/flutter_svg.dart";
import "your_budget.dart";
// import 'package:address_search_field/address_search_field.dart';

class CreateTravelChooseTown extends StatefulWidget {
  const CreateTravelChooseTown({
    super.key,
    required this.params,
  });

  final Map params;

  @override
  State<CreateTravelChooseTown> createState() => _CreateTravelChooseTownState();
}

class _CreateTravelChooseTownState extends State<CreateTravelChooseTown> {
  final TextEditingController townc = TextEditingController();
  late TownHints townhint;
  @override
  void initState() {
    super.initState();
    townhint = TownHints(controller: townc);
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
              // print("AAA");
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
            // color: Colors.red,
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
          Column(
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
                  "Выбор города",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFFDCDCDC),
                  ),
                ),
              ),

              // Inputs
              Container(
                margin: const EdgeInsets.only(top: 40),
                child: Input(
                  placeholder: "название города",
                  onChanged: (s) {
                    townhint.update(s);
                    // townhint.
                  },
                  controller: townc,
                ),
              ),

              Container(
                child: townhint,
              ),

              Container(
                margin: const EdgeInsets.only(bottom: 40, top: 10),
                child: BlackButton(
                  text: "Далее",
                  onPressed: () {
                    var params = widget.params;
                    params["town"] = townhint.curtown;
                    // print(widget.params);
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder: (context, _, __) => CreateTravelBudget(
                          params: params,
                        ),
                        transitionsBuilder: trans,
                        transitionDuration: const Duration(milliseconds: 200),
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
