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
        body: Column(
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
                onValidChanged: (v) {},
                labelColor: const Color(0xFFFFFFFF),
                bgColor: const Color(0xFFFFFFFF),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
