import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:travel_manager_new/uikit/uikit.dart';
// import 'package:flutter_svg/svg.dart';
import 'register.dart';
import '../main/main_home.dart';
import "package:http/http.dart";
import "package:flutter_secure_storage/flutter_secure_storage.dart";

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

var loaded = false;
var s = const FlutterSecureStorage();

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    s.read(key: "username").then(
      (username) {
        if (username != null && username != "") {
          s.read(key: "password").then(
            (password) {
              if (password != null && password != "") {
                get(
                  Uri.http(
                    serveraddr,
                    "/api/v1/login",
                    {"username": username, "password": password},
                  ),
                ).then(
                  (value) {
                    var j = jsonDecode(value.body);

                    s.write(key: "name", value: j["name"]);

                    if (j["status"] == "success") {
                      sleep(
                        const Duration(seconds: 1),
                      );
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MainHome(),
                        ),
                      );
                    } else {
                      setState(
                        () {
                          loaded = true;
                        },
                      );

                      switch (j["code"]) {
                        case "user_not_exists":
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Пользователь не найден"),
                            ),
                          );
                        case "invalid_password":
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Неверный пароль"),
                            ),
                          );
                        default:
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Произошла ошибка при входе"),
                            ),
                          );
                      }
                    }
                  },
                );
              } else {
                setState(
                  () {
                    loaded = true;
                  },
                );
              }
            },
          );
        } else {
          setState(() {
            loaded = true;
          });
          print("LOADED FALSE");
        }
      },
    );

    return Scaffold(
      body: Stack(
        children: [
          // BG Image
          Positioned.fill(
            child: Image.asset(
              "assets/images/png/loginbg.png",
              fit: BoxFit.fill,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
            ),
          ),

          // FG
          ConstrainedBox(
            constraints: const BoxConstraints.expand(),
            child: SingleChildScrollView(
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                child: Column(
                  children: [
                    // Text Войти
                    Container(
                      margin: const EdgeInsets.only(
                        top: 70,
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        "Войти",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 38,
                          letterSpacing: -0.4,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    // Inputs
                    Container(
                      margin: const EdgeInsets.only(
                        top: 43,
                      ),
                      alignment: Alignment.center,
                      width: 319,
                      height: 110,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Input(
                            textFieldKey: const Key('loginKey'),
                            controller: _email,
                            placeholder: "e-mail",
                            onChanged: (s) {},
                          ),
                          Input(
                            textFieldKey: const Key('passwordKey'),
                            controller: _password,
                            placeholder: "пароль",
                            onChanged: (s) {},
                          ),
                        ],
                      ),
                    ),

                    // Margin
                    Expanded(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          minHeight: 0,
                        ),
                        child: Container(),
                      ),
                    ),

                    // Buttons
                    Container(
                      margin: const EdgeInsets.only(
                        bottom: 60,
                      ),
                      alignment: Alignment.bottomCenter,
                      child: Column(
                        children: [
                          BlackButton(
                            text: "Войти",
                            buttonKey: const Key('loginButtonKey'),
                            onPressed: () {
                              if (_email.text.trim() != "" &&
                                  _password.text.trim() != "") {
                                get(
                                  Uri.http(
                                    serveraddr,
                                    "/api/v1/login",
                                    {
                                      "username": _email.text,
                                      "password": _password.text
                                    },
                                  ),
                                ).then(
                                  (value) {
                                    var j = jsonDecode(value.body);

                                    if (j["status"] == "success") {
                                      s.write(
                                          key: "username", value: _email.text);
                                      s.write(
                                          key: "password",
                                          value: _password.text);
                                      s.write(key: "name", value: j["name"]);

                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return const MainHome(
                                              key: Key("mainPageKey"),
                                            );
                                          },
                                        ),
                                      );
                                    } else {
                                      switch (j["code"]) {
                                        case "user_not_exists":
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  "Пользователь не найден"),
                                            ),
                                          );
                                        case "invalid_password":
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text("Неверный пароль"),
                                            ),
                                          );
                                        default:
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  "Произошла ошибка при входе"),
                                            ),
                                          );
                                      }
                                    }
                                  },
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Вы не ввели логин/пароль"),
                                  ),
                                );
                              }
                            },
                          ),
                          WhiteButton(
                            text: "Зарегестрироваться",
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RegisterStep1(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Loadscreen
          Container(
            width: loaded ? 0 : MediaQuery.of(context).size.width,
            height: loaded ? 0 : MediaQuery.of(context).size.height,
            color: Colors.white.withOpacity(0.5),
            child: loaded ? null : const LoadingScreen(),
          ),
        ],
      ),
    );
  }
}
