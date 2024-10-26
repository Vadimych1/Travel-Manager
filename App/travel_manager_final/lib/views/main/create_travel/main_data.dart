// 14.05.2024 // main_data.dart // Create travel main data

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:travel_manager_final/views/widgets/interactive.dart';

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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFF162125),
        appBar: AppBar(
          backgroundColor: const Color(0xFF162125),
          leading: const BackButton(
            color: Color(0xFFFFFFFF),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(width: MediaQuery.of(context).size.width), // width fix
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
                  controller: titleC,
                  label: "Название",
                  placeholder: "Название поездки",
                  validator: (s) {
                    return s.isNotEmpty;
                  },
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
                  controller: budgetC,
                  label: "Бюджет",
                  placeholder: "Ваш бюджет (в рублях)",
                  validator: (s) {
                    return RegExp(r"[0-9]{3,}").hasMatch(s);
                  },
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
                  Navigator.of(context)
                      .pushNamed("/create/select_town", arguments: {
                    "title": titleC.text,
                    "budget": budgetC.text,
                    "startDate": startDate,
                    "endDate": endDate
                  });

                  // print(titleValid);
                  // print(budgetValid);
                  // print(startDate);
                  // print(endDate);
                },
                text: "Далее",
                enabled: titleValid &&
                    budgetValid &&
                    startDate != null &&
                    endDate != null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
