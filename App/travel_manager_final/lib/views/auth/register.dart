// 28.03.2024 // register.dart // Register page

import "package:flutter/material.dart";
import 'package:travel_manager_final/views/widgets/interactive.dart';
import "package:email_validator/email_validator.dart";

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _password2 = TextEditingController();

  bool nameValid = false;
  bool emailValid = false;
  bool passwordValid = false;
  bool password2Valid = false;

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
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 18),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Input(
                          controller: _name,
                          label: "Имя",
                          placeholder: "Иван",
                          validator: (s) {
                            return s.length > 2;
                          },
                          onChanged: (s) {},
                          onValidChanged: (b) {
                            setState(() {
                              nameValid = b;
                            });
                          },
                        ),
                        const SizedBox(
                          height: 27,
                        ),
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
                        const SizedBox(
                          height: 27,
                        ),
                        Input(
                          controller: _password2,
                          label: "Повтор пароля",
                          placeholder: "*********",
                          validator: (s) {
                            return s == _password.text;
                          },
                          onChanged: (s) {},
                          onValidChanged: (b) {
                            setState(() {
                              password2Valid = b;
                            });
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
                      onPressed: () {
                        Navigator.of(context).pushNamed(
                          "/confirm_email",
                          arguments: {
                            "email": _email.text,
                            "name": _name.text,
                            "password": _password.text
                          },
                        );
                      },
                      enabled: emailValid &&
                          passwordValid &&
                          password2Valid &&
                          nameValid,
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
