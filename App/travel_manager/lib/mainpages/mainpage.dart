import 'package:flutter/material.dart';
import 'package:translit/translit.dart';
import '../create_plan/town_select.dart';

class MainPage extends StatefulWidget {
  MainPage({super.key, required this.subto, required this.name});

  final String name;
  final String subto;

  @override
  State<MainPage> createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  late String name;
  late String subto;

  bool havePlans = false;

  Widget plans = Column();

  @override
  void initState() {
    super.initState();
    name = widget.name;
    subto = widget.subto;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          // Gradient
          Container(
            width: MediaQuery.of(context).size.width,
            height: 306,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(156, 173, 231, 1),
                  Color.fromRGBO(156, 173, 231, 0.9),
                  Color.fromRGBO(156, 173, 231, 0),
                  Color.fromRGBO(113, 115, 155, 0),
                ],
                transform: GradientRotation(1.57),
              ),
            ),
          ),
          // Mountains
          Positioned.fill(
            child: Image.asset(
              "assets/images/backgrounds/main_background.png",
              fit: BoxFit.fitWidth,
              alignment: Alignment.bottomCenter,
            ),
          ),
          // Main content
          Column(
            children: [
              // Margin
              const SizedBox(
                height: 59,
              ),

              // Greeting text
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Здравствуйте, ${Translit().unTranslit(source: name)}!",
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),

              // Subscribe info
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    subto == "notsub"
                        ? "Подписка не оформлена"
                        : "Подписка до $subto",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w400,
                      letterSpacing: -0.72,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),

              // Margin
              const SizedBox(
                height: 50,
              ),

              // Button
              SizedBox(
                height: 35,
                child: TextButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                      Colors.black,
                    ),
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const CreatePlan_TownSelect(),
                      ),
                    );
                  },
                  child: const Text(
                    "Создать план отдыха",
                    style: TextStyle(
                      color: Colors.white,
                      letterSpacing: -0.72,
                      fontWeight: FontWeight.w400,
                      fontSize: 24,
                    ),
                  ),
                ),
              ),

              // Margin
              const SizedBox(
                height: 150,
              ),

              // Plans
              SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: <Color>[
                            Color.fromRGBO(217, 217, 217, 0.6),
                            Color.fromRGBO(157, 157, 157, 0.6),
                          ],
                        ),
                      ),
                      width: 301,
                      height: 139,
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          const Text(
                            "Ваши планы",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w400,
                              letterSpacing: -0.7,
                            ),
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          !havePlans
                              ? const Text(
                                  "Здесь пока пусто.\nЧтобы добавить план,\nнажмите кнопку выше",
                                  style: TextStyle(
                                    color: Color.fromRGBO(122, 120, 120, 1),
                                  ),
                                  textAlign: TextAlign.center,
                                )
                              : plans,
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
