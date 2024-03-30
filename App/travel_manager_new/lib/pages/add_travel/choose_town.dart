// Выбор города
import 'package:flutter/material.dart';
import 'package:travel_manager_new/pages/uikit/uikit.dart';
import "package:flutter_svg/flutter_svg.dart";
import "main_info.dart";

class CreateTravelChooseTown extends StatefulWidget {
  const CreateTravelChooseTown({
    super.key,
    required this.params,
  });

  final Map<String, dynamic> params;

  @override
  State<CreateTravelChooseTown> createState() => _CreateTravelChooseTownState();
}

class _CreateTravelChooseTownState extends State<CreateTravelChooseTown> {
  final TextEditingController townc = TextEditingController();
  late TownHints townhint;
  bool selected = false;

  @override
  void initState() {
    super.initState();
    townc.value = TextEditingValue(text: widget.params["preTown"]);
    townhint = TownHints(
      controller: townc,
      onSelected: () {
        selected = true;
      },
    );
    townhint.update(townc.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // BG
          Container(
            color: const Color(0xFF101010),
          ),

          // Header
          Container(
            width: MediaQuery.of(context).size.width,
            height: 124,
            decoration: const BoxDecoration(
              color: Color(0xFF303030),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(
                    top: 67,
                    left: 50,
                  ),
                  child: const Text(
                    "Выбор города",
                    style: TextStyle(
                      color: Color(0xFFFFFFFF),
                      fontSize: 20,
                    ),
                  ),
                ),
              ],
            ),
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
                // ignore: deprecated_member_use
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
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height - 120,
            margin: const EdgeInsets.only(top: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Inputs
                Container(
                  margin: const EdgeInsets.only(top: 40),
                  child: Input(
                    placeholder: "название города",
                    onChanged: (s) {
                      selected = false;
                      townhint.update(s);
                    },
                    controller: townc,
                  ),
                ),

                Container(
                  margin: const EdgeInsets.only(top: 10),
                  child: townhint,
                ),

                Container(
                  margin: const EdgeInsets.only(bottom: 15, top: 15),
                  child: BlackButton(
                    text: "Далее",
                    onPressed: () {
                      if (selected) {
                        var params = widget.params;
                        params["town"] = townhint.curtown;
                        // print(widget.params);
                        Navigator.of(context).push(
                          PageRouteBuilder(
                            pageBuilder: (context, _, __) =>
                                CreateTravelMainInfo(
                              params,
                            ),
                            transitionsBuilder: trans,
                            transitionDuration:
                                const Duration(milliseconds: 200),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Выберите город из списка"),
                          ),
                        );
                      }
                    },
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
