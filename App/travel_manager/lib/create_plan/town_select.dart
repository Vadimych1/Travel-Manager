import 'package:flutter/material.dart';

class CreatePlan_TownSelect extends StatefulWidget {
  const CreatePlan_TownSelect({super.key});

  @override
  State<CreatePlan_TownSelect> createState() => CreatePlan_TownSelectState();
}

class CreatePlan_TownSelectState extends State<CreatePlan_TownSelect> {
  final TextEditingController _town = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main content
          Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: 200,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromRGBO(156, 173, 231, 0),
                      Color.fromRGBO(156, 173, 231, 0),
                      Color.fromRGBO(156, 173, 231, 1),
                      Color.fromRGBO(156, 173, 231, 0),
                      Color.fromRGBO(156, 173, 231, 0),
                    ],
                    transform: GradientRotation(1.57),
                  ),
                ),
                child: Column(
                  children: [
                    // Gradient+Input+Text
                    const SizedBox(
                      height: 45,
                    ),
                    const Text(
                      "Куда отправимся?",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    SizedBox(
                      width: 330,
                      height: 50,
                      child: TextField(
                        controller: _town,
                        style: const TextStyle(
                          fontSize: 17,
                        ),
                        decoration: InputDecoration(
                          // Border
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: const BorderSide(
                              color: Colors.white,
                            ),
                          ),

                          // Hint
                          hintText: "город",
                          hintStyle: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w400,
                            letterSpacing: -0.72,
                          ),

                          // Enabled border
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: const BorderSide(
                              color: Colors.white,
                            ),
                          ),

                          // Focused border
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: const BorderSide(
                              color: Colors.white,
                            ),
                          ),

                          // fill
                          fillColor: Colors.white,
                          filled: true,
                        ),
                      ),
                    ),
                  
                    // Maps
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
