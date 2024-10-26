// 28.03.2024 // confirm_email.dart // Confirm email page

import "dart:async";

import "package:flutter/material.dart";
import 'package:travel_manager_final/views/widgets/interactive.dart';

class ConfirmEmailPage extends StatefulWidget {
  const ConfirmEmailPage({super.key});

  @override
  State<ConfirmEmailPage> createState() => _ConfirmEmailPageState();
}

class _ConfirmEmailPageState extends State<ConfirmEmailPage> {
  bool codeValid = false;
  String email = "***@***.***";
  int timer_ = 59;
  Timer timer = Timer(Duration.zero, () {});

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    setState(() {
      timer_ = 60;
    });

    Timer.periodic(oneSec, (t) {
      timer = t;

      if (timer_ <= 0) {
        timer.cancel();
      }

      setState(() {
        timer_--;
      });
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(milliseconds: 10), () {
      setState(() {});
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
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
                      InkWell(
                        child: Text(
                          timer_ > 0
                              ? "Запросить повторно через $timer_ секунд"
                              : "Запросить повторно",
                        ),
                        onTap: () {
                          // print(timer_);

                          if (timer_ <= 0) {
                            startTimer();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Вы уже запросили код, подождите $timer_ секунд",
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Column(
                children: [
                  Button(
                    text: "Далее",
                    onPressed: () {
                      Navigator.of(context)
                          .pushReplacementNamed("/reset_password");
                    },
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
            ],
          ),
        ),
      ),
    );
  }
}
