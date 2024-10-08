import 'package:flutter/material.dart';
import 'package:travel_manager_new/pages/main/main_home.dart';
import '../../main.dart';
import 'package:travel_manager_new/pages/uikit/uikit.dart';
import 'login.dart';
import "package:http/http.dart";
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class RegisterStep1 extends StatefulWidget {
  const RegisterStep1({super.key});

  @override
  State<RegisterStep1> createState() => _RegisterStep1State();
}

class _RegisterStep1State extends State<RegisterStep1> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // BG Image
          Positioned.fill(
            child: Image.asset(
              "assets/images/png/registerbg1.png",
              fit: BoxFit.fill,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
            ),
          ),

          // FG
          Column(
            children: [
              // Text Регистрация
              Container(
                margin: const EdgeInsets.only(
                  top: 70,
                ),
                alignment: Alignment.center,
                child: const Text(
                  "Регистрация",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 38,
                    letterSpacing: -0.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              // Text основные данные
              Container(
                margin: const EdgeInsets.only(
                  top: 0,
                ),
                alignment: Alignment.center,
                child: Text(
                  "основные данные",
                  style: TextStyle(
                    color: myColors["secondaryText"],
                    fontSize: 20,
                    letterSpacing: -0.2,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              // Inputs
              Container(
                margin: const EdgeInsets.only(
                  top: 43,
                ),
                height: 170,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Input(
                      placeholder: "имя",
                      onChanged: (s) {},
                      controller: _name,
                    ),
                    Input(
                      placeholder: "e-mail",
                      onChanged: (s) {},
                      controller: _email,
                    ),
                    Input(
                      placeholder: "пароль",
                      onChanged: (s) {},
                      controller: _password,
                    ),
                  ],
                ),
              ),

              // Margin
              Expanded(
                child: Container(),
              ),

              // Register
              Container(
                margin: const EdgeInsets.only(
                  bottom: 40,
                ),
                child: BlackButton(
                  onPressed: () {
                    if (!isEmailValid(_email.text)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Неверный e-mail адрес.",
                          ),
                        ),
                      );
                    } else if (_name.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Введите свое имя.",
                          ),
                        ),
                      );
                    } else if (_password.text.trim().length < 8 ||
                        _password.text.trim().length > 30) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Длинна пароля должна составлять от 8 до 30 символов.",
                          ),
                        ),
                      );
                    } else {
                      Future.delayed(Duration.zero, () async {
                        var v = await service.auth
                            .register(_email.text, _password.text, _name.text);

                        if (v) {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => const LoginPage(),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Такой пользователь уже существует",
                              ),
                            ),
                          );
                        }
                      });
                    }
                  },
                  text: "Зарагестрироваться",
                ),
              )
            ],
          ),

          // Back button
          Container(
            margin: const EdgeInsets.only(
              top: 86,
              left: 10,
            ),
            child: BackButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const LoginPage(),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
