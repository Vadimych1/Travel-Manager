// 28.03.2024 // confirm_email.dart // Confirm email page
import "package:flutter/material.dart";
import 'package:travel_manager_final/views/widgets/interactive.dart';
import "package:email_validator/email_validator.dart";

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  bool codeValid = false;

  final TextEditingController _email = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(left: 18, bottom: 30),
                alignment: Alignment.topLeft,
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Сброс пароля",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text("Укажите почту, на которую зарегистрирован аккаунт"),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Input(
                        controller: _email,
                        label: "Почта",
                        placeholder: "example@test.com",
                        validator: (s) {
                          return EmailValidator.validate(s);
                        },
                        onChanged: (s) {},
                        onValidChanged: (b) {
                          setState(
                            () {
                              codeValid = b;
                            },
                          );
                        },
                      )
                    ],
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
                          "Вспомнили пароль?",
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
