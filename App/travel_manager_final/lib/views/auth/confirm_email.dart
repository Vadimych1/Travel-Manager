// 28.03.2024 // confirm_email.dart // Confirm email page

import "package:flutter/material.dart";
import 'package:travel_manager_final/views/widgets/interactive.dart';
import "package:email_validator/email_validator.dart";

class ConfirmEmailPage extends StatefulWidget {
  const ConfirmEmailPage({super.key});

  @override
  State<ConfirmEmailPage> createState() => _ConfirmEmailPageState();
}

class _ConfirmEmailPageState extends State<ConfirmEmailPage> {
  bool codeValid = false;
  String email = "***@***.***";

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(milliseconds: 10), () {
      setState(() {
        var args =
            ModalRoute.of(context)!.settings.arguments as Map<String, String>;
        email = args["email"]!;
      });
    });
    return Scaffold(
      appBar: AppBar(
        // set bottom border
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: const Color(0xFF000000),
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(left: 18, bottom: 30),
                alignment: Alignment.topLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Подтверждение почты",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                        "Письмо с кодом отправлено на ${email.substring(0, 2)}${"*" * (email.split("@")[0].length - 4)}${email.substring(email.split("@")[0].length - 2, email.length)}"),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 18),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        CodeInput(
                          code: "1234",
                          onChanged: (s) {
                            setState(
                              () {
                                codeValid = s;
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                child: Column(
                  children: [
                    Button(
                      text: "Далее",
                      onPressed: () {},
                      enabled: codeValid,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Есть аккаунт?",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(width: 6),
                        InkWell(
                          onTap: () {},
                          child: const Text(
                            "Вход",
                            style: TextStyle(
                              color: Color(0xFF659581),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
