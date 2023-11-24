// Бюджет
// Выбор города
import 'package:flutter/material.dart';
import "package:travel_manager_new/uikit/uikit.dart";
import "package:flutter_svg/flutter_svg.dart";
import "choose_activities.dart";
// import 'package:address_search_field/address_search_field.dart';

class CreateTravelBudget extends StatefulWidget {
  const CreateTravelBudget({
    super.key,
    required this.params,
  });

  final Map params;

  @override
  State<CreateTravelBudget> createState() => _CreateTravelBudgetState();
}

class _CreateTravelBudgetState extends State<CreateTravelBudget> {
  final TextEditingController budgetc = TextEditingController();
  String prev = "";

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
                  "Бюджет",
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
                  placeholder: "10 000 \u20BD",
                  onChanged: (s) {
                    try {
                      if (s.isNotEmpty) {
                        int.parse(s);
                      }
                      prev = s;
                    } catch (e) {
                      budgetc.value = TextEditingValue(
                        text: prev,
                      );
                    }
                  },
                  controller: budgetc,
                  // icon: SvgPicture.asset(
                  //   "assets/images/svg/money.svg",
                  //   width: 19,
                  //   height: 19,
                  //   color: myColors["gray"],
                  //   fit: BoxFit.scaleDown,
                  // ),
                ),
              ),

              // For what
              Container(
                margin: const EdgeInsets.only(top: 10),
                child: TextButton(
                  child: const Text(
                    "Для чего нам эта информация?",
                    style: TextStyle(
                      color: Color(0xFFCFCFCF),
                      letterSpacing: -0.2,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => const AlertDialog(
                        title: Text(
                          "Для чего нам эта информация?",
                          textAlign: TextAlign.center,
                        ),
                        content: Text(
                          "Нам нужно как можно больше\nданных о поездке, чтобы точнее\nподобрать для вас рекомендации",
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  },
                ),
              ),

              Expanded(
                child: Container(),
              ),

              Container(
                margin: const EdgeInsets.only(bottom: 40, top: 10),
                child: BlackButton(
                  text: "Далее",
                  onPressed: () {
                    if (budgetc.text.trim().isNotEmpty) {
                      var params = widget.params;
                      params["budget"] = budgetc.text;

                      Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder: (context, _, __) =>
                              CreateTravelChooseActivities(
                            params: params,
                          ),
                          transitionsBuilder: trans,
                          transitionDuration: const Duration(milliseconds: 200),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Введите ваш бюджет."),
                        ),
                      );
                    }
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
