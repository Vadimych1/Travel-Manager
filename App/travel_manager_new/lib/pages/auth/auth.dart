import 'package:flutter/material.dart';
import '../../uikit/uikit.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'register_1.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => AuthPageState();
}

class AuthPageState extends State<AuthPage> {
  @override
  void initState() {
    super.initState();
    FlutterSecureStorage storage = FlutterSecureStorage();

    storage.read(key: "jwt").then(
      (jwt) {
        storage.read(key: "json_data").then(
          (json) {
            if (jwt != null && json != null) {
              var json_ = jsonDecode(json);
              http
                  .get(
                Uri.http(
                  '127.0.0.1:2020',
                  "jwtlogin",
                  {"jwt": jwt, "username": json_["email"]},
                ),
              )
                  .then(
                (value) {
                  if (value.statusCode == 200) {
                    
                  }
                },
              );
            }
            ;
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Column(
          children: [
            Text(
              "Авторизация",
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.2,
              ),
            ),
            Text(
              "Войдите или зарегестрируйтесь",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),

        //
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            BlackButton(
              text: "Вход",
              onPressed: () {
                // Navigator.of(context).push();
              },
              type: "mini",
            ),
            WhiteButton(
              text: "Регистрация",
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const RegisterPage(),
                  ),
                );
              },
              type: "mini",
            ),
          ],
        )
      ],
    );
  }
}
