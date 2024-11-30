// 14.05.2024 // main_data.dart // Create travel main data

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:travel_manager_final/views/widgets/interactive.dart';
import 'package:travel_manager_final/main.dart';

class CreateTravelMainData extends StatefulWidget {
  const CreateTravelMainData({super.key});

  @override
  State<CreateTravelMainData> createState() => CreateTravelMainDataState();
}

class CreateTravelMainDataState extends State<CreateTravelMainData> {
  TextEditingController titleC = TextEditingController();
  TextEditingController budgetC = TextEditingController();

  bool titleValid = false;
  bool budgetValid = false;

  DateTime? startDate;
  DateTime? endDate;

  bool restored = false;
  bool restoreDialogOpened = false;
  Map<String, dynamic>? lastActivity = {};

  void _saveLastActivity(Map<String, dynamic> data) {
    service.storage.saveLastActivity(data);
  }

  bool _checkInputsValid() {
    return titleValid && budgetValid && startDate != null && endDate != null;
  }

  bool _budgetValidator(String s) {
    return RegExp(r"[0-9]{3,}").hasMatch(s);
  }

  bool _nameValidator(String s) {
    return s.isNotEmpty;
  }

  void _restoreLogic(Map<String, dynamic>? state) {
    var stage = lastActivity?["stage"] ?? "unknown";

    switch (stage) {
      case "main_data":
        setState(() {
          titleC.text = lastActivity?["title"] ?? "";
          budgetC.text = lastActivity?["budget"] ?? "";

          startDate = DateTime.parse(
            lastActivity?["start_date"],
          );
          endDate = DateTime.parse(lastActivity?["end_date"]);

          titleValid = _nameValidator(titleC.text);
          budgetValid = _budgetValidator(budgetC.text);

          restoreDialogOpened = false;
        });
        break;

      case "town":
        setState(() {
          titleC.text = lastActivity?["title"] ?? "";
          budgetC.text = lastActivity?["budget"] ?? "";

          startDate = DateTime.parse(
            lastActivity?["start_date"],
          );
          endDate = DateTime.parse(lastActivity?["end_date"]);

          titleValid = _nameValidator(titleC.text);
          budgetValid = _budgetValidator(budgetC.text);

          restoreDialogOpened = false;

          Navigator.of(context).pushNamed(
            "/create/select_town",
            arguments: lastActivity,
          );
        });
        break;

      case "activities":
        print("Activities");
        break;

      case _:
        setState(() {
          restoreDialogOpened = false;
          service.storage.clearLastActivity();
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(milliseconds: 20), () async {
      lastActivity = await service.storage.restoreLastActivity();

      if (lastActivity != null && !restored) {
        restoreDialogOpened = true;
        setState(() {});
      }

      restored = true;
    });

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFF162125),
        appBar: AppBar(
          backgroundColor: const Color(0xFF162125),
          leading: const BackButton(
            color: Color(0xFFFFFFFF),
          ),
        ),
        body: restoreDialogOpened
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "Создание предыдущей поездки не было завершено",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                    textAlign: TextAlign.center,
                  ),

                  //
                  const Text(
                    "Продолжить?",
                    style: TextStyle(color: Colors.grey, fontSize: 18),
                    textAlign: TextAlign.center,
                  ),

                  //
                  const SizedBox(height: 20),

                  //
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Button(
                        text: "Начать заново",
                        onPressed: () {
                          service.storage.clearLastActivity();
                          setState(() {
                            restoreDialogOpened = false;
                          });
                        },
                        enabled: false, // small visual trick
                      ),
                      Button(
                        text: "Продолжить",
                        onPressed: () {
                          _restoreLogic(lastActivity);
                        },
                      ),
                    ],
                  ),
                ],
              )
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                        width: MediaQuery.of(context).size.width), // width fix
                    SvgPicture.asset("assets/create_travel_icon.svg"),

                    // Header
                    const SizedBox(height: 10),
                    const Text(
                      "Введите нужные данные",
                      style: TextStyle(
                        color: Color(0xFFFFFFFF),
                        fontSize: 20,
                      ),
                    ),
                    const Text(
                      "их можно будет изменить позже",
                      style: TextStyle(
                        color: Color(0xFF808A8C),
                        fontSize: 11,
                      ),
                    ),

                    const SizedBox(height: 30),

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Input(
                        initialValid: titleValid,
                        controller: titleC,
                        label: "Название",
                        placeholder: "Название поездки",
                        validator: _nameValidator,
                        onChanged: (v) {},
                        onValidChanged: (v) {
                          titleValid = v;
                          setState(() {});
                        },
                        labelColor: const Color(0xFFFFFFFF),
                        bgColor: const Color(0xFFFFFFFF),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Text label
                    Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: const Text(
                        "Даты",
                        style: TextStyle(
                          color: Color(0xFFFFFFFF),
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    // const SizedBox(height: 10),

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: DatePickerInput(
                        onChanged: (d) {
                          startDate = d;
                          setState(() {});
                        },
                        currentDate: startDate,
                        startDate: DateTime.now(),
                        text: "Дата начала",
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 13),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: DatePickerInput(
                        onChanged: (d) {
                          endDate = d;
                          setState(() {});
                        },
                        currentDate: endDate,
                        startDate: startDate ?? DateTime.now(),
                        canSelect: startDate != null,
                        text: "Дата окончания",
                      ),
                    ),

                    // TODO: peoples input (in design)

                    const SizedBox(height: 30),

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Input(
                        initialValid: budgetValid,
                        controller: budgetC,
                        label: "Бюджет",
                        placeholder: "Ваш бюджет (в рублях)",
                        validator: _budgetValidator,
                        onChanged: (v) {},
                        onValidChanged: (v) {
                          budgetValid = v;
                          setState(() {});
                        },
                        labelColor: const Color(0xFFFFFFFF),
                        bgColor: const Color(0xFFFFFFFF),
                      ),
                    ),

                    const SizedBox(height: 150),

                    Button(
                      onPressed: () {
                        final d = {
                          "stage": "main_data",
                          "title": titleC.text,
                          "budget": budgetC.text,
                          "start_date": startDate,
                          "end_date": endDate
                        };
                        _saveLastActivity(d);
                        Navigator.of(context).pushNamed(
                          "/create/select_town",
                          arguments: d,
                        );
                      },
                      text: "Далее",
                      enabled: _checkInputsValid(),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
