// 28.03.2024 // login.dart // Login page

import "package:flutter/material.dart";
import 'package:travel_manager_final/views/widgets/interactive.dart';
import "package:email_validator/email_validator.dart";
import "package:travel_manager_final/main.dart";

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  bool emailValid = false;
  bool passwordValid = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(left: 18, top: 25, bottom: 30),
                alignment: Alignment.topLeft,
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Авторизация",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text("Войдите в аккаунт, чтобы продолжить"),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(
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
                        setState(() {
                          emailValid = b;
                        });
                      },
                    ),
                    const SizedBox(
                      height: 27,
                    ),
                    Input(
                      controller: _password,
                      label: "Пароль",
                      placeholder: "*********",
                      validator: (s) {
                        return s.length > 5;
                      },
                      onChanged: (s) {},
                      onValidChanged: (b) {
                        setState(() {
                          passwordValid = b;
                        });
                      },
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context)
                            .pushReplacementNamed("/reset_password");
                      },
                      style: ButtonStyle(
                        splashFactory: NoSplash.splashFactory,
                        overlayColor:
                            MaterialStateProperty.all(Colors.transparent),
                        foregroundColor: MaterialStateProperty.all(
                          const Color(0xFF659581),
                        ),
                        padding: MaterialStateProperty.all<EdgeInsets>(
                          EdgeInsets.zero,
                        ),
                      ),
                      child: const Text(
                        "Забыли пароль?",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Button(
                text: "Войти",
                onPressed: () async {
                  bool res = await service.auth
                      .login(_email.text.trim(), _password.text.trim());

                  if (res) {
                    Navigator.of(context).pushReplacementNamed("/home");
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Неверная почта или пароль"),
                      ),
                    );
                  }
                },
                enabled: emailValid && passwordValid,
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Нет аккаунта?",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(width: 6),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pushReplacementNamed("/register");
                    },
                    child: const Text(
                      "Регистрация",
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
      ),
    );
  }
}
