import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../uikit/uikit.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart'
    as secure_storage;
import 'package:translit/translit.dart' as translit;

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  State<RegisterPage> createState() => RegisterPageState();
}

class RegisterPageState extends State<RegisterPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(
              left: 28,
              top: 81,
            ),
            child: TextButton(
              style: ButtonStyle(
                enableFeedback: false,
                backgroundColor: MaterialStateProperty.all<Color>(
                  Colors.transparent,
                ),
                shadowColor: MaterialStateProperty.all<Color>(
                  Colors.transparent,
                ),
                overlayColor: MaterialStateProperty.all<Color>(
                  Colors.transparent,
                ),
              ),
              child: SvgPicture.asset(
                "assets/images/arrow_back.svg",
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          Column(
            children: [
              // Top texts
              Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.only(
                  top: 70,
                ),
                child: const Column(
                  children: [
                    Text(
                      "Регистрация",
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      "основные данные",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Color.fromRGBO(
                          169,
                          169,
                          169,
                          1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Inputs
              Container(
                height: 220,
                margin: const EdgeInsets.only(
                  top: 20,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Input(
                      placeholder: "имя",
                      onChanged: (s) {},
                      controller: nameController,
                      inputType: TextInputType.name,
                    ),
                    Input(
                      placeholder: "e-mail",
                      onChanged: (s) {},
                      controller: emailController,
                      inputType: TextInputType.emailAddress,
                    ),
                    Input(
                      placeholder: "пароль",
                      onChanged: (s) {},
                      controller: passwordController,
                      inputType: TextInputType.visiblePassword,
                    ),
                  ],
                ),
              ),
              // Adaptive Margin
              Expanded(
                child: Container(),
              ),

              // Button
              Container(
                margin: const EdgeInsets.only(
                  bottom: 61,
                ),
                alignment: Alignment.bottomCenter,
                child: BlackButton(
                  text: "Далее",
                  onPressed: () {
                    String name = nameController.text;
                    String password = passwordController.text;
                    String email = emailController.text;

                    if (!RegExp(
                            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                        .hasMatch(
                      email,
                    )) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Введите существующий e-mail адрес",
                          ),
                        ),
                      );
                    } else if (name.isEmpty ||
                        name.trim() == "" ||
                        name.length < 2) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Введите свое настоящее имя",
                          ),
                        ),
                      );
                    } else if (password.isEmpty ||
                        password.trim() == "" ||
                        password.length < 8) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Пароль должен содержать минимум 8 символов",
                          ),
                        ),
                      );
                    } else {
                      http
                          .get(
                        Uri.http(
                          "127.0.0.1:2020",
                          "/register",
                          {
                            "password": password,
                            "login": email,
                            "name": translit.Translit().toTranslit(
                              source: name,
                            ),
                          },
                        ),
                      )
                          .then(
                        (value) {
                          if (value.statusCode == 200) {
                            String responce =
                                String.fromCharCodes(value.bodyBytes);

                            if (responce == "USER_ALREADY_EXISTS") {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Пользователь уже существует. Попробуйте войти в аккаунт",
                                  ),
                                ),
                              );
                            } else {
                              secure_storage.FlutterSecureStorage
                                  secureStorage =
                                  secure_storage.FlutterSecureStorage();

                              List values = responce.split("||");
                              secureStorage.write(
                                key: "jwt",
                                value: values[0],
                              );
                              secureStorage.write(
                                key: "json_data",
                                value: values[1],
                              );
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Произошла ошибка при регистрации",
                                ),
                              ),
                            );
                          }
                        },
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
